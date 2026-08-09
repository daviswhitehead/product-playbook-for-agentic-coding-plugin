# Product Requirements Document

> This PRD defines the work of turning the playbook's existing, hand-operated improvement
> loop into an autonomous one. The Framing section is the heart: the core insight is that
> autonomy is not a feature to add but a set of human judgment points to *replace with
> machine verification*, one at a time, in a specific order. The Solution section is
> deliberately concrete about that order because getting it wrong (automating before
> measuring) produces the negative compound loop this document exists to avoid.

---

## Intro

### Metadata

| Field | Value |
|-------|-------|
| **Name** | Recursive Self-Improvement Loop |
| **Description** | Make the playbook repo improve itself with as little human judgment as possible, safely |
| **Priority** | P1 — the playbook is the leverage point for all of Davis's agentic work; compounding it compounds everything downstream |
| **Status** | In Progress |
| **Size** | Medium |
| **Date** | 2026-08-09 |
| **Owner** | Davis (sponsor) / autonomous agents (execution) |

### Summary

- The playbook already has every layer of the market-consensus improvement architecture (capture, session mining, gap analysis, promotion, versioning) — but every layer is manually triggered and gated on Davis's judgment.
- This project adds the three missing elements: a **clock** (scheduled runs), a **ruler** (usage data + eval fixtures), and **pruning shears** (data-fed deletion) — then removes human gates rung by rung as machine verification comes online behind each one.
- Primary metric: human interventions per shipped improvement, driven toward ~0 for low-risk change classes.
- Expected outcome: the playbook improves weekly without Davis initiating anything, with his role reduced to skimming one evidence-backed draft PR — and eventually less.

---

## Framing

### Opportunity

**The playbook only improves when Davis remembers to ask, and every improvement consumes his judgment.**

Market research (2026-08-09, see Resources) found the practice has converged: self-improving instruction repos are real ("compound engineering", claude-reflect, ACE, GEPA), and the repos that work share a structure this repo already has. What separates a *manual* loop from a *recursive* one is precisely the three pieces this repo lacks.

| Evidence | Value | Source | Implication |
|----------|-------|--------|-------------|
| Improvement commands exist but have no scheduler | 0 scheduled runs | repo inspection | Improvement frequency = Davis's memory |
| `/playbook:improve-playbook` has 5 human checkpoints | 5 gates/run | `commands/workflows/improve-playbook.md` | Throughput capped by Davis's attention |
| Command surface growth is monotonic | 40 commands, no removals in CHANGELOG | CHANGELOG.md, 51 releases | Without pruning data, bloat is unbounded |
| No instruction change has ever been eval-verified | 0 fixtures | repo inspection | Cannot distinguish improvement from accretion |
| Anthropic postmortem: tested prompt changes still regressed evals 3% | — | anthropic.com/engineering/april-23-postmortem | Even careful instruction edits need regression checks |

### Who

| Audience | Description | Why They Matter |
|----------|-------------|-----------------|
| **Primary: Davis** | Solo builder running Chef Chopsky through this playbook | Every hour not spent on playbook maintenance goes to the product |
| **Secondary: the agents** | Claude sessions in Chef Chopsky and this repo | They are the playbook's runtime users; instruction quality is their performance ceiling |

### What

**Current flow:** Davis notices friction → remembers a command exists → runs `/playbook:learnings` or `/playbook:improve-playbook` → answers 3–5 checkpoints → reviews and merges → runs release.

**Proposed flow:** Hooks log usage and capture learnings continuously → a weekly scheduled run mines the week's evidence and opens one draft PR with promotions *and* deletions, each carrying cited incidents and eval results → low-risk classes auto-merge on green CI; higher-risk classes wait 72h for objection or Davis's approval → release runs automatically after merge → regressions auto-revert by changeset.

### Why

**Strategic rationale:** Learning compounds only if capture is cheap and application is automatic. Today both cost Davis attention, so the loop runs at the rate of his spare attention rather than the rate of evidence accumulation.

