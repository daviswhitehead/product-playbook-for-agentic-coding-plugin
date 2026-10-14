---
plugin: product-playbook-for-agentic-coding
bump: minor
---

### Added
- **Every founder decision is recorded when it is made, in one shape.** New `resources/templates/decision-line.md` is the single definition of the decision line `/playbook:explore` already wrote, now with optional `images` (what he was shown; required for rendered options), `why` and `why_basis` (`stated` or `inferred`), and `stage` values `review`, `qa-round`, `delivery` and `packet`. Ids per source: `D<NN>-<n>` discovery (unchanged, still `discovery/decisions.jsonl`), `R-<n>` review, `Q<round>-<n>` QA round, `W-<n>` delivery queue, `P<pr>-<n>` PR packet, all in `<project>/decisions.jsonl`. Before this, only discovery picks were logged as they happened; review calls, QA rulings, queue rows and packet decisions were reconstructed at the retro, if at all, so the taste ledger and a stand-in could not learn from most of them.

### Changed
- **`/playbook:review`, `/playbook:qa-round`, the decisions queue (`work`, `work-multiple`, `autonomous-execution`), `/playbook:monitor-pr`'s proof-of-completion packet and `/playbook:merge-prs` escalations** each append a decision line when a choice reaches the founder and fill its `answer` when he rules. A short reason after his pick ("B, simpler") is recorded as `why` with `why_basis: stated`; agents never ask him for one.
- **Generic stand-in hook:** if the repo documents a stand-in predict command, agents run it right after appending lines and before the founder sees them, and never read or show its output.
- **`/playbook:learnings` Step 10 (agreement tally)** reads both `discovery/decisions.jsonl` and the project's `decisions.jsonl` first.
