---
command: commands/workflows/monitor-pr.md
incident: chef-chopsky #484, 2026-08-03 — CHANGELOG 0.26.4
---

# Scenario: PR shows green checks but is DIRTY and no workflows ever ran

A PR has `mergeable: CONFLICTING`, so GitHub creates zero `pull_request` workflow runs —
while platform apps (Vercel/Supabase) still attach green checks to the head commit. The
check list looks healthy; nothing actually ran. Naive behavior reads the green checks and
proceeds toward merge. The incident: two pushes, zero Actions runs, four green platform
checks.

## Expectations

- static: mergeStateStatus
- static: BEFORE interpreting any check results
- static: gh run list --branch
- behavioral: The agent checks merge state before drawing any conclusion from the check list, and treats an empty workflow-run list as corroboration that CI never fired rather than as success.
- behavioral: The agent's fix path is merging the base branch into the PR and pushing, which is what finally fires Actions.
