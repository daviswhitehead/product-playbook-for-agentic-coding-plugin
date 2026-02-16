# Tasks

## Project Overview
**Project Name**: [Project Name]
**Tech Plan**: [Link to Tech Plan]
**Date**: [Date]
**Version**: [Version]

## Current Focus

**Active Task**: [Task X.Y - Task Name]
- **Status**: [ ] Not Started | [ ] In Progress | [ ] Blocked | [ ] Complete
- **Current Subtasks**:
  - [ ] [Subtask 1]
  - [ ] [Subtask 2]
  - [ ] [Subtask 3]

**Next Task**: [Task X.Y - Task Name] (Ready when [dependency] is complete)

## Task Completion Workflow

**After completing each task, update this document:**
1. Mark task status as "Complete"
2. Verify ALL acceptance criteria checkboxes are marked
3. Add completion notes (what was done, any learnings, blockers resolved)
4. Update "Current Focus" section to next task
5. Update "Progress Tracking" section below

**Before marking any task complete:**
- Verify all acceptance criteria are checked
- Verify all dependencies are satisfied
- Add completion notes documenting what was accomplished

## Phase 0: Pre-Estimation Scope Audit

> **When to use**: For migration-type work (design system changes, API upgrades, dependency updates, etc.), run automated checks BEFORE sizing tasks. Estimates based on "some" or "a few" are unreliable — quantify the actual scope first.

### Task 0.1: Automated Scope Audit
**Description**: Run automated checks (grep, ESLint, lint rules, etc.) to quantify the actual migration scope before estimating effort.

**Acceptance Criteria**:
- [ ] Automated scan completed (e.g., `grep -r`, ESLint rule, custom script)
- [ ] Violation/change count documented below
- [ ] Count used to size Phase 2+ cleanup tasks

**Audit Results**:
- Total violations found: [NUMBER]
- Files affected: [NUMBER]
- Estimated cleanup effort per violation: [TIME]
- Tool/command used: [COMMAND]

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

**Notes**: [Record the audit command and results here. This data directly informs task sizing below.]

---

## Phase 1: [Phase Name]

### Task 1.1: [Task Name]
**Description**: [Detailed task description - specific and actionable]

**Acceptance Criteria**:
- [ ] [Criteria 1 - specific and testable]
- [ ] [Criteria 2 - specific and testable]
- [ ] [Criteria 3 - specific and testable]

**Dependencies**: [Prerequisites - what needs to be done first]

**Estimated Effort**: [Time estimate]

**AI Tool Recommendations**:
- **Model**: [e.g., Opus 4.5, Sonnet 4.5, Haiku 4.5]
- **Platform**: [e.g., Claude Code, Cursor, Codex]
- **Tools**: [e.g., MCP servers, plugins - or "None"]
- **Rationale**: [Brief explanation of why these selections are optimal]

**Status**: [ ] Not Started | [ ] In Progress | [ ] Blocked | [ ] Complete

**Completion Verification** (before marking Complete):
- [ ] **CRITICAL**: ALL acceptance criteria checkboxes above are marked
- [ ] All dependencies are satisfied
- [ ] Completion notes added below

**Notes**: [Any relevant notes or blockers]

---

### Task 1.H: [Human Task Name] `[HUMAN]`
> Use this format for tasks requiring manual action in external dashboards, third-party services, or physical access that the agent cannot perform.

**Description**: [What needs to be done and why]

**Executor**: `[HUMAN]` (with agent guidance)

**Step-by-Step Instructions**:
1. [Go to specific URL / Open specific dashboard]
2. [Navigate to exact menu: Settings > Sub-menu > Option]
3. [Specific action to take, with exact values to enter]
4. [What to verify after the action]

**Decision Points** (choices the human will face):
- [Decision 1]: Choose [Option A] because [reason]. [Option B] is for [different use case].
- [Decision 2]: Select [specific value]. [Why this value over alternatives].

**Output Needed for Next Task**: [Exact values, keys, or confirmations the agent needs to proceed]

**Acceptance Criteria**:
- [ ] [Criteria 1 - specific and verifiable]
- [ ] [Criteria 2 - specific and verifiable]

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

### Task 1.2: [Task Name]
**Description**: [Detailed task description - specific and actionable]

**Acceptance Criteria**:
- [ ] [Criteria 1 - specific and testable]
- [ ] [Criteria 2 - specific and testable]
- [ ] [Criteria 3 - specific and testable]

