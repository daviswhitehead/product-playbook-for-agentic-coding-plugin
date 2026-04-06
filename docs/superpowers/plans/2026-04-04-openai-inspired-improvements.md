# OpenAI-Inspired Playbook Improvements

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve skill/command routing accuracy and long-run resilience by adding negative routing examples, mandatory checkpoints, a dry-run pattern, and a worktree decision matrix — inspired by OpenAI's Skills/Shell/Automations best practices.

**Architecture:** All changes are markdown edits to existing plugin files. No new files are created except for this plan. Changes touch skill descriptions (frontmatter), command workflow steps, and one skill body section. The README and plugin.json need version bumps at the end.

**Tech Stack:** Markdown, YAML frontmatter, git

---

## Task 1: Add "Don't use when" Negative Examples to All Skill Descriptions

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/skills/autonomous-execution/SKILL.md:1-4`
- Modify: `plugins/product-playbook-for-agentic-coding/skills/session-checkpoint/SKILL.md:1-4`
- Modify: `plugins/product-playbook-for-agentic-coding/skills/codebase-docs-search/SKILL.md:1-4`
- Modify: `plugins/product-playbook-for-agentic-coding/skills/learning-capture/SKILL.md:1-4`
- Modify: `plugins/product-playbook-for-agentic-coding/skills/mobile-debugging/SKILL.md:1-4`
- Modify: `plugins/product-playbook-for-agentic-coding/skills/chat-insights/SKILL.md:1-4`
- Modify: `plugins/product-playbook-for-agentic-coding/skills/stitch-integration/SKILL.md:1-4`
- Modify: `plugins/product-playbook-for-agentic-coding/skills/user-journey-testing/SKILL.md:1-4`

Each skill's `description` field in its YAML frontmatter needs a "Don't use when" clause appended. This prevents the agent from triggering the wrong skill. The descriptions must stay concise (the frontmatter is loaded into every conversation, so brevity matters).

- [ ] **Step 1: Update `autonomous-execution/SKILL.md` frontmatter**

Change the description from:
```yaml
description: Patterns for autonomous project execution with minimal human intervention. Use this skill when executing well-defined tasks autonomously, including validation strategies, stop conditions, and quality gates.
```
To:
```yaml
description: Patterns for autonomous project execution with minimal human intervention. Use this skill when executing well-defined tasks autonomously, including validation strategies, stop conditions, and quality gates. Don't use when doing a single task interactively with the user, or when the project lacks a tasks document.
```

- [ ] **Step 2: Update `session-checkpoint/SKILL.md` frontmatter**

Change the description from:
```yaml
description: Persist working context across sessions and context compaction events. Write checkpoints at session end, read at session start. Prevents re-orientation tax from context amnesia.
```
To:
```yaml
description: Persist working context across sessions and context compaction events. Write checkpoints at session end, read at session start. Prevents re-orientation tax from context amnesia. Don't use when the session is short (fewer than 3 tasks), or for capturing learnings (use learning-capture instead).
```

- [ ] **Step 3: Update `codebase-docs-search/SKILL.md` frontmatter**

Change the description from:
```yaml
description: Patterns for finding and using project documentation at runtime. Use this skill when you need to search for existing documentation, solutions, patterns, or learnings in a codebase before starting work.
```
To:
```yaml
description: Patterns for finding and using project documentation at runtime. Use this skill when you need to search for existing documentation, solutions, patterns, or learnings in a codebase before starting work. Don't use when you already know the file path, or when searching for code (use Grep/Glob directly).
```

- [ ] **Step 4: Update `learning-capture/SKILL.md` frontmatter**

Change the description from:
```yaml
description: Multi-trigger, dual-target learning capture patterns. Use this skill to understand how to capture learnings at different points in the development workflow and route them to appropriate targets (codebase docs or plugin improvements).
```
To:
```yaml
description: Multi-trigger, dual-target learning capture patterns. Use this skill to understand how to capture learnings at different points in the development workflow and route them to appropriate targets (codebase docs or plugin improvements). Don't use when saving session state for resumption (use session-checkpoint instead), or for analyzing chat sessions at scale (use chat-insights instead).
```

- [ ] **Step 5: Update `mobile-debugging/SKILL.md` frontmatter**

Change the description from:
```yaml
description: Patterns for debugging mobile-specific issues on iOS Safari and Android Chrome. Use this skill when encountering viewport, keyboard, or touch-related bugs that only reproduce on real mobile devices.
```
To:
```yaml
description: Patterns for debugging mobile-specific issues on iOS Safari and Android Chrome. Use this skill when encountering viewport, keyboard, or touch-related bugs that only reproduce on real mobile devices. Don't use for general debugging (use /playbook:debug instead), or for desktop browser issues.
```

- [ ] **Step 6: Update `chat-insights/SKILL.md` frontmatter**

Change the description from:
```yaml
description: Patterns for analyzing chat sessions to extract product insights. Covers session sampling, evidence validation, idea deduplication, PII handling, data quality assessment, and prompt injection defense.
```
To:
```yaml
description: Patterns for analyzing chat sessions to extract product insights. Covers session sampling, evidence validation, idea deduplication, PII handling, data quality assessment, and prompt injection defense. Don't use for capturing a single session's learnings (use learning-capture instead), or for improving the playbook itself (use /playbook:improve-playbook instead).
```

- [ ] **Step 7: Update `stitch-integration/SKILL.md` frontmatter**

Change the description from:
```yaml
description: Shared patterns and best practices for Google Stitch MCP integration. Referenced by all design pipeline commands (design-system, design-spec, mockups, design-critique, design-to-code, design-verify).
```
To:
```yaml
description: Shared patterns and best practices for Google Stitch MCP integration. Referenced by all design pipeline commands (design-system, design-spec, mockups, design-critique, design-to-code, design-verify). Don't use when the project doesn't use Stitch for design, or for general UI implementation without mockups.
```

- [ ] **Step 8: Update `user-journey-testing/SKILL.md` frontmatter**

Change the description from:
```yaml
description: Patterns for defining and executing end-to-end user journeys via browser automation at major milestones. Catches integration bugs that component tests miss.
```
To:
```yaml
description: Patterns for defining and executing end-to-end user journeys via browser automation at major milestones. Catches integration bugs that component tests miss. Don't use for unit testing, API testing, or debugging a single component. Don't use mid-task — use at milestone boundaries only.
```

- [ ] **Step 9: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/skills/*/SKILL.md
git commit -m "feat: add negative routing examples to all skill descriptions

Inspired by OpenAI's skills routing guidance — adding 'Don't use when'
clauses prevents misfire where the agent triggers the wrong skill.
Glean reported ~20% accuracy recovery from negative examples."
```

