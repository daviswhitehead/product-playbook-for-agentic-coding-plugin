#!/usr/bin/env bash
#
# Tests for check-testing-guide.sh (the /playbook:qa-round guide guard).
#
#   scripts/test-check-testing-guide.sh
#
# The guard exists because a founder could not run four of nineteen steps he was
# handed: all four were "after deploy" one-liners mixed into a pre-deploy guide,
# with no screen to expect. The important tests reproduce that shape and require
# a FAIL; a guard that only ever passes is a rubber stamp.

# shellcheck disable=SC2015

set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
GUARD="${HERE}/check-testing-guide.sh"
fails=0

ok()  { printf 'PASS  %s\n' "$1"; }
bad() { printf 'FAIL  %s\n' "$1"; fails=$((fails + 1)); }

HEADER='| # | Do | Expect | Agent test | Evidence |
|---|----|--------|------------|----------|'

# usage: guide <dir> <relative path> <body...>  — writes a guide file
guide() { local d="$1" rel="$2"; shift 2; mkdir -p "$d/$(dirname "$rel")"; printf '%s\n' "$@" > "$d/$rel"; }
run_in() { ( cd "$1" && shift && "$GUARD" "$@" >/dev/null 2>&1; echo $? ); }
out_in() { ( cd "$1" && shift && "$GUARD" "$@" 2>&1 ); }

R=projects/in-progress/demo/qa/round-2

echo "=== check-testing-guide.sh ==="

# 1. A good guide passes.
d="$(mktemp -d)"
guide "$d" "$R/testing-guide.md" "# Guide" "## 1. iPad mini, Safari" "$HEADER" \
  "| P1 | 1. Open Recipes. 2. Tap **Search**. | The search field opens at the top | Pass 3, iOS Simulator iPad mini: field in view | shot.png |" \
  "| P2 | 1. Open Memory. | Your memories list | Nobody: needs your real memories | - |"
[ "$(run_in "$d")" = "0" ] && ok "good guide passes" || bad "good guide should pass"
rm -rf "$d"

# 2. THE regression: an after-deploy step inside a pre-deploy guide.
d="$(mktemp -d)"
guide "$d" "$R/testing-guide.md" "# Guide" "$HEADER" \
  "| D6 | After deploy, check the email arrives | An email | Nobody: needs production | - |"
rc=$(run_in "$d")
[ "$rc" != "0" ] && ok "after-deploy step in a pre-deploy guide FAILS (the D6/D7 bug)" || bad "after-deploy step must fail, got rc=$rc"
rm -rf "$d"

# 3. A step table under an "After deploy" heading in a pre-deploy guide.
d="$(mktemp -d)"
guide "$d" "$R/testing-guide.md" "# Guide" "## After deploy" "$HEADER" \
  "| G4 | 1. Open the app. | It loads | Pass 1 | shot.png |"
rc=$(run_in "$d")
[ "$rc" != "0" ] && ok "step table under an after-deploy heading FAILS" || bad "after-deploy heading must fail, got rc=$rc"
rm -rf "$d"

# 4. A step with an empty Agent test cell (the pre-tested rule).
d="$(mktemp -d)"
guide "$d" "$R/testing-guide.md" "# Guide" "$HEADER" \
  "| P1 | 1. Tap **Save**. | Saved toast | | shot.png |"
rc=$(run_in "$d")
[ "$rc" != "0" ] && ok "empty Agent test cell FAILS" || bad "empty Agent test must fail, got rc=$rc"
rm -rf "$d"

d="$(mktemp -d)"
guide "$d" "$R/testing-guide.md" "# Guide" "$HEADER" \
  "| P1 | 1. Tap **Save**. | Saved toast | TBD | shot.png |"
rc=$(run_in "$d")
[ "$rc" != "0" ] && ok "placeholder Agent test (TBD) FAILS" || bad "TBD Agent test must fail, got rc=$rc"
rm -rf "$d"

