---
name: playbook:critique
description: Run parallel multi-persona critiques on documents with versioning and synthesis
argument-hint: "<path> [--personas list] [--version N] [--rerun]"
recommended-mode: edit
thinking-depth: think-harder
---

# Document Critique

You are orchestrating a **parallel multi-persona critique workflow**. Multiple AI agents with distinct perspectives review documents simultaneously, then findings are synthesized into a prioritized action plan.

## Your Goal

Help the user run structured critiques of their documents by:
1. Selecting appropriate personas for the content type
2. Launching parallel critique agents
3. Synthesizing findings into P0/P1/P2 prioritized issues
4. Tracking issues across versions
5. Generating actionable tasks from findings

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (learnings, tasks)
2. **Agents**: Specialized agents via Task tool (critique personas)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools for the task at hand.

## Arguments

Parse the user's input for:
- **path** (required): Path to documents to critique (e.g., `docs/foundations/`)
- **--personas** (optional): Comma-separated list of personas (default: auto-select based on content)
- **--version** (optional): Version number for this critique (default: auto-detect next version)
- **--rerun** (optional): Re-run previous critique with incremented version
- **--output** (optional): Output directory (default: same directory as input)
- **--keep-perspectives** (optional): Keep individual persona critique files in the output directory. By default, individual perspectives are archived to `[output]/archive/` after synthesis — only the synthesis and issue tracker remain in the output directory.

## Available Personas

In addition to persona-based critique, you can run a **Devil's Advocate review** using `resources/methods/devils-advocate.md`. This is persona-independent — it pressure-tests the decision logic rather than reviewing from a stakeholder perspective.

Reference these persona definitions from `resources/personas/`:

| Persona | Best For |
|---------|----------|
| `marketing-strategist` | Messaging, positioning, competitive differentiation |
| `product-manager` | Internal consistency, requirements clarity, prioritization |
| `technical-reviewer` | Feasibility, architecture, technical accuracy |
| `domain-expert` | Domain-specific accuracy and credibility (customize for domain) |
| `investor` | Business viability, market opportunity, defensibility |

## Process

### Step 1: Setup

**1.1 Parse Arguments**

Extract path, personas, version, and options from user input.

**1.2 Discover Documents**

```bash
ls [path]/*.md
```

Report: "Found X documents to critique"

**1.3 Detect Version**

Check for existing critique files to determine version:
```bash
ls [output]/*critique*.md 2>/dev/null | grep -o 'v[0-9]*' | sort -V | tail -1
```

If `--rerun`, increment from detected version.
If `--version` specified, use that.
Otherwise, use v1 or increment from existing.

**1.4 Select Personas**

If `--personas` specified, use those.
Otherwise, recommend based on content type:
- **Product/Marketing docs**: marketing-strategist, product-manager, investor
- **Technical docs**: technical-reviewer, product-manager
- **Domain-specific docs**: domain-expert (specify domain), product-manager
- **UI/UX projects**: product-manager, technical-reviewer, **accessibility-expert** (WCAG compliance, contrast ratios, screen reader support), **design-system-architect** (token architecture, naming conventions, migration scope)
- **Styling/theming projects**: technical-reviewer, **accessibility-expert**, **design-system-architect**
- **Comprehensive**: all five personas

> **Recommendation**: The critique phase is HIGH-ROI. Always run it after PRD and tech plan — it catches issues that are expensive to fix later (e.g., WCAG failures, re-render bugs, flaky tests). For UI projects, always include accessibility-expert and design-system-architect personas.

Present selection to user:
```
📋 Critique Setup

Documents: [path] (X files)
Version: v[N]
Personas: [list]
Output: [output path]

Proceed with critique?
```

**CHECKPOINT**: Get user confirmation before launching agents.

---

### Step 2: Launch Parallel Critiques

**2.1 Launch Agents**

For each persona, launch a Task agent with:
- Persona definition (from `resources/personas/[name].md`)
- List of files to review
- Output format requirements
- Version number for file naming

Launch ALL personas in PARALLEL using multiple Task tool calls in a single message.

**2.2 Agent Instructions Template**

```
You are a [PERSONA NAME] conducting an intensive critique of [DOCUMENT SET].

## Your Perspective
[Insert persona definition from resources/personas/[name].md]

## Documents to Review
[List all .md files in the path]

## Output Format

Write your critique to: [output]/critique-v[N]-[persona-slug].md

Structure your critique as:

# [Persona Name] Critique: [Document Set] - v[N]

## Executive Summary
[2-3 sentences on overall assessment from your perspective]

## [Your Focus Area 1]
[Issues found]

## [Your Focus Area 2]
[Issues found]

## [Continue for each focus area from persona definition]

## Credibility Concerns
[Claims that feel unearned or risky]

## Specific Recommendations

### High Priority
1. [Recommendation with file reference]
2. [Recommendation with file reference]

### Medium Priority
3. [Recommendation]

### Lower Priority
4. [Recommendation]

---
*Critique by [Persona Name] - v[N] - [Date]*
```

**2.3 Wait for Completion**

Monitor all agents until complete. Report progress.

---

### Completeness Gate

Before synthesizing, verify:
- [ ] All dispatched persona agents returned results
- [ ] Any failed agents were retried or noted as gaps
- [ ] Results cover the requested scope (not just the first section of each document)

