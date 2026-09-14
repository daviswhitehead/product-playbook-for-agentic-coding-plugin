---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Added
- **`/playbook:learnings` — verify a finding's *mechanism*, not just its causality, before writing it down.** The existing check covers causal claims against an authoritative timeline. But a candidate finding usually also rests on a claim about how the system behaves ("CI only validated the head", "that job is path-filtered", "the hook runs on pre-push") — and those read as background knowledge rather than claims, so they get written without being checked. Adds the instruction to read the config, workflow file, or script that actually decides it before the finding ships, plus explicit permission to count a killed finding as a success and report it. Grounded in a 2026-09-13 near-miss on this plugin: a retro was about to record "CI only tested the PR head, so validate a trial merge locally" when `plugin-guard.yml` uses `actions/checkout@v4` with no `ref:` — which on `pull_request` checks out `refs/pull/N/merge`, so GitHub had already tested the merge result. The rule would have been wrong, and this workflow's own checklist holds that a wrong rule is worse than a missing one.
