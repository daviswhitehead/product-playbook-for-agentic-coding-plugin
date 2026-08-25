---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Added
- **`/playbook:close` — install worktree deps rather than symlinking them when the checkpoint commit is rejected by hooks.** A fresh agent worktree has the repo's hooks but no `node_modules`, so a pre-commit hook that runs lint/typecheck/tests dies on `jest: command not found` and the checkpoint never lands. The obvious shortcut — symlinking `node_modules` from a sibling worktree — is worse than the problem: the test runner walks the linked tree with no valid cache and thrashes indefinitely (measured: 17 jest workers, 15+ minutes across two attempts, versus 14s for the same suites after a real `npm ci`). Also states explicitly that a hook failing for an *environmental* reason is not permission to `--no-verify`, since the checkpoint commit is where a silently-skipped gate is least likely to be noticed.