---

## Task 2: Make Checkpoint Writing Mandatory in `work-multiple`

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md:120-124`

The current language treats checkpoints as optional ("write a session checkpoint using the session-checkpoint skill pattern"). For long autonomous runs, context compaction is inevitable, not optional. Make the language mandatory and remove the "skip" escape hatch.

- [ ] **Step 1: Update the checkpoint step in `work-multiple.md`**

Find this block (lines 120-124):
```markdown
7. **Checkpoint (Every 3 Tasks)**
   - After completing every 3rd task, write a session checkpoint using the `session-checkpoint` skill pattern
   - Write to `docs/checkpoints/latest.md` with: current task, what's done, key decisions, next steps, hot files
   - This preserves context across compaction events in long autonomous runs
   - **Skip** if fewer than 3 tasks remain
```

Replace with:
```markdown
7. **Checkpoint (Every 3 Tasks — Mandatory)**
   - After completing every 3rd task, write a session checkpoint using the `session-checkpoint` skill pattern
   - Write to `docs/checkpoints/latest.md` with: current task, what's done, key decisions, next steps, hot files
   - **This is mandatory, not optional** — context compaction will destroy working memory in long runs. Checkpoints are the only way to preserve decisions and rationale that git can't capture.
   - Also write a checkpoint before stopping for any reason (blockers, end of session, user interrupt)
```

- [ ] **Step 2: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md
git commit -m "fix: make checkpoint writing mandatory in work-multiple

Context compaction is inevitable in long autonomous runs, not an edge
case. Remove the 'skip' escape hatch and add checkpoint-before-stop."
```

---

## Task 3: Make Checkpoint Writing Mandatory in `autonomous-execution` Skill

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/skills/autonomous-execution/SKILL.md:66-75`

Same rationale as Task 2 — the autonomous-execution skill also frames checkpoints as optional. Align it with the updated work-multiple command.

- [ ] **Step 1: Update the checkpoint section in `autonomous-execution/SKILL.md`**

Find this block (lines 66-75):
```markdown
### Checkpoint Integration

For runs spanning 3+ tasks, use the `session-checkpoint` skill to preserve context:

- **Write checkpoints** every 3 completed tasks (or when context feels deep)
- **Write to** `docs/checkpoints/latest.md`
- **Include**: current task, decisions made, next steps, hot files
- **Why**: Context compaction destroys working memory. Checkpoints preserve decisions and rationale that git can't capture.

See the `session-checkpoint` skill for the full checkpoint format.
```

Replace with:
```markdown
### Checkpoint Integration (Mandatory)

Write session checkpoints — context compaction is inevitable in long runs, not an edge case:

