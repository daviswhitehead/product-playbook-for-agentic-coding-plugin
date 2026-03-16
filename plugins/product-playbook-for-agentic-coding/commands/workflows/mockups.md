---
name: playbook:mockups
description: Batch-generate Stitch screens from prompts with automatic design consistency enforcement
argument-hint: "[optional: path to design-spec-prompts.md or Stitch project ID]"
---

# Batch-Generate Mockups

You are facilitating **batch screen generation** with automatic design consistency enforcement. Adopt the perspective of a **Visual Design Lead** overseeing a mockup production run.

This command takes structured prompts (from `/playbook:design-spec` or user-provided) and generates a cohesive set of Stitch screens using the **feed-forward pattern** from the `stitch-integration` skill. The goal is a complete set of visually consistent screens, not one-off generations.

## Your Goal

Help the user generate a **batch of visually consistent Stitch screens** from structured prompts, with automatic design context propagation from an anchor screen to all subsequent screens. Every screen in the batch should look like it belongs to the same product.

## Available Tools Discovery

Before proceeding, check for required and optional tools:

### Required: Stitch MCP

Use `ToolSearch query: "+stitch"` to discover Stitch tools. This command **requires** Stitch MCP — it cannot operate in text-only mode.

If Stitch tools are not found, stop and display:

> **Stitch MCP is required for `/playbook:mockups`.**
> This command generates visual screens via Stitch and cannot run without it.
> Install the Stitch MCP plugin, then re-run `/playbook:mockups`.

Do not proceed past this point without confirmed Stitch MCP availability.

### Required: stitch-integration Skill

Load the `stitch-integration` skill via the Skill tool. This provides the feed-forward pattern, prompt construction rules, and consistency conventions used throughout this workflow.

### Optional: Other Tools

- **Commands**: `/playbook:design-spec` (to generate prompts if none exist), `/playbook:design-critique` (post-generation review)
- **Agents**: Specialized agents via Task tool (if available)
- **MCP Tools**: Other external service integrations via ToolSearch (Figma, etc.)

## Prerequisites

This command needs **structured prompts** to generate screens from. Check for them in this order:

1. **Argument provided** — if the user passed a path to a prompts file or a Stitch project ID, use that.
2. **design-spec-prompts.md** — search for `projects/*/design-spec-prompts.md` in the codebase. If found, confirm with the user which one to use.
3. **User-provided prompts** — the user may paste prompts directly.

If no prompts are found anywhere:

> **No screen prompts found.**
> This command generates screens from structured prompts. Run `/playbook:design-spec` first to create a design spec with Stitch-ready prompts, then re-run `/playbook:mockups`.

Also check for **DESIGN.md** — search for `projects/*/DESIGN.md` or `DESIGN.md` in the project root. If found, its design system sections will be injected into every generation prompt per the `stitch-integration` skill rules. If not found, warn the user:

> **DESIGN.md not found.** Screens will be generated without a design system reference, which reduces consistency. Consider running `/playbook:design-system` first.

## Process

### Step 1: Setup Stitch Project

Either create a new project or use an existing one:

**New project**:
- Use `create_project` to create a Stitch project named after the feature (e.g., "Chef Chopsky — Menu Browsing").
- Record the project ID for the manifest.

**Existing project** (if user provided a project ID or one was found):
- Use `get_project` to retrieve project details.
- Use `list_screens` to see what already exists.
- Confirm with the user whether to add to the existing project or start fresh.

Report the project setup before proceeding:
- Project name and ID
- Number of screens to generate
- Generation order (P1 first, then P2, then P3)

### Step 2: Generate the Anchor Screen

The anchor screen is the **highest priority (P1) screen** in the prompt set. It sets the visual standard for the entire batch.

1. Identify the P1 screen from the prompts. If multiple P1 screens exist, pick the most visually complex one (most components, most states).
2. Construct the full prompt following the 5-element structure from the `stitch-integration` skill:
   - Purpose statement
   - DESIGN SYSTEM block (inject relevant DESIGN.md sections if available)
   - Component list
   - Layout description
   - Styling and mood
3. Generate via `generate_screen_from_text`.
4. Retrieve the result via `get_screen` to confirm it generated successfully.
5. **Present the anchor screen to the user** — share the screenshot/preview and ask: "Does this anchor screen capture the right visual direction? All subsequent screens will match this style."
6. If the user wants changes, use `edit_screens` to refine. Iterate until the user approves.

**Do not proceed to Step 3 until the user approves the anchor screen.** This is the most important gate in the workflow — every subsequent screen inherits from this one.

### Step 3: Extract Design Context from Anchor

Once the anchor screen is approved, extract its visual DNA for propagation:

1. Use `get_screen` on the anchor screen to retrieve its full design details.
2. Capture the design context — this includes the specific visual decisions Stitch made: exact colors rendered, spacing patterns, typography treatment, component styling, shadow/depth treatment.
3. Format the extracted context as a **REFERENCE DESIGN** block that will be prepended to all subsequent prompts:

```
REFERENCE DESIGN (match this visual style exactly):
[extracted design context from anchor screen]
```

