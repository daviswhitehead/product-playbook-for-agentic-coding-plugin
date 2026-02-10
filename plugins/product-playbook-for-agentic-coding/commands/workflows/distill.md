---
name: playbook:distill
description: Create focused summaries or quick references from longer documents, optimized for a specific purpose.
argument-hint: "<purpose> --from <sources> [--max-length <pages>] [--format <format>]"
---

# Document Distillation

You are creating a focused, actionable summary from longer source documents, optimized for a specific purpose or context.

## Your Goal

Transform comprehensive documentation into a concise reference that:
1. Serves a specific purpose (interview prep, presentation, quick reference)
2. Captures the most essential information
3. Is formatted for easy scanning and use
4. Links back to source documents for details

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (refine-doc, critique)
2. **Agents**: Specialized agents via Task tool (insight-extractor-agent)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools for the task at hand.

## Arguments

Parse the command arguments:
- `<purpose>`: What this distillation is for (e.g., "interview", "presentation", "quick-reference", "stakeholder-briefing")
- `--from <sources>`: Source documents or directories to distill
- `--max-length <pages>`: Target length (default: 2 pages / ~1000 words)
- `--format <format>`: Output format (bullet, prose, table, mixed)

## Process

### Step 1: Understand the Purpose

Different purposes require different distillation strategies:

| Purpose | Focus On | Format |
|---------|----------|--------|
| **interview** | Key talking points, likely questions, memorable examples | Bullet lists, Q&A format |
| **presentation** | Story arc, key messages, visual-friendly content | Headers + bullets, callout boxes |
| **quick-reference** | Essential facts, definitions, key numbers | Dense tables, bullet lists |
| **stakeholder-briefing** | Business impact, decisions needed, recommendations | Executive summary format |
| **onboarding** | Core concepts, where to find things, who to ask | Numbered guides, links |

**Ask if unclear**: "What situation will you use this in? Who's the audience?"

### Step 2: Analyze Source Material

Read the source documents and identify:

1. **Core concepts**: What are the 5-7 most important ideas?
2. **Key facts/numbers**: What data points are essential?
3. **Critical decisions**: What choices or recommendations are captured?
4. **Memorable examples**: What stories or examples illustrate key points?
5. **Action items**: What should the reader do with this information?

### Step 3: Apply Distillation Strategy

#### For Interview Prep
Focus on what you'll need to say and answer:

```markdown
# [Topic] Quick Reference

## Core Message (30-second version)
[Single paragraph that captures the essence]

## Key Points to Make
1. [Point 1 with supporting evidence]
2. [Point 2 with supporting evidence]
3. [Point 3 with supporting evidence]

## Likely Questions & Answers
**Q: [Anticipated question]**
A: [Prepared response with specific example]

**Q: [Anticipated question]**
A: [Prepared response]

## Numbers to Know
- [Key metric]: [value]
- [Key metric]: [value]

## Stories/Examples Ready to Use
- **[Story name]**: [1-sentence setup] → [Key point it illustrates]

## Quick Reminders
- [Don't forget X]
- [Emphasize Y]
```

#### For Presentations
Focus on narrative flow and key takeaways:

```markdown
# [Topic] Presentation Guide

## The Story Arc
1. **Hook**: [Opening that grabs attention]
2. **Problem**: [Why this matters]
3. **Solution**: [What we're proposing]
4. **Proof**: [Evidence it works]
5. **Ask**: [What we need]

## Key Slides Content

### Slide: [Title]
- [Bullet 1]
- [Bullet 2]
> Speaker note: [What to say]

### Slide: [Title]
- [Bullet 1]
- [Bullet 2]
> Speaker note: [What to say]

## Q&A Prep
[Anticipated questions and answers]
```

#### For Quick Reference
Focus on density and scannability:

```markdown
# [Topic] Quick Reference

## At a Glance
| Aspect | Key Info |
|--------|----------|
| [Category] | [Essential fact] |
| [Category] | [Essential fact] |

## Key Terms
- **[Term]**: [Definition]
- **[Term]**: [Definition]

## Critical Numbers
| Metric | Value | Context |
|--------|-------|---------|
| [Metric] | [Value] | [Why it matters] |

## Decision Framework
When [situation], do [action] because [reason].

## Where to Find More
- [Topic]: See [source-doc.md](path)
- [Topic]: See [source-doc.md](path)
```

#### For Stakeholder Briefing
Focus on decisions and business impact:

```markdown
# [Topic] Executive Briefing

## Bottom Line Up Front
[1-2 sentences: What do they need to know/decide?]

## Situation
[Brief context - what's happening]

## Recommendation
[What we propose and why]

## Impact
| Area | Expected Impact |
|------|-----------------|
| [Revenue/Cost/Risk] | [Quantified if possible] |

## Decision Needed
- [ ] [Specific approval or decision requested]

## Timeline
[Key dates and milestones]

## Appendix
[Link to detailed documents]
```

### Step 4: Respect Length Constraints

To hit target length:

1. **Start with everything essential**, then cut
2. **Prioritize ruthlessly**: What MUST be included?
3. **Use formatting to compress**: Tables > paragraphs, bullets > prose
4. **Link instead of include**: "For details, see [source]"
5. **Test the 30-second scan**: Can someone get the gist quickly?

### Step 5: Add Navigation Aids

Make the distillation easy to use:

1. **Table of contents** (for 2+ pages)
2. **Bold key terms** for scanning
3. **Numbered lists** for sequences
4. **"See also" links** to sources
5. **Version/date** for freshness

## Distillation Principles

### Preserve Accuracy
- Don't paraphrase in ways that change meaning
- Keep important caveats and nuances
- Link to sources for verification

### Optimize for Use Case
- Interview prep needs things you'll SAY
- Presentations need things you'll SHOW
- References need things you'll LOOK UP
- Briefings need things to DECIDE

### Make It Scannable
- Front-load the most important info
- Use headers liberally
- Bold key terms
- Keep paragraphs short

### Include Source Links
- Every section should link to detailed source
- Enable "drill down" when needed
- Maintain traceability

## Quality Checks

Before delivering:

- [ ] **Length**: Hits target (or explains why longer)
- [ ] **Coverage**: All essential points included
- [ ] **Accuracy**: No misrepresentations
- [ ] **Scannability**: Can get the gist in 30 seconds
- [ ] **Links**: Source documents referenced
- [ ] **Purpose-fit**: Formatted for the stated use case

## Example Usage

```
/playbook:distill interview --from docs/product-strategy/ --max-length 2
```

Creates a 2-page interview prep guide from product strategy docs.

```
/playbook:distill quick-reference --from foundations/ --format table
```

Creates a dense, table-heavy quick reference from foundations docs.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| Including everything | Ruthlessly prioritize for the purpose |
| Walls of text | Use bullets, tables, bold |
| Losing nuance | Keep important caveats |
| No source links | Always link to details |
| Generic format | Optimize for specific use case |

---

*Distill for action—create references people will actually use in the moment.*
