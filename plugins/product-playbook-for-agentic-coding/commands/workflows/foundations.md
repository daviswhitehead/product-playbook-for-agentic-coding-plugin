---
name: playbook:foundations
description: Build strategy foundations that anchor all downstream product decisions. Creates Mission, Vision, Personas, and Engagement frameworks.
argument-hint: "[--context <path>] [brief product/project description]"
---

# Build Strategy Foundations

You are facilitating the creation of a **Strategy Stack** — the foundation documents that anchor all downstream product decisions. Every PRD, prioritization decision, and product idea should trace back to these foundations.

## Why Foundations Matter

Without foundations, PRDs float without strategic anchoring. Ideas get debated on taste instead of strategy. Prioritization becomes political instead of evidence-based. Foundations solve this by creating shared decision filters.

## The Strategy Stack

Foundation documents build on each other in a deliberate sequence:

```
Mission (why we exist)
  → Vision (where we're going)
    → Core Promise (what we uniquely deliver)
      → Problem Statement (what we're solving)
        → Personas (who we serve)
          → Value Propositions (what value we provide each persona)
            → Retention/Engagement Framework (how we measure success at each moment)
              → Competitive Landscape (how we differentiate)
                → Success Metrics (how we know we're winning)
```

Not every project needs every layer. A small feature may only need Personas and a Problem Statement. A new product strategy needs the full stack.

## Process

### Step 1: Assess Scope

Ask the user:
- Are we creating foundations for a **new product/strategy** (full stack) or a **specific project** (targeted)?
- What already exists? (Search for existing strategy docs, CLAUDE.md, README.md, prior foundations)
- What sources are available? (Interviews, data, company docs, competitive research)

Based on the answer, determine which sections to include.

### Step 2: Gather Context

Search extensively for existing materials:

```
Search order:
1. --context path (if provided)
2. docs/, docs/foundations/, docs/strategy/
3. CLAUDE.md, AGENTS.md, README.md
4. Company materials (about pages, blog posts, marketing)
5. User research, interview notes, data analysis
6. Competitive analysis, market research
```

**Track your sources.** Every foundation statement should trace to evidence.

### Step 3: Build the Stack

Work through each section in order, because each builds on the previous.

**For each section:**
1. Present what you found in existing context
2. Draft the section based on evidence
3. Ask the user to validate or refine
4. Confirm before moving to the next section

**Key questions to ask at each layer:**

| Section | Key Questions |
|---------|---------------|
| **Mission** | "Why does this product exist? What would the world lose if it disappeared?" |
| **Vision** | "Where should this be in 2-5 years? What does wild success look like?" |
| **Core Promise** | "What do you deliver that no one else does? What would users miss most?" |
| **Problem Statement** | "What specific problem are you solving? What evidence supports this?" |
| **Personas** | "Who are the 2-3 most important user types? Walk me through their day." |
| **Value Propositions** | "What specific value does each persona get? How do they experience it?" |
| **Engagement Framework** | "What are the key moments in a user's journey? Where do they succeed or drop off?" |
| **Competitive Landscape** | "Who else solves this? What do they do well? Where do they fall short?" |
| **Success Metrics** | "What's the north star metric? What leading indicators predict it?" |

### Step 4: Cross-Reference and Validate

After completing the stack, verify internal consistency:
- Does each persona map to the problem statement?
- Do value propositions connect to the mission?
- Do success metrics measure what matters for the vision?
- Does the engagement framework cover the key moments for each persona?

Flag any inconsistencies for the user.

### Step 5: Document Sources

Create a sources table tracking which evidence informed each section. This makes the foundations defensible and updatable.

## Principles

### Evidence Over Assertion
Every foundation statement should trace to evidence — data, user research, stakeholder input, or competitive analysis. If evidence is thin, flag it.

### Build in Order
Earlier sections inform later ones. Don't jump ahead — the Mission shapes the Vision, which shapes Personas, which shape everything else.

### Living Documents
Foundations evolve as understanding deepens. Mark sections with confidence levels and revisit when new evidence emerges.

### Simplify Ruthlessly
Each section should be concise enough to be useful as a decision filter. If the Mission takes a paragraph to explain, it's too complicated.

### Adapt to Scope
A startup creating its first strategy needs the full stack. A team adding a feature needs Personas and a Problem Statement. Don't create ceremony for ceremony's sake.

## Output

Create the foundations document at an appropriate location:
- Default: `docs/foundations/strategy-foundations.md`
- Or: `projects/[project-name]/foundations.md`
- Or: Path specified by user

Use the template at `resources/templates/strategy-foundations.md` as a starting point, adapted to the project's scope.

## Next Steps

Once foundations are complete, guide the user to:
1. **Use foundations as decision filters** — reference them in PRDs and prioritization
2. **Proceed to Research Synthesis** — use `/playbook:research-synthesis` to structure research findings
3. **Proceed to Product Requirements** — use `/playbook:product-requirements` for the next phase
4. **Review periodically** — update foundations as new evidence emerges

---

*Strategy foundations are decision filters, not decoration. Every product idea should trace back to something here.*
