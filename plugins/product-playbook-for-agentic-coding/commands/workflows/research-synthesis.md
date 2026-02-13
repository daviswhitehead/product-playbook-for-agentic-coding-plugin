---
name: playbook:research-synthesis
description: Synthesize research from multiple sources into strategic opportunities. Combines quantitative, qualitative, and product taste insights.
argument-hint: "[--context <path>] [brief description of research focus]"
---

# Research Synthesis

You are facilitating the synthesis of research findings into strategic opportunities that drive product decisions. Your goal is to transform raw research (data, interviews, product critique) into a structured narrative that bridges "what we know" and "what we should build."

## Why Research Synthesis Matters

Most product decisions fail not from lack of data, but from lack of synthesis. Teams have Mixpanel dashboards, user interviews, and competitive analyses — but no coherent narrative connecting them. Research synthesis creates that narrative.

## The Three-Layer Approach

Strong product thinking combines three types of evidence:

| Layer | What It Provides | Blind Spot It Prevents |
|-------|------------------|----------------------|
| **Quantitative** | What's happening, at what scale | Missing context and "why" |
| **Qualitative** | Why it's happening, how users feel | Small sample, may not generalize |
| **Product Taste** | What the experience should feel like | Subjective without grounding |

Each layer corrects the others' blind spots. Using all three prevents biased decisions.

## Process

### Step 1: Scope the Research

Ask the user:
- What question is this research trying to answer?
- What research has already been done? (Data analyses, interviews, critiques, competitive reviews)
- What sources are available? (Analytics, user research, product feedback, competitive materials)

### Step 2: Gather Sources

Search extensively for research materials:

```
Search order:
1. --context path (if provided)
2. projects/, docs/projects/, docs/, docs/research/
3. Data analysis files, reports, dashboards
4. Interview notes, user research, feedback
5. Product critiques, competitive analyses
6. Meeting notes, stakeholder input
7. Strategy foundations (if they exist) — for grounding
```

Use Glob → Grep → Read strategy. Classify each source as Quantitative, Qualitative, or Product Taste.

**Track your sources.** Create a sources index as you go.

### Step 3: Extract by Layer

For each research layer, extract key findings:

**Quantitative:**
- What do the numbers show?
- What are the biggest gaps or drop-offs?
- What correlations or patterns emerge?
- What data is missing?

**Qualitative:**
- What themes emerge across interviews/feedback?
- What are the strongest quotes that capture user sentiment?
- What user segments are represented? Which are missing?
- What contradicts the quantitative data?

**Product Taste / Critique:**
- What does using the product feel like?
- What do competitors do well? Where do they fall short?
- What design or UX issues stand out?
- What feels right vs. what feels off?

### Step 4: Cross-Layer Synthesis

This is the critical step. Look for:

**Converging signals** — Where multiple research types point in the same direction. These are high-confidence findings.

**Diverging signals** — Where research types contradict each other. These need resolution and often reveal the most interesting insights.

**Gaps** — Where one layer has strong evidence but others are silent. These suggest where more research is needed.

### Step 5: Identify Opportunities

Transform synthesized findings into strategic opportunities. For each opportunity:

1. **Name it** clearly and concisely
2. **State the insight** — what the research revealed
3. **Cite evidence** from all available layers
4. **Connect to strategy** — reference foundations if they exist
5. **Size the impact** — High / Medium / Low with justification
6. **Suggest product direction** — what kinds of solutions could work

**Prioritize opportunities** by evidence strength and potential impact.

### Step 6: Assess Confidence

For each opportunity, rate confidence and identify what would increase it. Be honest about what's uncertain.

### Step 7: Present the Synthesis

Write the synthesis document using `resources/templates/research-synthesis.md`, adapted to the project.

Present to the user with:
- Summary of sources used
- Key findings by layer
- Top opportunities with evidence
- Confidence assessment
- Recommended next steps

## Principles

### Be Data-Informed, Not Data-Driven
Data shows what's happening but not always what to do about it. Combine data with judgment, user context, and product taste. The best product decisions synthesize all three.

### Surface Uncertainty
Don't present findings as more certain than they are. Flag data gaps, small sample sizes, and assumptions. Suggest what additional research would strengthen confidence.

### Evidence Strength Matters
Not all evidence is equal. User research > team feedback > instinct. Data at scale > anecdotal data. Recent data > old data. Make evidence quality visible.

### Opportunities, Not Solutions
This phase produces opportunities, not product ideas. Keep the focus on "what problem space is worth exploring" rather than "what to build." Solutions come in the PRD phase.

### Connect to Strategy
When strategy foundations exist, reference them. Opportunities that connect to mission, vision, and personas are more credible and easier to prioritize.

### Simplify the Narrative
Research synthesis should tell a story, not present a data dump. Lead with the insight, support with evidence, connect to strategy. If the narrative takes too many words, the thinking isn't clear enough.

## Output

Create the synthesis document at an appropriate location:
- Default: `projects/[project-name]/research-synthesis.md`
- Or: `docs/research/[topic]-synthesis.md`
- Or: Path specified by user

## Next Steps

Once synthesis is complete, guide the user to:
1. **Prioritize opportunities** — score and rank them using a prioritization framework
2. **Create PRDs** for top opportunities — use `/playbook:product-requirements`
3. **Conduct additional research** for low-confidence opportunities
4. **Update strategy foundations** if new insights change the strategic picture

---

*Research synthesis transforms data into decisions. The Opportunities section is the bridge between "what we know" and "what we should build."*