**Forecast confidence:** Medium. The mechanism (more improvement cycles at lower cost) is near-certain; the magnitude of downstream benefit to Chef Chopsky velocity is not directly measurable and is inferred from correction-rate and re-learned-lesson trends.

### Hypotheses

**Primary:**
> If improvement runs on a clock with machine verification instead of on memory with human judgment, then shipped improvements per month increase ≥3x with no quality regression, because the current bottleneck is trigger frequency and gate attention — not evidence supply (sessions generate evidence daily).

**Secondary:**
> If pruning is fed by real usage data, then total instruction surface stabilizes or shrinks while coverage of actual workflows improves, because today's growth is additions-only under uncertainty about what's safe to delete.

### Success Metrics

| Metric | Definition | Target | Measurement |
|--------|------------|--------|-------------|
| **Primary:** Human interventions per shipped improvement | Approvals, redirects, manual triggers per merged improvement PR | <0.5 by Phase 4 (from ~5 today) | Count gates answered per PR |
| **Secondary:** Improvement cadence | Improvement PRs opened per month | ≥4 (one per weekly run) | GitHub PR list |
| **Secondary:** Pruning ratio | Deletion/demotion changes per 10 additions | ≥2 | CHANGELOG analysis |
| **Guardrail:** Instruction quality | Eval fixture pass rate; corrections-per-session trend | No regression vs. baseline | Eval harness (Phase 1); retro counts |
| **Guardrail:** Size budgets | CLAUDE.md/AGENTS.md ≤300 lines; components ≤1200 | 0 CI errors | `validate-plugin.sh` (now enforced) |

---

## Solution

### Vision

Within 6 months: the playbook is a system Davis *consults and occasionally vetoes* rather than one he maintains. Every week it reads its own usage, proposes its own edits with evidence, verifies them against fixtures, ships the safe ones, and queues the risky ones — and its CHANGELOG doubles as a legible audit trail of a self-improving system that has never needed an emergency rollback it couldn't perform in one changeset.

### Evolution

| Phase | What We Ship | What We Learn |
|-------|--------------|---------------|
| **0 — Constitution** | `IMPROVEMENT.md` (objective, standing rules, autonomy ladder), CI size budgets, CLAUDE.md pointer | Whether written rules change agent behavior in improvement PRs |
| **1 — The ruler** | Usage instrumentation hook; eval fixtures for top-5 commands; baseline scores | Which components actually get used; whether fixtures catch real regressions |
| **2 — Autonomous capture** | Correction-capture into a queue; session-close auto-learnings | Signal quality of automatically captured corrections |
| **3 — The clock** | Weekly scheduled run → one draft PR (promotions + deletions, evidence + eval deltas) | Whether unattended runs produce mergeable PRs |
| **4 — Autonomy ladder** | Auto-merge for low-risk classes; 72h-objection for medium | Bad-merge rate per class; when to promote rungs |
| **5 — Closed loop** | Outcome-metric tracking; auto-revert on regression | Whether the loop's *own* reward signal is trustworthy |

### Scope

#### In Scope

| Item | Notes |
|------|-------|
| Constitution + guardrail files | Phase 0 |
| Usage logging, eval fixtures, baselines | Phase 1 |
| Correction queue + auto-capture | Phase 2 |
| Weekly scheduled improvement run (draft PRs only) | Phase 3 |
| Risk-tiered auto-merge policy + implementation | Phase 4 |
| Outcome metrics + changeset-level auto-revert | Phase 5 |

#### Out of Scope

| Item | Rationale |
|------|-----------|
| Autonomous edits to guardrail files (IMPROVEMENT.md, guard scripts, workflows, fixtures) | Permanent human gate — the loop must not rewrite its own gates |
| GEPA/DSPy-style automated prompt optimization | Revisit after Phase 5; needs the eval harness at maturity first |
| Improving Chef Chopsky's own docs/rules | That's the learnings workflow's codebase track, already exists |
| Multi-user/marketplace-consumer considerations | Single-user repo today; revisit if adoption grows |

### Technical Context

