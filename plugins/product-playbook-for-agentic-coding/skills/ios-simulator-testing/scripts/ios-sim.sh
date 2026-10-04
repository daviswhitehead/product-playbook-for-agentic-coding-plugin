#!/usr/bin/env bash
# ios-sim.sh — drive Safari on the iOS Simulator with real taps (Appium + XCUITest).
#
# WHY: desktop Chromium and Playwright WebKit cannot show a phone keyboard, so
# "does the keyboard come up?" and other iOS-Safari-only questions were
# unanswerable by an agent. This runs the real engine and the real keyboard.
#
# Usage: ios-sim.sh <doctor|setup|selftest|shot|run|stop> [args]
# Guide: ../SKILL.md
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# xcode-select often points at the Command Line Tools, which have no simctl.
# Switching it needs sudo, so select Xcode per-process instead.
if [ -z "${DEVELOPER_DIR:-}" ] && ! xcrun simctl help >/dev/null 2>&1; then
  if [ -d /Applications/Xcode.app/Contents/Developer ]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
  fi
fi

# Appium supports even Node majors (20/22/24). Fresh worktrees may default to an odd one.
node_ok() { node -e 'process.exit([20,22,24].includes(+process.versions.node.split(".")[0])?0:1)' 2>/dev/null; }
if ! node_ok; then
  for d in "$HOME"/.nvm/versions/node/v24* "$HOME"/.nvm/versions/node/v22* "$HOME"/.nvm/versions/node/v20*; do
    if [ -x "$d/bin/node" ]; then export PATH="$d/bin:$PATH"; break; fi
  done
fi

exec node "$DIR/cli.mjs" "$@"
