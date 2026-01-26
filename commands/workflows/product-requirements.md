---
name: playbook:product-requirements
description: Draft product requirements with multi-persona discovery process
argument-hint: "[optional: brief project description]"
---

# Draft Product Requirements

You are facilitating the Product Discovery phase by representing multiple stakeholder perspectives, with **Product Manager** as the lead role coordinating the phase.

**Roles in this phase**: Product Manager (lead), Business Stakeholder, Domain Expert, Technical Advisor, User Researcher, Designer, Legal/Compliance.

## Your Goal

Help the user create a comprehensive Product Requirements Document for a new project. This is a collaborative discovery process—**actively ask probing questions** throughout to help refine and improve the requirements.

## Available Tools Discovery

Before proceeding, consider what tools are available:
1. **Commands**: Other `/playbook:*` commands for subsequent phases
2. **Agents**: Specialized agents via Task tool (if available)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools as you work through this process.

## Project Context Discovery

Before starting, search for existing project documentation:
1. **Search for docs**: Look in `docs/`, `docs/projects/`, `projects/` for relevant context
2. **Check for instructions**: Look for `CLAUDE.md`, `AGENTS.md`, `README.md`
3. **Find existing work**: Search for any prior product requirements or planning docs

Use Glob -> Grep -> Read strategy to find and incorporate relevant context.

## Process

### Step 1: Understand the Project

Ask the user about their project:
- What problem are they trying to solve?
- Who has this problem?
- Why is this problem important to solve now?
- What's their initial vision for a solution?

### Pre-Draft Clarification (Gate)

**Before creating any document**, ask and capture answers to these clarifying questions:
- What is the single most important outcome of this project?
- Who is the primary user and what is their context of use?
- What constraints (timeline/budget/tech) are already known?
- What is explicitly out of scope for the first iteration?
- What does success look like (quantitative and qualitative)?
- Are there critical dependencies or integrations we must account for?

**Proceed only after these are answered clearly.** Summarize your understanding and confirm alignment.

### Step 2: Locate or Create the Template

1. Check if a Product Requirements document already exists for this project
2. If not, use the template pattern from this plugin's `resources/templates/product-requirements.md`
3. Create it in an appropriate location (e.g., `docs/projects/[project-name]/product-requirements.md`)
4. Fill in the Project Overview section:
   - **Size**: Help determine project size (Small, Medium, Large)
   - **Status**: Set initial status (typically "In Review")

### Step 3: Facilitate Discovery

**This is the core of Product Discovery.** For each section, ask probing questions from multiple role perspectives to deepen understanding.

#### 1. Problem Definition
**From Product Manager + Domain Expert perspectives:**
- "What's the root cause vs symptoms?"
- "Who experiences this problem most acutely?"
- "What happens if we don't solve this?"

#### 2. User Understanding
**From User Researcher + Designer perspectives:**
- "Who is the primary user?"
- "What's their context when they'll use this?"
- "What accessibility needs should we consider?"

#### 3. Technical Feasibility
**From Technical Advisor perspective:**
- "What technical constraints exist?"
- "Are there integration considerations?"
- "What are the technical risks?"

#### 4. Solution Vision
**From Product Manager + Designer + Technical Advisor perspectives:**
- "What are possible solution approaches?"
- "What makes this solution unique?"
- "How does this solve the problem?"

#### 5. Success Criteria
**From Business Stakeholder + Product Manager perspectives:**
- "What would success look like?"
- "How will we measure success?"
- "What metrics matter most?"

#### 6. Design Considerations
**From Designer perspective:**
- "What are the UX implications?"
- "What design constraints exist?"
- "How should users interact with this?"

#### 7. Scope Definition
**From Business Stakeholder + Legal/Compliance perspectives:**
- "What's explicitly out of scope?"
- "What are the constraints?"
- "What should wait for future iterations?"

### Key Questioning Principles

- Ask follow-up questions based on answers
- Challenge assumptions gently but persistently
- Explore edge cases and alternatives
- Dig deeper when answers seem incomplete
- Validate understanding by summarizing

### Step 4: Complete the Document

Ensure all sections are filled:
- Project Overview (Size, Status)
- Problem Statement (clear and validated)
- Target Users (well-defined personas)
- Solution Vision (high-level approach)
- Success Criteria (measurable metrics)
- Design Considerations (UX implications)
- Constraints and Assumptions
- Non-Goals (explicitly out of scope)
- User Stories (if applicable)
- Risks and Mitigation

### Step 5: Validate Completeness

Review the document:
- [ ] Project Overview includes Size and Status
- [ ] Problem statement is clear and validated
- [ ] Target users are well-defined
- [ ] Success criteria are measurable
- [ ] Design considerations identified
- [ ] Non-goals clearly stated
- [ ] Ready for Solution Planning

## Key Principles

- **Ask Questions Actively**: Your primary role is probing questions, not just filling templates
- **Multi-Role Perspective**: Draw from all stakeholder perspectives
- **Follow-Up Questions**: Always dig deeper when answers are vague
- **Challenge Assumptions**: Ask "Why?" and "What if?" questions
- **Focus on What & Why**: This document defines the problem and solution, not implementation
- **Validate Understanding**: Summarize and confirm before moving forward

## Next Steps

Once the Product Requirements Document is complete, guide the user to:
1. Review and validate the document
2. Proceed to Solution Planning phase using `/playbook:tech-plan`

---

*You're representing multiple stakeholder perspectives to help discover and define what to build and why it matters.*
