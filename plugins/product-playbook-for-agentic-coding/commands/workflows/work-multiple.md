---
name: playbook:work-multiple
description: Work autonomously on multiple tasks without interruption
argument-hint: "[optional: number of tasks or specific task IDs]"
---

# Work on Multiple Tasks

You are facilitating autonomous task execution in the Delivery phase, working on multiple tasks from the Tasks Document without interruption.

## Your Goal

Work autonomously on multiple tasks, prioritizing lower-risk tasks that require minimal manual review. Provide comprehensive validation instructions when complete.

- Maximize number of tasks completed
- Minimize risk by prioritizing safer tasks
- Provide clear validation summary at end

## Prerequisites

Before starting, ensure:
- Tasks Document exists with multiple tasks defined
- Multiple tasks are ready to work on (dependencies satisfied, status is "Not Started")
- Sufficient context for multiple task execution

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (debug, learnings)
2. **Agents**: Specialized agents via Task tool (delivery-agent)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool (autonomous-execution, session-checkpoint)

Select the most appropriate tools for the task at hand.

## Task Prioritization (Lower Risk First)

When selecting tasks to work on, prioritize in this order:

### Priority 1: Documentation & Configuration Tasks
- README updates
- Documentation improvements
- Configuration file updates
- Environment setup scripts
- Code comments and inline documentation

### Priority 2: Testing & Validation Tasks
- Writing tests for existing features
- Test coverage improvements
- Test refactoring
- Validation scripts

### Priority 3: UI/Styling Tasks
- Component styling improvements
- Layout adjustments
- Visual polish
- Accessibility improvements (non-breaking)

### Priority 4: Low-Risk Feature Additions
- Self-contained new components
- Helper functions/utilities
- Non-critical feature enhancements
- Performance optimizations (non-breaking)

### Priority 5: Refactoring Tasks
- Code cleanup
- Type safety improvements
- Code organization improvements
- Removing technical debt (non-breaking)

### DEFER to Manual Review: High-Risk Tasks
- Core API changes
- Database schema modifications
- Authentication/authorization changes
- Breaking changes to public APIs
- Integration with external services
- Complex state management changes

## Process

### Step 1: Load and Analyze Tasks

1. Read the Tasks Document
2. Identify all tasks with status "Not Started" and dependencies satisfied
3. Score each task for risk and priority
4. Create execution order

### Step 2: Execute Tasks in Sequence

For each task:

1. **Start Task**
   - Update task status to "In Progress"
   - Note start time in task notes

2. **Complete Work**
   - Follow acceptance criteria
   - Write tests if applicable
   - Keep changes focused

3. **Validate** (before committing):
   - Run project validation: check CLAUDE.md / package.json for `ci:local` or `test:verify`
   - At minimum: `npm run lint && npm run typecheck && npm test`
   - Check acceptance criteria
   - Verify no regressions

4. **Commit**
   - Atomic commit for this task
   - Clear commit message referencing task

5. **Update Status**
   - Mark task complete
   - Add completion notes
   - Note any issues or follow-ups

6. **Move to Next Task**
   - Don't stop unless blocked
   - Continue until all viable tasks complete

7. **Checkpoint (Every 3 Tasks — Mandatory)**
   - After completing every 3rd task, write a session checkpoint using the `session-checkpoint` skill pattern
   - Write to `docs/checkpoints/latest.md` with: current task, what's done, key decisions, next steps, hot files
   - **This is mandatory, not optional** — context compaction will destroy working memory in long runs. Checkpoints are the only way to preserve decisions and rationale that git can't capture.
   - Also write a checkpoint before stopping for any reason (blockers, end of session, user interrupt)

8. **Status Update (Between Tasks)**
   - After completing each task, emit a brief structured update:
     ```
     ✓ Task [X.Y] done — [one-line summary of what was built/fixed]
     → Next: Task [X.Y] — [one-line description]
     Progress: [N/M tasks] | Blocked: [N] | Deferred: [N]
     ```
   - Keep updates to 3 lines max. The user should be able to glance at progress without reading paragraphs.
   - Do NOT summarize what you're about to do in detail — just the task name and progress count.

### Step 3: Handle Blockers

If you encounter a blocker:

1. **Document the blocker** in task notes
2. **Set status** to "Blocked"
3. **Move to next task** - don't get stuck
4. **Note for summary** - user needs to know

### Step 3.5: Reconcile All Tasks (Before Stopping)

**CRITICAL**: Before producing the completion summary, sweep EVERY task in the Tasks Document — not just the ones you worked on. For each task, assign a final disposition:

| Disposition | Meaning | When to Use |
|-------------|---------|-------------|
| **Done** | Completed this session with all acceptance criteria met | Task was implemented and validated |
| **Blocked** (with reason) | Cannot proceed without external input | Missing dependency, unclear requirement, external service issue |
| **Deferred** (with reason) | Deliberately skipped | Too risky for autonomous execution, out of scope for this session |
| **Cancelled** (with reason) | No longer needed | Superseded by another task, requirement changed |
| **Not Reached** | Session ended before getting to this task | Ran out of time/context, lower priority |

**Why this matters**: Without explicit reconciliation, the most common failure mode in long autonomous runs is silent task loss — the agent completes 8/10 tasks, stops, and nobody notices 2 tasks were never addressed. Every task must have an explicit disposition.

Update the Tasks Document with dispositions before producing the summary.

### Step 4: Provide Completion Summary

When finished (or stopping), provide:

```markdown
## Autonomous Execution Summary

### Tasks Completed: X
| Task | Status | Notes |
|------|--------|-------|
| Task 1 | ✅ Complete | [Brief note] |
| Task 2 | ✅ Complete | [Brief note] |

### Tasks Blocked: Y
| Task | Blocker | Needs |
|------|---------|-------|
| Task 3 | Missing API key | User to provide |

### Tasks Deferred: Z
| Task | Reason |
|------|--------|
| Task 4 | High risk - needs review |

### Validation Instructions
To verify all changes:
1. Run: `npm test`
2. Check: [specific things to verify]
3. Review: [files changed]

### Files Changed
- file1.ts - [brief description]
- file2.tsx - [brief description]

### Next Steps
1. Review and merge changes
2. Address blocked tasks
3. Continue with `/playbook:work-multiple` for remaining tasks
```

## Risk Assessment Criteria

### Lower Risk (Prefer)
- Changes isolated to single file/component
- Has existing test coverage
- Non-breaking changes
- Easily reversible
- Well-defined acceptance criteria

### Higher Risk (Defer)
- Touches multiple systems
- No test coverage
- Breaking changes possible
- Hard to roll back
- Ambiguous requirements

## Key Principles

1. **Momentum With Guardrails**: Keep moving, but never commit code that fails lint, typecheck, or unit tests. A 3-minute local validation saves 30+ minutes of CI iteration.
2. **Lower Risk First**: Build confidence with safer tasks
3. **Atomic Changes**: One task, one commit
4. **Document Everything**: Clear notes help validation
5. **Know When to Stop**: Defer high-risk tasks for human review

## Next Steps

After autonomous execution:
1. Review the completion summary
2. Validate changes using provided instructions
3. Address blocked tasks manually
4. Review deferred high-risk tasks
5. Use `/playbook:learnings` to capture what worked well
