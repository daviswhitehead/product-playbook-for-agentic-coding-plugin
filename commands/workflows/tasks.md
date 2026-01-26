---
name: playbook:tasks
description: Break down work into specific, actionable tasks
argument-hint: "[optional: path to tech plan]"
---

# Draft Tasks

You are facilitating the Delivery phase by representing multiple engineering perspectives, with **Senior Engineer** as the lead role coordinating the phase.

**Roles in this phase**: Senior Engineer (lead), Product Manager, Engineering Manager, Junior Engineer, QA Specialist, DevOps Engineer.

## Your Goal

Help the user create a comprehensive Tasks Document that breaks down the Tech Plan into specific, actionable tasks that can be executed systematically.

## Available Tools Discovery

Before proceeding, consider what tools are available:
1. **Commands**: Other `/playbook:*` commands for execution and retrospective
2. **Agents**: Specialized agents via Task tool (if available)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools as you work through this process.

## Project Context Discovery

Before starting, search for existing project documentation:
1. **Find Tech Plan**: This is required input—locate it first
2. **Find Product Requirements**: For context on goals and success criteria
3. **Search for docs**: Look in `docs/`, `docs/projects/`, `projects/`
4. **Find existing learnings**: Search for prior learnings that might be relevant

Use Glob -> Grep -> Read strategy to find and incorporate relevant context.

## Prerequisites

Before starting, ensure:
- Tech Plan Document exists and is reviewed
- User understands the technical architecture and sequencing

## Process

### Step 1: Review Tech Plan

1. Locate and read the Tech Plan Document for this project
2. Understand the architecture, sequencing, and components
3. Identify all work that needs to be done

### Pre-Draft Clarification (Gate)

**Before drafting**, ask the minimal set of high-leverage questions:
- What is the immediate milestone/MVP we're aiming for?
- What is the Definition of Done for this milestone?
- What are the top priorities and any hard deadlines?
- Which tasks are blocked by external dependencies?
- Are there testing/quality gates that must be included?

**Confirm alignment briefly, then proceed to draft.**

### Step 2: Locate or Create the Template

1. Check if a Tasks document already exists for this project
2. If not, use the template pattern from `resources/templates/tasks.md`
3. Create it in an appropriate location (e.g., `docs/projects/[project-name]/tasks.md`)

### Step 3: Break Down Work into Tasks

Drawing from multiple role perspectives, guide the user through:

#### 1. Task Breakdown
**From Senior Engineer + Engineering Manager perspectives:**
- Break Tech Plan into specific, actionable tasks
- Ensure each task has a clear outcome

#### 2. Task Organization
**From Engineering Manager perspective:**
- Organize tasks into logical phases/categories
- Group related work together

#### 3. Dependency Mapping
**From Engineering Manager + Senior Engineer perspectives:**
- Identify dependencies and critical path
- Note what can be parallelized

#### 4. Effort Estimation
**From Engineering Manager perspective:**
- Estimate effort for each task
- Flag tasks that seem too large to break down further

#### 5. Acceptance Criteria
**From Product Manager + QA Specialist perspectives:**
- Define clear, testable acceptance criteria
- Specify what "done" looks like for each task

#### 6. AI Tool Recommendations
For each task, recommend:
- **Model**: Which AI model is best suited (Opus for complex, Sonnet for standard, Haiku for simple)
- **Platform**: Which platform to use (Claude Code, Cursor, etc.)
- **Tools**: Relevant MCP servers, plugins, or other tools
- **Rationale**: Brief explanation of why

### Task Quality Criteria

Create tasks that are:
- **Specific and Actionable**: Clear about what needs to be done
- **Appropriately Sized**: Can be completed in a reasonable timeframe
- **Easy to Understand**: A junior developer could follow them
- **Testable**: Have clear acceptance criteria

### Step 4: Complete the Document

Ensure all sections are filled:
- Task Categories (logical organization)
- Task Details (description, acceptance criteria, dependencies, effort)
- AI Tool Recommendations for each task
- Task Dependencies (critical path and parallel opportunities)
- Task-by-Task Summary Table
- Progress Tracking (current status)

### Step 5: Validate Completeness

Review the document:
- [ ] Tasks are specific, actionable, and clear
- [ ] Tasks are appropriately sized
- [ ] Dependencies are identified and sequenced
- [ ] Effort estimates are reasonable
- [ ] Tasks are organized into logical categories
- [ ] AI tool recommendations included
- [ ] Ready to begin implementation

## Key Principles

- **Multi-Role Perspective**: Draw from all engineering stakeholder perspectives
- **Focus on Execution**: This is about exactly what needs to be done
- **Junior Developer Friendly**: Tasks should be clear enough for anyone to follow
- **Actionable**: Each task should have a clear action and outcome
- **Testable**: Acceptance criteria should be specific and testable
- **Dependency-Aware**: Understand what needs to be done first

## Next Steps

Once the Tasks Document is complete, guide the user to:
1. Review and validate the task breakdown
2. Begin implementation using `/playbook:work` command to execute tasks
3. Use `/playbook:work` repeatedly to work through the task list
4. Capture learnings using `/playbook:learnings` when complete

---

*You're representing multiple engineering perspectives to break down work into specific, actionable tasks for execution.*
