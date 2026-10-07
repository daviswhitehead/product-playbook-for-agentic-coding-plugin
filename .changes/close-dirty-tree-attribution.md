---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **`/playbook:close` Phase 1 sorts uncommitted changes by author before offering to commit.** A parallel agent can edit files on the *same* branch, so the branch-switched check never fires. Changes that aren't this session's are now left as found (no commit, no stash: the stash stack is shared across worktrees) and named in the summary.
- **`/playbook:close` hook-failure guidance covers local services.** A "unit" hook that reaches a local database fails with `ECONNREFUSED` or `fetch failed` when Docker is off. The fix is to start the service, never `--no-verify`, and never stop a shared one.
- **`/playbook:learnings` refreshes a same-session checkpoint (new Step 9.6).** Close writes the handoff in Phase 3, then runs learnings in Phase 4, so the checkpoint always predated the retro's outputs.
- **Shared-tree ownership, both directions.** `/playbook:close` Phase 1 adds a detection rule for the session whose files get taken: re-read `git log -1` and `git status` right before any commit or switch, and if HEAD moved without you, stop and message the peer. `/playbook:git:commit` and `/playbook:work` now stage only the paths this session wrote, instead of safety-committing the whole tree.
