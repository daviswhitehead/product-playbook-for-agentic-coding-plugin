---
plugin: product-playbook-for-agentic-coding
bump: minor
---

### Added
- **`ios-simulator-testing` skill, with a bundled harness** — agents can now drive real Safari on the iOS Simulator with real taps and read whether the on-screen keyboard came up (`ios-sim.sh doctor | setup | selftest | shot | run`). Before this, "does the keyboard appear on an iPhone?" needed a human with a phone, because desktop Chromium and Playwright WebKit have no on-screen keyboard. The harness has no project dependencies (Appium installs once into `~/.ios-sim-harness`), needs no sudo, and its selftest carries a negative control so a blind harness fails instead of reporting "keyboard down". The skill also records the one trap that hangs session start with no error: Appium writing the Simulator app's preferences triggers a macOS permission prompt an agent cannot answer.

### Changed
- **`mobile-debugging` no longer says the iOS Simulator cannot reproduce keyboard behavior.** Measured on iOS 27.0, it does. The skill now points at `ios-simulator-testing` first and keeps physical devices for older iOS versions, installed web apps, Android, and performance.
