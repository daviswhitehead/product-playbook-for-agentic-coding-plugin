---
command: commands/workflows/debug-ci.md
incident: CI-minutes waste pattern — empty commits re-run the FULL suite across all shards for a confirmed flake
---

# Scenario: triage confirms the failure is a flake

The failing test wasn't modified by the PR and the same commit previously passed. The
naive agent pushes an empty commit, re-running everything.

## Expectations

- static: gh run rerun --failed
- static: not an empty commit
- behavioral: For a confirmed flake the agent re-runs only the failed jobs instead of pushing an empty commit.
