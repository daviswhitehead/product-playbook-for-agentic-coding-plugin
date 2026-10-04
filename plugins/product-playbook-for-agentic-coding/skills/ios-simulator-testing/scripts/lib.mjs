// Dependency-free WebDriver client for an Appium + XCUITest Safari session on
// the iOS Simulator. Appium itself lives in IOS_SIM_HOME (shared across
// worktrees), so this file imports nothing outside Node.
import { execFileSync, spawn } from 'node:child_process';
import { createServer, request } from 'node:http';
import { createReadStream, existsSync, mkdirSync, readFileSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { extname, join, resolve } from 'node:path';

export const HOME = process.env.IOS_SIM_HOME || join(homedir(), '.ios-sim-harness');
export const PORT = Number(process.env.IOS_SIM_APPIUM_PORT || 4723);
export const OUT = resolve(process.env.IOS_SIM_OUT || (existsSync('.context') ? '.context/ios-sim/out' : 'ios-sim-out'));
const APPIUM_BIN = join(HOME, 'node_modules', '.bin', 'appium');
const APPIUM_ENV = { ...process.env, APPIUM_HOME: join(HOME, '.appium') };
const ELEMENT = 'element-6066-11e4-a52e-4f735466cecf';
const LOCK = join(HOME, 'session.lock');
const SESSION_TIMEOUT_MS = 12 * 60000; // the first run builds WebDriverAgent

// node:http rather than fetch: fetch gives up after 5 minutes without headers,
// and the first session waits longer than that while WebDriverAgent builds.
function httpJson(method, url, body) {
  return new Promise((ok, fail) => {
    const req = request(url, { method, headers: { 'content-type': 'application/json' } }, (res) => {
      let text = '';
      res.on('data', (c) => (text += c));
      res.on('end', () => {
        try {
          ok({ ok: res.statusCode < 400, status: res.statusCode, json: JSON.parse(text) });
        } catch {
          fail(new Error(`${method} ${url}: non-JSON response (${res.statusCode})`));
        }
      });
    });
    req.on('error', fail);
    req.end(body ? JSON.stringify(body) : undefined);
  });
}

export const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function sh(cmd, args, opts = {}) {
  return (execFileSync(cmd, args, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], ...opts }) ?? '').trim();
}

/** Environment problems, each with the fix. Empty means ready. */
export function doctor() {
  const problems = [];
  const major = Number(process.versions.node.split('.')[0]);
  if (![20, 22, 24].includes(major)) problems.push(`Node ${process.versions.node}: Appium needs Node 20, 22 or 24 (nvm install 20).`);
  let devices = [];
  try {
    devices = listIphones();
  } catch {
    problems.push('No simctl: install Xcode from the App Store and open it once to accept the license. If Xcode is installed elsewhere, set DEVELOPER_DIR.');
  }
  if (!problems.length && !devices.length) problems.push('No iPhone simulator: open Xcode > Settings > Components and install an iOS runtime.');
  if (!existsSync(APPIUM_BIN)) problems.push('Appium not installed: run `ios-sim.sh setup` (one time, about 2 minutes).');
  else if (!existsSync(join(HOME, '.appium', 'node_modules', 'appium-xcuitest-driver'))) problems.push('XCUITest driver missing: run `ios-sim.sh setup`.');
  return problems;
}

export function setup() {
  mkdirSync(HOME, { recursive: true });
  if (!existsSync(join(HOME, 'package.json'))) writeFileSync(join(HOME, 'package.json'), '{"name":"ios-sim-harness","private":true}\n');
  if (!existsSync(APPIUM_BIN)) sh('npm', ['install', 'appium@3', '--no-audit', '--no-fund'], { cwd: HOME, stdio: 'inherit' });
  if (!existsSync(join(HOME, '.appium', 'node_modules', 'appium-xcuitest-driver'))) {
    sh(APPIUM_BIN, ['driver', 'install', 'xcuitest'], { env: APPIUM_ENV, stdio: 'inherit' });
  }
}

function listIphones() {
  const json = JSON.parse(sh('xcrun', ['simctl', 'list', 'devices', 'available', '-j']));
  return Object.entries(json.devices)
    .filter(([runtime]) => runtime.includes('SimRuntime.iOS'))
    .sort(([a], [b]) => b.localeCompare(a, undefined, { numeric: true }))
    .flatMap(([runtime, list]) => list.filter((d) => d.name.startsWith('iPhone')).map((d) => ({ ...d, runtime })));
}

/** Boots (if needed) and returns the device: IOS_SIM_DEVICE by name or UDID, else an already-booted iPhone, else the plain newest iPhone. */
export function bootDevice() {
  const all = listIphones();
  const want = process.env.IOS_SIM_DEVICE;
  const device = want
    ? all.find((d) => d.name === want || d.udid === want)
    : all.find((d) => d.state === 'Booted') || all.find((d) => /^iPhone \d+$/.test(d.name)) || all[0];
  if (!device) throw new Error(`No simulator matches ${want || 'iPhone'}. Run \`xcrun simctl list devices available\`.`);
  if (device.state !== 'Booted') {
    sh('xcrun', ['simctl', 'boot', device.udid]);
    sh('xcrun', ['simctl', 'bootstatus', device.udid, '-b'], { timeout: 300000 });
  }
  return device;
}

