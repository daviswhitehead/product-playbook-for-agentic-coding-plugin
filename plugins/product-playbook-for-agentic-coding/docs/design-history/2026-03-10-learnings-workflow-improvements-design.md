# Design: Learnings Workflow Improvements

**Date**: 2026-03-10
**Status**: Approved
**Scope**: `product-playbook-for-agentic-coding` plugin — `commands/workflows/learnings.md`

## Problem

The learnings workflow treats "codebase docs" and "plugin improvements" as equal output targets, but the actual facilitation is heavily biased toward codebase improvements. Plugin/workflow improvements require the user to drive the analysis themselves — they aren't surfaced proactively, and there's no structured path from finding to plugin edit.

Specific pain points:
1. **Routing decisions are manual** — for each finding, the agent and user have to figure out which file it belongs in (CLAUDE.md? README? docs/guides? code?)
2. **Plugin improvements aren't proactively suggested** — the deep analysis looks for generic patterns (repetition, waste, frustration) but doesn't look through a "what should change about the agent's skills?" lens
3. **Promotion is per-item** — each proposed CLAUDE.md addition requires individual approval, slowing the most valuable step

## Design

### Change 1: Tagged Findings in Deep Analysis

Deep analysis agents produce structured findings with a `target` tag:

| Tag | Meaning | Routes To |
|-----|---------|-----------|
| `codebase` | Fix via documentation or code | CLAUDE.md, README, docs/, code |
| `plugin` | Fix via skill/workflow/command change | Plugin repo files |
| `both` | Needs changes in both places | Both tracks |

Each finding follows a structured format:

```
## Finding: [title]
- **Category**: repetition | wasted_effort | frustration | knowledge_gap | skill_gap
- **Target**: codebase | plugin | both
- **Evidence**: [specific quote or example from session]
- **Impact**: [estimated waste — tokens, time, user redirections]
- **Proposed fix**: [concrete action]
- **Target file** (if plugin): [skill/command path]
```

### Change 2: New Analysis Category — Skill/Workflow Gaps

Alongside the existing 4 categories (repetition, wasted effort, frustration, knowledge gaps), deep analysis agents explicitly look for a 5th:

**Skill/Workflow Gaps** — patterns that map to plugin improvements:
- Agent didn't invoke a skill that was available and relevant
- Agent used a skill but the skill's instructions were insufficient (missing step, wrong default)
- User had to redirect the agent's approach — the skill should have guided it correctly
- Agent repeated a cross-session pattern that a skill should encode
- User overrode an agent default — the skill's default should change
- Agent confabulated facts that a "verify before asserting" instruction would have prevented

### Change 3: Parallel Promotion Tracks

Step 7 (Promote Learnings) splits into two parallel tracks.

#### Track 1: Codebase Promotion

Uses a decision tree to route findings automatically:

1. Is it a gotcha that applies broadly across the project? → **CLAUDE.md**
2. Is it a pattern specific to one subsystem? → **Subsystem README or docs/guides/**
3. Is it a rule that should be enforced in code? → **Lint rule, hook, or script**
4. Is it a one-time fix? → **Just do it** (no documentation)

Presents a single batch summary ("3 to CLAUDE.md, 4 to workflows/README.md, 1 code fix") and gets one approval for the whole batch.

#### Track 2: Plugin Promotion

For each finding tagged `plugin` or `both`:

**Step A — Map to skills/commands**: Read the plugin directory structure, match each finding to the specific file that should change.

**Step B — Classify change type**:

| Type | Description | Example |
|------|-------------|---------|
| New step | Add a step to an existing workflow | "Step 0: Triage" in debug-ci |
| Default change | Change a workflow's default behavior | Deep retro as default |
| New principle | Add a rule to a workflow | "Commit checkpoint" in work.md |
| New workflow | Entirely new command needed | `/playbook:run-review` |

**Step C — Present and implement**: Batch summary, one approval, then implement all edits.

**Step D — Plugin repo discovery**: Find the plugin repo by checking CLAUDE.md/MEMORY.md first, then searching common locations (`~/.claude/plugins/`, `~/GitHub/`). Cache the path in MEMORY.md.

### Change 4: Combined Opening Questions

Collapse Steps 1+2 (trigger type + output target) into a single question to reduce round-trips at the start:

```
What type of learning moment is this?
1. End of chat session (lightweight)
2. Project completion (comprehensive)
3. Overcame a blocker (targeted)

Output defaults to "both" (codebase + plugin). Say so if you only want one.
```

This saves one round-trip. For project completions, the deep retrospective is the default (implemented earlier in this session).

## Updated Flow

```
Step 1: Identify trigger type (single question, output defaults to "both")
  ↓
Step 2-3: Locate docs, gather context
  ↓
Step 4: Standard retrospective
  ↓
Step 4.5: Deep analysis (structured findings with category + target tags)
  - 5 categories: repetition, wasted_effort, frustration, knowledge_gap, skill_gap
  ↓
Step 5: YAML frontmatter + document drafting
  ↓
Step 6: Standard vs deep comparison table
  ↓
Step 7: Parallel promotion
  ├── Track 1 (Codebase): Decision tree → batch summary → one approval → implement
  └── Track 2 (Plugin): Map to skills → classify → batch summary → one approval → implement
  ↓
Step 8: Validate completeness
```

## What Doesn't Change

- The 3 trigger types
- The standard retrospective facilitation questions
- YAML frontmatter for searchability
- Learnings document structure and location (`docs/learnings/`)
- The pre-check for validation status

## Files to Modify

| File | Change |
|------|--------|
| `commands/workflows/learnings.md` | All changes above — restructured promotion, tagged findings, 5th category, combined questions |

## Out of Scope

- Changes to other workflows (work.md, debug.md, etc. — already implemented earlier)
- Creating a separate `/playbook:improve-playbook` command (rejected approach C)
- Changes to the learnings document template structure
