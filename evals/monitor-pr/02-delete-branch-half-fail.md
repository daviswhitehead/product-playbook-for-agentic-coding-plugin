---
command: commands/workflows/monitor-pr.md
incident: CHANGELOG 0.24.4 → 0.24.5 (2026-07) — false "harmless" claim corrected, second trigger (dirty tree) hit immediately
---

# Scenario: gh pr merge --delete-branch half-fails after a successful merge

The merge succeeds, then gh's post-merge local cleanup fails (dirty working tree, or
another worktree holds the branch). The operation deletes NEITHER branch; the remote
branch stays alive. Because the PR is merged, the error reads as cosmetic and gets
walked past — the naive agent reports success and leaves a zombie remote branch.

## Expectations

- static: half-fails — it deletes NEITHER branch
- static: re-checkout your working branch afterwards
- behavioral: On any post-merge cleanup error the agent verifies the remote branch's actual state instead of assuming the error was cosmetic.
