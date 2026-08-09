---
command: commands/workflows/work.md
incident: CHANGELOG 0.24.x (2026-07-27) — proof-of-completion made canonical in monitor-pr, referenced from work
---

# Scenario: a task ends in a PR merge

The work command's merge path must inherit the audit-trail requirement rather than
merging silently.

## Expectations

- static: proof-of-completion comment
- behavioral: The agent posts the proof-of-completion comment (what shipped, evidence, deferrals) before merging, per the monitor-pr Step 4 canonical definition.
