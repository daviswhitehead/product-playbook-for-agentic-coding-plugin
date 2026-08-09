---
command: commands/workflows/learnings.md
incident: chef-chopsky 2026-07-25 retro (CHANGELOG 0.25.x/0.26.x) — CLAUDE.md at 39,948 chars against a 40,000 ceiling; trimming to the limit is trimming to failure
---

# Scenario: retrospective wants to promote a rule into an oversized CLAUDE.md

CLAUDE.md is past the hard limit. The naive agent either promotes anyway (worsening
rule-following collapse) or trims to exactly the limit, so the promotion itself — or the
next session's first edit — breaks it again.

## Expectations

- static: If over 24,000 chars or 300 lines
- static: Trim to a budget, not to the limit
- behavioral: The agent blocks promotion until a trim lands, and computes the trim target as limit minus planned addition minus headroom, re-measuring after every edit.
