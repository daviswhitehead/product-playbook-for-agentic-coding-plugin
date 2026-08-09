# Tech Plan

## Project Overview
**Project Name**: Recursive Self-Improvement Loop
**Product Requirements**: [product-requirements.md](product-requirements.md)
**Date**: 2026-08-09
**Size**: Medium — balanced planning; each phase is small, the discipline is in the ordering

## Technical Architecture

### System Overview

The loop is a pipeline of five components wrapped around the repo's existing changeset/release machinery. Data flows one direction; authority flows the other:

```
 evidence (cheap, continuous)          judgment (scarce, machine-replacing-human)
 ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────┐
 │ Instrumenta- │→ │ Capture      │→ │ Weekly run   │→ │ Verification │→ │ Ship/revert│
 │ tion (hooks) │  │ (queue files)│  │ (scheduled)  │  │ (CI + evals) │  │ (changesets)│
 └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘  └────────────┘
        Phase 1          Phase 2          Phase 3          Phases 1+4        Phase 4+5
```

`IMPROVEMENT.md` (Phase 0) sits above all five: it is read by the weekly run's prompt, cited by PR reviews, and its guardrail-file list is what Phase 4's ownership check enforces.

### Core Components

**Component 1: Constitution (`IMPROVEMENT.md`)** — SHIPPED
- **Purpose**: objective function + standing rules + autonomy ladder
- **Interfaces**: referenced by CLAUDE.md; loaded by the weekly run prompt; rule 5's file list consumed by the Phase 4 ownership check

