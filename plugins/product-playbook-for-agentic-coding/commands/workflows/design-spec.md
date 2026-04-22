---
name: playbook:design-spec
description: Create a high-fidelity design specification for complex UI features
argument-hint: "[optional: project name or feature]"
recommended-mode: edit
thinking-depth: think-harder
---

# Draft Design Spec (Optional)

You are facilitating an **optional Design Spec step** that can be used in any phase when UX clarity will reduce implementation risk. Adopt the perspective of a **Product Designer** as the lead.

This workflow is **optional**. Not all projects require a design critique or a design spec. Only run this when:
- The UI has multiple states (loading/streaming/error/retry)
- Pixel-perfect implementation matters
- Motion/animation is part of the experience
- Cross-platform parity is required
- Perceived performance is a primary goal

## Your Goal

Help the user produce a **high-fidelity, engineer-executable design spec** that enables junior engineers (including agentic engineers) to build a pixel-accurate implementation with minimal ambiguity.

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (tech-plan, tasks, work)
2. **Agents**: Specialized agents via Task tool (if available)
3. **MCP Tools**: External service integrations via ToolSearch (Figma, etc.)
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools for the task at hand.

## Inputs (Optional)

- Product Requirements Document (recommended, not required)
- Design Critique from `/playbook:design-critique` (optional)
- Screenshots / competitor references (optional)
- Existing design system/tokens (recommended if available)
- DESIGN.md from `/playbook:design-system` (recommended for Stitch prompt generation)

## Process

### Step 0: Confirm a Design Spec is warranted (Gate)

Ask:
- Do we need a design spec for this project, or can we proceed with a tech plan directly?
- What's the single most important UX outcome?
- Which surfaces are in scope (desktop/mobile/web/native)?
- What's explicitly out of scope?
- Are there must-have states (empty, typing, sending, waiting, streaming, error)?

If the user says a design spec is not needed, stop here and proceed to the next appropriate workflow (e.g., `/playbook:tech-plan`).

### Step 1: Gather and organize references

1. Ask for the minimum set of visuals needed (screenshots, mockups, competitor flows).
2. Recommend saving images in `projects/[project-name]/`.
3. Use clear filenames (e.g., `agent-reply-states.png`, `composer-states.png`).
4. Capture short notes for each image: what it shows and why it matters.

*(Optional)* If images are huge and hard to view in tooling, suggest exporting a smaller JPG alongside the original PNG.

### Step 2: Locate or create the template

1. Check if a design spec already exists for this project
2. If not, use the design-spec template from this plugin's `resources/templates/`
3. Create it at: `projects/[project-name]/design-spec.md`

### Step 3: Draft the spec (Product Designer lead)

Write the spec as if a junior engineer will implement it without further explanation:

1. **Goals / Non-goals**
2. **Content structure & hierarchy**
3. **Layout / spacing / whitespace** (with explicit numbers)
4. **Visual design** (color/typography/background/texture)
5. **Components** (per-component spec cards)
6. **State machines** (tables: states, transitions, triggers, UI)
7. **Motion spec** (durations, easing, reduced-motion)
8. **Copy / microcopy**
9. **Accessibility**
10. **Instrumentation hooks** (timing points + correlation IDs where needed)
11. **Edge cases / failure states**
12. **Acceptance criteria** (pixel + behavior; testable)
13. **Engineering map** (files/components likely to change)

### Step 4: Resolve open decisions

End the draft with a short "Open Decisions" list. Ask the user to resolve them. Update the spec accordingly.

### Step 5: Validate completeness

Confirm the doc has:
- [ ] Explicit state machines for interactive areas
- [ ] Exact spacing/dimensions where pixel fidelity matters
- [ ] Motion timings + reduced-motion behavior
- [ ] Error states + retry behavior
- [ ] Accessibility constraints
- [ ] Instrumentation points (if performance UX is a goal)
- [ ] Acceptance criteria that can be tested

