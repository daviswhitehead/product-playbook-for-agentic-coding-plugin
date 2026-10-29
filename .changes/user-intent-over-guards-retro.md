---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Changed
- **tasks template, Proof line** — for a model-behaviour change, iterate on a scoped real-model run of the touched scenarios (`--ids=…`, cents) and run the full tier once at ready-for-review; a full run reads "189/193" with no attribution (chef-chopsky 2026-10-27: four agent bugs found for ≈ $2.50 before the PR was cut).
- **tasks template, `[GATE]` dry-run** — the dry-run's tooling must leave its rows in place until the consuming query has read them; a replay that cleans up first manufactures false misses (chef-chopsky 2026-10-29).
- **tasks command** — the identifier verification pass is done by a different agent than the author (8 of 42 anchors wrong and one non-functional state channel found that way).
- **tech-plan command** — run the critique before the founder reads the plan, and name the best-in-class / upstream answer before the local fix (two founder redirects on one plan).
- **learnings command, Part A0** — when the repo has no taste ledger file, record the tally in the learnings doc and name creating the ledger as an action item instead of inventing one.

### Fixed
- **`verify-close-project.sh`** — the "living references" check reads tracked files only (`git grep`), so gitignored scratch (`.tmp/`, `.context/`) and build output (`dist/`) no longer block a close-out; negative-tested against an injected tracked reference.
