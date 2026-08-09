# Tasks

## Project Overview
**Project Name**: Recursive Self-Improvement Loop
**Tech Plan**: [tech-plan.md](tech-plan.md)
**Date**: 2026-08-09

## Current Focus

**Active Task**: none — Phase 0 and Phase 1 (1.1–1.3) shipped 2026-08-09 (PR 1)
**Next Task**: Task 2.1 — Correction-capture hook (parallel-track); Task 3.1 — `/playbook:self-improve` (critical path)

## Phase 0: Constitution

### Task 0.1: Write IMPROVEMENT.md ✅
**Description**: The loop's objective ("make the next session cheaper and more correct"), standing rules (friction-driven, itemized edits only, one-in-one-out, changesets always, guardrail files human-only, no session-specific content), and the autonomy ladder table.

**Acceptance Criteria**:
- [x] Objective stated and argued from (not just asserted)
- [x] Rule 5 lists the exact guardrail files an autonomous run may never edit
- [x] Autonomy ladder names current gate + promotion condition per change class

**Status**: [x] Complete — 2026-08-09

**Notes**: Shipped as repo-root `IMPROVEMENT.md`. Ladder promotions are themselves human-approved edits to the table.

---

### Task 0.2: CI-enforced size budgets ✅
**Description**: Add instruction-file line budgets to `scripts/validate-plugin.sh`: CLAUDE.md/AGENTS.md warn >200 / error >300; command/agent/skill files warn >800 / error >1200. Env-overridable thresholds.

**Acceptance Criteria**:
- [x] Guard added; full validation still passes on current repo
- [x] **Negative-tested in both directions**: `BUDGET_ALWAYS_MAX=10` → exit 1 with actionable message; `BUDGET_COMPONENT_MAX=100` → exit 1 (54 component errors observed)

**Status**: [x] Complete — 2026-08-09

**Notes**: Current honest warnings: CLAUDE.md 286 lines, AGENTS.md 208, learnings.md 1018 (the known outlier — refactor candidate for a future improvement PR, not this one). Guard-default changes are rule-5 (human-only).

---

### Task 0.3: CLAUDE.md pointer ✅
**Description**: Short "Self-Improvement Loop" section in CLAUDE.md pointing at IMPROVEMENT.md; README references (hooks table row, self-improvement section).

**Acceptance Criteria**:
- [x] CLAUDE.md stays under the 300-line hard cap (286 after edit)
- [x] README Hooks & Checks table covers the new hook

**Status**: [x] Complete — 2026-08-09

---

## Phase 1: The Ruler

### Task 1.1: Usage instrumentation hook ✅ `[INSTRUMENTATION]`
**Description**: UserPromptSubmit hook logging `/playbook:*` command mentions to `~/.claude/playbook-usage.log` (timestamp, command, repo basename — never prompt content).

**Emission**: `plugins/.../scripts/log-playbook-usage.sh`, wired in `hooks/hooks.json`

**Consumption** (verified per the instrumentation rule — the metric read, not just the event fired):
| Consumer | Query | Expected | Actual | Date |
|---|---|---|---|---|
| pruning / weekly run | `cat ~/.claude/playbook-usage.log` after a `/playbook:work` + `/playbook:learnings` prompt | 2 TSV rows, correct commands + repo | `2026-08-09T18:18:10Z→playbook:learnings→chef-chopsky` + `…playbook:work…` (sandbox HOME) | 2026-08-09 |

**Acceptance Criteria**:
- [x] Consuming query run, non-null correct output pasted above
- [x] Silent on stdout in all paths (UserPromptSubmit stdout injects into context)
- [x] No-op, malformed-stdin, and opt-out (`PLAYBOOK_NO_USAGE_LOG=1`) paths all exit 0 and write nothing
- [x] Log bounded (1 MB → keep newest 5000 lines)

**Status**: [x] Complete — 2026-08-09

