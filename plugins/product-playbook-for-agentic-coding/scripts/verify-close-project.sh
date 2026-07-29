#!/usr/bin/env bash
#
# Executable close-out check for /playbook:close-project.
#
#   scripts/verify-close-project.sh <project-name>
#
# Why this exists
# ---------------
# close-project's Step 7 checklist asked "Project lives under projects/done/?"
# — and that question was *true* during the failure it was supposed to catch.
# forgot-password and illustration-batch were copied rather than moved, so they
# sat in BOTH in-progress/ and done/ for ~3.7 months. Every checklist item
# passed. The source directory was never asserted gone.
#
# A prose checkbox cannot catch that, because the agent answering it is the same
# one that just did the copy. This asserts the invariant instead: after a close,
# exactly ONE copy of the project exists, and it is the one under done/.
#
# Exits non-zero on any failure. Safe to run repeatedly.

set -uo pipefail

NAME="${1:-}"
if [ -z "$NAME" ]; then
  echo "usage: verify-close-project.sh <project-name>" >&2
  exit 64
fi

fails=0
pass() { printf '  \033[0;32mPASS\033[0m  %s\n' "$1"; }
fail() { printf '  \033[0;31mFAIL\033[0m  %s\n' "$1"; fails=$((fails + 1)); }
skip() { printf '  \033[0;33mSKIP\033[0m  %s\n' "$1"; }

echo "Verifying close-out of '${NAME}'"
echo

# --- 1. It landed ------------------------------------------------------------
if [ -d "projects/done/${NAME}" ]; then
  pass "projects/done/${NAME}/ exists"
else
  fail "projects/done/${NAME}/ does not exist — the project never landed"
fi

# --- 2. THE ONE THAT MATTERS: the source is gone -----------------------------
# This is the assertion whose absence cost 3.7 months of duplicated state.
for tray in in-progress to-do; do
  if [ -d "projects/${tray}/${NAME}" ]; then
    fail "projects/${tray}/${NAME}/ STILL EXISTS — copied instead of moved. Use 'git mv', then delete the source."
  else
    pass "projects/${tray}/${NAME}/ is gone"
  fi
done

# --- 3. Nothing living still points at the old paths -------------------------
# Excludes done/ itself (historical references there are fine) and .git.
stale=0
for tray in in-progress to-do; do
  hits=$(grep -rl --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=done \
           "projects/${tray}/${NAME}" . 2>/dev/null | head -20 || true)
  if [ -n "$hits" ]; then
    fail "living references to projects/${tray}/${NAME}:"
    while IFS= read -r hit; do
      [ -n "$hit" ] && printf '           %s\n' "$hit"
    done <<< "$hits"
    stale=1
  fi
done
[ "$stale" -eq 0 ] && pass "no living references to the old path"

# --- 4. The close-out artifact exists ----------------------------------------
if [ -f "projects/done/${NAME}/planned-vs-implemented.md" ]; then
  pass "planned-vs-implemented.md present"
else
  fail "planned-vs-implemented.md missing from projects/done/${NAME}/"
fi

# --- 5. Merged PRs carry a proof-of-completion comment -----------------------
# Autonomous merge authority is granted in exchange for a reviewable audit
# trail; green CI is not that trail. Best-effort: needs gh, auth, and a remote.
if ! command -v gh >/dev/null 2>&1; then
  skip "proof-of-completion check (gh not installed)"
elif ! gh auth status >/dev/null 2>&1; then
  skip "proof-of-completion check (gh not authenticated)"
else
  prs=$(git log --oneline --all -- "projects/done/${NAME}" "projects/in-progress/${NAME}" "projects/to-do/${NAME}" 2>/dev/null \
        | grep -oE '#[0-9]+' | tr -d '#' | sort -un | head -20 || true)
  if [ -z "$prs" ]; then
    skip "proof-of-completion check (no PR numbers found in this project's history)"
  else
    missing=""
    for pr in $prs; do
      state=$(gh pr view "$pr" --json state --jq .state 2>/dev/null || echo "")
      [ "$state" = "MERGED" ] || continue
      body=$(gh pr view "$pr" --json comments --jq '[.comments[].body] | join("\n")' 2>/dev/null || echo "")
      printf '%s' "$body" | grep -qiE 'proof of completion|what shipped|proof-of-completion' \
        || missing="${missing} #${pr}"
    done
    if [ -n "$missing" ]; then
      fail "merged PR(s) missing a proof-of-completion comment:${missing}"
      echo "           Post retroactively — see /playbook:monitor-pr Step 4."
    else
      pass "all merged PRs carry a proof-of-completion comment"
    fi
  fi
fi

echo
if [ "$fails" -eq 0 ]; then
  echo "Close-out verified."
else
  echo "${fails} check(s) failed — close-out is NOT complete."
fi
exit "$fails"
