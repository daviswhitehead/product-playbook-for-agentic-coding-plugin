---
name: ios-simulator-testing
description: Drive real Safari on the iOS Simulator (iPhone or iPad) with real taps, and read whether the on-screen keyboard came up and whether it reflowed the page. Use this skill when a question can only be answered on iOS Safari (keyboard appears or not, focus() inside a tap, Safari viewport and toolbar, safe areas) and you are on a Mac with Xcode. Ships a ready harness. Don't use for layout bugs that reproduce in desktop Chromium at a phone width, for native apps, or as a substitute for a production reading on real devices.
---

# iOS Simulator Testing

Desktop Chromium and Playwright WebKit cannot show a phone keyboard, so questions like "does tapping this raise the keyboard on an iPhone?" used to need a human with a phone. The harness in `scripts/` answers them from an agent session: Appium and its XCUITest driver open Safari on the iOS Simulator, taps are real touches, and the keyboard state is read from iOS rather than from the page.

## When to use

- Whether the keyboard appears after a tap, and whether typing lands where expected
- The iOS rule that `focus()` only raises the keyboard inside a real gesture
- Safari viewport, toolbar and safe-area behavior
- A screenshot of a page as iOS Safari renders it

First rule out the cheap case: if the bug reproduces in desktop Chromium at a phone width, it is not iOS-specific and this skill is the wrong tool (see `mobile-debugging`, Step 0).

## Setup

`SKILL_DIR` below is this skill's directory.

```bash
"$SKILL_DIR/scripts/ios-sim.sh" doctor     # lists what is missing and the fix for each
"$SKILL_DIR/scripts/ios-sim.sh" setup      # one time per machine, about 2 minutes
"$SKILL_DIR/scripts/ios-sim.sh" selftest   # must pass before you trust anything else
```

- **The one human step:** Xcode installed from the App Store and opened once (license plus an iOS runtime). Ask the user for this if `doctor` reports no `simctl`; do not try to work around it.
- No sudo is needed. If `xcode-select` points at the Command Line Tools, the script selects Xcode per-process with `DEVELOPER_DIR`.
- Appium installs into `~/.ios-sim-harness`, shared by every repo and worktree. Nothing is added to the project's dependencies.
- The first session builds WebDriverAgent and takes a few minutes. Give that command a 10 minute timeout. Later sessions start in about 20 seconds.

If the project wants a stable command, copy `scripts/` into the repo (for example `scripts/ios-sim/`) and add an npm script that calls `ios-sim.sh`. The files have no dependencies beyond Node.

## Commands

```bash
ios-sim.sh shot <url> [name]            # open a URL in Safari, save a screenshot
ios-sim.sh run <check.mjs> [args...]    # run a scripted check
ios-sim.sh stop                         # shut the simulator down
```

Output goes to `.context/ios-sim/out/` if `.context` exists, else `ios-sim-out/` (override with `IOS_SIM_OUT`). The Simulator shares the Mac's loopback, so `http://localhost:<port>` reaches a local dev server.

**Pick the device with `IOS_SIM_DEVICE`** (a name or UDID from `xcrun simctl list devices available`; iPhones and iPads both work). Without it, the newest plain iPhone. If the founder reviews on an iPad, every keyboard and gesture check runs twice: at his device and at phone size.

```bash
IOS_SIM_DEVICE="iPad mini (A17 Pro)" ios-sim.sh selftest
IOS_SIM_DEVICE="iPad mini (A17 Pro)" ios-sim.sh run checks/my-check.mjs http://127.0.0.1:3000
```

## Writing a check

A check is an `.mjs` file whose default export receives the driver. It needs no imports. Return the exit code.

```js
export default async function (sim, { args, sleep }) {
  await sim.goto(args[0]);
  await sim.waitFor(() => !!document.querySelector('#open-chat'));
  await sleep(1500);                         // hydration

  await sim.tap('#open-chat');               // a real touch
  await sleep(1500);                         // keyboard animation
  const result = await sim.keyboardShown();
  await sim.screenshot('after-open-chat');

  await sim.dismissKeyboard();
  await sim.tap('textarea');                 // positive control
  await sleep(1500);
  if (!(await sim.keyboardShown())) {
    console.error('INVALID: a direct tap did not raise the keyboard');
    return 1;
  }
  console.log({ keyboardAfterOpenChat: result });
  return 0;
}
```

