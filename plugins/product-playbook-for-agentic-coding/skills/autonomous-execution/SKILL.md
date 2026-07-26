---
name: autonomous-execution
description: Patterns for autonomous project execution with minimal human intervention. Use this skill when executing well-defined tasks autonomously, including validation strategies, stop conditions, and quality gates. Don't use when doing a single task interactively with the user, or when the project lacks a tasks document.
---

# Autonomous Execution

This skill provides patterns for executing projects autonomously while maintaining quality and knowing when to stop and ask for help.

## Prerequisites for Autonomous Execution

Before starting autonomous work, verify:

### Project Readiness
- [ ] **Tech Plan exists** - Architecture and sequencing documented
- [ ] **Tasks Document exists** - Granular tasks with acceptance criteria
- [ ] **Success criteria defined** - Clear "done" definition
- [ ] **Tests exist** - Automated validation available
- [ ] **Quality gates configured** - Pre-commit hooks, CI checks

### Documentation Readiness
- [ ] **Project docs available** - CLAUDE.md, relevant docs
- [ ] **Troubleshooting guide exists** - Common issues documented
- [ ] **Stop conditions clear** - When to pause and ask

## Execution Patterns

### Pattern 1: Task-by-Task Execution

**When to use**: Standard execution for most projects

**Process**:
1. **Read task** - Understand requirements and acceptance criteria
2. **Plan approach** - Identify implementation strategy
3. **Implement** - Write code following project standards
4. **Self-validate** - Run tests, check acceptance criteria
5. **Update status** - Mark task complete, update progress
6. **Proceed to next** - Move to next task

**Validation Checkpoints**:
- After each task: Run relevant test suite
- After each phase: Run full test suite
- Before completion: Complete quality gate checklist

### Pattern 2: Phase-by-Phase Execution

**When to use**: Projects with clear phases (migrations, refactors)

**Process**:
1. Complete all tasks in current phase
2. Run phase-specific validation
3. Verify quality gates pass
4. Document learnings
5. Proceed to next phase only after validation

### Pattern 3: Incremental Validation

**When to use**: Large projects or risky changes

**Process**:
1. Make small, focused change
2. Validate immediately
3. Commit only if validation passes
4. Repeat with next small change

### Checkpoint Integration (Mandatory)

Write session checkpoints — context compaction is inevitable in long runs, not an edge case:

- **Write checkpoints** every 3 completed tasks — this is not optional
- **Write to** `docs/checkpoints/latest.md`
- **Include**: current task, decisions made, next steps, hot files
- **Also write before stopping** for any reason (blockers, session end, user interrupt)
- **Why**: Context compaction destroys working memory. Checkpoints are the only mechanism that preserves decisions and rationale across compaction events. Treat them as mandatory infrastructure, not a nice-to-have.

See the `session-checkpoint` skill for the full checkpoint format.

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

## Self-Validation Strategies

### Task-Level Validation

After completing each task:

1. **Run relevant tests**:
   - Unit tests for logic changes
   - Integration tests for API/service changes
   - E2E tests for user-facing changes

2. **Check acceptance criteria**:
   - Review each criterion
   - Verify all can be marked complete
   - Document any deviations

3. **Run quality checks**:
   - Type checking
   - Linting
   - Build verification

4. **Update task status**:
   - Mark acceptance criteria complete
   - Add completion notes
   - Update status to "Complete"

### Instrumented-Task Verification Gate (do NOT close on a static check)

If a task's acceptance criterion includes **"event fires", "metric captured", "instrumentation added", or "tracked in <analytics tool>"**, the task **cannot be marked complete on a static/import check** ("the code calls `capture()`", "imports are clean"). Code-is-wired ≠ behavior-verified.

Before marking such a task ✅, require ONE of:
1. **Runtime evidence AND metric evidence** — the two-part rule below, OR
2. **An explicit unverified flag** surfaced to the user: *"Code is wired but I could not verify the event fires at runtime — needs a runtime check before this is truly done."*

Never silently equate the two. This failure mode has recurred across three projects (Memory Phase 1 gates closed with `null` metrics; acquisition T10/T11/T12 closed with zero/deprecated events — `recipe_cta_clicked` logged **zero events for 12 days** after being marked done on "imports are clean"). The symptom of a miss is "No data recorded" for a *shipped* event — treat that as instrumentation-suspect, not "no traffic," and fire a synthetic event to disambiguate.

#### Emission and the metric are two separate checks

"It landed in the analytics tool" is **emission**, not the metric. Verify both:

1. **Emission** — fire the event yourself (synthetic click / incognito + DevTools network filter) and confirm it arrives.
2. **The metric** — run the query, dashboard, or report that **consumes** the data and confirm it returns a **correct non-null value**. Paste that output as the evidence.

Step 2 is the one that gets skipped, and skipping it is invisible. A 202 from the endpoint, a network request in DevTools, a green unit test asserting the tracking call, and the event visible in a live-events stream are **all** compatible with a metric that reads zero forever.