**Notes**: First implementation had a real bug caught by testing: `python3 - <<heredoc` claims stdin for the script, so the hook JSON was never read and the hook silently no-opped. Fixed by capturing stdin into `HOOK_INPUT` before the heredoc. Reinforces the negative-test rule.

**Known limitation**: logs *mentions* in prompts, not harness-level invocations; skills/agents invoked without a slash mention aren't counted. Good enough for pruning signal; revisit if a harness-level signal becomes available.

---

### Task 1.2: Eval harness v1 ✅
**Description**: Create `evals/` with fixtures for the 5 highest-traffic commands. Design refinement during implementation: expectations split into **static** (load-bearing phrase, fixed-string matched — deterministic, CI-able today via `run-static.sh` called from `validate-plugin.sh`) and **behavioral** (binary assertions for the LLM runner, wired in at Phase 3).

**Acceptance Criteria**:
- [x] 3 fixtures each for monitor-pr, close, learnings, work, debug-ci — every one citing a real incident (CHANGELOG version or learnings lineage)
- [x] Runner produces deterministic TSV; baseline committed (`evals/baselines.tsv`, 25/25 static pass, 16 behavioral pending)
- [x] IMPROVEMENT.md "what the loop measures" updated: static layer gating, behavioral directional
- [x] `evals/` added to rule 5's guardrail list

**Status**: [x] Complete — 2026-08-09

**Notes**: "Top-5" chosen by incident richness (usage log has no data yet — revisit selection once it does). Static layer means CI now fails any edit that drops a phrase encoding a documented fix.

---

### Task 1.3: Harness negative test ✅ `[GATE]`
**Description**: Break a command file, run the harness, observe FAIL; restore.

**Acceptance Criteria**:
- [x] Rewrote the monitor-pr GATE phrase ("BEFORE interpreting any check results" → paraphrase) → `run-static.sh` exit 1 with `FAIL phrase missing from commands/workflows/monitor-pr.md: ...`
- [x] Restored via `git checkout --`, clean status verified, post-restore run 25/25 PASS

**Status**: [x] Complete — 2026-08-09

---

## Phase 2: Autonomous Capture

### Task 2.1: Correction-capture hook
**Description**: UserPromptSubmit hook matching high-precision correction shapes ("no,", "don't", "instead", short imperative after agent output) → append to a bounded queue (location decision: global `~/.claude/` vs per-repo, decide here). Same constraints as usage hook (silent, exit 0, opt-out).

**Acceptance Criteria**:
- [ ] Happy/no-op/malformed/opt-out paths tested like 1.1
- [ ] Precision spot-check on a week of real usage: >70% of queued items are genuine corrections
- [ ] No prompt content beyond the matched correction snippet is stored; secrets-shaped strings excluded

**Dependencies**: none (parallel to Phase 1)
**Status**: [ ] Not Started

---

## Phase 3: The Clock

### Task 3.1: `/playbook:self-improve` command
**Description**: New command encoding the autonomous weekly run per tech-plan Component 6: read IMPROVEMENT.md → gather evidence (usage log, correction queue, learnings, CHANGELOG delta) → improve-playbook analysis with gates auto-answered in writing → ONE draft PR, itemized, each change with cited evidence + eval delta + changeset. No-op week = valid outcome. Never touches rule-5 files.

**Acceptance Criteria**:
- [ ] Command passes validate-plugin (frontmatter, help.md + README rows — coverage guard will enforce)
- [ ] Two supervised runs produce mergeable draft PRs (or justified no-ops) before unattended operation
- [ ] Changeset: minor (new command)

**Dependencies**: 1.2 (eval deltas are part of the PR format), 2.1 (queue input; degrade gracefully if empty)
**Status**: [ ] Not Started

---

### Task 3.2: Scheduler wiring `[HUMAN]` + `[ACTIVATION]`
**Description**: Wire the weekly trigger (decision: Claude Code Routine vs GitHub Actions cron — decide with fresh info; both must deliver a self-contained prompt). Davis authorizes whichever mechanism from his account.

