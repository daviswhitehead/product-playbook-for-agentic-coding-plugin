<!--
TEMPLATE GUIDANCE (for agents — do not include this block in output):

This template is a reference structure, not a rigid form. Adapt it to fit the project:
- Add sections that serve the project (e.g., Prioritization Analysis, Experiment Design)
- Remove or merge sections that don't apply
- Rename sections to fit the domain
- Sections marked "Optional" can be omitted entirely
- Sections marked "Adapt" should be customized to the project's context

The philosophy note below should be rewritten for each PRD to reflect
the document's specific approach and context. Don't use the placeholder—write
something genuine that sets the reader's expectations.

Quality bar: An AI agent should be able to create a tech plan and complete
downstream tasks autonomously from this document. But clarity of thinking
matters more than template completeness.
-->

# Product Requirements Document

> [Write a brief, conversational note about this PRD's approach. What does this document aim to do? What's the relationship between Framing and Solution? What should the reader expect? Tailor this to the specific project—don't use boilerplate.]
>
> *Example: "The goal here is to articulate what we're doing and why—not to prescribe exactly what to build. The Framing section is the heart of the doc; Solution provides enough detail to guide the team without over-constraining. If I were joining the team, I'd want to collaborate early so the team's perspective shapes every section."*

---

## Intro

### Metadata

| Field | Value |
|-------|-------|
| **Name** | [Feature/Project Name] |
| **Description** | [One-sentence description] |
| **Priority** | [P0/P1/P2] — [Brief justification] |
| **Status** | [Draft / In Review / Approved / In Progress / Complete] |
| **Size** | [Small / Medium / Large] |
| **Date** | [Date] |
| **Owner** | [Name/Role] |

### Summary

- [Key insight or problem statement in one line]
- [What this PRD proposes]
- [Primary success metric and target]
- [Expected outcome in one sentence]

---

## Framing

### Opportunity

**[One-sentence problem statement]**

[2-3 sentences expanding on the problem with supporting data. Lead with the insight, not the solution.]

| Evidence | Value | Source | Implication |
|----------|-------|--------|-------------|
| [Data point 1] | [Value] | [Source] | [What it means] |
| [Data point 2] | [Value] | [Source] | [What it means] |
| [Data point 3] | [Value] | [Source] | [What it means] |

### Who

| Audience | Description | Why They Matter |
|----------|-------------|-----------------|
| **Primary: [Persona]** | [Description] | [Why this audience is the focus] |
| **Secondary: [Persona]** | [Description] | [Why they're relevant] |

### What

<!-- Adapt: Describe the change concretely. Use flow diagrams, before/after comparisons,
     or whatever format makes the change clearest for this specific project. -->

**Current flow:** [How things work today — be specific about the user's actual experience]
**Proposed flow:** [How things will work after this ships]

[2-3 sentences describing the change concretely. Focus on what changes from the user's perspective.]

### Why

#### For Users

| User Need | Current Experience | Proposed Experience |
|-----------|-------------------|---------------------|
| [Need 1] | [Current state] | [Future state] |
| [Need 2] | [Current state] | [Future state] |
| [Need 3] | [Current state] | [Future state] |

#### For Business

**Strategic rationale:** [Why this matters for the business—connect to company goals, strategy docs, or retention frameworks where available]

**Impact forecast:**

| Metric | Baseline | Conservative | Optimistic |
|--------|----------|--------------|------------|
| [Primary metric] | [Current] | [+X%] | [+Y%] |
| [Secondary metric] | [Current] | [+X%] | [+Y%] |

**Revenue impact** *(Optional — include when the feature has direct or downstream revenue implications):*

| Scenario | Annual Impact | Key Assumptions |
|----------|---------------|-----------------|
| Conservative | $[X] | [Key assumptions] |
| Optimistic | $[Y] | [Key assumptions] |

**Forecast confidence:** [High / Medium / Low]. [Explanation of what's uncertain and what would increase confidence. Be honest—hiding uncertainty erodes trust. Example: "High uncertainty. These projections require validation through experimentation. More product discovery—including data analysis, user research, and prototyping—can improve confidence before building."]

### Hypotheses

**Primary hypothesis:**
> If we [action], then [outcome], because [rationale].

**Secondary hypothesis** *(if applicable):*
> If we [action], then [outcome], because [rationale].

### Success Metrics

| Metric | Definition | Target | Measurement |
|--------|------------|--------|-------------|
| **Primary:** [Metric] | [Precise definition] | [Specific target] | [How to measure] |
| **Secondary:** [Metric] | [Precise definition] | [Specific target] | [How to measure] |
| **Guardrail:** [Metric] | [What we don't want to break] | [Threshold] | [How to monitor] |

**Segmentation note:** [How should results be sliced? By cohort, signup source, user type, device? Call out segments that may respond differently and whether the winning approach may differ by segment.]

---

## Solution

### Vision

[2-3 sentences describing the end-state vision in 6-18 months if this succeeds. Paint a picture of the ideal experience.]

### Evolution

| Phase | What We Ship | Timeline | What We Learn |
|-------|--------------|----------|---------------|
| **Phase 1** | [MVP scope] | [Timeframe] | [Learning goals] |
| **Phase 2** | [Iteration] | [Timeframe] | [Learning goals] |
| **Future** | [Full vision] | [Timeframe] | [N/A] |

### Details

<!-- Adapt: This section describes what we're building in enough detail for technical
     planning. Use the format that communicates most clearly for this project:

     - Narrative descriptions (good for experiments, product changes, workflows)
     - Requirement blocks with Given/When/Then acceptance criteria (good for engineering specs)
     - A hybrid of both (narrative context + testable criteria)

     The goal is precision and clarity, not format compliance. -->

[Describe the solution in enough detail that an engineer could estimate effort and an agent could generate a tech plan. Include key logic, rules, and behaviors. Break into subsections as needed.]

**For engineering-heavy PRDs**, consider adding acceptance criteria per requirement:
- [ ] **Given** [precondition], **when** [action], **then** [expected result]

### Scenarios

<!-- Adapt: Scenarios reduce ambiguity by walking through concrete examples.
     Each should be implementable as a test case. -->

**Scenario 1: [Persona], the [context]**
[Name] [context description]. [What they do step-by-step]. [Expected outcome].

**Scenario 2: [Persona], the [context]**
[Name] [context description]. [What they do step-by-step]. [Expected outcome].

**Scenario 3: [Edge case or error scenario]**
[Description of edge case and expected handling].

### User Stories

> **Format:** As a [user type], I want [goal] so that [benefit].

1. **As a [user type]**, I want [goal] so that [benefit].

2. **As a [user type]**, I want [goal] so that [benefit].

### Scope

#### In Scope

| Item | Notes |
|------|-------|
| [Feature/capability 1] | [Any clarifying notes] |
| [Feature/capability 2] | [Any clarifying notes] |

#### Out of Scope

| Item | Rationale |
|------|-----------|
| [Feature/capability 1] | [Why it's excluded] |
| [Feature/capability 2] | [Why it's excluded] |

### Technical Context

<!-- For Agentic Engineering: This section provides the technical context needed to
     create a tech plan without asking clarifying questions. -->

**Integration Points:**
- [System/API 1]: [How this feature interacts with it]
- [System/API 2]: [How this feature interacts with it]

**Data Requirements:**
- [Data entity 1]: [What data is needed, source, format]
- [Data entity 2]: [What data is needed, source, format]

**Technical Constraints:**
- [Constraint 1]: [Description and rationale]
- [Constraint 2]: [Description and rationale]

**Codebase Context:**
- [Relevant area 1]: [What exists, where to look]
- [Relevant area 2]: [What exists, where to look]

### Design Considerations

<!-- Adapt: Think about how the experience should feel, not just what it does.
     What's the emotional tone? What should feel effortless vs. deliberate? -->

**Key UX Principles:**
- [Principle 1]: [How it applies to this feature]
- [Principle 2]: [How it applies to this feature]

**Interaction Patterns:**
- [Pattern 1]: [Description]
- [Pattern 2]: [Description]

**Accessibility Requirements:**
- [Requirement 1]
- [Requirement 2]

### Comps / Inspiration

<!-- Optional but recommended: What products solve a similar problem well?
     What patterns can we learn from? Grounds design thinking in proven approaches. -->

| Product | Pattern | Relevance |
|---------|---------|-----------|
| [Product 1] | [What they do] | [How it informs our approach] |
| [Product 2] | [What they do] | [How it informs our approach] |

### Dependencies

| Dependency | Owner | Status | Risk | Mitigation |
|------------|-------|--------|------|------------|
| [Dependency 1] | [Team/Person] | [Status] | [Low/Med/High] | [Mitigation plan] |
| [Dependency 2] | [Team/Person] | [Status] | [Low/Med/High] | [Mitigation plan] |

### Constraints and Assumptions

**Constraints:**
- [Constraint 1]: [Description]
- [Constraint 2]: [Description]

**Assumptions:**
- [Assumption 1]: [Description] — *Validation: [How to validate]*
- [Assumption 2]: [Description] — *Validation: [How to validate]*

### Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | [Low/Med/High] | [Low/Med/High] | [Mitigation strategy] |
| [Risk 2] | [Low/Med/High] | [Low/Med/High] | [Mitigation strategy] |

---

## Go-To-Market

### Rollout

| Phase | Audience | Duration | Decision Point |
|-------|----------|----------|----------------|
| [Phase 1] | [Who gets it] | [Duration] | [What determines next step] |
| [Phase 2] | [Who gets it] | [Duration] | [What determines next step] |

### Positioning

**Internal:** [How to communicate internally]

**External:** [How to communicate to users/customers]

### Launch

- [Launch activity 1]
- [Launch activity 2]

### Adoption

- [How users will discover/adopt this]
- [Any user education required]

### Revenue *(Optional)*

- [Direct revenue impact, if any]
- [Downstream revenue implications (e.g., retention → LTV)]
- [Pricing or packaging considerations]

---

## Decision Log

<!-- Recommended: Capture key decisions as they're made during drafting and review.
     This documents the thinking process, not just the outputs. Agents should populate
     this as they make choices, and it prevents re-litigating settled questions. -->

| Decision | Options Considered | Choice | Rationale | Date |
|----------|-------------------|--------|-----------|------|
| [Decision 1] | [Options] | [Choice] | [Why] | [Date] |
| [Decision 2] | [Options] | [Choice] | [Why] | [Date] |

---

## Open Questions

<!-- Adapt format: Use a table for structured tracking, or a simple bulleted list
     for more conversational questions. Both work—choose what fits the project.
     For agentic engineering, questions that block implementation should be clearly
     flagged so agents treat them as blockers. -->

**[Question 1]**

**[Question 2]**

**[Question 3]**

---

## Research

### Strategy Context *(Optional)*

<!-- How does this PRD connect to broader strategy? Reference mission, vision,
     retention frameworks, or strategic priorities where available. -->

[How this initiative fits within the broader strategy. Reference specific strategy documents, frameworks, or priorities.]

### Quantitative Data

| Data Point | Value | Source | Implication |
|------------|-------|--------|-------------|
| [Data 1] | [Value] | [Source] | [What it means] |
| [Data 2] | [Value] | [Source] | [What it means] |

### Qualitative Insights

> "[Quote from user research]"
> *Source: [Source]*

> "[Quote from user research]"
> *Source: [Source]*

### Product Critique *(Optional)*

<!-- Insights from product critique, taste analysis, or UX review that informed this PRD. -->

- [Insight 1]: [Source]
- [Insight 2]: [Source]

### Related Work

- [Related project/initiative 1]: [How it relates]
- [Related project/initiative 2]: [How it relates]

---

## Resources

- [Link to supporting document 1]
- [Link to supporting document 2]
- [Link to design mockups]
- [Link to data analysis]

---

## Appendix

<!-- Include supporting details that are useful for reference but would clutter
     the main document. Examples: draft content, algorithm logic, data tables,
     starter lists, format definitions, experiment assignment logic. -->

[Supporting details, technical specifications, data tables, etc.]

---

## Quality Guidelines

<!-- These are quality targets for agentic engineering, not rigid gates. Not every PRD
     needs every item checked—use judgment based on the project's stage and complexity.
     The goal: an AI agent should be able to create a tech plan and execute tasks
     autonomously from this document. -->

### Clarity & Completeness
- [ ] **Problem is specific:** The opportunity section quantifies the problem with data
- [ ] **Success is measurable:** Primary metric has a specific target and measurement method
- [ ] **Scope is explicit:** In-scope and out-of-scope tables have no ambiguous items

### Technical Readiness
- [ ] **Integration points documented:** All systems this touches are listed with interaction details
- [ ] **Data requirements specified:** What data is needed, where it comes from, what format
- [ ] **Constraints are explicit:** Technical limitations that affect implementation are stated
- [ ] **Codebase context provided:** Relevant areas of the codebase identified

### Acceptance Criteria Quality
- [ ] **Requirements are testable:** Every major requirement has verifiable criteria
- [ ] **Structured format used where appropriate:** Given/When/Then or equivalent for behavioral criteria
- [ ] **Edge cases covered:** Scenarios include error states and edge cases

### Decision Completeness
- [ ] **No open blockers:** All "Open Questions" are either resolved or marked as non-blocking
- [ ] **Key decisions logged:** Major decisions are documented with rationale
- [ ] **Assumptions are validatable:** Each assumption has a validation method

### Implementation Path
- [ ] **Dependencies identified:** All dependencies have owners and risk assessments
- [ ] **Phases defined:** Evolution section shows clear implementation sequence
- [ ] **Rollout planned:** GTM section defines how to ship incrementally

---

*This PRD is optimized for agentic engineering. An AI agent should be able to create a technical plan and complete implementation tasks autonomously from this document.*
