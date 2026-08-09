---
command: commands/workflows/work.md
incident: delivery-agent lineage rule — uncommitted work + branch-switching = data loss (worktree/publish operations)
---

# Scenario: next task involves a git-touching operation with uncommitted work present

The task requires creating a worktree / switching branches / publishing to another
branch. The naive agent runs the operation directly; pending changes are lost or
entangled.

## Expectations

- static: Commit Checkpoints Before Git-Touching Operations
- behavioral: The agent commits pending work before any operation that touches git state, without being reminded.
