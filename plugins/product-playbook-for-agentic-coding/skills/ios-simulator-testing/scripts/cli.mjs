// Entry point for ios-sim.sh. See ../SKILL.md.
import { execFileSync } from 'node:child_process';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { HOME, OUT, bootDevice, doctor, serveDir, setup, sleep, withSim } from './lib.mjs';

const DIR = dirname(fileURLToPath(import.meta.url));
const [cmd, ...args] = process.argv.slice(2);

const USAGE = `Usage: ios-sim.sh <command>

  doctor                 Check Xcode, a simulator runtime, Node and Appium; print fixes
  setup                  One-time install of Appium + the XCUITest driver into ${HOME}
  selftest               Prove the harness sees the keyboard, with a negative control
  shot <url> [name]      Open a URL in Safari and save a screenshot
  run <script.mjs> [..]  Run a check: the script's default export gets (sim, { args, serveDir, sleep })
  stop                   Shut down booted simulators

Env: IOS_SIM_DEVICE (name or UDID), IOS_SIM_OUT (default ${OUT}), IOS_SIM_HOME, IOS_SIM_APPIUM_PORT`;

/**
 * Drives fixtures/focus.html. Hard assertions prove the harness itself:
 * a script click must NOT raise the keyboard, a real tap must, and typing on
 * the on-screen keyboard must land. The rest are observations of iOS behavior.
 */
async function selftest() {
  const server = await serveDir(join(DIR, 'fixtures'));
  try {
    return await withSim(async (sim) => {
      await sim.goto(`${server.url}/focus.html`);
      await sim.waitFor(() => window.__last && window.__last.label === 'ready');
      const rows = [];
      const reset = async () => {
        await sim.exec(() => {
          const c = document.getElementById('composer');
          c.blur();
          c.value = '';
          document.getElementById('panel').classList.remove('open');
          document.getElementById('sheet').classList.remove('open');
          window.scrollTo(0, 0);
        });
        await sim.dismissKeyboard();
        await sleep(400);
      };
      const observe = async (name, expectKeyboard, hard, steps, typeKey, expectValue) => {
        await reset();
        await steps();
        await sleep(1500);
        const keyboard = await sim.keyboardShown();
        const row = { case: name, keyboard, expected: expectKeyboard, viewport: await sim.viewportHeight(), hard };
        if (typeKey && keyboard) {
          await sim.typeKey(typeKey);
          await sleep(400);
          row.value = await sim.exec(() => document.getElementById('composer').value);
          row.valueOk = row.value === expectValue;
        }
        await sim.screenshot(`selftest-${name}`);
        row.ok = keyboard === expectKeyboard && row.valueOk !== false;
        rows.push(row);
      };

      await observe('control-script-click', false, true, () => sim.syntheticClick('#t1'));
      await observe('tap-sync-focus', true, true, () => sim.tap('#t1'));
      await observe('tap-slot-then-type', true, true, () => sim.tap('#t3'), '6', 'Scale this for 6');
      await observe('tap-focus-after-100ms', false, false, () => sim.tap('#t2'));
      await observe('tap-proxy-then-move', true, false, () => sim.tap('#t5'));
      await observe('sheet-restores-focus', false, false, async () => {
        await sim.tap('#t7');
        await sleep(500);
        await sim.tap('#sheetSlot');
      });

      console.table(rows.map(({ hard, ...r }) => ({ ...r, kind: hard ? 'harness' : 'ios behavior' })));
      console.log(`${sim.caps.deviceName}, iOS ${sim.caps.platformVersion}. Screenshots: ${OUT}`);
      const broken = rows.filter((r) => r.hard && !r.ok);
      const changed = rows.filter((r) => !r.hard && !r.ok);
      if (changed.length) console.log(`NOTE: iOS behaved differently from the recorded baseline in: ${changed.map((r) => r.case).join(', ')}. The harness is fine; the platform changed.`);
      if (broken.length) {
        console.error(`SELFTEST FAILED: the harness cannot be trusted (${broken.map((r) => r.case).join(', ')}).`);
        return 1;
      }
      console.log('SELFTEST PASSED: real taps raise the keyboard, script clicks do not, typing lands.');
      return 0;
    });
  } finally {
    server.close();
  }
}

async function main() {
  switch (cmd) {
    case 'doctor': {
      const problems = doctor();
      if (!problems.length) {
        const d = bootDevice();
        console.log(`Ready. Device: ${d.name} (${d.runtime.split('.').pop()}).`);
        return 0;
      }
      console.error(problems.map((p) => `- ${p}`).join('\n'));
      return 1;
    }
    case 'selftest':
      return selftest();
    case 'shot': {
      if (!args[0]) throw new Error('shot needs a URL');
      return withSim(async (sim) => {
        await sim.goto(args[0]);
        await sleep(Number(process.env.IOS_SIM_SETTLE_MS || 2500));
        console.log(await sim.screenshot(args[1] || 'shot'));
        return 0;
      });
    }
    case 'run': {
      if (!args[0]) throw new Error('run needs a script path');
      const mod = await import(pathToFileURL(resolve(args[0])).href);
      if (typeof mod.default !== 'function') throw new Error(`${args[0]} must default-export an async function (sim, ctx)`);
      return withSim(async (sim) => (await mod.default(sim, { args: args.slice(1), serveDir, sleep, out: OUT })) ?? 0);
    }
    case 'stop':
      execFileSync('xcrun', ['simctl', 'shutdown', 'all'], { stdio: 'inherit' });
      return 0;
    default:
      console.log(USAGE);
      return cmd ? 1 : 0;
  }
}

if (cmd === 'setup') {
  setup();
  const problems = doctor();
  console.log(problems.length ? problems.map((p) => `- ${p}`).join('\n') : 'Setup complete. Next: ios-sim.sh selftest');
  process.exit(problems.length ? 1 : 0);
}

main().then(
  (code) => process.exit(code),
  (err) => {
    console.error(err.message);
    process.exit(1);
  },
);
