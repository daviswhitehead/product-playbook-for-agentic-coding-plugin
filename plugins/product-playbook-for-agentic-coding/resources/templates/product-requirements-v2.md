# Product Requirements Document

> **PRD Philosophy:** This document defines *what* we're building and *why*—not *how* to build it. The **Framing** section is the heart; **Solution** provides enough detail for technical planning without over-constraining. This PRD is optimized for agentic engineering: an AI agent should be able to create a tech plan and complete downstream tasks autonomously from this document alone.

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

[2-3 sentences expanding on the problem with supporting data]

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

**Current state:** [How things work today]
**Proposed state:** [How things will work after this ships]

[2-3 sentences describing the change concretely]

### Why

#### For Users

| User Need | Current Experience | Proposed Experience |
|-----------|-------------------|---------------------|
| [Need 1] | [Current state] | [Future state] |
| [Need 2] | [Current state] | [Future state] |
| [Need 3] | [Current state] | [Future state] |

#### For Business

**Strategic rationale:** [Why this matters for the business—connect to company goals]

**Impact forecast:**

| Metric | Baseline | Conservative | Optimistic |
|--------|----------|--------------|------------|
| [Primary metric] | [Current] | [+X%] | [+Y%] |
| [Secondary metric] | [Current] | [+X%] | [+Y%] |

**Revenue impact (if applicable):**

| Scenario | Annual Impact | Assumptions |
|----------|---------------|-------------|
| Conservative | $[X] | [Key assumptions] |
| Optimistic | $[Y] | [Key assumptions] |

**Forecast confidence:** [High / Medium / Low]. [Brief explanation of uncertainty and what would increase confidence]

### Hypotheses

**Primary hypothesis:**
> If we [action], then [outcome], because [rationale].

**Secondary hypothesis (if applicable):**
> If we [action], then [outcome], because [rationale].

### Success Metrics

| Metric | Definition | Target | Measurement Method |
|--------|------------|--------|-------------------|
| **Primary:** [Metric] | [Precise definition] | [Specific target] | [How to measure] |
| **Secondary:** [Metric] | [Precise definition] | [Specific target] | [How to measure] |
| **Guardrail:** [Metric] | [What we don't want to break] | [Threshold] | [How to monitor] |

---

## Solution

### Vision

[2-3 sentences describing the end-state vision in 6-12 months if this succeeds. Paint a picture of the ideal experience.]

### Evolution

| Phase | What We Ship | Timeline | What We Learn |
|-------|--------------|----------|---------------|
| **Phase 1** | [MVP scope] | [Timeframe] | [Learning goals] |
| **Phase 2** | [Iteration] | [Timeframe] | [Learning goals] |
| **Future** | [Full vision] | [Timeframe] | [N/A] |

### Functional Requirements

> **For Agentic Engineering:** Each requirement must have verifiable acceptance criteria. Use precise, testable language.

#### Requirement 1: [Name]

**Description:** [What this requirement accomplishes]

**Acceptance Criteria:**
- [ ] **Given** [precondition], **when** [action], **then** [expected result]
- [ ] **Given** [precondition], **when** [action], **then** [expected result]
- [ ] [Additional criteria as needed]

**Priority:** [Must Have / Should Have / Nice to Have]

#### Requirement 2: [Name]

**Description:** [What this requirement accomplishes]

**Acceptance Criteria:**
- [ ] **Given** [precondition], **when** [action], **then** [expected result]
- [ ] **Given** [precondition], **when** [action], **then** [expected result]

**Priority:** [Must Have / Should Have / Nice to Have]

[Continue for all requirements]

### Scenarios

> **For Agentic Engineering:** Scenarios provide concrete examples that reduce ambiguity. Each scenario should be implementable as a test case.

**Scenario 1: [Persona], the [context]**
[Name] [context description]. [What they do step-by-step]. [Expected outcome].

**Scenario 2: [Persona], the [context]**
[Name] [context description]. [What they do step-by-step]. [Expected outcome].

**Scenario 3: [Edge case or error scenario]**
[Description of edge case and expected handling].

### User Stories

> **Format:** As a [user type], I want [goal] so that [benefit].

1. **As a [user type]**, I want [goal] so that [benefit].
   - **Acceptance Criteria:**
     - [ ] [Testable criterion 1]
     - [ ] [Testable criterion 2]

2. **As a [user type]**, I want [goal] so that [benefit].
   - **Acceptance Criteria:**
     - [ ] [Testable criterion 1]
     - [ ] [Testable criterion 2]

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

> **For Agentic Engineering:** This section provides the technical context needed to create a tech plan without asking clarifying questions.

**Integration Points:**
- [System/API 1]: [How this feature interacts with it]
- [System/API 2]: [How this feature interacts with it]

**Data Requirements:**
- [Data entity 1]: [What data is needed, source, format]
- [Data entity 2]: [What data is needed, source, format]

**Technical Constraints:**
- [Constraint 1]: [Description and rationale]
- [Constraint 2]: [Description and rationale]

**Existing Patterns to Follow:**
- [Pattern 1]: [Where it exists, why to follow it]
- [Pattern 2]: [Where it exists, why to follow it]

### Design Considerations

**Key UX Principles:**
- [Principle 1]: [How it applies to this feature]
- [Principle 2]: [How it applies to this feature]

**Interaction Patterns:**
- [Pattern 1]: [Description]
- [Pattern 2]: [Description]

**Accessibility Requirements:**
- [Requirement 1]
- [Requirement 2]

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

---

## Decision Log

> **For Agentic Engineering:** This section captures key decisions so agents don't re-litigate settled questions.

| Decision | Options Considered | Choice | Rationale | Date |
|----------|-------------------|--------|-----------|------|
| [Decision 1] | [Options] | [Choice] | [Why] | [Date] |
| [Decision 2] | [Options] | [Choice] | [Why] | [Date] |

---

## Open Questions

> **For Agentic Engineering:** Questions that must be answered before implementation can proceed. Agents should flag these as blockers.

| Question | Owner | Status | Answer |
|----------|-------|--------|--------|
| [Question 1] | [Who can answer] | [Open/Resolved] | [Answer if resolved] |
| [Question 2] | [Who can answer] | [Open/Resolved] | [Answer if resolved] |

---

## Research

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

### Competitive/Comparable Analysis

| Product | Pattern | Relevance |
|---------|---------|-----------|
| [Product 1] | [What they do] | [How it informs our approach] |
| [Product 2] | [What they do] | [How it informs our approach] |

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

[Supporting details, technical specifications, data tables, etc.]

---

## Agent-Ready Checklist

> **For Agentic Engineering:** Before considering this PRD complete, verify the following. An agent should be able to answer "yes" to all items.

### Clarity & Completeness
- [ ] **Problem is specific:** The opportunity section quantifies the problem with data
- [ ] **Success is measurable:** Primary metric has a specific target and measurement method
- [ ] **Scope is explicit:** In-scope and out-of-scope tables have no ambiguous items

### Technical Readiness
- [ ] **Integration points documented:** All systems this touches are listed with interaction details
- [ ] **Data requirements specified:** What data is needed, where it comes from, what format
- [ ] **Constraints are explicit:** Technical limitations that affect implementation are stated
- [ ] **Existing patterns identified:** Relevant patterns in the codebase to follow

### Acceptance Criteria Quality
- [ ] **All requirements have acceptance criteria:** Every functional requirement has testable criteria
- [ ] **Given/When/Then format used:** Criteria follow structured format where appropriate
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
