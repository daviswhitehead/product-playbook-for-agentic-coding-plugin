---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Changed
- **`/playbook:merge-prs` and `/playbook:monitor-pr` merge without `--delete-branch` when the repo has `deleteBranchOnMerge: true`.** The server already deletes the remote branch. Every recorded `--delete-branch` failure (half-fails, a stranded checkout, a live PR's head deleted) came from the flag's local half, which fails whenever a worktree holds the branch or the tree is dirty. The verdict gate and `ls-remote` check stay.
- **`/playbook:merge-prs` skips merging main in (Step 5.2) for a PR that is already `CLEAN` and needs no push.** That step only bought a CI run. The post-merge guard on `main` is the backstop.
- **`/playbook:close` Phase 4.6 counts CI cost by the session's own SHAs, never by a date window.** A date window counted 7 other sessions' runs and turned a correct figure into a wrong one.
