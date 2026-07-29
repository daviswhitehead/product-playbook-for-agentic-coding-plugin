#!/usr/bin/env bash
#
# Tests for verify-close-project.sh and session-orientation.sh.
#
#   scripts/test-close-project-checks.sh
#
# The important test is "reproduces the historical bug": a check that only ever
# passes is a rubber stamp. verify-close-project.sh must FAIL when pointed at the
# exact shape that went unnoticed for 3.7 months — the project present in BOTH
# in-progress/ and done/ — and pass on a correct close.

# 'cond && ok || bad' is intentional here: ok/bad are printf wrappers that
# cannot fail, so the else-branch semantics are exactly what we want.
# shellcheck disable=SC2015

set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
VERIFY="${HERE}/verify-close-project.sh"
ORIENT="${HERE}/session-orientation.sh"
fails=0

ok()   { printf 'PASS  %s\n' "$1"; }
bad()  { printf 'FAIL  %s\n' "$1"; fails=$((fails + 1)); }

# Build a throwaway repo with a given project layout.
# usage: fixture <name> <tray-or-empty>   (tray="" means properly moved)
fixture() {
  local name="$1" tray="${2:-}"
  local d; d="$(mktemp -d)"
  ( cd "$d" \
    && git init -q . \
    && git config user.email t@t && git config user.name t \
    && mkdir -p "projects/done/${name}" \
    && echo "# diff" > "projects/done/${name}/planned-vs-implemented.md" \
    && if [ -n "$tray" ]; then mkdir -p "projects/${tray}/${name}"; echo x > "projects/${tray}/${name}/tasks.md"; fi \
    && git add -A && git commit -qm "fixture" ) >/dev/null 2>&1
  printf '%s' "$d"
}

run_in() { ( cd "$1" && "$VERIFY" "$2" >/dev/null 2>&1; echo $? ); }

echo "=== verify-close-project.sh ==="

d=$(fixture alpha "")
[ "$(run_in "$d" alpha)" = "0" ] && ok "clean close passes" || bad "clean close should pass"
rm -rf "$d"

# THE regression: forgot-password / illustration-batch shape.
d=$(fixture beta "in-progress")
rc=$(run_in "$d" beta)
[ "$rc" != "0" ] && ok "duplicated in in-progress/ FAILS (the 3.7-month bug)" \
                 || bad "duplicated in in-progress/ must fail, got rc=$rc"
rm -rf "$d"

d=$(fixture gamma "to-do")
rc=$(run_in "$d" gamma)
[ "$rc" != "0" ] && ok "duplicated in to-do/ FAILS" || bad "duplicated in to-do/ must fail, got rc=$rc"
rm -rf "$d"

# Never moved at all.
d="$(mktemp -d)"
( cd "$d" && git init -q . && git config user.email t@t && git config user.name t \
  && mkdir -p projects/in-progress/delta && echo x > projects/in-progress/delta/tasks.md \
  && git add -A && git commit -qm f ) >/dev/null 2>&1
rc=$(run_in "$d" delta)
[ "$rc" != "0" ] && ok "never moved FAILS" || bad "never moved must fail, got rc=$rc"
rm -rf "$d"

# Missing close-out artifact.
d=$(fixture epsilon "")
rm "$d/projects/done/epsilon/planned-vs-implemented.md"
rc=$(run_in "$d" epsilon)
[ "$rc" != "0" ] && ok "missing planned-vs-implemented.md FAILS" || bad "missing artifact must fail"
rm -rf "$d"

# A stale reference in a living doc.
d=$(fixture zeta "")
echo "see projects/in-progress/zeta/tasks.md" > "$d/README.md"
rc=$(run_in "$d" zeta)
[ "$rc" != "0" ] && ok "stale reference in a living doc FAILS" || bad "stale reference must fail"
rm -rf "$d"

# Historical references inside done/ are fine.
d=$(fixture eta "")
echo "was projects/in-progress/eta/" > "$d/projects/done/eta/history.md"
rc=$(run_in "$d" eta)
[ "$rc" = "0" ] && ok "historical reference inside done/ is allowed" || bad "done/ reference should not fail"
rm -rf "$d"

[ "$("$VERIFY" 2>/dev/null; echo $?)" = "64" ] && ok "missing arg exits 64" || bad "missing arg should exit 64"

echo
echo "=== session-orientation.sh ==="

# Silent outside a git repo.
d="$(mktemp -d)"
out=$( cd "$d" && "$ORIENT" 2>/dev/null )
[ -z "$out" ] && ok "silent outside a git repo" || bad "should print nothing outside a git repo"
rm -rf "$d"

# Silent in a git repo with no playbook layout — most repos.
d="$(mktemp -d)"
( cd "$d" && git init -q . ) >/dev/null 2>&1
out=$( cd "$d" && "$ORIENT" 2>/dev/null )
[ -z "$out" ] && ok "silent in a repo with no playbook layout" || bad "should print nothing without projects/"
rm -rf "$d"

# Emits in a playbook repo, and stays bounded.
d=$(fixture theta "in-progress")
out=$( cd "$d" && "$ORIENT" 2>/dev/null )
printf '%s' "$out" | grep -q "Session orientation" && ok "emits in a playbook repo" || bad "should emit with projects/"
lines=$(printf '%s\n' "$out" | wc -l | tr -d ' ')
[ "$lines" -le 12 ] && ok "output bounded (${lines} lines)" || bad "output too long: ${lines} lines"
rm -rf "$d"

# Opt-out honored.
d=$(fixture iota "in-progress")
out=$( cd "$d" && PLAYBOOK_NO_ORIENTATION=1 "$ORIENT" 2>/dev/null )
[ -z "$out" ] && ok "PLAYBOOK_NO_ORIENTATION=1 silences it" || bad "opt-out not honored"
rm -rf "$d"

# Never fails a session, even somewhere hostile.
d=$(fixture kappa "")
rm -rf "$d/.git"
if ( cd "$d" && "$ORIENT" >/dev/null 2>&1 ); then
  ok "exits 0 even with a broken repo"
else
  bad "must never fail the session"
fi
rm -rf "$d"

echo
if [ "$fails" -eq 0 ]; then echo "All checks passed."; else echo "${fails} FAILURE(S)"; fi
exit "$fails"
