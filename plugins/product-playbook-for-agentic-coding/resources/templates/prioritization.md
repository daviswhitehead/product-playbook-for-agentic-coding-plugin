<!--
TEMPLATE GUIDANCE (for agents — do not include this block in output):

This template provides a customizable prioritization framework. The default
uses a RICE-inspired approach, but agents should adapt the scoring dimensions,
formula, and designations to fit the project's context.

Key principles:
- Show your work: transparent calculations build stakeholder trust
- Evidence quality matters: cite sources for each score
- Designations are communication tools: "No Brainer" / "Quick Win" / "Big Bet" / "Don't Do"
  make prioritization conversations productive
- The framework is a starting point for discussion, not a final answer

This template is designed to be used AFTER research synthesis and BEFORE PRDs.
The ideas scored here should trace back to opportunities from research synthesis,
and top-ranked ideas should become PRDs.
-->

# Prioritization Analysis

> [Brief note on what's being prioritized, what framework is used, and how this connects to the research/strategy that produced these ideas.]

---

## Framework

<!-- Adapt: Use the scoring framework that fits the project's context.
     Common options: RICE, ICE, Impact/Effort, Custom weighted scoring.
     The key is transparency — show the formula and explain what each dimension means. -->

### Scoring Dimensions

| Dimension | Scale | Definition |
|-----------|-------|------------|
| **Reach** | 1-5 | How many users/customers are affected? (1 = niche, 5 = nearly all) |
| **Impact** | 1-5 | How much does this influence the key outcome? (1 = marginal, 5 = transformative) |
| **Confidence** | 1-5 | How confident are we in achieving the outcome? (1 = speculative, 5 = proven) |
| **Effort** | 1-5 | How much work is required? (1 = trivial, 5 = major initiative) |

### Formula

```
Value = (Reach + Impact) / 2
Risk  = ((6 - Confidence) + Effort) / 2
Score = Value / Risk          (when Value > Risk)
Score = 0                     (when Value = Risk)
Score = -(Risk / Value)       (when Risk > Value)
```

### Designations

| Designation | Criteria | Action |
|-------------|----------|--------|
| **No Brainer** | High Value, Low Risk | Do first — high confidence, high impact |
| **Quick Win** | Lower Value, Low Risk | Easy wins — grab them when convenient |
| **Big Bet** | High Value, High Risk | Worth pursuing with validation — experiment first |
| **Don't Do** | Low Value, High Risk | Skip — poor return on investment |

---

## Ideas

<!-- List all ideas being considered. Each should trace to an opportunity
     from research synthesis or strategy foundations. -->

### Idea 1: [Name]

**Description:** [One-sentence description]

**Rationale:** [Why this idea addresses an identified opportunity]

**Evidence:** [What data, research, or insights support this]

**Scores:**

| Reach | Impact | Confidence | Effort | Value | Risk | Score | Designation |
|-------|--------|------------|--------|-------|------|-------|-------------|
| [1-5] | [1-5] | [1-5] | [1-5] | [calc] | [calc] | [calc] | [designation] |

### Idea 2: [Name]

**Description:** [One-sentence description]

**Rationale:** [Why this idea addresses an identified opportunity]

**Evidence:** [What data, research, or insights support this]

**Scores:**

| Reach | Impact | Confidence | Effort | Value | Risk | Score | Designation |
|-------|--------|------------|--------|-------|------|-------|-------------|
| [1-5] | [1-5] | [1-5] | [1-5] | [calc] | [calc] | [calc] | [designation] |

[Continue for all ideas]

---

## Summary Table

<!-- All ideas in a single sortable table, ranked by score. -->

| Rank | Name | Description | Reach | Impact | Confidence | Effort | Value | Risk | Score | Designation |
|------|------|-------------|-------|--------|------------|--------|-------|------|-------|-------------|
| 1 | [Name] | [Brief] | [R] | [I] | [C] | [E] | [V] | [Ri] | [S] | [D] |
| 2 | [Name] | [Brief] | [R] | [I] | [C] | [E] | [V] | [Ri] | [S] | [D] |
| 3 | [Name] | [Brief] | [R] | [I] | [C] | [E] | [V] | [Ri] | [S] | [D] |

---

## Evidence-Based Adjustments *(Optional)*

<!-- Document any scores that were adjusted based on specific evidence,
     and track how confidence changed across iterations. -->

| Idea | Dimension Adjusted | Original | Adjusted | Evidence | Reasoning |
|------|-------------------|----------|----------|----------|-----------|
| [Idea] | [Dimension] | [Old] | [New] | [What evidence prompted change] | [Why] |

---

## Recommendations

### Top Priorities (Recommend for PRD)

1. **[Idea Name]** — [One line on why this is the top priority]
2. **[Idea Name]** — [One line on why]
3. **[Idea Name]** — [One line on why]

### Quick Wins (Low-Effort Improvements)

- [Idea Name]: [What to do]
- [Idea Name]: [What to do]

### Needs Validation (Big Bets)

- [Idea Name]: [What validation is needed before committing]

### Not Recommended

- [Idea Name]: [Why it's not worth pursuing now]

---

## Assumptions and Caveats

- [Key assumption behind the scoring]
- [Known limitation of the analysis]
- [What would change the rankings]

---

## Next Steps

- [ ] Review rankings with stakeholders
- [ ] Create PRDs for top priorities → `/playbook:product-requirements`
- [ ] Design validation experiments for Big Bets
- [ ] Revisit rankings when new evidence emerges

---

*Prioritization is a communication tool, not just a decision tool. Transparent calculations build stakeholder trust and enable productive debates about assumptions, not conclusions.*