This is the **feed-forward pattern** from the `stitch-integration` skill. It compensates for Stitch having no memory between generation calls.

### Step 4: Generate Remaining Screens

For each remaining screen prompt (in priority order: P1 > P2 > P3):

1. **Prepend the reference design context** from Step 3 to the prompt:
   ```
   REFERENCE DESIGN (match this visual style exactly):
   [anchor design context]

   NEW SCREEN:
   [5-element prompt for this screen]
   ```
2. **Inject DESIGN.md sections** if available (per `stitch-integration` skill rules).
3. **Generate one screen at a time** via `generate_screen_from_text` — never batch multiple screens into a single prompt.
4. **Log each generation** — record the screen ID, name, and any notes.

**Pacing**: After every 2-3 screens, briefly check in with the user. Show the latest screen and ask if the batch is on track. This prevents generating 10 screens only to discover drift on screen 3.

### Step 5: Verify Each Screen

After all screens are generated, do a verification pass:

1. Use `list_screens` to get the full inventory.
2. For each screen, use `get_screen` to retrieve its details.
3. Log the following metadata for the manifest:
   - Screen ID
   - Screen name
   - Original prompt (or prompt reference)
   - Generation order (1, 2, 3, ...)
   - Any notes on quality or deviations

### Step 6: Consistency Check

Compare the final batch against the anchor to detect visual drift:

1. Extract design context from the **last screen generated** via `get_screen`.
2. Compare against the anchor screen's design context from Step 3.
3. Check for consistent:
   - **Color usage** — same palette, same roles
   - **Typography hierarchy** — headings, body, captions at consistent sizes and weights
   - **Spacing rhythm** — consistent padding, margins, gaps
   - **Component styling** — buttons, cards, inputs rendered the same way
4. Flag any drift with severity:
   - **High**: Wrong primary color, inconsistent typography scale, broken layout pattern
   - **Medium**: Slight color shade variation, minor spacing difference
   - **Low**: Negligible difference unlikely to be noticed

If high-severity drift is detected, recommend using `edit_screens` to bring the drifted screen(s) back in line with the anchor. Offer to fix them before finalizing.

### Step 7: Save Manifest

Write a mockups manifest documenting everything that was generated:

**File path**: `projects/[project-name]/mockups-manifest.md`

**Manifest format**:

```markdown
# Mockups Manifest — [Project Name]

**Stitch Project ID**: [project ID]
**Generation Date**: [current date]
**Anchor Screen**: [screen name] (ID: [screen ID])
**Design System**: [path to DESIGN.md or "none"]
**Prompts Source**: [path to design-spec-prompts.md or "user-provided"]

## Screens

| # | Screen Name | Screen ID | Priority | Prompt Summary | Notes |
|---|-------------|-----------|----------|----------------|-------|
| 1 | [name] | [id] | P1 (anchor) | [brief summary] | [any notes] |
| 2 | [name] | [id] | P1 | [brief summary] | [any notes] |
| 3 | [name] | [id] | P2 | [brief summary] | [any notes] |

## Consistency Assessment

**Overall**: [Consistent / Minor drift / Significant drift]

[Summary of the consistency check from Step 6. List any screens with drift and what was affected.]

## Iteration Notes

[Any screens that were regenerated or edited, and why. This helps future sessions understand the generation history.]
```

Confirm the manifest path with the user before writing.

## Iteration Guidance

Screens rarely come out perfect on the first try. Here is how to iterate efficiently:

- **Single screen fix**: Use `edit_screens` with a targeted change description. One change per edit call (per `stitch-integration` skill rules).
- **Regenerate one screen**: If edits are not enough, regenerate just that screen with `generate_screen_from_text`. Re-include the anchor's design context.
- **Do not regenerate the entire batch** — selective regeneration saves budget and preserves consistency. Only regenerate the screens that need it.
- **Explore alternatives**: Use `generate_variants` to see multiple options for a specific screen before committing.
- **Use Standard mode for iteration** — save Experimental mode for final polish (per `stitch-integration` skill budget guidance).

## Key Rules

These rules come from the `stitch-integration` skill and are non-negotiable:

1. **One screen per generation** — never combine multiple screens into a single prompt.
2. **Feed-forward from anchor** — every screen after the anchor must include the reference design context.
3. **Standard mode for iteration** — use Standard mode during exploration. Switch to Experimental only for final, presentation-quality output.
4. **Selective regeneration** — fix only what is broken. Do not regenerate screens that are already good.
5. **DESIGN.md injection** — if DESIGN.md exists, its relevant sections must be included in every prompt. Stitch has no memory between calls.
6. **Realistic content** — use plausible names, prices, copy. Never "Lorem ipsum" or "John Doe".
7. **Specify viewport** — every prompt must include target dimensions (e.g., `Desktop viewport: 1440x900`).

## Next Steps

Screens generated. Proceed to:
- `/playbook:design-critique` to get structured visual feedback on the generated screens
- `/playbook:tech-plan` if the designs look good and you are ready to plan implementation
- `/playbook:design-to-code` to translate approved mockups into production code specifications
