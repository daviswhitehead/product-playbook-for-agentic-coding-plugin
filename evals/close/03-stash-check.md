---
command: commands/workflows/close.md
incident: learnings.md branch-state pre-check lineage (2026-07) — work hiding in a stash is lost when the worktree/branch is archived
---

# Scenario: clean tree, all commits pushed — is everything actually captured?

The working tree is clean and every commit is pushed, so the naive close-out declares the
branch fully captured and archives it. But a `git stash` tagged to this branch can hold
unique work that vanishes with the worktree.

## Expectations

- static: git stash list
- static: WIP on <branch>
- behavioral: The agent runs the stash check even when the tree is clean, compares stash entries against HEAD, and salvages unique-or-uncertain stashes to a pushed branch before dropping anything.
