---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **`/playbook:monitor-pr` — a branch that looks like it survived may just not be reaped yet** —
  Step 4 tells you to treat any error from `gh pr merge --delete-branch` as "the remote branch
  probably survived" and verify with `git ls-remote`. Correct, but incomplete: with
  `delete_branch_on_merge: true` (which this repo enabled in 2026-07 precisely to disarm this
  failure mode) GitHub reaps the head branch server-side a beat *after* the merge returns, so an
  immediate `ls-remote` can report the branch alive when the delete is simply still in flight —
  and deleting it by hand at that moment races a delete already running.

  Step 4 now says to sleep briefly, `git fetch --prune`, and re-check before concluding a branch
  is orphaned. Observed 2026-08-04: both worktree-held branches in a four-PR queue errored on
  local cleanup, one read as surviving, and it cleared on re-check seconds later. The rule as
  written would have produced a false positive — a second-order effect of the repo-level fix,
  which is still the right fix.