> A conversion pixel passed step 1 completely — SDK loaded on both hosts, event accepted 202, attribution param on the payload, person properties written correctly, unit tests green — and was marked done. The consuming query read a property path the event never carried (the event is captured server-side; that path only exists on client captures), so every signup bucketed as "direct (no UTM)". Nothing had run the query against a real attributed signup, so code review couldn't see it. Found in a pre-launch audit, one click before a paid campaign would have spent its full budget for zero attribution — which ad platforms cannot backfill.

Two habits that prevent this class:
- **Put the attribute on the same record the metric counts.** Joins and person-property lookups are where NULLs and read-time races hide.
- **Make the consuming query a runnable check** that fails on an empty/null result, and validate it in **both** directions — a check that doesn't fail when pointed at the old broken version is a rubber stamp, not a guard.

If no consumer exists yet, the task is not done: write the query.

### Negative-test every guardrail you add (a check that can't fail is not a check)

**Applies to ANY guard, not just instrumentation**: lint rules, CI jobs, pre-commit hooks, schema/migration audits, quality gates, assertion helpers, smoke checks.

Before marking a guard-adding task complete, you must have run it **twice**:

1. **Positive** — against correct input. It passes.
2. **Negative** — against the broken input it exists to catch. **It fails, with an actionable message that names the fix.**

If you have not seen it fail, you have not tested it — you have only observed that it is silent, and silence is what a no-op looks like too.

Also check the guard can't become **unsatisfiable**. A check that derives its query/config from production code can inherit a filter that removes the very fixture it needs, and then fails forever for a reason unrelated to what it guards. That trains people to ignore it, which is worse than having no guard.

> Real incidents. (a) A metrics verifier inherited the production query's internal-account exclusion — the only attributed fixture was a test account that filter removed, so it failed on production with a message *indistinguishable from the real bug*. (b) An ESLint rule and a CI check were both authored, and only the passing direction was ever exercised; the negative case was assumed.
>
> This rule was written down after an earlier incident (a CI guardrail that never fired) and lived **only in a retrospective for two months**, so the next guardrail repeated it. That is why it is here, in the workflow, and not only in a doc.

**Cheap pattern**: temporarily revert the fix (or point the guard at the old/broken version), run the guard, confirm red + read the message, restore. Paste both outcomes as the completion evidence.

### Acknowledge Method Substitution (don't silently downgrade verification)

If a task names a **specific verification method** (e.g., "browser automation / E2E test of the full flow") and you cannot or do not perform it, you must **say so explicitly** — never substitute a weaker method (a code trace, a line-number citation, a manual read) and report it as if the named method was performed. State: *"The task asked for an E2E run; I did a code trace instead because <reason>. This is weaker — the browser test still needs to run."* For E2E specs specifically, "wired into the test runner's `testMatch`/suite + seen running in CI" is part of done — a spec file that exists but never runs is zero coverage.

### Phase-Level Validation

After completing each phase:

1. Run phase-specific validation (if script exists)
2. Run full test suite multiple times (catch flakiness)
3. Verify all quality gates pass
4. Document any learnings or issues

## Stop Conditions

**CRITICAL**: Stop and ask for help when encountering:

