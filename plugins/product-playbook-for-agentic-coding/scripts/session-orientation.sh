#!/usr/bin/env bash
#
# SessionStart hook — deterministic session orientation.
#
# The session-start-status skill exists because agents burn 10-30K tokens per
# session re-discovering the same context. But a skill only runs when someone
# remembers to invoke it, which makes "orient at session start" a suggestion.
# This gathers the same raw inputs unconditionally, in the harness, at ~zero
# context cost, so the agent starts with them instead of spending five tool
# round-trips fetching them.
#
# The skill is still the right tool for the *judgment* pass (what's the next
# action, what's blocked). This just removes the fetching.
#
# Design constraints, because this runs for every user in every session:
#   - Fast: only cheap git plumbing, no network, no file walks.
#   - Bounded: hard caps on every list. Never dumps a large repo into context.
#   - Silent when irrelevant: no git repo or no playbook layout -> print nothing.
#   - Never fails the session: always exits 0.
#
# Opt out with PLAYBOOK_NO_ORIENTATION=1.

# Format strings below contain literal markdown backticks, not command
# substitution — the single quotes are deliberate.
# shellcheck disable=SC2016

set -uo pipefail

[ "${PLAYBOOK_NO_ORIENTATION:-}" = "1" ] && exit 0
command -v git >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Any output at all is context cost, so bail unless this repo actually uses the
# playbook layout. A plain repo gets nothing.
[ -d projects ] || [ -d docs/checkpoints ] || exit 0

branch=$(git branch --show-current 2>/dev/null || echo "detached")
dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || true)
if [ -n "$upstream" ]; then
  counts=$(git rev-list --left-right --count "${upstream}...HEAD" 2>/dev/null || echo "0	0")
  behind=$(printf '%s' "$counts" | cut -f1)
  ahead=$(printf '%s' "$counts" | cut -f2)
  track="${ahead} ahead / ${behind} behind ${upstream}"
else
  track="no upstream"
fi

printf '## Session orientation (auto)\n\n'
printf -- '- **Branch**: `%s` — %s — %s uncommitted file(s)\n' "$branch" "$track" "$dirty"

# Active projects. Capped: a long list is noise, and the count conveys the rest.
if [ -d projects/in-progress ]; then
  active=$(find projects/in-progress -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort)
  n=$(printf '%s\n' "$active" | grep -c . || true)
  if [ "$n" -gt 0 ]; then
    shown=$(printf '%s\n' "$active" | head -6 | tr '\n' ' ')
    if [ "$n" -gt 6 ]; then
      printf -- '- **In progress** (%s): %s… (+%s more)\n' "$n" "$shown" "$((n - 6))"
    else
      printf -- '- **In progress** (%s): %s\n' "$n" "$shown"
    fi
  fi
fi

# Freshest checkpoint, if the repo keeps them. Path only — reading it is the
# agent's call, and it is usually higher signal than anything gathered here.
if [ -f docs/checkpoints/latest.md ]; then
  when=$(grep -m1 -E '^\*\*Date\*\*:' docs/checkpoints/latest.md 2>/dev/null | sed 's/\*\*Date\*\*:[[:space:]]*//' || true)
  printf -- '- **Checkpoint**: `docs/checkpoints/latest.md`%s — higher signal than this summary; read it before re-deriving state\n' "${when:+ (${when})}"
fi

printf -- '- **Recent**: '
git log --oneline -3 --no-decorate 2>/dev/null | sed 's/^/    /' | paste -sd '; ' - | sed 's/^ *//' || true
printf '\n'

# Stashes are the classic way work gets lost when a worktree or branch is
# archived: every commit is pushed, so the branch reads "clean", and the stash
# goes with the directory. Surface only stashes tagged to THIS branch.
if [ -n "$branch" ]; then
  stashes=$(git stash list 2>/dev/null | grep -c -E "(On|WIP on) ${branch}:" || true)
  [ "${stashes:-0}" -gt 0 ] && \
    printf -- '- ⚠️ **%s stash(es) on this branch** — `git stash list`. Pushed ≠ captured; check these before archiving the worktree.\n' "$stashes"
fi

exit 0