### Step 6: Generate Stitch Prompts (Optional — requires Stitch MCP)

This step generates structured prompts for Stitch MCP screen generation. It is **optional** and only runs when Stitch MCP is available.

**Gate: Check for Stitch MCP availability**

Use ToolSearch to search for "stitch". If Stitch MCP tools are not found, skip this step entirely and note:

> Stitch MCP not available — skipping prompt generation. To enable this step, install the Stitch MCP plugin and re-run `/playbook:design-spec`.

**Gate: Check for DESIGN.md prerequisite**

Look for a `DESIGN.md` file in the project root or `docs/` directory. If not found:

> DESIGN.md not found. Run `/playbook:design-system` first to generate your design system reference, then re-run this step. DESIGN.md provides the token definitions, component inventory, and spacing scale that Stitch needs for consistent screen generation.

If DESIGN.md exists, load the `stitch-integration` skill via Skill tool for prompt construction rules.

**Prompt Generation Process**

For each screen defined in the design spec:

1. **Extract from the spec**: purpose/user goal, component list, layout structure, interactive states, priority level (P1/P2/P3)
2. **Structure as a Stitch 5-element prompt**:
   - **Purpose statement**: One sentence describing what the screen does and the user goal it serves
   - **DESIGN SYSTEM block**: Paste the relevant sections from DESIGN.md (tokens, palette, typography scale)
   - **Components**: List each component using standard UI/UX terminology (e.g., "floating action button", "bottom sheet", "segmented control") with brief behavioral notes
   - **Layout**: Specify structure with explicit dimensions — grid columns, spacing values, breakpoints. Include viewport: desktop 1440x900, mobile 375x812
   - **Styling**: Mood adjectives that guide visual treatment (e.g., "warm and approachable", "dense and data-rich", "minimal and focused")

**Rules**:
- One prompt per screen — do not combine multiple screens into a single prompt
- One concern per prompt — separate layout from interaction from content
- Use realistic content (real names, plausible data, actual copy from the spec's microcopy section) — never use "Lorem ipsum" or "John Doe"
- Include viewport specifications: desktop 1440x900, mobile 375x812
- If dark mode is defined in DESIGN.md, include a dark mode variant note in each prompt
- Tag each prompt with the priority level from the spec: `[P1]` critical path, `[P2]` important, `[P3]` nice-to-have

**Prompt Template**:

```markdown
## [Screen Name] [P1/P2/P3]

**Purpose**: [One sentence: what does this screen do and what user goal does it serve?]

**DESIGN SYSTEM**:
[Paste relevant DESIGN.md sections — tokens, colors, typography, spacing]

**Components**:
- [Component name]: [UI/UX term] — [brief behavioral note]
- [Component name]: [UI/UX term] — [brief behavioral note]

**Layout**:
- Viewport: [desktop 1440x900 | mobile 375x812]
- [Grid/structure description with explicit dimensions]
- [Spacing values between sections]

**Styling**: [2-3 mood adjectives, e.g., "warm, approachable, and clean"]

**States**: [List key states if interactive: default, hover, active, disabled, loading, error]

**Dark mode**: [Yes — include variant | No — light only]
```

**Save prompts to**: `projects/[project-name]/design-spec-prompts.md`

Include a header in the output file:

```markdown
# Design Spec Prompts — [Project Name]

Generated from: `projects/[project-name]/design-spec.md`
Design system: `DESIGN.md`
Date: [current date]

> These prompts are structured for Stitch MCP screen generation.
> Use `/playbook:mockups` to batch-generate screens from these prompts.
```

## Next Steps

After the design spec:
- If Stitch prompts were generated: proceed to `/playbook:mockups` to batch-generate screens
- If architecture work is next: proceed to `/playbook:tech-plan`
- If tasks are next: proceed to `/playbook:tasks`
- If implementation begins: use `/playbook:work`
