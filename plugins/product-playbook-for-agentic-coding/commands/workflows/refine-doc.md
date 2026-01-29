---
name: playbook:refine-doc
description: Incorporate new information or feedback into existing documents while maintaining consistency across related docs.
argument-hint: "<new-context> [--docs <path-or-pattern>] [--check-consistency]"
---

# Document Refinement

You are refining existing documents by incorporating new information, feedback, or context while maintaining consistency across related documents.

## Your Goal

When new information arrives (stakeholder feedback, new insights, changed requirements), systematically:
1. Understand how the new information relates to existing content
2. Identify all documents that may need updates
3. Make consistent changes across the document set
4. Verify cross-references remain valid

## Arguments

Parse the command arguments:
- `<new-context>`: The new information to incorporate (can be a quote, insight, or feedback)
- `--docs <path-or-pattern>`: Documents to consider (default: current directory)
- `--check-consistency`: Run consistency check across all related docs after changes

## Process

### Step 1: Understand the New Context

First, clarify what's being incorporated:

1. **What is the new information?**
   - A stakeholder quote or insight
   - Feedback on existing content
   - A new requirement or constraint
   - Updated data or facts

2. **What's the source?**
   - Who provided this information?
   - When was it captured?
   - What was the context?

3. **What's the intent?**
   - Add new content?
   - Modify existing content?
   - Strengthen/emphasize existing content?
   - Correct inaccurate content?

### Step 2: Assess Current State

Search the document set to understand how this topic is currently represented:

1. **Find related content**:
   ```
   - Grep for keywords related to the new context
   - Note which files mention this topic
   - Note line numbers and surrounding context
   ```

2. **Map the representation**:
   - Is this topic already covered? Where?
   - Is it mentioned in multiple places?
   - Are there inconsistencies in current coverage?

3. **Identify affected documents**:
   - Primary document(s) to update
   - Related documents that may need consistency updates
   - Documents that reference the affected sections

### Step 3: Plan Changes

Before making edits, create a change plan:

```markdown
## Refinement Plan

**New Context**: [Summary of the new information]
**Source**: [Who/where/when]

### Affected Documents

| Document | Current State | Proposed Change | Priority |
|----------|---------------|-----------------|----------|
| doc1.md | Mentions briefly at L45 | Expand with new quote | High |
| doc2.md | Related concept at L78 | Add cross-reference | Medium |
| doc3.md | No mention | No change needed | — |

### Cross-Reference Impacts
- [doc1.md:L45 references doc2.md:L78] - Verify alignment
- [doc2.md links to doc1 definition] - Update if definition changes
```

**Present this plan to the user before proceeding.**

### Step 4: Make Changes

Execute the refinement:

1. **Start with the primary document**:
   - Make the main content update
   - Add proper citations for the new information
   - Preserve existing structure

2. **Update related documents**:
   - Add cross-references where appropriate
   - Align terminology and definitions
   - Update any summaries that reference changed content

3. **For each edit**:
   - Show the specific change (before/after)
   - Explain why this change was needed
   - Note any decisions made

### Step 5: Verify Consistency

After making changes, verify consistency:

1. **Check cross-references**:
   - Do all links still work?
   - Do definitions match across documents?
   - Are related concepts aligned?

2. **Check terminology**:
   - Is the same term used consistently?
   - Are there any contradictions?

3. **Check completeness**:
   - Is the new information reflected everywhere it should be?
   - Are there any gaps?

## Refinement Patterns

### Pattern 1: Add Stakeholder Quote
When incorporating a direct quote:

1. Add the quote with attribution
2. Connect it to existing content
3. Update any summaries
4. Add to sources section if applicable

```markdown
<!-- Example -->
> "Contextualization means books connect to the canonical idea—leads to learning more about the underlying idea than even reading the book."
> — Allen Cheng, Interview (2025-01-21)
```

### Pattern 2: Strengthen Existing Theme
When feedback emphasizes something already covered:

1. Search for all mentions of the theme
2. Identify opportunities to strengthen
3. Add examples, quotes, or emphasis
4. Ensure consistent representation

### Pattern 3: Correct Inaccuracy
When correcting existing content:

1. Identify the inaccurate content
2. Document what was wrong and why
3. Make the correction with citation
4. Check if the error propagated elsewhere

### Pattern 4: Add New Concept
When introducing something entirely new:

1. Identify the right location in document structure
2. Add with proper context and citations
3. Create cross-references to related concepts
4. Update any indexes or summaries

## Consistency Checking

When `--check-consistency` is specified, run these checks:

### Terminology Check
```
- Find all definitions of key terms
- Verify definitions match across documents
- Flag any inconsistencies
```

### Cross-Reference Check
```
- Find all internal links
- Verify linked sections exist
- Verify linked content is still accurate
```

### Summary Alignment Check
```
- Find all summaries (README, overview docs)
- Compare to source documents
- Flag any drift between summary and source
```

## Output Format

After refinement, provide:

```markdown
## Refinement Summary

**Context Incorporated**: [Brief description]
**Source**: [Attribution]

### Changes Made

#### [Document 1]
- **Line X-Y**: [Description of change]
- **Reason**: [Why this change was needed]

#### [Document 2]
- **Line Z**: [Description of change]
- **Reason**: [Why this change was needed]

### Consistency Status
- [x] Cross-references verified
- [x] Terminology consistent
- [x] Summaries updated
- [ ] [Any remaining items]

### Recommendations
- [Any follow-up actions suggested]
```

## Key Principles

### Minimal Changes
- Only change what's necessary
- Preserve existing structure
- Don't refactor while refining

### Source Everything
- New content needs citations
- Link to the source of the feedback/insight
- Note who requested the change

### Maintain Consistency
- Same term = same definition everywhere
- Cross-references should align
- Summaries should reflect sources

### Show Your Work
- Present the plan before executing
- Show each change clearly
- Explain the reasoning

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| Changing without checking related docs | Always check for cross-references |
| Adding without citing | Every addition needs a source |
| Massive refactors | Keep changes focused on the new context |
| Skipping the plan step | Always present plan before executing |
| Assuming consistency | Verify with actual searches |

---

*Refine documents thoughtfully—incorporate new context while preserving coherence across the document set.*