**Component 2: Size-budget guard (`scripts/validate-plugin.sh` §10)** — SHIPPED
- **Purpose**: mechanical ceiling on instruction bloat (the loop's #1 failure mode)
- **Key detail**: thresholds env-overridable → negative-testable; defaults changeable only by human PR (rule 5)

**Component 3: Usage instrumentation (`scripts/log-playbook-usage.sh`)** — SHIPPED
- **Purpose**: ground truth for pruning and prioritization
- **Interfaces**: UserPromptSubmit hook → `~/.claude/playbook-usage.log` (TSV: timestamp, command, repo). Consumers: `/playbook:review-playbook`, weekly run
- **Constraints honored**: silent (UserPromptSubmit stdout injects into context), bounded (1 MB self-truncation), never fails session, no prompt content stored, `PLAYBOOK_NO_USAGE_LOG=1` opt-out

**Component 4: Eval harness (`evals/`)**
- **Purpose**: regression + improvement verification for instruction changes
- **Design**: per-command fixture dirs (`evals/<command>/NN-<scenario>.md`) each defining: input context, the situation, and 3–8 assertable expectations ("the workflow asks for X before Y", "the guard step is present"). Runner = a Claude session (or subagent fan-out) that role-plays each fixture against the command file and scores expectations; output = TSV scores committed as `evals/baselines.tsv`
- **Why not promptfoo first**: fixtures-as-markdown keeps authorship inside the loop's own toolchain and needs no new dependency; promptfoo can wrap the same fixtures later if CI-grade rigor is needed
- **Fixture sourcing rule**: fixtures are friction-driven like rules — each derives from a real incident (learnings docs are the seed corpus)

**Component 5: Correction queue (`.captures/` or extended usage hook)**
- **Purpose**: catch "no, do X" moments at occurrence, the highest-signal learning source
- **Design sketch**: UserPromptSubmit hook matching correction shapes (short imperative after agent output; "no," / "don't" / "instead" openers) appends candidates to a queue file with timestamp + matched text (bounded, opt-out, same constraints as Component 3). Weekly run triages the queue; precision tuning expected — start high-precision/low-recall
- **Open detail**: whether queue lives per-repo (`.captures/`, gitignored) or in `~/.claude/` (global). Decide in task; leaning global to match the usage log

**Component 6: Weekly run (scheduler + runbook command)**
- **Purpose**: the clock
- **Design**: a new `/playbook:self-improve` command encoding the run: read IMPROVEMENT.md → gather week's evidence (usage log, correction queue, learnings docs, CHANGELOG since last run) → run improve-playbook's analysis autonomously (its checkpoint gates auto-answered in writing, per learnings.md's autonomous-invocation rules) → emit ONE draft PR: itemized changes, each with cited evidence + eval delta + changeset. Scheduler (Routine vs Actions cron) invokes it with a self-contained prompt
- **Hard rules**: draft PR only; never touches rule-5 files; if evidence is thin, opens nothing (a no-op week is a valid outcome, logged in the PR-less run summary)

**Component 7: Autonomy ladder enforcement**
- **Purpose**: let low-risk classes merge without Davis
- **Design**: PR classifier (paths + change shape → change-class label) + branch-protection-compatible auto-merge for the terminal class; a scheduled 72h sweep merges "objection-window" PRs whose window expired with CI+evals green. Ownership check: CI job fails any PR authored by the loop's bot identity that touches a rule-5 file

### Data Models

- **Usage log**: TSV `timestamp \t command \t repo` — append-only, self-truncating
- **Eval fixture**: markdown with frontmatter (`command`, `incident` citation, `expectations[]`)
- **Baselines**: TSV `fixture \t pass|fail \t date \t model`
- **Correction queue**: TSV or JSONL `timestamp \t repo \t matched-snippet`

## Sequencing

**Phase 0 → 1 → 2 → 3 → 4 → 5, strictly.** The ordering is the design: each phase builds the verification the next phase's autonomy spends. Within phases, tasks parallelize freely.

**Critical path**: eval harness (1.2) → weekly run (3.x) → auto-merge (4.x). Usage logging, correction capture, and outcome metrics hang off the path and can slip without blocking it.

## PR Strategy

| PR | Phase | Description |
|----|-------|-------------|
| 1 | 0 + 1a | Constitution, size budgets, usage hook, pipeline docs (this PR) |
| 2 | 1b | `evals/` harness + top-5 fixtures + baselines |
| 3 | 2 | Correction capture hook |
| 4 | 3 | `/playbook:self-improve` command + scheduler wiring + activation verification |
| 5 | 4 | Classifier + auto-merge + ownership check |
| 6 | 5 | Outcome metrics + auto-revert runbook |

Each PR is independently shippable and carries its own changeset. Review cadence: per-PR (Davis) through PR 4; PR 5 is the one that starts removing him.

## Testing Strategy

- **Scripts**: negative-test every guard (both directions) — repo standing rule. Size budgets: done (env-override → observed failing). Hooks: tested happy/no-op/malformed/opt-out paths
- **Eval harness**: the harness tests itself — a deliberately broken command edit must fail its fixture before the harness is trusted (harness negative test, task 1.3)
- **Weekly run**: first two runs execute supervised (Davis watches the PR get built) before unattended operation
- **Auto-merge**: first month runs in "shadow mode" — classifier labels and logs what it *would* have merged; compare against Davis's actual decisions before enabling

## Technical Risks

**Risk 1: Correction-capture precision too low (noise floods the queue)**
- Mitigation: start high-precision patterns only; weekly run reports queue precision; recall can grow later

**Risk 2: Eval runner is itself an LLM → nondeterministic scores**
- Mitigation: expectations written as binary, assertable checks; 2-of-3 majority on disagreement; drift tracked in baselines.tsv

**Risk 3: Scheduled environment lacks repo/tool access (activation failure)**
- Mitigation: tasks.md includes a mandatory `[ACTIVATION]` task with runtime-environment verification — the repo's 5-incident cron lesson

## Architectural Decisions

**Decision: fixtures-as-markdown + LLM runner over promptfoo (initially)**
- Context: need evals fast, with authorship the loop itself can do
- Rationale: zero new dependencies; fixtures double as documentation; promptfoo wrap later if needed

**Decision: new `/playbook:self-improve` command rather than parameterizing improve-playbook**
- Context: improve-playbook is interactive-first with 5 checkpoints
- Rationale: the autonomous run has different invariants (no gates, draft-only, rule-5 awareness, no-op weeks valid); entangling them risks degrading the interactive path. improve-playbook remains the shared analysis core the new command invokes

---

*This document focuses on How — planning the technical approach and implementation order.*
