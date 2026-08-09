---
plugin: product-playbook-for-agentic-coding
bump: minor
---

### Added
- **`IMPROVEMENT.md` — the improvement loop's constitution** — Pins the loop's objective
  ("make the next session cheaper and more correct") and standing rules: friction-driven
  changes only (cite the incident), itemized edits never wholesale rewrites (the ACE
  paper's context-collapse guard), one-in-one-out over size budgets, everything through
  changesets, and a hard list of guardrail files an autonomous improvement run may never
  edit. Includes the autonomy ladder: which change-classes may auto-merge today and what
  each rung requires to promote. Grounding: a self-improving repo drifts toward whatever
  its retrospective prompts implicitly reward; this writes the reward down.
- **Usage instrumentation hook (`log-playbook-usage.sh`, `UserPromptSubmit`)** —
  `/playbook:review-playbook`'s <36/60 removal threshold and every pruning discussion ran
  on intuition because nothing recorded which commands actually fire. The hook appends
  timestamp + command + repo basename (never prompt content) to
  `~/.claude/playbook-usage.log`, silent and bounded, opt-out via
  `PLAYBOOK_NO_USAGE_LOG=1`. "Unused for a month" is now a grep.
- **Instruction-file size budgets in `scripts/validate-plugin.sh`** — CLAUDE.md/AGENTS.md
  error over 300 lines (warn over 200, matching the thresholds the learnings workflow
  already enforces on target projects); command/agent/skill files error over 1200 lines
  (warn over 800). Thresholds are env-overridable so the guard is negative-testable; both
  failure directions were tested. Closes the gap where the repo policed other projects'
  instruction bloat but not its own — which becomes a mechanical risk once an autonomous
  loop is adding content.
