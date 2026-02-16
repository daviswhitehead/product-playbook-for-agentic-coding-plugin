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
3. **Search for docs**: Look in `projects/`, `docs/projects/`, `docs/`
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
3. Create it in an appropriate location (e.g., `projects/[project-name]/tasks.md`)

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

#### 6.5. Human Task Instructions
**From DevOps Engineer + Engineering Manager perspectives:**

Some tasks require human action in external dashboards or services (e.g., creating accounts, configuring third-party tools, setting secrets). Mark these with `[HUMAN]` executor and provide:

- **Step-by-step instructions**: Exact menu paths, URLs, and actions — not just "create a project in [Service]"
- **Decision points**: Where the human will face choices, explain which option to pick and why
- **Output needed**: What values/keys/confirmations the agent needs from the human to proceed with dependent tasks

**Why this matters**: Vague `[HUMAN]` tasks create back-and-forth friction. The human shouldn't need to ask "which option do I pick?" at every step. Write instructions as if the human has never used the service before.

#### 7. Design & Creative Project Considerations

**From Designer + Product Manager perspectives:**

If the project involves design, creative, or visual work (UI design, branding, illustration, style exploration), apply these additional patterns:

- **User review checkpoints are tasks, not notes**: Create explicit tasks for stakeholder review at each phase gate (e.g., "User reviews palette options," "User approves character direction"). These are blocking dependencies.
- **Explore → Critique → Refine → Approve cycles**: Structure phases as iteration loops, not linear sequences. Each design phase should include:
  1. Exploration task (generate N options)
  2. Critique task (evaluate against rubric or stakeholder feedback)
  3. User review checkpoint (blocking)
  4. Refinement task (iterate on selected option)
- **Style exploration before implementation**: Add early tasks for style/direction exploration before any production implementation. This prevents expensive rework.
- **Critique rounds between phases**: Reference `/playbook:critique` or specialist agent reviews between major phases, not just at the end.
- **Visual acceptance criteria**: For design tasks, acceptance criteria should describe visual outcomes ("Logo readable at 32px," "Contrast ratio passes WCAG AA") not just code outcomes.
- **Tool diversity**: Design tasks may require different AI tools per task type (image generation, SVG creation, font selection). Include tool recommendations per task.

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
2. **Run a stakeholder critique** — use `/playbook:critique` on the tasks document. This catches missing dependencies, underestimated effort, and unclear acceptance criteria before work begins.
3. Begin implementation using `/playbook:work` command to execute tasks
4. Use `/playbook:work` repeatedly to work through the task list
5. **During implementation**: Use specialist code review agents (security-sentinel, performance-oracle, etc.) at milestone boundaries — don't accumulate >100 files without review
6. Capture learnings using `/playbook:learnings` when complete

---

*You're representing multiple engineering perspectives to break down work into specific, actionable tasks for execution.*
