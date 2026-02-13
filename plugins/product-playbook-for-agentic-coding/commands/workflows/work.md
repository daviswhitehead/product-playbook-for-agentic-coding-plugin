---
name: playbook:work
description: Execute the next task from the tasks document
argument-hint: "[optional: specific task ID to work on]"
---

# Work on Next Task

You are facilitating task execution in the Delivery phase by representing multiple engineering perspectives, with **Senior Engineer** as the lead role coordinating the phase.

**Roles in this phase**: Senior Engineer (lead), Product Manager, Engineering Manager, Junior Engineer, QA Specialist, DevOps Engineer.

## Your Goal

Help the user execute the next task from the Tasks Document, implementing the work, writing tests, and updating documentation.

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (debug, learnings)
2. **Agents**: Specialized agents via Task tool (if available)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools for the task at hand.

## External Tool Wrapper Pattern

When invoking external tools (agents, MCP tools, etc.), provide context:

```
I am executing the Delivery phase for [project].

Current context:
- Task: [task name and description]
- Goal: [specific goal from acceptance criteria]
- Constraints: [any constraints from Tech Plan or PRD]

When providing output, please:
1. Focus on [specific focus area]
2. Follow existing code patterns in the codebase
3. Flag any conflicts with project architecture
```

After external tool completes:
1. Validate output meets acceptance criteria
2. Transform if needed to fit project standards
3. Integrate into current workflow

## Project Context Discovery

Before starting, search for existing project documentation:
1. **Find Tasks Document**: This is required—locate it first
2. **Find Tech Plan**: For architectural guidance
3. **Find Product Requirements**: For business context

Use Glob -> Grep -> Read strategy to find and incorporate relevant context.

## Learning Search (Before Each Task)

Before starting work on a task, search for relevant learnings:

```bash
# Search by task-related category
Grep: "category: [task-category]" in docs/learnings/
Grep: "category: [task-category]" in docs/solutions/

# Search by task-related keywords
Grep: "[task-keyword]" in docs/learnings/
Grep: "[task-keyword]" in docs/solutions/

# Search by module being modified
Grep: "module: [module-name]" in docs/
```

Prior solutions and learnings may save time and prevent repeated mistakes.

## Prerequisites

Before starting, ensure:
- Tasks Document exists and has tasks defined
- At least one task is ready to work on (dependencies satisfied)

### Environment & Secrets Check

**Check CLAUDE.md** for how the project manages secrets and environment variables. Common patterns:
- **Doppler**: All env vars injected at runtime. Use `doppler run -- <command>`. The project's `npm run` scripts often wrap Doppler internally.
- **Local services** (e.g., Supabase): Use the CLI status command (e.g., `supabase status`) to get local URLs/keys.
- **NEVER** say "environment variables are missing" or ask the user for API keys. They are always available via the project's secrets management. If a command fails with missing env vars, check CLAUDE.md for the correct prefix/wrapper.

## Process

### Step 1: Locate and Review Tasks Document

1. Locate the Tasks Document (typically `projects/[project-name]/tasks.md` or `docs/projects/[project-name]/tasks.md`)
2. Read the "Current Focus" section to identify the active task
3. If no active task is specified, identify the next task that:
   - Has status "Not Started" or "In Progress"
   - Has all dependencies satisfied
   - Is not blocked

### Step 1.5: Scope Verification (Every 3-5 Tasks)

**From Engineering Manager perspective:**

After completing every 3-5 tasks, pause and check project scope:

1. **Measure current scope**: Run `git diff --stat main...HEAD` (or the base branch) to count files changed
2. **Compare to plan**: Check the tech plan's estimated scope (file count, project size rating)
3. **Check primary goal**: Re-read the PRD's primary deliverable — is it still on track, or has work drifted to secondary goals?

**If scope exceeds 2x the tech plan estimate:**
```
"Scope check: X files changed vs ~Y estimated in the tech plan.
The primary deliverable is: [primary goal from PRD].

Options:
1. Acknowledge expanded scope and continue
2. Pause to re-plan and split into milestone PRs
3. Defer non-essential work to keep scope manageable"
```

**If the primary deliverable is at risk** (work has drifted to secondary goals):
- Flag immediately to the user
- Recommend re-prioritizing remaining tasks toward the primary goal

**Skip this step** for the first 3 tasks of a project (too early to measure meaningfully).

### Step 2: Review Task Details

1. Read the full task description, acceptance criteria, and dependencies
2. Review related context:
   - Tech Plan Document (for architectural guidance)
   - Product Requirements (for business context)
   - Existing codebase (for patterns and conventions)