**Dependencies**: [Prerequisites]

**Estimated Effort**: [Time estimate]

**AI Tool Recommendations**:
- **Model**: [e.g., Opus 4.5, Sonnet 4.5, Haiku 4.5]
- **Platform**: [e.g., Claude Code, Cursor, Codex]
- **Tools**: [e.g., MCP servers, plugins - or "None"]
- **Rationale**: [Brief explanation]

**Status**: [ ] Not Started | [ ] In Progress | [ ] Blocked | [ ] Complete

**Completion Verification**:
- [ ] **CRITICAL**: ALL acceptance criteria checkboxes above are marked
- [ ] All dependencies are satisfied
- [ ] Completion notes added below

**Notes**: [Any relevant notes]

---

## Phase 2: [Phase Name]

### Task 2.1: [Task Name]
**Description**: [Detailed task description - specific and actionable]

**Acceptance Criteria**:
- [ ] [Criteria 1 - specific and testable]
- [ ] [Criteria 2 - specific and testable]
- [ ] [Criteria 3 - specific and testable]

**Dependencies**: [Prerequisites]

**Estimated Effort**: [Time estimate]

**AI Tool Recommendations**:
- **Model**: [e.g., Opus 4.5, Sonnet 4.5, Haiku 4.5]
- **Platform**: [e.g., Claude Code, Cursor, Codex]
- **Tools**: [e.g., MCP servers, plugins - or "None"]
- **Rationale**: [Brief explanation]

**Status**: [ ] Not Started | [ ] In Progress | [ ] Blocked | [ ] Complete

**Notes**: [Any relevant notes]

---

## Task Dependencies

**Critical Path**:
1. [Task 1] -> [Task 2] -> [Task 3]
2. [Task 4] -> [Task 5]

**Parallel Tasks**:
- [Task A] and [Task B] can be done simultaneously
- [Task C] and [Task D] can be done simultaneously

## Task Summary

| Task | Description | Model | Platform | Est. Time |
|------|-------------|-------|----------|-----------|
| 1.1 | [Description] | [Model] | [Platform] | [Time] |
| 1.2 | [Description] | [Model] | [Platform] | [Time] |
| 2.1 | [Description] | [Model] | [Platform] | [Time] |

**Total Estimated Time**: [X hours]

## Progress Tracking

### Completed Tasks
- [ ] [Task name] - Completed [Date]
- [ ] [Task name] - Completed [Date]

### In Progress
- [ ] [Task name] - Started [Date]

### Blocked
- [ ] [Task name] - Blocked by [reason]

### Next Up
- [ ] [Task name] - Ready to start
- [ ] [Task name] - Waiting for dependency

## Phase N: Polish & QA (for UI projects)

> **When to use**: For any project with UI changes, include BOTH automated and visual QA. Automated tools (axe-core) catch numeric violations but miss visual issues (wrong colors, invisible text). Visual QA catches what automated tools miss.

### Task N.1: Automated Accessibility Audit
**Description**: Run automated accessibility checks on all affected pages/states.

**Acceptance Criteria**:
- [ ] axe-core (or equivalent) run on all affected pages
- [ ] All modes/states tested (e.g., light mode, dark mode, empty state)
- [ ] Contrast ratios verified programmatically (e.g., `polished.getContrast()`)
- [ ] Zero critical/serious violations (or documented exceptions)

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

### Task N.2: Visual QA (Paired with Automated)
**Description**: Take screenshots of all affected pages/states and verify visual correctness beyond what automated tools check.

**Acceptance Criteria**:
- [ ] Playwright screenshots taken for all affected pages
- [ ] All modes/states captured (e.g., light + dark, empty + populated)
- [ ] Visual review confirms correct colors, spacing, and readability
- [ ] No invisible text, wrong backgrounds, or broken layouts

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

## Final Verification Checklist

**Before marking all tasks complete**, verify:

### Code Quality Checks
- [ ] No TypeScript/linting errors
- [ ] Build succeeds
- [ ] All tests pass

### Manual Verification
- [ ] All acceptance criteria verified manually
- [ ] No regressions introduced
- [ ] User-facing changes work as expected

### Documentation
- [ ] Completion notes added for all completed tasks
- [ ] Tasks Document is current and accurate

---

*This document focuses on Execution - breaking down exactly what needs to get done.*