**Integration Points:**
- Claude Code hooks (`hooks/hooks.json`): SessionStart exists; UserPromptSubmit added for usage logging; correction capture likely also UserPromptSubmit
- Changeset/release pipeline (`.changes/`, `scripts/release.sh`, `check-version-bump.sh`): every improvement ships through it, unchanged
- Scheduling: Claude Code Routines (cloud) or GitHub Actions cron — decision logged below
- Existing commands: `/playbook:improve-playbook` (the run's core logic), `/playbook:learnings` (autonomous-mode rules already written), `/playbook:review-playbook` (pruning rubric, now data-fed)

**Technical Constraints:**
- Hooks run for every user of the plugin: must be silent, fast, bounded, never fail the session, opt-out-able (established pattern: `session-orientation.sh`)
- UserPromptSubmit stdout is injected into context → instrumentation hooks must print nothing
- Scheduled cloud sessions start fresh: prompts must be fully self-contained
- No secrets/PII from transcripts may reach persisted instructions or logs (usage log stores command names only, never prompt content)

### Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Negative compound loop (bad rule → worse sessions → worse rules) | Med | High | Order: ruler before clock before auto-merge; eval gates; changeset-level revert |
| Instruction bloat from an eager autonomous loop | High | Med | CI size budgets (shipped, negative-tested); pruning-ratio metric; one-in-one-out |
| Weekly run produces noisy, unmergeable PRs | Med | Low | Draft-only until precision proves out; evidence citation required per change |
| Eval fixtures overfit → false confidence | Med | Med | Fixtures derived from real incidents (friction-driven, like rules); reviewed at each rung promotion |
| Loop edits its own guardrails | Low | High | IMPROVEMENT.md rule 5 + guardrail-file list; CI ownership check (Phase 4) |

---

## Decision Log

| Decision | Options Considered | Choice | Rationale | Date |
|----------|-------------------|--------|-----------|------|
| Gate autonomy per change-class, not globally | Global "autonomous mode" toggle; per-class ladder | Per-class ladder | Risk varies by orders of magnitude between a learnings doc and a CLAUDE.md edit; a global toggle forces the most conservative gate onto everything | 2026-08-09 |
| Build measurement before scheduling | Clock first (fastest to "autonomous"); ruler first | Ruler first (Phase 1 before 3) | Scheduled runs without verification = accretion at machine speed; the market's clearest failure mode | 2026-08-09 |
| Usage log stores command names only | Full prompt logging; names only | Names only | Prompts contain project content and potentially secrets; command names answer the only question asked ("what gets used?") | 2026-08-09 |
| Guardrail files permanently human-gated | Allow with extra review; permanent gate | Permanent gate | A loop that can edit its own gates has no gates; cost is near zero (these files change rarely) | 2026-08-09 |
| Improvements ship via changesets, no side channel | Direct commits for "trivial" auto-merges; changesets always | Changesets always | The version-keyed propagation bug class (content shipped at unchanged version = zero installs) is this repo's founding lesson | 2026-08-09 |
| Scheduler mechanism | Claude Code Routine; GitHub Actions cron | Deferred to Phase 3 task | Routine is richer (full session, MCP); Actions is more inspectable. Decide with fresh info at implementation; both satisfy "self-contained prompt, draft-PR output" | 2026-08-09 |

## Open Questions

**Non-blocking:** Where should eval fixtures live — `evals/` at repo root or per-command sidecar files? (Phase 1 task decides; leaning `evals/` so the guardrail list stays one directory.)

**Non-blocking:** Should the weekly run also mine Chef Chopsky's `docs/learnings/` (cross-repo read) or only this repo's evidence? (Phase 3; requires thinking about repo access from the scheduled environment.)

---

## Resources

- Research brief (market survey, tools, papers): claude.ai artifact "Recursive Repo Improvement — Research Brief", 2026-08-09
- `IMPROVEMENT.md` — the constitution this PRD mandates (shipped with Phase 0)
- Key sources: ACE (arxiv.org/abs/2510.04618), GEPA (arxiv.org/abs/2507.19457), claude-reflect (github.com/BayramAnnakov/claude-reflect), Anthropic skill-authoring best practices, compound engineering (every.to)