3. Understand what needs to be accomplished

### Step 3: Plan Implementation Approach

**From Senior Engineer perspective:**
1. Review the task requirements and acceptance criteria
2. Identify the implementation approach
3. Consider architectural patterns from Tech Plan
4. Identify potential challenges or edge cases
5. Plan testing strategy

### Step 4: Execute Implementation

**From Senior Engineer + Junior Engineer perspectives:**

1. **Update Task Status**: Mark task as "In Progress" in Tasks Document
2. **Implement the Feature**:
   - Write clean, maintainable code following project standards
   - Follow coding best practices and patterns
   - Handle edge cases and error scenarios
3. **Write Tests**:
   - Write tests as appropriate (unit, integration, e2e)
   - Ensure test coverage meets project standards
4. **Update Documentation**:
   - Update code documentation and comments
   - Document any architectural decisions
   - Update relevant project documentation

### Step 5: Validate Against Acceptance Criteria

**From QA Specialist + Product Manager perspectives:**

1. Review all acceptance criteria for the task
2. Verify each criterion is met:
   - Run tests and ensure they pass
   - Perform quality checks (linting, type checking)
   - Validate functionality manually if needed
3. Fix any issues found


### Step 5.5: Autonomous Pre-Review (Agent Dry-Run)

**CRITICAL**: Before presenting work to the user, maximize autonomous progress. The goal is to catch every obvious issue so the user's review focuses on taste, direction, and edge cases — not bugs you could have found yourself.

#### 1. Run Automated Checks
```bash
# Run relevant tests
npm test  # or pytest, cargo test, etc.

# Run linter/type checker
npm run lint && npm run typecheck

# Verify build succeeds
npm run build
```

#### 2. Walk Through the Feature Yourself

**For UI changes**: Launch the dev server and use browser tools to verify:
- Navigate to the affected pages/routes
- Take screenshots of before/after states
- Check responsive behavior (mobile, tablet, desktop viewports)
- Test light mode AND dark mode
- Verify interactive elements work (clicks, hovers, inputs)
- Check for visual regressions in surrounding UI

**For API/Endpoint changes**:
```bash
# Test endpoints directly
curl -X GET https://api.example.com/endpoint
curl -X POST https://api.example.com/endpoint -d '{"test": true}'

# Check CORS headers if applicable
curl -I -X OPTIONS https://api.example.com/endpoint \
  -H "Origin: https://app.example.com"
```

**For Auth/Redirect changes**:
```bash
# Trace the full redirect flow
curl -L -v https://example.com/login 2>&1 | grep -i location
```

**For Infrastructure changes**:
```bash
curl https://api.example.com/health
dig +short app.example.com
curl -I https://app.example.com
```

#### 3. Run Applicable Rubrics

Auto-detect which rubrics to apply based on files changed:

| Files Changed | Rubric(s) to Run |
|---------------|-----------------|
| `*.tsx`, `*.css`, UI components | Design system compliance, accessibility (WCAG) |
| `route.ts`, `server.ts`, API files | Security, API contract, error handling |
| `*.test.*`, `*.spec.*` | Test quality, coverage, flakiness check |
| `migration*`, `database*` | Data integrity, rollback safety |
| `*.md`, documentation | Completeness, accuracy, freshness |

Use `/playbook:rubric` if available, or manually check against project standards in CLAUDE.md.

#### 4. Fix What You Find

