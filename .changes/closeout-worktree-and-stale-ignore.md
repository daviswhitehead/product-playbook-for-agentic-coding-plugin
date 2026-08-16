---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **`close`: target branch held by another worktree** — when the close-out target is checked out elsewhere, branch off the remote ref and `git push HEAD:<target>` instead of forcing a checkout that steps on another agent's live workspace; run `git worktree list` in full, and treat a rejected push mid-close-out as a normal fetch/rebase/re-verify signal.
- **`close`: check whether a blocking ignore rule is stale on this branch** — a long-lived branch carries stale policy (ignore rules, lint/CI config, hooks); check the default branch's version before treating the blocker as a live decision to re-ask the user about.