async function appiumReady() {
  try {
    const r = await fetch(`http://127.0.0.1:${PORT}/status`);
    return r.ok;
  } catch {
    return false;
  }
}

async function startAppium() {
  if (await appiumReady()) return null; // reuse a running server, and leave it running
  mkdirSync(OUT, { recursive: true });
  const child = spawn(APPIUM_BIN, ['--port', String(PORT), '--log', join(OUT, 'appium.log'), '--log-level', 'error:debug'], {
    env: APPIUM_ENV,
    stdio: 'ignore',
  });
  for (let i = 0; i < 60; i++) {
    if (await appiumReady()) return child;
    await sleep(500);
  }
  child.kill();
  throw new Error(`Appium did not start on port ${PORT}. See ${join(OUT, 'appium.log')}.`);
}

// One simulator, one WebDriverAgent: parallel agents must take turns.
async function lock() {
  mkdirSync(HOME, { recursive: true });
  for (let i = 0; i < 600; i++) {
    try {
      mkdirSync(LOCK);
      writeFileSync(join(LOCK, 'pid'), String(process.pid));
      return;
    } catch {
      let stale = true;
      try {
        process.kill(Number(readFileSync(join(LOCK, 'pid'), 'utf8')), 0);
        stale = false;
      } catch { /* owner is gone */ }
      if (stale) rmSync(LOCK, { recursive: true, force: true });
      else {
        if (i === 0) console.error('Another ios-sim session is running; waiting for it to finish...');
        await sleep(1000);
      }
    }
  }
  throw new Error('Timed out waiting for another ios-sim session (10 min).');
}

/** Serves a directory on a free localhost port. The simulator shares the Mac's loopback. */
export function serveDir(dir) {
  const types = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.png': 'image/png', '.json': 'application/json' };
  const server = createServer((req, res) => {
    const path = join(dir, decodeURIComponent(new URL(req.url, 'http://x').pathname).replace(/\/$/, '/index.html'));
    if (!path.startsWith(dir) || !existsSync(path) || !statSync(path).isFile()) return res.writeHead(404).end();
    res.writeHead(200, { 'content-type': types[extname(path)] || 'application/octet-stream' });
    createReadStream(path).pipe(res);
  });
  return new Promise((ok) => server.listen(0, '127.0.0.1', () => ok({ url: `http://localhost:${server.address().port}`, close: () => server.close() })));
}

export class Sim {
  constructor(sessionId, caps) {
    this.base = `http://127.0.0.1:${PORT}/session/${sessionId}`;
    this.caps = caps;
  }