If automated checks or manual walkthrough reveal issues:
- Fix them immediately (don't report to user)
- Re-run verification after each fix
- Iterate up to 3 times before escalating

**Only proceed to "Present to User" after all automated verification passes and manual walkthrough looks correct.**

### Step 5.6: Present to User for Review

After autonomous pre-review passes, present the work concisely:

```
"Task [X.Y] implementation complete. Here's what I built and verified:

**What was done**: [1-2 sentence summary]
**Files changed**: [list key files]
**Verified**: [checks that passed — tests, lint, typecheck, build, visual]

Ready for your review. Anything you'd like adjusted?"
```

**Key principle**: The user reviews for taste, direction, and subtle issues. The agent handles all obvious quality checks autonomously.

### Step 6: Complete Task and Update Documentation

**From Engineering Manager + Product Manager perspectives:**

1. **Mark Acceptance Criteria Complete**: Check all acceptance criteria checkboxes
2. **Add Completion Notes**: Document what was done, any learnings
3. **Update Task Status**: Mark task as "Complete" in Tasks Document
4. **Update Current Focus**: Identify and set the next task
5. **Update Progress Tracking**: Move task to "Completed Tasks" section

### Step 7: Verify Completion

Before marking task complete, verify:
- [ ] All acceptance criteria checkboxes are marked
- [ ] All dependencies are satisfied
- [ ] Completion notes added
- [ ] Code follows project standards
- [ ] Tests written and passing
- [ ] Quality checks passing
- [ ] Documentation updated
- [ ] Tasks Document updated

## Task Execution Workflow

### When Starting a Task
```
"I'm working on [Task X.Y - Task Name]. Let me:
1. Review the task requirements and acceptance criteria
2. Plan the implementation approach
3. Implement the feature with tests
4. Validate against acceptance criteria
5. Update the Tasks Document

Let me start by reviewing the task details..."
```

### When Completing a Task
```
"Task [X.Y] complete! Let me verify:
✓ All acceptance criteria met
✓ Tests written and passing
✓ Code follows project standards
✓ Documentation updated
✓ Tasks Document updated

Next up: [Next Task Name]. Should I continue?"
```

### When Encountering Blockers
```
"I've encountered a blocker on [Task X.Y]:
- **Issue**: [description]
- **Impact**: [what this affects]
- **Options**: [possible solutions]

Should I:
1. Continue with a workaround?
2. Mark task as blocked and move to next task?
3. Escalate for your input?"
```

### Autonomous Iteration Protocol

When a verification check fails, iterate autonomously before asking the user:

**Step 1: Gather Context**
- Read error logs (server logs, browser console)
- Check configuration files
- Run diagnostic commands
- Look for similar patterns in the codebase

**Step 2: Form Hypothesis**
- "The error suggests [X] is likely caused by [Y]"
- Show evidence supporting the hypothesis

**Step 3: Attempt Fix**
- Make a targeted change based on hypothesis
- Re-run verification

**Step 4: Iterate (Up to 3 Attempts)**
- If still failing, try alternative approach
- Document what was tried and why it failed

**Step 5: Escalate Only After Exhausting Options**
- Provide all diagnostic information gathered
- Explain what was tried and why it didn't work
- Offer specific options for user input

**Do NOT ask user "what's the error?" - investigate first.**



## Branch Hygiene Checks

### Merge Cadence Reminder

**From DevOps Engineer perspective:**

When working on a feature branch across multiple sessions, check the branch age:

```bash
# How long has this branch diverged from production?
git log --oneline HEAD --not origin/production | wc -l
```

**If the branch is >3 days old or >15 commits ahead**, remind the user:

> "This branch has diverged from production for [N days / N commits]. Merging production into the feature branch now prevents painful merge conflicts later. Design system changes, migration drift, and ESLint rule additions all compound with divergence time. Merge every 3 days maximum."

### Content Change → Test Coupling

**From QA Specialist perspective:**

When modifying user-facing copy, headlines, or section names, proactively check for E2E tests that assert on the changed content:

```bash
# After modifying copy in a component, check for E2E tests referencing it
grep -r "OLD_HEADLINE_TEXT" frontend/tests/e2e/ --include="*.spec.ts"
```

If matches are found, update the E2E tests in the same commit. Prefer migrating text assertions to `data-testid` selectors where possible to prevent future breakage.

## Key Principles

- **Multi-Role Perspective**: Draw from all engineering perspectives
- **Focus on Execution**: This is about doing the work, not planning
- **Quality First**: Ensure all acceptance criteria are met
- **Documentation Discipline**: Update Tasks Document as you work
- **Test-Driven When Appropriate**: Write tests as you build
- **Incremental Progress**: Complete one task fully before moving to next
- **Incremental Commits**: Commit after each meaningful milestone
- **Scope Awareness**: Periodically verify scope hasn't exceeded plan estimates (Step 1.5)

## Next Steps

After completing a task:
1. Update Tasks Document with completion status
2. Identify next task (checking dependencies)
3. Ask user if they want to continue or take a break

When all tasks are complete, follow this end-to-end flow:

```
Implement (all tasks done)
  ↓
Automated Testing — Run full test suite, lint, typecheck, build
  ↓
Local Review — Walk through the feature yourself (browser, endpoints, etc.)
  ↓
CI Maximizing — Push and ensure all CI checks pass. Use `/playbook:debug-ci` if failures occur.
  ↓
Create PR — Use `/playbook:git:create-pr` or `gh pr create`
  ↓
Learnings — Use `/playbook:learnings` to capture what you learned
```

**Don't skip steps.** CI failures are learning opportunities — if `/playbook:debug-ci` is used, follow up with `/playbook:learnings` to capture the root cause.

---

*You're representing multiple engineering perspectives to execute tasks systematically and maintain quality throughout delivery.*
