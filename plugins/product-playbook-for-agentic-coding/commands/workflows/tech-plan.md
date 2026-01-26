---
name: playbook:tech-plan
description: Create technical plan with architecture and sequencing
argument-hint: "[optional: path to product requirements]"
---

# Draft Tech Plan

You are facilitating the Solution Planning phase by representing multiple technical perspectives, with **Software Architect** as the lead role coordinating the phase.

**Roles in this phase**: Software Architect (lead), Product Manager, Engineering Manager, DevOps Engineer, QA Specialist, Designer.

## Your Goal

Help the user create a comprehensive Tech Plan Document for the project. This document focuses on **how** to build the solution—architecture, sequencing, and technical approach.

## Available Tools Discovery

Before proceeding, consider what tools are available:
1. **Commands**: Other `/playbook:*` commands for subsequent phases
2. **Agents**: Specialized agents via Task tool (if available)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools as you work through this process.

## Project Context Discovery

Before starting, search for existing project documentation:
1. **Find Product Requirements**: This is required input—locate the PRD first
2. **Search for docs**: Look in `docs/`, `docs/projects/`, `projects/` for relevant context
3. **Check for instructions**: Look for `CLAUDE.md`, `AGENTS.md`, `README.md`

Use Glob -> Grep -> Read strategy to find and incorporate relevant context.

## Learning Search (Before Planning)

Search for relevant learnings that might inform this plan:

```bash
# Search by category
Grep: "category: architecture" in docs/learnings/
Grep: "category: performance" in docs/learnings/
Grep: "category: integration" in docs/solutions/

# Search by relevant tags
Grep: "tags:.*[relevant-technology]" in docs/
Grep: "tags:.*[relevant-pattern]" in docs/learnings/

# Search by module (if known)
Grep: "module: [module-name]" in docs/
```

Review any relevant learnings before making architectural decisions. Prior solutions may inform current approach.

## Prerequisites

Before starting, ensure:
- Product Requirements Document exists and is reviewed
- User understands the high-level solution vision from Product Requirements

## Process

### Step 1: Review Product Requirements

1. Locate and read the Product Requirements Document for this project
2. Understand the problem, users, success criteria, and solution vision
3. **Identify the project size** (Small, Medium, Large) from the Project Overview
4. Identify key technical components needed to deliver the solution
5. **Adapt planning approach based on size**:
   - **Small**: Keep planning simple; use existing patterns
   - **Medium**: Balanced approach with some research
   - **Large**: Comprehensive planning with extensive research

### Pre-Draft Clarification (Gate)

**Before drafting**, ask the most important clarifying questions:
- What is the MVP scope we are targeting first?
- What constraints (timeline/budget/tech) are firm?
- Which integrations are must-have vs nice-to-have?
- What are the primary performance/scalability expectations?
- Any known high-risk areas requiring research/POCs?

**Confirm alignment with a brief summary, then proceed to draft.**

### Step 2: Locate or Create the Template

1. Check if a Tech Plan document already exists for this project
2. If not, use the template pattern from `resources/templates/tech-plan.md`
3. Create it in an appropriate location (e.g., `docs/projects/[project-name]/tech-plan.md`)

### Step 3: Facilitate Technical Planning

Drawing from multiple role perspectives, guide the user through technical planning **appropriate to the project size**:

#### For Small Projects
1. **Architecture Design**: Simple, focused component structure
2. **Sequencing**: Direct, straightforward implementation order
3. **Technology**: Use existing patterns (minimal evaluation)
4. **Integration**: Map only essential external dependencies
5. **Risks**: Identify key risks only

#### For Medium Projects
1. **Architecture Design**: Clear architecture with key components
2. **Sequencing**: Phased implementation with dependencies
3. **Technology**: Evaluate and recommend with rationale
4. **Integration**: Map all external dependencies and APIs
5. **Risks**: Comprehensive risk identification with mitigation

#### For Large Projects
1. **Architecture Design**: Detailed architecture with all components
2. **Sequencing**: Multi-phase with critical paths and parallel streams
3. **Technology**: Extensive evaluation, research, POCs
4. **Integration**: Comprehensive mapping with API contracts
5. **Risks**: Detailed assessment with mitigation and contingencies
6. **Performance**: Detailed scalability planning
7. **Decisions**: Document key decisions with rationale

### Role-Based Questions

**From Software Architect perspective:**
- "What are the core components and their responsibilities?"
- "How do components interact with each other?"
- "What are the data models and relationships?"

**From Engineering Manager perspective:**
- "What can be parallelized to speed delivery?"
- "What are the critical path dependencies?"
- "Where might we get blocked?"

**From DevOps perspective:**
- "What infrastructure is needed?"
- "How will we deploy and monitor this?"
- "What environments are in scope?"

**From QA Specialist perspective:**
- "How will we test this?"
- "What are the testing requirements?"
- "What could go wrong?"

### Step 4: Complete the Document

Ensure all sections are filled with complexity matching project size:

**Required for All Projects**:
- Project Overview (including Size)
- Technical Architecture
- Sequencing Plan
- Technology Stack
- Technical Risks

**For Medium and Large Projects**:
- Integration Approach
- Design System Architecture (if applicable)
- Performance Considerations

**For Large Projects Only**:
- Architectural Decisions with rationale
- Research documentation

### Step 5: Validate Completeness

Review the document:
- [ ] Technical architecture is clear and well-structured
- [ ] Sequencing plan minimizes dependencies
- [ ] Technology stack is appropriate and justified
- [ ] Integration points are identified
- [ ] Technical risks are assessed with mitigation
- [ ] Ready for Delivery phase

## Key Principles

- **Multi-Role Perspective**: Draw from all technical stakeholder perspectives
- **Focus on How (High-Level)**: Plan the approach, not implementation details
- **Minimize Blockers**: Sequencing should enable parallel work
- **Justify Choices**: Provide rationale for technology decisions
- **Identify Risks**: Surface technical challenges early

## Next Steps

Once the Tech Plan Document is complete, guide the user to:
1. Review and validate the document
2. Proceed to Delivery phase using `/playbook:tasks`

---

*You're representing multiple technical perspectives to plan how to build the solution.*
