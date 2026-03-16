---
name: playbook:design-system
description: Extract or create a canonical DESIGN.md from Stitch screens, codebase tokens, or guided interview
argument-hint: "[optional: project name or path to existing design tokens]"
---

# Extract / Create Design System (DESIGN.md)

You are facilitating the creation of a **canonical DESIGN.md** that serves as the single source of truth for all visual design decisions. Adopt the perspective of a **Design Systems Engineer** as the lead.

This is the foundation step of the design pipeline. Every downstream command (`/playbook:design-spec`, `/playbook:mockups`, `/playbook:design-critique`, `/playbook:design-to-code`, `/playbook:design-verify`) depends on a well-defined DESIGN.md. The `stitch-integration` skill defines the canonical DESIGN.md format and prompt construction rules that this command produces.

## Your Goal

Help the user produce a **complete, Stitch-optimized DESIGN.md** by extracting design DNA from every available source (Stitch screens, codebase tokens, brand guidelines, user interview) and synthesizing it into one authoritative document.

**Critical**: The output must use **descriptive, physical language** with exact hex values. Stitch has no memory between calls, so the DESIGN.md must be precise enough to inject directly into generation prompts and produce consistent results.

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Stitch MCP Tools**: Use `ToolSearch query: "+stitch"` to discover Stitch tools (`list_projects`, `get_project`, `list_screens`, `get_screen`). If unavailable, operate in text-only mode.
2. **Commands**: Other `/playbook:*` commands (design-spec, design-critique, mockups)
3. **Agents**: Specialized agents via Task tool (if available)
4. **MCP Tools**: Other external service integrations via ToolSearch (Figma, etc.)
5. **Skills**: `stitch-integration` skill for DESIGN.md format and prompt rules

Select the most appropriate tools for the task at hand.

## Process

### Step 1: Discover Sources

Scan for every available source of design information. Check each category and report what was found:

**Stitch sources** (if Stitch MCP is available):
- Use `list_projects` to find existing Stitch projects
- If projects exist, use `list_screens` to inventory existing screens
- These screens contain implicit design decisions (colors, spacing, typography) that need extraction

**Codebase sources** — search for:
- `design-tokens.*` (any format: `.ts`, `.js`, `.json`, `.css`)
- `tailwind.config.*` (Tailwind theme extensions)
- Existing `DESIGN.md` or `design-system.md`
- `design-spec-prompts.md` or similar prompt libraries
- CSS custom properties files (`:root` variable definitions)
- Component library theme files (gluestack, shadcn, etc.)

**Manual sources** — ask the user:
- Brand guidelines or mood boards
- Competitor references they want to draw from
- Existing Figma files or design tool exports

Report a summary of all discovered sources before proceeding.

### Step 2: Extract Design DNA

Pull concrete design values from each discovered source.

**From Stitch screens** (if available):
- Use `get_screen` on 2-3 representative screens
- Extract: dominant colors (with hex), typography patterns, spacing rhythm, component styles, overall mood
- Note any inconsistencies between screens (these will surface in Step 5)

**From codebase tokens**:
- Read token files and parse the full palette, type scale, spacing scale, radius tokens, shadow definitions
- Map technical token names to their values (e.g., `--color-primary-500` -> `#C75B3F`)
- Identify which tokens are actively used vs. defined but unused

**From the user** (guided interview — ask these questions):
- "Describe the atmosphere of your product in physical terms. What room, surface, or material does it feel like?"
- "What are the 2-3 most important visual impressions a new user should have?"
- "Are there any colors, patterns, or styles that are off-limits?"
- "Does the product support dark mode? If so, is it a full theme or a simple inversion?"

Capture all extracted values before moving to translation.

### Step 3: Translate to Stitch-Optimized Language

Convert raw technical values into the descriptive format that Stitch interprets well. Follow the DESIGN.md writing style from the `stitch-integration` skill:

**Colors**: Pair every hex value with a physical, descriptive name.
- `#C75B3F` becomes `Warm Terracotta (#C75B3F)`
- `#FAF6F1` becomes `Warm Linen (#FAF6F1)`
- `#F0E8DC` becomes `Light Oak (#F0E8DC)`
- Use material and nature metaphors: stone, linen, oak, clay, sage, charcoal, parchment

