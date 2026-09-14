---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **`/playbook:merge-prs` and `/playbook:monitor-pr` — require a `MERGED` verdict before deleting any PR branch.** Both commands told you to treat *any* non-empty error from `gh pr merge --delete-branch` as "the remote branch probably survived" and to finish the delete by hand. That rule was derived entirely from *post-merge cleanup* failures (a worktree holding the branch, a dirty working tree, async server-side reaping) where the merge did succeed — but it keys on the presence of an error, never on which error, so it applies equally to a merge that was *rejected* (`Base branch was modified`, not mergeable, checks red). Applied there it deletes the head of a PR that still needs it, which also closes the PR. Both commands now gate the delete on `gh pr view <N> --json state,mergeCommit` reading `MERGED` with a non-null sha, with a verdict table covering `OPEN`/`CLOSED` + null, and carry a recovery recipe (`git push origin <sha>:refs/heads/<branch>` + `gh pr reopen`) since every worktree of a repo shares one object store.
