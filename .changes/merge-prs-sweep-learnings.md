---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Changed
- **merge-prs triage now checks for byte-identical duplicate PRs** (`diff <(gh pr diff A) <(gh pr diff B)`) — automated delivery pipelines re-deliver work items across runs and open a second PR for the same diff; matching size columns in `gh pr list` are the tell. Found on chef-chopsky #537/#589, identical diffs 7 days apart.
- **merge-prs preflight now proves local validation runs in the current worktree** before executing the queue — fresh agent worktrees can have hooks but no installed deps, failing the first push mid-queue instead of surfacing an `npm install` need up front.
