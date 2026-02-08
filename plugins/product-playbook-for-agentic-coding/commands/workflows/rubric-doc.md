---
name: playbook:rubric-doc
description: Generate a document based on a spec file with rubric/excellence criteria. Searches context directories and produces a cited draft.
argument-hint: "<doc-type> [--spec <spec-file>] [--context <dir1,dir2>] [--output <path>]"
---

# Rubric-Based Document Generator

You are generating a structured document based on a specification that defines the document's purpose, structure, and excellence criteria.

## Your Goal

Create a high-quality document that:
1. Follows the structure defined in a spec/rubric file
2. Draws content from context directories (interview notes, resources, existing docs)
3. Includes proper citations and source links for all referenced content
4. Meets the excellence criteria defined in the spec

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (distill, refine-doc)
2. **Agents**: Specialized agents via Task tool (insight-extractor-agent)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools for the task at hand.

## Arguments

Parse the command arguments:
- `<doc-type>`: The type of document to generate (e.g., "vision", "personas", "competitive-analysis")
- `--spec <spec-file>`: Path to spec file with rubric (optional - will search for relevant spec)
- `--context <dir1,dir2>`: Comma-separated directories to search for context
- `--output <path>`: Where to create the document (optional - will suggest location)

## Process

### Step 1: Locate or Confirm the Spec

**If spec file provided**: Read it directly.

**If no spec file**:
1. Search for a README or spec file that defines the document type
2. Look in common locations: `docs/`, `foundations/`, project root
3. Search for patterns like `**/README.md`, `**/*-spec.md`, `**/*-rubric.md`
4. If found, read and confirm with user: "I found this spec at [path]. Should I use it?"

**Extract from the spec**:
- **Purpose**: Why this document exists
- **Structure**: Required sections and their order
- **Excellence Rubric**: Criteria for a high-quality document
- **Examples**: Any referenced examples of excellence

### Step 2: Gather Context

Search the context directories for relevant information:

1. **List all potential sources**:
   - Use Glob to find all `.md` files in context directories
   - Prioritize by relevance to document type

2. **Search for specific content**:
   - Grep for keywords related to the document type
   - Look for quotes, data points, and insights
   - Search for existing related documents

3. **Read and extract**:
   - Read the most relevant files
   - Extract quotes with exact source locations (file:line)
   - Note any existing analysis or conclusions

4. **Track all sources**:
   - Maintain a list of every file consulted
   - Note specific line numbers for quotes

### Step 3: Draft the Document

Create the document following this structure:

```markdown
# [Document Title]

**Purpose**: [From spec - why this document exists]

---

## [Section 1 from spec structure]

[Content synthesized from context sources]

> "[Direct quote if relevant]" — [Source file](relative-path), line X

[Analysis and synthesis]

## [Section 2 from spec structure]

[Continue for all required sections...]

---

## Sources Used

| Source | Lines Referenced | Key Contributions |
|--------|------------------|-------------------|
| [filename](relative-path) | L12-45, L78 | [What was used from this source] |
| [filename](relative-path) | L5-10 | [What was used from this source] |

---

## Excellence Checklist

Based on the rubric in [spec file]:

- [ ] [Criterion 1 from rubric]
- [ ] [Criterion 2 from rubric]
- [ ] [Criterion 3 from rubric]
...
```

### Step 4: Self-Evaluate Against Rubric

Before presenting the draft:

1. **Check each rubric criterion**:
   - Mark which criteria are fully met
   - Identify gaps or areas needing improvement

2. **Verify citations**:
   - Ensure every claim has a source
   - Verify line numbers are accurate
   - Check that quotes are exact

3. **Assess completeness**:
   - All required sections present?
   - Sufficient depth in each section?
   - Any obvious gaps?

### Step 5: Present and Iterate

Present the draft with:
1. The document itself
2. Excellence checklist showing which criteria are met
3. Any gaps identified
4. Questions for the user about uncertain areas

Ask: "Would you like me to strengthen any sections or address specific gaps?"

## Key Principles

### Source Everything
- Every factual claim needs a citation
- Direct quotes include exact source:line references
- Link to original files using relative paths

### Follow the Rubric
- The spec defines what "good" looks like
- Check each criterion explicitly
- Don't add content that doesn't serve the purpose

### Synthesize, Don't Just Copy
- Connect ideas across sources
- Add analysis that creates new value
- Identify patterns and themes

### Keep It Simple
- "Quick draft" means efficient, not sloppy
- Start with essentials, add depth where needed
- Avoid over-engineering the first draft

## Example Usage

```
/playbook:rubric-doc personas --spec docs/foundations/README.md --context interviews/,resources/
```

This would:
1. Read the personas spec from README.md
2. Search interviews/ and resources/ for relevant context
3. Generate a personas document with citations
4. Self-evaluate against the rubric

## Output Location

If `--output` not specified:
- Suggest location based on spec file location
- Or ask user: "Where should I create this document?"

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| Inventing content without sources | Only include what can be cited |
| Ignoring the rubric | Explicitly check each criterion |
| Massive dumps of quotes | Synthesize and summarize |
| Missing source attribution | Cite everything, including line numbers |
| Skipping the self-evaluation | Always check against rubric before presenting |

---

*Generate documents that are well-sourced, well-structured, and verifiably excellent.*