# 5. Missing columns.
d="$(mktemp -d)"
guide "$d" "$R/testing-guide.md" "# Guide" "| # | Do | Evidence |" "|---|----|----------|" \
  "| P1 | Test the sheet | shot.png |"
out=$(out_in "$d"); rc=$(run_in "$d")
[ "$rc" != "0" ] && printf '%s' "$out" | grep -q 'Agent test' && printf '%s' "$out" | grep -q 'Expect' \
  && ok "missing Agent test and Expect columns FAIL (both named)" || bad "missing columns must fail and be named, got rc=$rc"
rm -rf "$d"

# 6. The after-deploy guide may say "after deploy".
d="$(mktemp -d)"
guide "$d" "$R/testing-guide-after-deploy.md" "# After the deploy" "**Production, after deploy:** 2026-10-12 · abc123 · re-run by agent · 3 of 3" \
  "## After deploy" "$HEADER" \
  "| A1 | 1. After deploy, open the app. | It loads | Production re-run 2026-10-12 | shot.png |"
[ "$(run_in "$d")" = "0" ] && ok "after-deploy guide may contain after-deploy steps" || bad "after-deploy guide should pass"
rm -rf "$d"

# 7. More than 10 steps warns but does not fail.
d="$(mktemp -d)"
rows=()
for i in $(seq 1 11); do rows+=("| P$i | 1. Tap **X$i**. | Screen $i | Pass 1 | s$i.png |"); done
guide "$d" "$R/testing-guide.md" "# Guide" "$HEADER" "${rows[@]}"
out=$(out_in "$d"); rc=$(run_in "$d")
[ "$rc" = "0" ] && printf '%s' "$out" | grep -q '^ *WARN' && ok "11 steps warns, does not fail" || bad "11 steps should warn and pass, got rc=$rc"
rm -rf "$d"

# 8. projects/done/ is frozen history and skipped.
d="$(mktemp -d)"
guide "$d" "projects/done/old/qa/round-1/testing-guide.md" "# Guide" "$HEADER" \
  "| D6 | After deploy, check email | An email | | - |"
[ "$(run_in "$d")" = "0" ] && ok "projects/done/ is skipped" || bad "done/ should be skipped"
rm -rf "$d"

# 9. Explicit file arguments, and a non-guide file is ignored.
d="$(mktemp -d)"
guide "$d" "$R/testing-guide.md" "# Guide" "$HEADER" "| P1 | 1. Tap. | X | | - |"
guide "$d" "notes/other.md" "| # | Do | Expect |" "|---|---|---|" "| 1 | after deploy | x |"
rc=$(run_in "$d" "$R/testing-guide.md")
[ "$rc" != "0" ] && ok "explicit file argument is checked" || bad "explicit bad guide must fail, got rc=$rc"
[ "$(run_in "$d" notes/other.md)" = "0" ] && ok "non-guide file argument is ignored" || bad "non-guide file should be ignored"
rm -rf "$d"

# 10. Nothing to check is a pass (and says so).
d="$(mktemp -d)"
out=$(out_in "$d"); rc=$(run_in "$d")
[ "$rc" = "0" ] && printf '%s' "$out" | grep -qi 'no guides' && ok "no guides: passes and says so" || bad "no guides should pass with a message"
rm -rf "$d"

# 11. Escaped pipes inside a cell are text, not separators.
d="$(mktemp -d)"
guide "$d" "$R/testing-guide.md" "# Guide" "$HEADER" \
  "| P1 | 1. Type a \\| b. | Shows a \\| b | Pass 1 | s.png |"
[ "$(run_in "$d")" = "0" ] && ok "escaped pipes don't shift columns" || bad "escaped pipe should not break the row"
rm -rf "$d"

echo
if [ "$fails" -eq 0 ]; then echo "All checks passed."; else echo "${fails} FAILURE(S)"; fi
exit "$fails"
