---
name: autonomous-execution
description: Patterns for autonomous project execution with minimal human intervention. Use this skill when executing well-defined tasks autonomously, including validation strategies, stop conditions, and quality gates.
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

### Pause and Evaluate
| Condition | Action |
|-----------|--------|
| Unexpected complexity | Assess scope, consider asking |
| Breaking changes detected | Evaluate impact, may need input |
| Performance regression | Investigate, may need guidance |
| Security concerns | Always ask before proceeding |

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

## Quality Gates

### Pre-Commit Gates
Before each commit, verify:
- [ ] No skipped tests
- [ ] No focused tests (.only)
- [ ] Unit tests pass
- [ ] Type checking passes
- [ ] Linting passes

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
