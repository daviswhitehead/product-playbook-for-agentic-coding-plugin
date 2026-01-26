# Product Playbook for Agentic Coding

## Overview

This document provides universal AI instructions for systematic software development using a 4-phase workflow. These instructions are portable across AI tools and environments.

## The 4-Phase Workflow

### Phase 1: Product Discovery
**Goal**: Define WHAT to build and WHY

- Clarify user needs and business goals
- Identify constraints and success criteria
- Document requirements with acceptance criteria
- Output: Product Requirements Document

### Phase 2: Solution Planning
**Goal**: Design HOW to build it

- Analyze technical architecture
- Identify dependencies and risks
- Create sequencing plan
- Output: Tech Plan Document

### Phase 3: Delivery
**Goal**: Build and ship the solution

- Break work into specific tasks
- Execute tasks systematically
- Maintain quality throughout
- Output: Working software + Tasks Document

### Phase 4: Retrospective
**Goal**: Learn and improve

- Capture what worked and what didn't
- Document learnings for future reference
- Improve processes and documentation
- Output: Learnings Document

## Core Principles

### 1. Multi-Persona Approach
Different phases benefit from different perspectives:
- **Product Discovery**: PM, Business Stakeholder, Domain Expert, End User
- **Solution Planning**: Architect, Engineering Manager, PM, Security Engineer
- **Delivery**: Senior Engineer, PM, QA Engineer
- **Retrospective**: Engineering Manager, PM, Individual Contributors

### 2. Systematic Workflows
- Follow structured processes to reduce cognitive load
- Use templates for consistency
- Check documentation before starting work
- Validate assumptions early

### 3. Learning Compounds
- Capture learnings at multiple points:
  - After chat sessions (lightweight)
  - After project completion (comprehensive)
  - After overcoming blockers (targeted)
- Learnings improve both codebase docs and workflows

### 4. Tool Orchestration
- Inventory available tools before starting tasks
- Select the right tool for each job
- Combine tools effectively for complex work

### 5. Documentation Discipline
- Keep documentation updated as you work
- Search existing docs before creating new ones
- Write for future readers (including AI)

## Safety Rules

### Code Quality
- Never ship code without tests
- Follow existing patterns in the codebase
- Keep changes focused and minimal
- Validate changes before committing

### Communication
- Be transparent about limitations
- Ask clarifying questions when uncertain
- Report blockers early
- Document decisions and rationale

### Data Safety
- Never expose secrets or credentials
- Validate inputs at system boundaries
- Handle errors gracefully
- Maintain data integrity

## Document Templates

### Product Requirements
```markdown
# Product Requirements: [Project Name]

## Problem Statement
What problem are we solving?

## Goals
- Primary goal
- Secondary goals

## Success Criteria
- [ ] Measurable outcome 1
- [ ] Measurable outcome 2

## Scope
### In Scope
- Feature 1
- Feature 2

### Out of Scope
- Deferred feature
```

### Tech Plan
```markdown
# Tech Plan: [Project Name]

## Architecture
How will this be built?

## Sequencing
1. Phase 1: Foundation
2. Phase 2: Core Features
3. Phase 3: Polish

## Risks
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Risk 1 | High | High | Mitigation strategy |
```

### Tasks
```markdown
# Tasks: [Project Name]

## Phase 1: [Phase Name]
- [ ] Task 1.1: Description (~Xh)
- [ ] Task 1.2: Description (~Xh)

## Definition of Done
- All tests pass
- Documentation updated
- Code reviewed
```

### Learnings
```markdown
---
title: "Brief descriptive title"
date: YYYY-MM-DD
trigger: [chat-session|project-completion|blocker-overcome]
category: [performance|database|integration|workflow|debugging]
tags: [relevant, searchable, keywords]
---

# Title

## Context
What was happening when this learning emerged...

## Learning
The key insight or pattern discovered...

## Application
How to apply this learning in the future...
```

## Integration Guidance

### Searching Project Documentation
Standard locations to check:
1. `docs/` - Primary documentation
2. `docs/projects/` - Project-specific docs
3. `projects/` - Alternative project location
4. `CLAUDE.md` - Project AI instructions
5. `AGENTS.md` - Universal AI instructions
6. `README.md` - Project overview

### Working with External Tools
When using external tools or agents:
1. Provide context about current phase and goals
2. Specify output format requirements
3. Validate outputs meet quality standards

### Debugging Approach
1. Reproduce the issue first
2. Form hypothesis before investigating
3. Verify hypothesis with evidence
4. Check existing learnings for similar issues
5. Document solution when resolved

---

*This document is designed to be portable across AI tools and environments.*