- **Write checkpoints** every 3 completed tasks — this is not optional
- **Write to** `docs/checkpoints/latest.md`
- **Include**: current task, decisions made, next steps, hot files
- **Also write before stopping** for any reason (blockers, session end, user interrupt)
- **Why**: Context compaction destroys working memory. Checkpoints are the only mechanism that preserves decisions and rationale across compaction events. Treat them as mandatory infrastructure, not a nice-to-have.

See the `session-checkpoint` skill for the full checkpoint format.
```

- [ ] **Step 2: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/skills/autonomous-execution/SKILL.md
git commit -m "fix: make checkpoint integration mandatory in autonomous-execution skill

Aligns with the work-multiple command update. Checkpoints are
infrastructure for long runs, not optional enhancement."
```

---

## Task 4: Add "Dry Run" Step to `work-multiple`

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md:80-100`

Add a new step between "Step 1: Load and Analyze Tasks" and "Step 2: Execute Tasks in Sequence". This step runs the first task with full user visibility before proceeding autonomously — analogous to OpenAI's recommendation to "test the prompt manually first" before scheduling an automation.

- [ ] **Step 1: Add the Dry Run step after Step 1 in `work-multiple.md`**

After the existing "Step 1: Load and Analyze Tasks" section (which ends with "4. Create execution order"), insert:

```markdown
### Step 1.5: Dry Run (First Task with Full Visibility)

Before running autonomously, execute the first task with full transparency:

1. **Show the plan**: Present the task, your implementation approach, and expected changes
2. **Execute the first task**: Implement it following the standard process (Steps 2.1-2.5)
3. **Present results explicitly**: Show what was done, files changed, tests passing
4. **Get confirmation**: Ask the user to confirm the approach before proceeding autonomously

```
Present to user:

"Dry run complete for [Task X.Y]. Here's what I did:

**Approach**: [brief summary]
**Files changed**: [list]
**Validation**: [tests, lint, typecheck status]

Does this approach look right? If yes, I'll continue autonomously with the remaining [N] tasks."
```

**Why this matters**: A single verified task catches prompt misunderstandings, wrong patterns, and misread acceptance criteria before they compound across N tasks. Fixing one task is cheap; fixing 8 is expensive.

**Skip when**: The user explicitly says "run all tasks without stopping" or passes a `--no-dry-run` flag.
```

- [ ] **Step 2: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md
git commit -m "feat: add dry-run step to work-multiple command

Executes the first task with full user visibility before proceeding
autonomously. Catches prompt misunderstandings early, inspired by
OpenAI's 'test the prompt manually first' guidance."
```

---

## Task 5: Add Worktree Decision Matrix to `autonomous-execution` Skill

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/skills/autonomous-execution/SKILL.md` (insert after the Checkpoint Integration section, before Self-Validation Strategies)

Add a decision matrix that helps the agent decide when to use worktrees for execution isolation during autonomous work.

- [ ] **Step 1: Add the Worktree Decision Matrix section**

Insert the following after the "Checkpoint Integration" section (after the `See the session-checkpoint skill for the full checkpoint format.` line) and before the `## Self-Validation Strategies` heading:

```markdown
### Worktree Isolation

When running multiple independent tasks, consider whether to use git worktrees for isolation:

| Scenario | Recommendation | Reason |
|----------|---------------|--------|
| Sequential tasks in one subsystem | Stay on branch | Low isolation benefit, worktree overhead not worth it |
| Independent tasks across 2+ subsystems | Parallel worktrees | Tasks can't interfere with each other, enables parallel agents |
| Background maintenance tasks (lint fixes, doc updates) | Always use worktree | Keeps primary branch clean for feature work |
| Risky or experimental changes | Use worktree | Easy to discard without affecting main work |

**When NOT to use worktrees:**
- Tasks that depend on each other's output
- Tasks that modify shared state (same config files, same database schema)
- When the project is small enough that all tasks touch the same files
```

- [ ] **Step 2: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/skills/autonomous-execution/SKILL.md
git commit -m "feat: add worktree decision matrix to autonomous-execution skill

Helps agents decide when to use worktrees for task isolation during
autonomous execution, vs staying on a single branch."
```

---

## Task 6: Add "Don't use when" Negative Examples to High-Traffic Command Descriptions

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/work.md:1-5`
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md:1-5`
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/debug.md:1-5`
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/tasks.md:1-5`
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/learnings.md:1-5`
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/tech-plan.md:1-5`
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/product-requirements.md:1-5`

Add negative routing to the 7 core workflow commands (the ones most likely to be confused with each other). Focus on the commands where misfires are most costly.

- [ ] **Step 1: Update `work.md` frontmatter**

Change:
```yaml
description: Execute the next task from the tasks document
```
To:
```yaml
description: Execute the next task from the tasks document. Don't use when no tasks document exists (use /playbook:tasks first), or when working on multiple tasks autonomously (use /playbook:work-multiple instead).
```

