# Real-device checklist: [Project] QA round [N]

<!-- Pass 3 of /playbook:qa-round. Run on the iOS Simulator (skill `ios-simulator-testing`) at the
     founder's device size AND at phone size, in Safari, for every touch surface the round changed.
     Desktop Chromium and Playwright WebKit cannot show an on-screen keyboard, so a phone-width browser
     pass proves nothing about these rows. In the project that produced this list, every agent check
     passed and the founder still found eleven problems in one morning on his iPad mini.
     Delete this comment. -->

**Devices:** [e.g. `IOS_SIM_DEVICE="iPad mini (A17 Pro)"` and the default iPhone] · **iOS:** [version] · **Positive control:** [a direct tap on a known input reads keyboard "up"; a known-good page passes]

| Check | Pass when | How to see it | iPad | Phone |
|-------|-----------|---------------|------|-------|
| Keyboard does not reflow the page | Focusing any field keeps the screen's header inside `visualViewport`, `window.scrollY` stays 0 (and the largest `scrollY` seen since the tap is 0), and the field sits above the keyboard | `keyboardShown()`, then the header's and the field's rects against `visualViewport.height`, plus `scrollY`; screenshot | | |
| Sheet gestures | The grabber, and a drag anywhere on the sheet, moves it with the finger; a flick or a long drag dismisses; a horizontal swipe inside it scrolls and never drags the sheet | Simulator drag and flick; screenshots mid-drag and after | | |
| Scroll lock | With a sheet or modal open, the page behind does not scroll and shows no empty space under it | Swipe behind the scrim; `scrollY` before and after | | |
| Safe areas and system gestures | Bottom content clears `env(safe-area-inset-bottom)` and the home-indicator / app-switcher zone | Screenshot; tap near the bottom edge | | |
| Press states release | After a touch that becomes a scroll, nothing keeps a pressed or hover look | Touch-scroll over controls, lift, screenshot | | |
| Derived content follows the page | Minimize an overlay, change page, reopen: derived content matches the new page; the user's typed text is untouched | Two pages, screenshots | | |
| Disabled controls say why | Every control disabled at a limit shows its reason near it | Screenshot at the limit | | |

<!-- Each cell: pass / fail + the screenshot path, or "could not run: <why>". A "down" or "pass" with
     no positive control in the same run counts for nothing. Report as "iOS Simulator, iOS <version>,
     <device>", never "tested on iPad". -->
