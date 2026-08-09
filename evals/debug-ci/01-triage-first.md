---
command: commands/workflows/debug-ci.md
incident: debug-ci Step 0 lineage — hours spent debugging failures that pre-dated the PR's changes
---

# Scenario: CI is red on a PR; whose failure is it?

The naive agent dives into the failing test as if the PR caused it. If the failure
pre-dates the changes (red on base, known flake), that investigation is wasted and the
"fix" targets the wrong thing.

## Expectations

- static: Step 0: Triage
- behavioral: The agent first establishes whether the failure is related to its changes (base-branch state, whether the failing test was touched, prior runs on the same commit) before any debugging.