**Step-by-Step (human)**:
1. Choose mechanism (agent will present trade-offs at implementation time)
2. Authorize it (Routine creation from a session, or merge the workflow file)
3. Confirm first scheduled fire

**Activation Checklist** (the merge is not the finish line):
- [ ] Scheduler entry exists — read back from the scheduling system, not assumed
- [ ] Runtime environment has repo access + tool access (verified by a dry run FROM that environment)
- [ ] One end-to-end scheduled run produced its draft PR (or logged no-op)
- [ ] Failure visibility: where does a crashed run surface, and would silence be noticed within a week?

**Dependencies**: 3.1
**Status**: [ ] Not Started

---

## Phase 4: The Autonomy Ladder

### Task 4.1: Change-class classifier + ownership check
**Description**: CI job labeling improvement PRs by change class (paths + shape) per IMPROVEMENT.md's ladder; hard-fail any loop-authored PR touching rule-5 files.

**Acceptance Criteria**:
- [ ] Classifier labels match hand labels on the last 10 real PRs
- [ ] Ownership check negative-tested (loop-authored PR touching IMPROVEMENT.md → CI fails)

**Dependencies**: 3.1 running
**Status**: [ ] Not Started

---

### Task 4.2: Shadow mode, then auto-merge `[GATE]`
**Description**: One month of shadow mode (classifier logs what it *would* auto-merge; compare to Davis's actual merges), then enable auto-merge for the terminal class and the 72h-objection sweep for the middle classes.

**Metrics**:
| Metric | Threshold | Source | Dry-Run Query |
|---|---|---|---|
| Shadow agreement | ≥95% would-merge decisions match Davis | shadow log vs merge history | compare log to `git log main` |
| Bad-merge rate after enable | 0 reverts/month for the enabled class | CHANGELOG reverts | grep CHANGELOG |

**Acceptance Criteria**:
- [ ] Dry-run queries return non-null before the gate closes
- [ ] Ladder table in IMPROVEMENT.md updated (human-approved edit) to record the promotion

**Dependencies**: 4.1
**Status**: [ ] Not Started

---

## Phase 5: Closed Loop

### Task 5.1: Outcome metrics + auto-revert runbook
**Description**: Track corrections/session and re-learned-lessons/retro as the loop's real reward; define the auto-revert trigger (metric regression sustained N sessions after a release → revert the changeset first, debate second) and encode it in the weekly run.

**Acceptance Criteria**:
- [ ] Metrics computed from real data for 4 consecutive weeks
- [ ] One fire-drill: a revert executed end-to-end on a synthetic regression

**Dependencies**: 3.2 live, 4.2 gate closed
**Status**: [ ] Not Started

---

## Phase N: Validation & QA

### Task N.1: Guard verification sweep
**Description**: Every guard this project added has been negative-tested (0.2 ✅, 1.3, 4.1's ownership check); every instrumentation task shows a consuming query with real output (1.1 ✅, 2.1, 5.1).

**Status**: [ ] In Progress — 4 of 6 verified (0.2 budgets ✅, 1.1 instrumentation ✅, 1.2 static evals in CI ✅, 1.3 harness fire-drill ✅; pending: 2.1, 4.1, 5.1)

---

## Task Dependencies

**Critical path**: 1.2 → 1.3 → 3.1 → 3.2 → 4.1 → 4.2 → 5.1
**Parallel**: 2.1 alongside Phase 1; N.1 continuous

## Progress Tracking

### Completed
- [x] 0.1 Constitution — 2026-08-09
- [x] 0.2 Size budgets (negative-tested) — 2026-08-09
- [x] 0.3 CLAUDE.md/README pointers — 2026-08-09
- [x] 1.1 Usage instrumentation (consuming query verified) — 2026-08-09
- [x] 1.2 Eval harness v1 (static layer in CI, 25/25 baseline) — 2026-08-09
- [x] 1.3 Harness negative test — 2026-08-09

### Next Up
- [ ] 2.1 Correction capture — ready (parallel)
- [ ] 3.1 `/playbook:self-improve` command — ready (critical path)