**Atmosphere**: Write the Visual Theme section using physical language.
- "Warm and grounded, like a sunlit kitchen with oak shelves and stone countertops"
- "Clean and precise, like a well-organized apothecary with glass jars and brass labels"
- Avoid abstract design jargon: no "modern", "minimal", "sleek"

**Typography**: Name the type scale levels by function, include exact values.
- `Display / 36px / Bold (700) / 1.2 line-height / Hero headlines`

**Spacing**: Describe the rhythm, not just the numbers.
- "Generous breathing room between sections (24-32px), tighter grouping within related elements (8-12px)"

### Step 4: Synthesize into DESIGN.md

Merge all sources into a single DESIGN.md using the template structure from `resources/templates/design-system.md`. The canonical sections are:

1. **Visual Theme & Atmosphere** — the sensory description from Step 3
2. **Color Palette & Roles** — table with Role, Name, Hex, Usage for every color
3. **Typography Rules** — font families, type scale table, typography rules
4. **Spacing & Radius** — base unit, spacing scale table, border radius table
5. **Component Patterns** — buttons, cards, inputs, navigation, empty states
6. **Shadow & Depth** — elevation levels table, depth rules
7. **Accessibility Constraints** — contrast requirements, touch targets, focus indicators, reduced motion, screen reader considerations

**Conflict resolution**: When sources disagree (e.g., Stitch screen uses `#D4553A` but codebase tokens define primary as `#C75B3F`):
- Flag the conflict explicitly in the document with a `<!-- CONFLICT: ... -->` comment
- Default to the codebase token value (code is the production source of truth)
- Record the Stitch screen value in the drift table (Step 5)
- Ask the user to resolve if the difference is significant

**Completeness check**: Every section of the template must be filled in. If a source does not provide values for a section (e.g., no shadow definitions in the codebase), ask the user or propose sensible defaults based on the overall atmosphere and existing values.

### Step 5: Drift Detection

If both Stitch screens and codebase tokens exist, produce a drift table showing inconsistencies:

```markdown
## Design Drift Report

| Property | Codebase Value | Stitch Screen Value | Screen(s) | Severity |
|----------|---------------|---------------------|-----------|----------|
| Primary action color | Terracotta (#C75B3F) | Darker Red (#D4553A) | menu-browse, checkout | Medium |
| Card border radius | 12px (lg) | 8px | menu-item-card | Low |
| Body font size | 16px | 14px | all screens | High |
```

**Severity levels**:
- **High**: Affects brand perception or accessibility (wrong primary color, incorrect font size, contrast failure)
- **Medium**: Noticeable inconsistency but not brand-breaking (shade variation, radius difference)
- **Low**: Minor difference unlikely to be noticed by users (1-2px spacing, subtle shadow variation)

If no Stitch screens exist, skip this step. If no codebase tokens exist, skip this step.

### Step 6: Save

1. Ask the user for the project name (if not provided as an argument)
2. Write the DESIGN.md to: `projects/[project-name]/DESIGN.md`
3. If a drift report was generated, include it as an appendix at the bottom of the DESIGN.md
4. Confirm the file path with the user

## Key Principles

- **DESIGN.md is the source of truth** — all design pipeline commands reference it. If it is incomplete or vague, every downstream output suffers.
- **Descriptive language over technical jargon** — "Warm Terracotta" tells Stitch more than "#C75B3F" alone. Always pair names with hex values.
- **Hex values are mandatory** — every color must have an exact hex. Descriptive names without hex are ambiguous. Hex without descriptive names is hard for humans and Stitch to interpret.
- **Keep it Stitch-optimized** — sections from this document get injected directly into Stitch generation prompts. Write as if Stitch is the reader: precise, visual, descriptive, complete.
- **Living document** — DESIGN.md should be updated as designs evolve. It is not a one-time artifact.

## Next Steps

Design system documented. Proceed to:
- `/playbook:design-spec` to generate screen-level design specifications and prompts
- `/playbook:mockups` if prompts already exist and you are ready to generate screens
- `/playbook:design-critique` to evaluate existing designs against this system
