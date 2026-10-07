---
name: ios-simulator-testing
description: Drive real Safari on the iOS Simulator with real taps, and read whether the on-screen keyboard came up. Use this skill when a question can only be answered on iOS Safari (keyboard appears or not, focus() inside a tap, Safari viewport and toolbar, safe areas) and you are on a Mac with Xcode. Ships a ready harness. Don't use for layout bugs that reproduce in desktop Chromium at a phone width, for native apps, or as a substitute for a production reading on real devices.
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

Built in chef-chopsky on 2026-10-04 (Xcode 27, iOS 27.0) to answer whether opening chat raises the keyboard. Findings there: synchronous `focus()` in the tap handler raises it; the same call 100ms later in a timer does not; focusing a hidden proxy input in the tap and moving focus later keeps it up; a sheet that restores focus to its opener on close drops it.
