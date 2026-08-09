# The Improvement Loop's Constitution

This file is the objective function and rulebook for every process — human-run or
autonomous — that modifies this repo's instructions (commands, agents, skills, templates,
CLAUDE.md/AGENTS.md). A self-improving repo drifts toward whatever its retrospective
prompts implicitly reward; this file pins the reward explicitly.

## Objective

> **Make the next session cheaper and more correct.**

Every proposed change must argue from this objective: fewer user corrections, fewer
re-learned lessons, less context burned re-discovering the same facts, fewer wrong turns.
"More capability" is not the objective; an addition that grows the instruction surface
without reducing next-session cost is a regression dressed as progress.

## Standing rules

1. **Friction-driven, never speculative.** A rule or workflow change needs a cited
   incident — ideally two. Every improvement PR names the session, learning doc, or
   correction that motivated it. "Might be useful" does not merge.

2. **Itemized edits only — never wholesale rewrites.** Improvement changes add, update,
   or delete specific sections of an instruction file. Regenerating a whole command,
   skill, or CLAUDE.md from scratch is forbidden: iterative full rewrites erode the
   hard-won details that carried the value (the ACE paper calls this context collapse;
   this repo's append-and-strengthen learnings pattern is the same rule).

3. **Additions pay for themselves.** Instruction files have CI-enforced size budgets
   (`scripts/validate-plugin.sh`). Over a soft limit, promotions follow one-in-one-out:
   each addition names a demotion or deletion in the same change. Deletion proposals are
   first-class improvements, not housekeeping.

4. **Everything ships through the changeset pipeline.** Every improvement is a changeset
   PR, released via `scripts/release.sh`. No exceptions for "small" changes — the
   version-keyed propagation and the CHANGELOG audit trail are what make bad changes
   findable and revertible (rollback is one changeset).

5. **The loop never edits its own guardrails.** These files are changeable only by a
   human-approved PR, never by an autonomous improvement run:
   - `IMPROVEMENT.md` (this file)
   - `scripts/validate-plugin.sh`, `scripts/check-version-bump.sh`, `scripts/release.sh`
     and their test suites
   - `.github/workflows/plugin-guard.yml`
   - `evals/` — fixtures, `run-static.sh`, and `baselines.tsv`. An autonomous run may
     READ and must RUN them; weakening a fixture to make an edit pass is the one move
     that must always cross a human

   An autonomous run that believes a guardrail is wrong writes that up as a finding for
   human review; it does not fix it.

6. **Nothing session-specific gets promoted.** No secrets, tokens, machine paths, or
   one-project quirks in plugin instructions. Scope check at promotion time: is this
   Chef Chopsky-specific (→ that repo's docs), playbook-general (→ here), or portable
   anywhere (→ a Lore skill)?

## The autonomy ladder

Autonomy is earned per change-class by the strength of the check that guards it — not
granted globally. Current rung for each class:

| Change class | Gate today | Promotes to (when) |
|---|---|---|
| Learnings docs, checkpoints, changeset prose | Auto-mergeable when CI is green | — (already terminal) |
| Dedupe / demotion of stale instruction content | Draft PR, human skim | Auto-merge (after eval harness exists and is green) |
| Appending to an existing command/skill section | Draft PR, human skim | Auto-merge when CI + evals green (after ~1 month without a bad merge) |
| Editing instruction semantics; new commands/skills | Draft PR, human approval | Auto-merge after evals green + 72h no objection |
| Deletions of components; CLAUDE.md; anything in rule 5's list | Human approval, always | Never |

Promotion between rungs is itself a human-approved edit to this table.

## What the loop measures

- **Usage**: which commands/skills actually fire (`~/.claude/playbook-usage.log`, written
  by the `log-playbook-usage.sh` hook). A component unused for a month is a pruning
  candidate for `/playbook:review-playbook`.
- **Eval fixtures** (`evals/`): incident-derived scenario checks per high-traffic
  command. The **static layer gates now** — `evals/run-static.sh` runs inside
  `validate-plugin.sh`, so CI fails any edit that drops a load-bearing phrase. The
  **behavioral layer** (LLM-scored assertions) is tracked directionally until the weekly
  run wires it in; an instruction edit must not regress either, and a claimed
  improvement should move at least one expectation.
- **Outcome trend** (the real reward): user corrections per session, re-learned lessons
  per retrospective, time-to-green on PRs. If these worsen after a release, the release
  gets reverted first and debated second.
