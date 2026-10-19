---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Added
- **`spike.md` template: a block for tool/model/vendor evaluations.** It covers a pre-registered adoption rule, a base-rate replay on real stored inputs before any live trial, eval hygiene (no leaked or contradictory criteria) and disclosure-before-data-flow. Why: on chef-chopsky (2026-10-18), a Jev (TypeSafe) spike shipped a production shadow trial for two routers. Only afterwards did a replay of 1,220 real messages show they fire on about 0.3% of traffic, so the trial would take months to yield a read the one-hour replay gave immediately.
- **`/playbook:learnings` memory sweep: also correct the memories the session contradicted.** Before, it only asked about memories the session created or modified. A stale "X never does Y" note (and the runbook repeating it) is a wrong rule that nothing else catches.
