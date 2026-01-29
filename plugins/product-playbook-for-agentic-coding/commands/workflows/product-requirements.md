---
name: playbook:product-requirements
description: Draft product requirements with multi-persona discovery process. Supports autonomous and interview modes.
argument-hint: "[--autonomous] [--context <path>] [brief project description]"
---

# Draft Product Requirements

You are facilitating the Product Discovery phase. Your goal is to create a comprehensive, **agent-ready** Product Requirements Document (PRD) that enables autonomous technical planning and implementation.

## Modes

This command supports two modes:

### Interview Mode (Default)
Guided multi-persona discovery with probing questions. Use when:
- Requirements are unclear or evolving
- You need to explore the problem space
- User wants to be involved in shaping the PRD

### Autonomous Mode (`--autonomous`)
Generate a complete PRD draft from available context. Use when:
- Sufficient context already exists (docs, research, data)
- User wants a first draft to react to
- Time is limited

Parse the arguments to determine mode:
- If `--autonomous` flag is present → Autonomous Mode
- If `--context <path>` is provided → Use that path for context gathering
- Otherwise → Interview Mode (default)

---

## Autonomous Mode Process

### Step 1: Gather Context

Search extensively for existing documentation:

```
Context sources (search in order):
1. --context path (if provided)
2. docs/, docs/projects/, projects/
3. CLAUDE.md, AGENTS.md, README.md
4. Any files mentioned in user's description
5. Related research, data analysis, meeting notes
```

Use Glob → Grep → Read strategy to find and read all relevant context.

**Minimum context required for autonomous mode:**
- Clear problem statement or opportunity
- Target user/audience information
- Some form of success criteria or goals
- Basic scope understanding

If minimum context is not found, inform the user and switch to Interview Mode.

### Step 2: Extract Insights

From gathered context, extract:
- **Problem/Opportunity:** What problem are we solving? What's the evidence?
- **Users:** Who has this problem? What are their contexts?
- **Current State:** How do users solve this today?
- **Proposed Solution:** What's the high-level approach?
- **Success Criteria:** How will we measure success?
- **Constraints:** Technical, timeline, resource limitations
- **Risks:** What could go wrong?

### Step 3: Draft the PRD

Use the template at `resources/templates/product-requirements-v2.md` to create a complete PRD.

**Agent-Ready Requirements:**
- Every functional requirement MUST have testable acceptance criteria
- Use Given/When/Then format for acceptance criteria
- Include edge cases in scenarios
- Document all integration points and data requirements
- Capture decisions with rationale in Decision Log
- Mark any unresolved questions as Open Questions

### Step 4: Validate Completeness

Run through the Agent-Ready Checklist at the end of the template. For any items that cannot be checked:
- Mark them explicitly as incomplete
- Add corresponding Open Questions
- Recommend follow-up actions

### Step 5: Present for Review

Present the draft to the user with:
- Summary of context sources used
- Key decisions made (with rationale)
- Items marked incomplete or needing validation
- Recommended next steps

---

## Interview Mode Process

### Step 1: Understand the Project

Ask the user about their project:
- What problem are they trying to solve?
- Who has this problem?
- Why is this problem important to solve now?
- What's their initial vision for a solution?

### Step 2: Search for Existing Context

Before deep discovery, search for existing documentation:
1. **Search for docs**: Look in `docs/`, `docs/projects/`, `projects/` for relevant context
2. **Check for instructions**: Look for `CLAUDE.md`, `AGENTS.md`, `README.md`
3. **Find existing work**: Search for any prior product requirements, research, or planning docs

Use Glob → Grep → Read strategy. Summarize what you found.

### Step 3: Pre-Draft Clarification Gate

**Before creating any document**, ask and capture answers to these clarifying questions:

| Question | Why It Matters for Agents |
|----------|---------------------------|
| What is the single most important outcome? | Defines primary success metric |
| Who is the primary user and their context? | Enables accurate scenarios |
| What constraints are already known? | Prevents invalid technical plans |
| What is explicitly out of scope? | Prevents scope creep |
| What does success look like (quantitative)? | Enables testable acceptance criteria |
| What existing systems does this touch? | Enables accurate dependency mapping |

