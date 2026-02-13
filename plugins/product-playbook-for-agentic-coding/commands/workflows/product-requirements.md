---
name: playbook:product-requirements
description: Draft product requirements with multi-persona discovery process. Supports autonomous and interview modes.
argument-hint: "[--autonomous] [--context <path>] [brief project description]"
---

# Draft Product Requirements

You are facilitating the Product Discovery phase. Your goal is to create a comprehensive, **agent-ready** Product Requirements Document (PRD) that enables autonomous technical planning and implementation.

## Step 0: Workflow Mode Detection

**Before starting discovery**, determine what type of work this is. Different work types need different workflow depth.

Ask the user:
```
What type of work is this?

1. **New feature / major addition** — Needs full discovery, planning, and task breakdown
   Examples: new page, new integration, new data model, new user flow
   → Full pipeline: PRD → Tech Plan → Tasks → Work → Learnings

2. **UI polish / iteration** — Known scope, feedback-driven, just needs execution
   Examples: spacing fixes, animation tweaks, responsive adjustments, copy changes
   → Lightweight: Scope note → Work directly → Learnings

3. **Bug fix / targeted repair** — Something is broken, needs systematic debugging
   Examples: broken layout, failed test, incorrect behavior, regression
   → Debug path: /playbook:debug → Learnings

4. **Refactor / technical improvement** — Code works but needs structural improvement
   Examples: extract component, improve types, reduce duplication, optimize performance
   → Lightweight with tech context: Quick scope → Work → Learnings

5. **Not sure yet** — Need to explore before deciding
   → Start with discovery questions, then route
```

### Routing Logic

**Route to Full Pipeline** (continue with this command) if ANY of:
- Work requires new data models or API endpoints
- Work touches 3+ systems or services
- Work needs architectural decisions not yet made
- Estimated scope is >20 files
- User selects option 1 or 5

**Route to Lightweight Path** if ALL of:
- Solution approach is already known
- Work is within a single system or component area
- No new architectural decisions needed
- Estimated scope is <20 files
- User selects option 2 or 4

**Route to Debug Path** if:
- User selects option 3
- Suggest: "Use `/playbook:debug` for systematic debugging, then `/playbook:learnings` to capture the solution."

### Lightweight Path (for options 2 and 4)

If routing to lightweight, skip the full PRD. Instead create a **scope note**:

```markdown
## Lightweight Scope Note

**Work type**: [UI polish | Refactor | Iteration]
**Goal**: [One sentence: what should be different when done]
**Files likely affected**: [List key files or components]
**Acceptance criteria**:
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
**Estimated scope**: [~N files]
**Approach**: [Brief description of how to accomplish it]
```

Save to `projects/[project-name]/scope-note.md` (or inline if trivial).

Then guide the user:
```
This looks like lightweight work. I've created a scope note instead of a full PRD.

Next steps:
1. Review the scope note above
2. Jump directly to implementation with `/playbook:work` (using scope note as context)
3. Capture learnings when done with `/playbook:learnings`

No tech plan or task document needed for this scope.
```

For option 4 (refactor), also ask: "What's the current pattern, the target pattern, and are there tests covering this code?"

---

## Full Pipeline (continues below for option 1 or 5)

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

## Principles for Quality PRDs

These principles apply to both modes. They represent hard-won learnings about what makes PRDs effective:

### Simplify Ruthlessly
Iterate toward simplicity, not complexity. If a section feels overcomplicated, cut rather than explain. Fewer words with more precision beats comprehensive but dense.

### Surface Uncertainty
Don't hide what you don't know. Use forecast confidence levels (High / Medium / Low) and explain what's uncertain. Flag assumptions explicitly. Suggest what would increase confidence. Example: "High uncertainty. These projections require validation through experimentation."

### Ground in Evidence
Every claim should trace to a source — data, user research, product critique, or strategic reasoning. Preference for data, but judgment and taste count too. Be data-informed, not data-driven.

### Anchor in Strategy
When strategy docs exist (mission, vision, retention frameworks, personas), connect the PRD to them. PRDs aren't isolated specs — they're part of a strategic narrative.

### Document Thinking
Capture key decisions with rationale in the Decision Log. The thinking process is as valuable as the output. When you simplify a section or reject an approach, note why.

### Adapt the Template
The template at `resources/templates/product-requirements-v2.md` is a strong starting point, not a rigid form. Add sections that serve the project (e.g., Prioritization Analysis, Experiment Design). Remove sections that don't apply. Rename sections to fit the domain. Write a genuine philosophy note for each PRD.

---

## Autonomous Mode Process

### Step 1: Gather Context

Search extensively for existing documentation:

```
Context sources (search in order):
1. --context path (if provided)
2. projects/, docs/projects/, docs/
3. CLAUDE.md, AGENTS.md, README.md
4. Strategy and foundation docs (mission, vision, retention framework, personas)
5. Any files mentioned in user's description
6. Related research, data analysis, meeting notes
```

Use Glob → Grep → Read strategy to find and read all relevant context.

**Track your sources.** Record which files you read and what you extracted from each. You will include a Context Summary in your output showing which sources informed which sections.

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
- **Current State:** How do users solve this today? What's the current flow?
- **Proposed Solution:** What's the high-level approach?
- **Success Criteria:** How will we measure success? How should results be segmented?
- **Strategy Context:** How does this connect to broader strategy or frameworks?
- **Comps/Inspiration:** What products solve similar problems well?
- **Constraints:** Technical, timeline, resource limitations
- **Risks:** What could go wrong?
- **Confidence:** Where is confidence high vs. where does it need validation?

