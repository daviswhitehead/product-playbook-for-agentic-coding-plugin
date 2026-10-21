---
plugin: product-playbook-for-agentic-coding
bump: patch
---
### Changed
- **autonomous-execution (conductor mode): five rules from a one-day five-PR batch** — `Closes #N` in every sub-agent PR body, a conductor code review on every sub-agent PR before ready, the untrusted-text gate stated in the task prompt for any new external text source, "diff the gate script against the policy before paying for another run", and draft→ready ordering so the full eval is not cancelled. (chef-chopsky 2026-10-20/21: 16 issues left open, 27 review findings, one wasted full CI run.)
- **learnings: feedback passed with the invocation is Part B input and a systemic candidate** — answered with an artifact in the same retro, not re-asked; a founder who asks for a wrap-up has delegated the gates; retry the ledger generator once on a transient GitHub 5xx.
