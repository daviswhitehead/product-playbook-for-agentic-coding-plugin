---
name: conciseness-check
description: Quality check for AI-generated output. Detects and removes hedge stacking, throat-clearing, motivational padding, restating, and unnecessary transitions. Use before presenting any substantive artifact to the user. Don't use for code comments or commit messages (those have their own conventions).
---

# Conciseness Check

Run this check before presenting any substantive artifact (PRD, tech plan, research synthesis, critique, handoff note) to the user.

## Section 1: Filler Patterns to Eliminate

Scan the artifact for these patterns. When found, apply the fix immediately.

| Pattern | Example | Fix |
|---------|---------|-----|
| Hedge stacking | "it's worth noting that perhaps" | State directly or omit |
| Unnecessary transitions | "with that in mind", "building on the above" | Delete — context is implicit from document structure |
| Throat-clearing | "in order to effectively address" | Start with the verb |
| Motivational padding | "this powerful approach enables teams to" | State what it does, drop the adjectives |
| Restating | Same point in different words in consecutive sentences | Keep the stronger version, delete the other |
| Meta-commentary | "I wanted to reach out to...", "as mentioned above" | Delete |
| Excessive hedging | "it might be possible that this could potentially" | Pick one hedge or commit to the statement |

### Additional Signals

- **Bullet points that restate the heading**: If a section heading says "Performance Risks" and the first bullet says "There are several performance risks to consider", delete the bullet.
- **Paragraphs that end where they started**: If the last sentence says the same thing as the first, delete one.
- **Qualify-then-unqualify**: "While there are many approaches, the best approach is X" — just say "X is the best approach."

## Section 2: Critique Before Checkpoint

Multi-phase commands that produce a substantive artifact should run a self-review pass before presenting to the user.

### When to Self-Review

Apply this when the output is:
- A document others will read (PRD, tech plan, research synthesis)
- A synthesis of multiple inputs (critique synthesis, research synthesis)
- A communication draft (handoff note, stakeholder update)

Skip for:
- Quick answers to direct questions
- Code output (different conventions apply)
- Task status updates

### Self-Review Process

1. **Scan for filler patterns** from Section 1. Fix silently.
2. **Check structure**: Are conclusions buried? Is there a clear hierarchy? Are sections redundant?
3. **Check specificity**: Replace vague claims with concrete ones. "Several issues" → "3 issues." "Significant impact" → "affects 40% of users."
4. **Cut length**: Read each paragraph and ask "does removing this lose information?" If no, remove it.

Fix issues silently. The user sees clean output, not the self-check process.

## Section 3: Stakeholder Document Structure

Any document going to multiple reviewers should use a two-layer structure.

### At-a-Glance (The Main Document)

- Self-sufficient — a reader who stops here has everything needed to decide or give feedback
- States decisions plainly — no teasers ("see appendix for details")
- As short as possible — every sentence earns its place

### Appendix (The Reference Material)

- Detailed analysis, evidence, methodology
- Sources and references
- Options considered and rejected
- Supporting data tables or calculations

### Boundary

Use a clear separator between the two layers:

```markdown
---

## Appendix

[Reference material below]
```

### When to Apply

Apply this structure when the artifact:
- Will be read by people who didn't request it (stakeholders, reviewers)
- Contains both decisions and the analysis behind them
- Exceeds ~2 pages of content

Skip for:
- Internal working documents (task lists, checkpoint notes)
- Single-reader artifacts (handoff notes to yourself)
- Short artifacts that don't need layering

## Proactive Invocation

This skill runs as an internal self-check, not a user-facing suggestion:
- Before presenting any multi-paragraph artifact (PRD, tech plan, research synthesis, critique synthesis, handoff note)
- As part of the Critique Before Checkpoint process (Section 2)

No user prompt needed — apply silently as part of output quality control.