### Step 3: Draft the PRD

Use the template at `resources/templates/product-requirements-v2.md` as a starting point, then adapt it to fit the project.

**Key requirements:**
- Write a genuine, tailored philosophy note (not boilerplate)
- Fill every section with specific, measurable content (not placeholders)
- Use the format that communicates most clearly — narrative, tables, Given/When/Then, or a hybrid
- Include edge cases in scenarios
- Document all integration points and data requirements
- Capture decisions with rationale in Decision Log
- Include forecast confidence assessments where projections appear
- Mark any unresolved questions as Open Questions

### Step 4: Validate Completeness

Run through the Quality Guidelines at the end of the template. These are quality targets, not rigid gates — use judgment based on the project's stage and complexity.

For any items that cannot be checked:
- Mark them explicitly as incomplete
- Add corresponding Open Questions
- Recommend follow-up actions

### Step 5: Present for Review

Present the draft to the user with:
- **Context summary**: Which source files informed which sections
- **Key decisions made** (with rationale, from the Decision Log)
- **Confidence assessment**: What's solid vs. needs validation
- **Items marked incomplete** or needing validation
- **Recommended next steps**

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
1. **Strategy docs**: Look for mission, vision, retention frameworks, strategic priorities
2. **Research and data**: Look for analyses, user research, product critiques, meeting notes
3. **Project docs**: Look in `projects/`, `docs/projects/`, `docs/` for relevant context
4. **Instructions**: Look for `CLAUDE.md`, `AGENTS.md`, `README.md`
5. **Prior work**: Search for existing PRDs, feature specs, or planning docs

Use Glob → Grep → Read strategy. Summarize what you found — this grounds the conversation in existing context rather than starting from zero.

### Step 3: Pre-Draft Clarification Gate

**Before creating any document**, ask and capture answers to these clarifying questions:

| Question | Why It Matters |
|----------|----------------|
| What is the single most important outcome? | Defines primary success metric |
| Who is the primary user and their context? | Enables accurate scenarios |
| What constraints are already known? | Prevents invalid technical plans |
| What is explicitly out of scope? | Prevents scope creep |
| What does success look like (quantitative)? | Enables testable acceptance criteria |
| What existing systems does this touch? | Enables accurate dependency mapping |
| How confident are we in these projections? | Surfaces uncertainty early |

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

#### Comps & Inspiration
**From Designer + Domain Expert:**
- "What products solve a similar problem well? What patterns can we learn from?"
- "How should the experience feel? What's the emotional tone?"
- "What design patterns should we reference or avoid?"

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
- "How should results be segmented? Will different cohorts respond differently?"
- "How confident are we in these projections? What would increase confidence?"

#### Acceptance Criteria (Critical for Agents)
**From Agentic Engineer:**
- "For each requirement, what would a test case look like?"
- "What are the edge cases that need explicit handling?"
- "What error states need to be defined?"

### Step 5: Draft the Document

Create the PRD using `resources/templates/product-requirements-v2.md` as a starting point, adapting it to fit the project.

Ensure every section is filled with:
- **Specific, measurable** content (not placeholders)
- **Verifiable criteria** for all major requirements
- **Explicit scope boundaries**
- **Technical context** sufficient for tech planning
- **A genuine philosophy note** tailored to this PRD
- **Forecast confidence** assessments where projections appear
- **Decisions captured** in the Decision Log

### Step 6: Validate Quality

Review against the Quality Guidelines:

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
- [ ] Major requirements have verifiable criteria
- [ ] Structured format used where appropriate
- [ ] Edge cases covered in scenarios

**Decision Completeness**
- [ ] No open blockers
- [ ] Key decisions logged with rationale
- [ ] Assumptions have validation methods

These are quality targets, not rigid gates. For any unchecked items, either:
1. Ask follow-up questions to fill the gap
2. Mark as Open Questions in the document

---

## Key Principles

### For Both Modes

- **Agent-Ready is the bar**: The PRD must enable autonomous tech planning and task completion
- **Explicit over implicit**: Nothing should be left to interpretation
- **Testable criteria**: Major requirements must have verifiable acceptance criteria
- **Technical context matters**: Integration points, data, constraints must be documented
- **Adapt the template**: The template is a starting point — customize it for the project

### For Interview Mode

- **Ask questions actively**: Your primary role is probing questions, not filling templates
- **Multi-perspective view**: Draw from all stakeholder perspectives
- **Challenge assumptions**: Ask "Why?" and "What if?" questions
- **Validate understanding**: Summarize and confirm before moving forward

### For Autonomous Mode

- **Use all available context**: Search thoroughly before drafting
- **Track your sources**: Document which files informed which sections
- **Make decisions explicit**: Document any decisions you made with rationale
- **Flag uncertainty**: Mark assumptions and open questions clearly
- **Present for validation**: Always have user review autonomous output

---

## Output

Create the PRD at an appropriate location:
- Default: `projects/[project-name]/product-requirements.md`
- Or: Path specified by user

---

## Next Steps

Once the PRD is complete, guide the user to:
1. **Review the Quality Guidelines** — verify key items are addressed
2. **Resolve Open Questions** — these are blockers for autonomous work
3. **Run a stakeholder critique** — use `/playbook:critique` to get multi-persona feedback on the PRD before proceeding. Critiques at document stages are the highest-ROI workflow step — catching issues here is 10x cheaper than during implementation.
4. **Proceed to Tech Planning** — use `/playbook:tech-plan` for the next phase

---

*This command creates PRDs optimized for agentic engineering—enabling autonomous technical planning and implementation.*
