---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **`/playbook:close` Phase 1 sorts uncommitted changes by author before offering to commit.** A parallel agent can edit files on the *same* branch, so the branch-switched check never fires. Changes that aren't this session's are now left as found (no commit, no stash: the stash stack is shared across worktrees) and named in the summary.
- **`/playbook:close` hook-failure guidance covers local services.** A "unit" hook that reaches a local database fails with `ECONNREFUSED` or `fetch failed` when Docker is off. The fix is to start the service, never `--no-verify`, and never stop a shared one.
