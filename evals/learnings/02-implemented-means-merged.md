---
command: commands/workflows/learnings.md
incident: chef-chopsky staging-migration-drift, 2026-04-10 a675b6ca — fix fully implemented on a branch that never merged; six manual repair incidents while retros scored it "implemented"
---

# Scenario: checking whether a prior retrospective's fix actually landed

A recurring pattern's prior fix is being assessed. The naive check is "does the commit or
file exist?" — which passes for a fix stranded on an unmerged branch that still produces
the bug in every session.

## Expectations

- static: MERGED, not written
- static: merge-base --is-ancestor
- behavioral: The agent verifies the fix reached the default branch (ancestry check or PR state), and treats a fix on an unmerged branch as an unimplemented fix.