**Proceed only after these are answered clearly.** Summarize understanding and confirm alignment.

### Step 4: Multi-Persona Discovery

**Roles**: Product Manager (lead), Business Stakeholder, Domain Expert, Technical Advisor, User Researcher, Designer, Agentic Engineer.

For each section, ask probing questions from multiple perspectives:

#### Opportunity Definition
**From Product Manager + Domain Expert:**
- "What's the root cause vs symptoms?"
- "What data supports this being a problem?"
- "What happens if we don't solve this?"

#### User Understanding
**From User Researcher + Designer:**
- "Walk me through a specific user's day when they encounter this problem"
- "What are the edge cases—users who don't fit the primary persona?"
- "What accessibility needs should we consider?"

#### Solution Vision
**From Product Manager + Technical Advisor:**
- "What are the possible solution approaches?"
- "What's the simplest version that would validate our hypothesis?"
- "What makes this solution unique/defensible?"

#### Technical Context (Critical for Agents)
**From Technical Advisor + Agentic Engineer:**
- "What existing systems does this need to integrate with?"
- "What data does this need, and where does it come from?"
- "What areas of the codebase are relevant to this feature?"
- "What technical constraints will affect implementation?"

#### Success Criteria
**From Business Stakeholder + Product Manager:**
- "What's the primary metric, and what specific target makes this a success?"
- "How will we measure this metric?"
- "What guardrail metrics should we monitor?"

#### Acceptance Criteria (Critical for Agents)
**From Agentic Engineer:**
- "For each requirement, what would a test case look like?"
- "What are the edge cases that need explicit handling?"
- "What error states need to be defined?"

### Step 5: Draft the Document

Create the PRD using `resources/templates/product-requirements-v2.md`.

Ensure every section is filled with:
- **Specific, measurable** content (not placeholders)
- **Testable acceptance criteria** for all requirements
- **Explicit scope boundaries**
- **Technical context** sufficient for tech planning

### Step 6: Validate Agent-Readiness

Review against the Agent-Ready Checklist:

**Clarity & Completeness**
- [ ] Problem is quantified with data
- [ ] Success metric has specific target and measurement method
- [ ] Scope tables have no ambiguous items

**Technical Readiness**
- [ ] All integration points documented
- [ ] Data requirements specified
- [ ] Constraints are explicit
- [ ] Codebase context provided

**Acceptance Criteria Quality**
- [ ] All requirements have acceptance criteria
- [ ] Given/When/Then format used
- [ ] Edge cases covered in scenarios

**Decision Completeness**
- [ ] No open blockers
- [ ] Key decisions logged with rationale
- [ ] Assumptions have validation methods

For any unchecked items, either:
1. Ask follow-up questions to fill the gap
2. Mark as Open Questions in the document

---

## Key Principles

### For Both Modes

- **Agent-Ready is the bar**: The PRD must enable autonomous tech planning and task completion
- **Explicit over implicit**: Nothing should be left to interpretation
- **Testable criteria**: Every requirement must have verifiable acceptance criteria
- **Technical context matters**: Integration points, data, constraints must be documented

### For Interview Mode

- **Ask questions actively**: Your primary role is probing questions, not filling templates
- **Multi-perspective view**: Draw from all stakeholder perspectives
- **Challenge assumptions**: Ask "Why?" and "What if?" questions
- **Validate understanding**: Summarize and confirm before moving forward

### For Autonomous Mode

- **Use all available context**: Search thoroughly before drafting
- **Make decisions explicit**: Document any decisions you made with rationale
- **Flag uncertainty**: Mark assumptions and open questions clearly
- **Present for validation**: Always have user review autonomous output

---

## Output

Create the PRD at an appropriate location:
- Default: `docs/projects/[project-name]/product-requirements.md`
- Or: Path specified by user

---

## Next Steps

Once the PRD is complete, guide the user to:
1. **Review the Agent-Ready Checklist** — ensure all items are checked
2. **Resolve Open Questions** — these are blockers for autonomous work
3. **Proceed to Tech Planning** — use `/playbook:tech-plan` for the next phase

---

*This command creates PRDs optimized for agentic engineering—enabling autonomous technical planning and implementation.*