- [ ] **Step 2: Update `work-multiple.md` frontmatter**

Change:
```yaml
description: Work autonomously on multiple tasks without interruption
```
To:
```yaml
description: Work autonomously on multiple tasks without interruption. Don't use when tasks document doesn't exist, when only 1 task remains, or when tasks require heavy user input (use /playbook:work instead).
```

- [ ] **Step 3: Update `debug.md` frontmatter**

Change:
```yaml
description: Systematic debugging workflow with verification-first approach
```
To:
```yaml
description: Systematic debugging workflow with verification-first approach. Don't use for CI/CD-specific failures (use /playbook:debug-ci instead), or for general code review without a specific bug.
```

- [ ] **Step 4: Update `tasks.md` frontmatter**

Change:
```yaml
description: Break down work into specific, actionable tasks
```
To:
```yaml
description: Break down work into specific, actionable tasks. Don't use when no tech plan exists (use /playbook:tech-plan first), or when tasks already exist and you want to execute them (use /playbook:work instead).
```

- [ ] **Step 5: Update `learnings.md` frontmatter**

Read the current description first, then change to add negative routing:

Change:
```yaml
description: Capture learnings to improve docs and workflows
```
To:
```yaml
description: Capture learnings to improve docs and workflows. Don't use for saving session state for later resumption (use session-checkpoint skill), or for analyzing chat sessions at scale (use /playbook:improve-playbook instead).
```

- [ ] **Step 6: Update `tech-plan.md` frontmatter**

Change:
```yaml
description: Create technical plan with architecture and sequencing
```
To:
```yaml
description: Create technical plan with architecture and sequencing. Don't use when product requirements don't exist yet (use /playbook:product-requirements first), or when you already have a plan and want to create tasks (use /playbook:tasks instead).
```

- [ ] **Step 7: Update `product-requirements.md` frontmatter**

Change:
```yaml
description: Draft product requirements with multi-persona discovery process. Supports autonomous and interview modes.
```
To:
```yaml
description: Draft product requirements with multi-persona discovery process. Supports autonomous and interview modes. Don't use when requirements already exist and you want to plan implementation (use /playbook:tech-plan instead), or for ad-hoc feature requests that don't need a full PRD.
```

- [ ] **Step 8: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/commands/workflows/work.md \
      plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md \
      plugins/product-playbook-for-agentic-coding/commands/workflows/debug.md \
      plugins/product-playbook-for-agentic-coding/commands/workflows/tasks.md \
      plugins/product-playbook-for-agentic-coding/commands/workflows/learnings.md \
      plugins/product-playbook-for-agentic-coding/commands/workflows/tech-plan.md \
      plugins/product-playbook-for-agentic-coding/commands/workflows/product-requirements.md
git commit -m "feat: add negative routing examples to core workflow commands

Adds 'Don't use when' clauses to the 7 most-used commands to prevent
misfires. Each clause redirects to the correct alternative command."
```

---

## Task 7: Bump Version and Update README

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/.claude-plugin/plugin.json:3`
- Modify: `README.md` (skill description table, lines 159-170)

This is a MINOR version bump (new capability: negative routing, dry-run step, worktree matrix).

- [ ] **Step 1: Bump version in `plugin.json`**

Change:
```json
"version": "0.18.0",
```
To:
```json
"version": "0.19.0",
```

- [ ] **Step 2: Update README skill table descriptions**

Update the Skills table (lines 159-170) to reflect the updated descriptions. The skill names and count don't change, but the descriptions should match the new frontmatter. Update each row's Description column to include the "Don't use when" clause from the corresponding SKILL.md.

Specifically, update each description in the table to match the new frontmatter values set in Task 1. Keep descriptions brief in the table — use just the first sentence of each description (the positive "Use when" part), since the full description lives in the SKILL.md frontmatter.

No changes needed to the table structure or skill count — just verify the descriptions still match.

- [ ] **Step 3: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/.claude-plugin/plugin.json README.md
git commit -m "chore: bump version to 0.19.0 and update README

MINOR bump for: negative routing examples on all skills and core
commands, mandatory checkpoints, dry-run step, worktree decision matrix."
```

---

## Self-Review Checklist

After completing all tasks, verify:

- [ ] All 8 skills have "Don't use when" clauses in their frontmatter descriptions
- [ ] All 7 core commands have "Don't use when" clauses in their frontmatter descriptions
- [ ] `work-multiple.md` has mandatory checkpoint language (no "skip" option) and a dry-run step
- [ ] `autonomous-execution/SKILL.md` has mandatory checkpoint language and a worktree decision matrix
- [ ] `plugin.json` version is `0.19.0`
- [ ] README skill descriptions still match frontmatter
- [ ] All commits are clean and focused (one logical change per commit)