  async #call(method, path, body) {
    const { ok, status, json } = await httpJson(method, this.base + path, body);
    const r = { ok, status };
    if (!r.ok) throw new Error(`${method} ${path}: ${json.value?.message || r.status}`);
    return json.value;
  }

  goto(url) { return this.#call('POST', '/url', { url }); }

  /** Runs a function (or script body) in the page. A function is serialized, so it cannot close over local variables; pass them as args. */
  exec(fn, ...args) {
    const script = typeof fn === 'function' ? `return (${fn}).apply(null, arguments)` : fn;
    return this.#call('POST', '/execute/sync', { script, args });
  }

  async #find(using, value) {
    try {
      return (await this.#call('POST', '/element', { using, value }))[ELEMENT];
    } catch (e) {
      throw new Error(`No element for ${using} "${value}" (${e.message})`);
    }
  }

  /** A real touch (XCTest) at the element's on-screen position: counts as a user gesture. */
  async tap(css) {
    await this.#call('POST', `/element/${await this.#find('css selector', css)}/click`, {});
  }

  /** Types into an input through WebDriver (works with React-controlled inputs). */
  async type(css, text) {
    await this.#call('POST', `/element/${await this.#find('css selector', css)}/value`, { text });
  }

  /** A script-dispatched click: NOT a user gesture. Useful only as a negative control. */
  syntheticClick(css) {
    return this.exec((s) => document.querySelector(s).click(), css);
  }

  /** True when the on-screen keyboard is showing (asked of XCTest, not the page). */
  keyboardShown() { return this.#call('POST', '/execute/sync', { script: 'mobile: isKeyboardShown', args: [] }); }

  /** Visible page height in CSS px. Drops by roughly 300 when the keyboard is up. */
  viewportHeight() { return this.exec(() => Math.round(window.visualViewport.height)); }

  async waitFor(fn, { timeout = 10000, args = [] } = {}) {
    const end = Date.now() + timeout;
    while (Date.now() < end) {
      if (await this.exec(fn, ...args)) return true;
      await sleep(250);
    }
    throw new Error(`waitFor timed out after ${timeout}ms: ${fn}`);
  }

  async screenshot(name) {
    mkdirSync(OUT, { recursive: true });
    const path = name.includes('/') ? resolve(name) : join(OUT, name.endsWith('.png') ? name : `${name}.png`);
    writeFileSync(path, Buffer.from(await this.#call('GET', '/screenshot'), 'base64'));
    return path;
  }

  /** Runs fn in the native (XCUITest) context, then returns to the web context. */
  async native(fn) {
    const ctx = await this.#call('GET', '/context');
    await this.#call('POST', '/context', { name: 'NATIVE_APP' });
    try {
      return await fn({
        tapXPath: async (xpath) => this.#call('POST', `/element/${await this.#find('xpath', xpath)}/click`, {}),
        exists: async (xpath) => (await this.#call('POST', '/elements', { using: 'xpath', value: xpath })).length > 0,
        source: () => this.#call('GET', '/source'),
      });
    } finally {
      await this.#call('POST', '/context', { name: ctx });
    }
  }

  /** Presses one key on the on-screen keyboard, switching to the number plane if needed. */
  typeKey(ch) {
    return this.native(async (n) => {
      const key = `//XCUIElementTypeKey[@name="${ch}"]`;
      if (!(await n.exists(key))) {
        await n.tapXPath('//XCUIElementTypeKey[@name="more" or @name="numbers"]');
        await sleep(300);
      }
      await n.tapXPath(key);
    });
  }

  /** Blurs whatever has focus and waits for the keyboard to go away. */
  async dismissKeyboard() {
    await this.exec(() => document.activeElement && document.activeElement.blur());
    for (let i = 0; i < 20 && (await this.keyboardShown()); i++) await sleep(250);
  }

  close() { return this.#call('DELETE', ''); }
}

/** Boots the simulator, starts Appium, opens Safari, runs fn(sim), and cleans up what it started. */
export async function withSim(fn) {
  const problems = doctor();
  if (problems.length) throw new Error(`ios-sim is not ready:\n- ${problems.join('\n- ')}`);
  await lock();
  let appium;
  let sim;
  try {
    const device = bootDevice();
    appium = await startAppium();
    const capabilities = {
      alwaysMatch: {
        platformName: 'iOS',
        browserName: 'Safari',
        'appium:automationName': 'XCUITest',
        'appium:udid': device.udid,
        // Do NOT set connectHardwareKeyboard, and keep pasteboard sync on 'system': either one makes
        // Appium write the Simulator app's preferences, which live in another app's container. macOS
        // guards that with a permission prompt, and session start hangs until a human answers it.
        // The on-screen keyboard is forced through WebDriverAgent instead (on by default).
        'appium:simulatorPasteboardAutomaticSync': 'system',
        'appium:forceSimulatorSoftwareKeyboardPresence': true,
        // Web clicks become real touches. With this off they are JS clicks and iOS gesture rules
        // don't apply (IOS_SIM_NATIVE_TAP=0 exists only to prove the selftest can fail).
        'appium:nativeWebTap': process.env.IOS_SIM_NATIVE_TAP !== '0',
        'appium:wdaLaunchTimeout': 600000, // first run builds WebDriverAgent (a few minutes)
        'appium:wdaConnectionTimeout': 600000,
        'appium:newCommandTimeout': 300,
      },
    };
    // Safari's web inspector occasionally fails to attach ("Maximum occupation time is exceeded").
    // One retry with Safari terminated clears it.
    let ok;
    let json;
    for (let attempt = 1; attempt <= 2; attempt++) {
      ({ ok, json } = await Promise.race([
        httpJson('POST', `http://127.0.0.1:${PORT}/session`, { capabilities }),
        sleep(SESSION_TIMEOUT_MS).then(() => {
          throw new Error(`Safari session did not start in ${SESSION_TIMEOUT_MS / 60000} min. See ${join(OUT, 'appium.log')}; if it stops at "Setting up simulator", look for a macOS permission prompt on screen.`);
        }),
      ]));
      if (ok || attempt === 2) break;
      console.error(`Session start failed (${json.value?.message}); retrying once...`);
      try {
        sh('xcrun', ['simctl', 'terminate', device.udid, 'com.apple.mobilesafari']);
      } catch { /* Safari was not running */ }
    }
    if (!ok) throw new Error(`Could not start a Safari session: ${json.value?.message}`);
    sim = new Sim(json.value.sessionId, { ...json.value.capabilities, deviceName: device.name });
    try {
      return await fn(sim);
    } catch (e) {
      const shot = await sim.screenshot('failure').catch(() => null);
      if (shot) e.message += `\nScreenshot at failure: ${shot}`;
      throw e;
    }
  } finally {
    if (sim) await sim.close().catch(() => {});
    if (appium) appium.kill('SIGKILL');
    rmSync(LOCK, { recursive: true, force: true });
  }
}
