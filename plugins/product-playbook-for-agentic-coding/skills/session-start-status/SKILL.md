---
name: session-start-status
description: Produce a 5-bullet session-start orientation summary by reading tasks.md, recent git log, and the latest specstory tail. Run at the start of any session that resumes work on an active project. Don't use when starting a brand-new project from scratch (use /playbook:foundations or /playbook:tech-plan instead) or when a fresh checkpoint already exists (read docs/checkpoints/latest.md instead — that's higher signal).
---

# Session Start Status

## Problem

Every session starts cold. Without an orientation pass, agents re-discover the same context every time: which tasks are open, what shipped recently, what the user was last working on, what's blocked. Deep analysis of multi-week projects (Memory & Personalization Phase 1) shows agents burning **10–30K tokens per session** on re-orientation reads — and still missing context that lived in untracked files or recent specstory transcripts.

This skill collapses that work into a single fixed pass that costs predictable tokens and produces a fixed-shape summary.

## When to Use

- **Resuming work on an active project** — branch already exists, tasks.md exists, recent commits exist
- **After context compaction mid-session** — re-orient without re-reading everything
- **When the user asks "what's the status of X?" / "where were we?"** — but a `latest.md` checkpoint does NOT exist (if it does, prefer `session-checkpoint` skill)

## When NOT to Use

- Brand-new project with no tasks.md yet (use `/playbook:foundations` or `/playbook:tech-plan`)
- Session-checkpoint skill already wrote `docs/checkpoints/latest.md` — that file is higher signal
- One-shot question that doesn't depend on project state ("what's the syntax for X?")

## Process

### Inputs to Read (in order, in parallel where possible)

1. **`projects/in-progress/*/tasks.md`** (or `projects/[active-project]/tasks.md` if known) — read just the summary table and "Current Focus" section, NOT the full task details. Goal: identify in-flight task and the immediate next task.
2. **`git log --oneline -10`** on the current branch — what shipped in the last 10 commits.
3. **`git status -sb`** — uncommitted changes, branch state vs. upstream.
4. **Most recent SpecStory transcript** if any: `ls -t .specstory/history/*.md 2>/dev/null | head -1` then read the **last ~80 lines only**. Goal: capture the last user/agent exchange to anchor session continuity.
5. **CLAUDE.md "Quick Reference" section** if present — confirms test/dev/build commands haven't changed.

### Output Shape (Fixed 5 Bullets)

Emit exactly five bullets. No preamble, no closing summary, no extra prose.

```
**Session start orientation**
- **Branch & state**: [branch name] — [N commits ahead/behind] — [N uncommitted files]
- **Active task**: [Task ID + name] — [status from tasks.md] — [one-line next action]
- **Last shipped**: [most recent commit subject + date] — [what user was last asking about, from specstory tail]
- **Blockers / open questions**: [from specstory tail or "none surfaced"]
- **Suggested next step**: [single, specific action — not a menu]
```

### Discipline

- **Hard cap on input reads**: tasks.md summary table + commit log + git status + last 80 lines of one specstory file. Total budget < 3K tokens. If you find yourself wanting to read more, stop — that's the user's job to ask for.
- **Do NOT read the full tasks.md** — only the summary table at the top and the "Current Focus" section. Detail sections waste budget at orientation time.
- **Do NOT read multiple specstory files** — one is enough to anchor continuity. If the latest specstory is from days ago, say so in "Last shipped" and stop.
- **Do NOT enumerate every open task** — only the in-flight one and the suggested next.
- **Output the 5 bullets and stop.** Do not propose a plan, do not start work, do not ask for permission to start. Wait for the user.

## Why This Skill Exists

Memory & Personalization Phase 1 retrospective (2026-04-26) measured that session-start re-orientation consumed 10-30K tokens per session, every session, across a 4-week project. The 23KB initial briefing existed but was rarely re-read. Agents asked "how do I see what's been extracted?" across 3+ separate sessions because no orientation pass surfaced the answer. This skill makes the orientation cost fixed, predictable, and low.