If any items are unchecked, go back and address them before continuing.

### Step 3: Synthesize Findings

**3.1 Read All Critiques**

Read each persona's critique document.

**3.2 Identify Common Themes**

Find issues flagged by multiple personas—these are highest priority.

**3.3 Prioritize Issues**

- **P0 (Must Fix)**: Flagged by 3+ personas OR any persona says "blocker"
- **P1 (Should Fix)**: Flagged by 2 personas OR high impact
- **P2 (Nice to Fix)**: Single persona, lower impact

**3.4 Generate Synthesis**

Create synthesis document using template from `resources/templates/critique-synthesis.md`:
- Write to: `[output]/critique-v[N]-synthesis.md`
- Include cross-version comparison if v2+
- Generate Launch Readiness Checklist
- Generate tasks from P0 items

**3.5 Update Issue Tracker**

If `[output]/critique-issue-tracker.md` exists:
- Update issue statuses based on new findings
- Add new issues
- Mark resolved issues as verified

If it doesn't exist and this is v1:
- Create it from `resources/templates/critique-issue-tracker.md`

---

### Step 3.6: Archive Individual Perspectives (Default Behavior)

Unless `--keep-perspectives` is specified, archive individual persona critique files after synthesis:

```bash
mkdir -p [output]/archive
mv [output]/critique-v[N]-*.md [output]/archive/ 2>/dev/null
mv [output]/archive/critique-v[N]-synthesis.md [output]/ 2>/dev/null
```

This keeps the output directory clean — only the synthesis and issue tracker remain as the primary deliverables. Individual perspectives are preserved in `archive/` for reference.

**Why this is the default**: Retrospective analysis of real projects found that individual perspective documents (often 50%+ of project doc volume) were never referenced during implementation. The synthesis captures all actionable findings. Archiving rather than deleting preserves the supporting evidence without cluttering the working directory.

---

### Step 4: Present Results

```
✅ Critique Complete: v[N]

## Summary
- Documents reviewed: X
- Personas used: [list]
- Issues found: Y total (A P0, B P1, C P2)

## P0 Issues (Must Fix)
1. [Issue 1] - flagged by [personas]
2. [Issue 2] - flagged by [personas]

## Changes from v[N-1]
- Resolved: X issues
- New: Y issues
- Persistent: Z issues

## Files Created
- [output]/critique-v[N]-synthesis.md
- [output]/critique-issue-tracker.md (created/updated)
- [output]/archive/critique-v[N]-[persona1].md (archived)
- [output]/archive/critique-v[N]-[persona2].md (archived)

## Next Steps
1. Review synthesis document
2. Implement P0 fixes (see Action Plan in synthesis)
3. Run `/playbook:critique [path] --rerun` after fixes

Would you like me to generate a tasks.md from the P0 items?
```

---

## Re-run Mode

When `--rerun` is specified:

1. Find the most recent critique version
2. Increment version number
3. Use same personas as previous run
4. Include "Changes Since Previous Version" in synthesis
5. Update issue tracker with resolution status

Example: `critique docs/foundations/ --rerun`

---

## Examples

### Basic Critique
```
/playbook:critique docs/foundations/
```
Auto-selects personas, creates v1 critique.

### Specific Personas
```
/playbook:critique docs/api-spec/ --personas technical-reviewer,product-manager
```

### Re-run After Fixes
```
/playbook:critique docs/foundations/ --rerun
```
Increments to next version, compares to previous.

### Explicit Version
```
/playbook:critique docs/foundations/ --version 3
```

### Keep Individual Perspectives
```
/playbook:critique docs/foundations/ --keep-perspectives
```
Skips archiving — all individual persona files remain in the output directory alongside the synthesis.

---

## Key Principles

### Parallel Execution
Always launch persona agents in parallel for speed. Use a single message with multiple Task tool calls.

### Version Everything
Every critique run should have a version. This enables tracking progress over iterations.

### Synthesis Over Individual Critiques
The synthesis is the primary output. Individual critiques are supporting evidence and are archived by default. Use `--keep-perspectives` if you need them in the output directory.

### Track Persistent Issues
Issues appearing in 3+ versions need dedicated resolution—they indicate a deeper problem.

### Exit Criteria Matter
Use the Launch Readiness Checklist to define "done" before starting iterations.

### Agent-Readiness Check (Product Manager Persona)
The Product Manager persona should specifically flag subjective acceptance criteria that an agent cannot verify:
- **Flag terms**: "appropriate", "premium", "feels like", "reasonable", "sufficient", "looks good", "nice"
- **Suggest replacements**: measurable criteria (e.g., "contrast ratio >= 4.5:1", "matches token surface-base", "passes axe-core with 0 violations")
- Subjective criteria lead to ambiguous sign-off and are a common source of scope creep.

---

## Error Handling

### No Documents Found
```
No .md files found at [path].

Please specify a path containing markdown documents to critique.
```

### Persona Not Found
```
Persona '[name]' not found in resources/personas/.

Available personas:
- marketing-strategist
- product-manager
- technical-reviewer
- domain-expert
- investor
```

### Agent Failure
If a persona agent fails, report which one failed and offer to:
1. Retry that persona
2. Continue with available critiques
3. Abort and investigate

---

*Run structured, multi-perspective critiques with version tracking and synthesis.*