| Method | What it does |
|---|---|
| `goto(url)` | Navigate |
| `tap(css)` | A real touch at the element's on-screen position |
| `type(css, text)` | Type into an input (works with React-controlled inputs) |
| `typeKey(char)` | Press one key on the on-screen keyboard |
| `exec(fn, ...args)` | Run a function in the page. It is serialized, so pass values as args |
| `waitFor(fn)` | Poll a page function until truthy |
| `keyboardShown()` | Whether the on-screen keyboard is up, asked of iOS |
| `viewportHeight()` | `visualViewport.height`; drops about 300px with the keyboard up |
| `rect(css)` | The element's client rect (CSS px), or null |
| `contentOrigin()` | Where client (0, 0) sits on screen, in points (Safari's toolbars move it) |
| `drag(from, to, opts)` | A real one-finger touch drag between client points; `duration` about 600 ms is a slow drag, under 120 ms a flick |
| `dismissKeyboard()` | Blur and wait for the keyboard to leave |
| `screenshot(name)` | Save a PNG; returns the path. Read it |
| `syntheticClick(css)` | A script click. Not a gesture. Negative controls only |
| `native(fn)` | Run in the native context (XPath taps, page source) |

## Rules that keep the result honest

1. **Run `selftest` first in any new environment.** It proves three things: a script click does not raise the keyboard, a real tap does, and typing lands. If it fails, nothing else the harness reports can be trusted.
2. **Every check carries a positive control.** "Keyboard down" is also what a blind check reports. Tap an input directly in the same page state and require `up` before concluding anything from a `down`.
3. **`tap` is a gesture; a script click is not.** iOS raises the keyboard only for a `focus()` inside a real gesture. A script click always reads `down` and says nothing about users.
4. **Wait for hydration before the first tap.** A tap before handlers attach does nothing and looks like a failure.
5. **Know what is on top.** A tap lands on whatever occupies the element's position. An overlay that persisted from an earlier session will take the tap. Read the screenshot.
6. **Two readings should agree:** `keyboardShown()` and a drop in `viewportHeight()`.
7. **Name the instrument.** Report "iOS Simulator, iOS <version>", never "tested on iPhone".

## Keyboard reflow: assert three things

"The field is visible" is not enough. iOS Safari often gets the focused field into view by scrolling the whole document, which pushes a fixed header (a chat panel's top bar, a page header) off the top of the screen. It happens even on a direct tap; on an iPad mini a composer tap scrolled the page 340 px. With the keyboard up, assert all three:

1. **The header is inside `visualViewport`**: its rect's top is at or below 0.
2. **`window.scrollY` is 0**, and so is the largest `scrollY` seen on any frame since the tap (something that scrolls back later still failed).
3. **The field is above the keyboard**: its rect's bottom is at or below `visualViewport.height`.

```js
// Inside a check, after a real tap that should raise the keyboard:
await sim.exec(() => {                       // record the worst frame since the tap
  window.__maxScrollY = 0;
  const tick = () => { window.__maxScrollY = Math.max(window.__maxScrollY, Math.round(window.scrollY)); requestAnimationFrame(tick); };
  tick();
});
await sim.tap(FIELD);
await sleep(1500);
const r = await sim.exec((h, f) => {
  const vv = window.visualViewport, hr = document.querySelector(h).getBoundingClientRect(), fr = document.querySelector(f).getBoundingClientRect();
  return { scrollY: Math.round(window.scrollY), maxScrollY: window.__maxScrollY, vvTop: Math.round(vv.offsetTop),
           headerIn: hr.top >= 0, fieldIn: fr.bottom <= vv.height };
}, HEADER, FIELD);
const ok = (await sim.keyboardShown()) && r.scrollY === 0 && r.maxScrollY === 0 && r.vvTop === 0 && r.headerIn && r.fieldIn;
```

The keyboard must read "up" in the same run (positive control), or a pass means nothing. The fix is structural (size the locked surfaces to `visualViewport.height` while the keyboard is up, then reveal the focused field inside its own scroll area), not a focus flag.

## Real-device checklist

For a founder-facing QA round, run `resources/templates/qa-round/real-device-checklist.md` (from `/playbook:qa-round`) at the founder's device and at phone size: keyboard reflow (above), sheet gestures (`drag`: the grabber and the sheet body follow the finger; a flick dismisses), scroll lock behind sheets, safe areas, press states that release after a touch-scroll, derived content after a page change, and disabled controls that say why. Every row needs a reading with a positive control, or says why it could not run.

## What it cannot tell you

- Older iOS versions (only the installed runtime runs)
- An installed home-screen web app (standalone mode)
- Real-device performance or hardware quirks
- Flows behind Google or Apple sign-in; use an email and password account

For those, keep a production measurement or a real device in the plan, and say so.

## Gotchas

- **Session start hangs at "Setting up simulator" in `appium.log`.** Appium is writing the Simulator app's preferences, which sit in another app's container; macOS guards that with a permission prompt an agent cannot answer. The harness avoids it by not setting `connectHardwareKeyboard` and by leaving pasteboard sync on `system`. Do not add either capability back. The on-screen keyboard is forced through WebDriverAgent instead.
- **Safari's data is wiped at the start of each session,** so a check that needs a signed-in user logs in every run.
- **One session at a time.** One simulator, one WebDriverAgent. The script takes a lock in `~/.ios-sim-harness`; a second caller waits.
- **After a force-stopped run:** `pkill -9 -f bin/appium` and remove `~/.ios-sim-harness/session.lock`.
- **Node:** Appium needs an even major (20, 22, 24). The script picks one from nvm if the default is odd.

## Origin

Built in chef-chopsky on 2026-10-04 (Xcode 27, iOS 27.0) to answer whether opening chat raises the keyboard. iPad device selection, `rect`, `contentOrigin`, `drag` and the keyboard-reflow assertions were added there on 2026-10-10 after a founder's iPad mini QA pass found the keyboard pushing the chat header off screen and a sheet grabber that did nothing; both passed every desktop check. Findings there: synchronous `focus()` in the tap handler raises it; the same call 100ms later in a timer does not; focusing a hidden proxy input in the tap and moving focus later keeps it up; a sheet that restores focus to its opener on close drops it.