### Immediate Stop (Blockers)
| Condition | Action |
|-----------|--------|
| Tests fail 3+ times | Stop, document issue |
| Architectural decision needed | Stop, ask for guidance |
| External dependency blocked | Stop, report blocker |
| Quality gate failure (can't fix) | Stop, seek help |
| Ambiguous requirements | Stop, ask for clarification |
| Same tool fails 2+ times | Switch strategy, don't brute-force |
| Unsure about platform capability | Say "I'm not sure, let me verify" — don't state as fact |

### Pause and Evaluate
| Condition | Action |
|-----------|--------|
| Unexpected complexity | Assess scope, consider asking |
| Breaking changes detected | Evaluate impact, may need input |
| Performance regression | Investigate, may need guidance |
| Security concerns | Always ask before proceeding |

### "Sequenced later" is NOT "blocked"

Distinguish a **soft sequencing preference you set** ("do the blog last", "warm outreach after polish") from a **hard external dependency** (missing API key, unmerged upstream PR, a gate that genuinely can't be evaluated yet). A self-imposed "later" is something you can revisit and propose to pull forward; it is not a blocker. When you find yourself idle because of a soft "later", **propose the next viable action** rather than reporting a block and waiting. (Found: agent reported "blog is blocked" and idled until the user said *"We're sitting here idle. Just answer."* — it had mistaken its own sequencing note for an external dependency.)

### How to Stop Gracefully

When stopping:

1. **Document current state**:
   - What was attempted
   - What failed
   - What was learned

2. **Update task status**:
   - Mark as "Blocked" or "In Progress"
   - Add blocker notes

3. **Create summary**:
   - Brief description of issue
   - What was tried
   - What's needed to proceed

## Name the Bottleneck — Don't Let Building Substitute for the Scary Work

Autonomous execution has a seductive failure mode: the agent's track is **always** productive. There is always more to build, refactor, document, or instrument. When a project has parallel tracks — "the agent builds infrastructure while the human does the hard manual thing (outreach, sales, recruiting users, a scary conversation)" — the agent can ship indefinitely while the metric that actually defines success stays at zero. The project *looks* productive (tasks closing, PRs merging) while nothing that matters moves.

**The check**: periodically ask *"is my buildable backlog outpacing the metric that defines success?"* If the infrastructure is largely done and the constraint is now the human's manual work, **say so plainly** instead of mining the backlog for more safe tasks:

> "The measurement infrastructure is ~90% built. The bottleneck is no longer engineering — it's getting real traffic through the funnel. Continuing to build is lower-value than unblocking that. What's blocking the outreach?"

Don't let an always-available build queue become a comfortable proxy for harder, scarier real-world validation. (Found: acquisition-engine — 10 weeks of measurement infrastructure shipped, exactly **one** acquisition channel actually run. The agent never surfaced that the bottleneck had shifted; the founder later named it: *"building felt safer than posting."*)

## Subagent Dispatch Hygiene (Multi-Agent / Shared-Workspace Execution)

When executing via dispatched subagents (implementer-per-task patterns) — especially in shared working directories (Conductor workspaces, git worktrees used by parallel sessions):

### Commit-surface verification (every commit-producing dispatch)

1. **Dispatch instruction**: every subagent that commits must stage **explicit paths only** (`git add <files>`, or at widest `git add -A <task-dir>`). Never `git add -A` / `git commit -am` at repo root — in a shared workspace, foreign uncommitted files (another session's WIP) get silently swept into the commit.
2. **Name the foreign files**: if the working tree contains uncommitted files from another session, list them in every dispatch prompt as never-stage.
3. **Controller verification**: before recording a task complete, verify the reported commit's `git show --stat --name-only <sha>` against the task's expected file surface. A commit touching files outside the surface is a **failed task** requiring history repair (amend + `rebase --onto` + force-push), not a bookkeeping note.

> Origin: 2026-07-07 agent-workforce retro — a fix-subagent's repo-wide staging swept another session's files into a commit; caught only at final whole-branch review, requiring history rewrite. Two prior shared-workspace incidents existed; per-incident recovery rules did not prevent the third.

### Reviewer context (plan-derived tasks)

When task briefs are derived from a design doc, give per-task **reviewers the design doc reference, not just the brief**. Plans narrow designs; implementers faithfully transcribe the narrower version; only a reviewer holding the design catches the fidelity gap. (Two contract gaps in the same retro were caught exactly this way; briefs alone would have passed both.)

## Quality Gates

### Pre-Commit Gates
Before each commit, discover and run project-specific validation (from CLAUDE.md / package.json):
- Discover: `ci:local` > `test:verify` > `test:pre-push` > individual commands
- If composite script exists (e.g., `npm run ci:local`): run it instead of individual commands
- Run with explicit Bash timeout (300000ms) if validation takes >2 minutes

At minimum verify:
- [ ] No skipped tests (.skip)
- [ ] No focused tests (.only)
- [ ] Linting passes
- [ ] Type checking passes
- [ ] Unit tests pass

### Pre-Phase Gates
Before proceeding to next phase:
- [ ] All phase tasks complete
- [ ] Phase validation passes
- [ ] Full test suite passes
- [ ] All pre-commit gates pass

### Pre-Completion Gates
Before marking project complete:
- [ ] All tasks complete
- [ ] All acceptance criteria met
- [ ] All tests passing
- [ ] No regressions
- [ ] Documentation updated

## Progress Tracking

### After Each Task

1. Mark acceptance criteria checkboxes
2. Add completion notes
3. Update task status
4. Update "Current Focus" to next task

### Metrics to Track
- Completion percentage (tasks done / total)
- Phase completion status
- Test coverage (maintain or improve)
- Quality gate status

## Troubleshooting Common Issues

### Tests Fail After Changes
1. Review test output for specific failures
2. Check if changes broke test assumptions
3. Verify test data/fixtures are correct
4. Run tests in isolation
5. Check if dependencies changed

### Quality Gates Block Commit
1. Read error message carefully
2. Fix the specific issue
3. Re-run checks locally
4. Don't bypass - fix root cause

### Unclear Acceptance Criteria
1. Review task description and context
2. Check tech plan for guidance
3. Review similar completed tasks
4. **Stop and ask** if still unclear

## Best Practices

### Code Quality
- Follow project standards and existing patterns
- Write tests when possible
- Keep changes small and focused
- Document decisions in completion notes

### Validation
- Validate early and often
- Run full suite regularly
- Don't proceed if gates fail
- Verify acceptance criteria are actually met

### Progress Management
- Update status after every task
- Document learnings as you go
- Track blockers explicitly
- Celebrate completed tasks

### Communication
- Write clear completion notes
- Ask when stuck (don't waste time)
- Share learnings
- Be transparent about deviations

## Integration with Playbook

This skill supports:
- `/playbook:work` - Primary execution command
- `/playbook:tasks` - Task document management
- `/playbook:learnings` - Post-execution capture

## Success Criteria

Autonomous execution is successful when:
- [ ] All tasks complete
- [ ] All tests passing
- [ ] Quality gates pass
- [ ] No regressions
- [ ] Documentation updated
- [ ] Ready for review

---

*Autonomous execution requires discipline: validate often, stop when uncertain, document everything.*
