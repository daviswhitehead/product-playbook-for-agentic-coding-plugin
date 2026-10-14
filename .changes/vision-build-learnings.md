---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Changed
- **`autonomous-execution` conductor rules from the 2026-10-14 vision build:**
  - Shared machine services (Docker, a local DB, simulators) belong to the conductor. Subagents probe and report, never restart, and a failing preflight holds only heavy steps.
  - Two sides of one contract built in parallel need one integration dry run from the real starting state on the real host.
  - A lever proposed from a small sample states its n and interval.
- **`/playbook:learnings` Part A0** runs in a light form for chat-session retros when the founder made calls that session, so the taste ledger doesn't lose them.
- **Release recipe** (repo `CLAUDE.md`) stages explicit paths; `git add -A` had committed a `.worktrees/` gitlink to `main`.
