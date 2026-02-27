---
name: stitch-integration
description: Shared patterns and best practices for Google Stitch MCP integration. Referenced by all design pipeline commands (design-system, design-spec, mockups, design-critique, design-to-code, design-verify).
---

# Stitch Integration

This skill encodes the conventions for working with Google Stitch MCP across the design pipeline. Every command that generates or evaluates visual designs references these patterns.

## Tool Discovery

### Finding Stitch MCP Tools

Use `ToolSearch` to locate Stitch tools before invoking them:

```
ToolSearch query: "+stitch"
```

Stitch tools are exposed through MCP and may carry a namespace prefix (e.g., `mcp__stitch__create_project`). The prefix depends on the user's MCP server configuration. Always discover the exact names at runtime rather than hard-coding them.

### Fallback When Stitch Is Not Available

If `ToolSearch` returns no Stitch tools:

1. **Inform the user** — explain that Stitch MCP is required for visual generation and link to setup docs.
2. **Offer text-only mode** — the design pipeline commands can still produce DESIGN.md, prompt libraries, and design specs without Stitch. Skip generation and verification steps.
3. **Never fabricate tool names** — if the tools are not discovered, do not guess at names or attempt calls that will fail.

## Prompt Construction Rules

Every prompt sent to `generate_screen_from_text` or `edit_screens` must follow the **5-element structure**:

### 1. Purpose Statement
A single sentence describing what the screen does and who it serves.

> "A restaurant menu browsing screen for hungry customers deciding what to order."

### 2. Design System Block
Inject the relevant DESIGN.md sections directly into the prompt. At minimum include:
- Color palette with hex values
- Typography scale
- Spacing and radius tokens
- Component patterns relevant to the screen

### 3. Component List
Enumerate the specific UI components that appear on the screen, with their states:
- Navigation bar (active tab: Menu)
- Category filter chips (scrollable, one selected)
- Menu item cards (image, name, price, add-to-cart button)
- Floating cart summary (item count, total, checkout CTA)

### 4. Layout Description
Describe the spatial arrangement:
- Stacking order (what is above/below what)
- Alignment (centered, left-aligned, edge-to-edge)
- Scroll behavior (fixed header, scrollable body)
- Grid or column structure if applicable

### 5. Styling and Mood
Descriptive language about the visual feel. Use physical metaphors:
- "Warm and approachable, like a sunlit kitchen counter"
- "Clean with breathing room, not cramped"
- "Subtle depth — cards float slightly above the background"

### Prompt Rules

| Rule | Rationale |
|------|-----------|
| **One change per prompt** when editing | Stitch handles single edits more reliably than compound changes. Chain multiple `edit_screens` calls for multiple changes. |
| **One screen per generation** | Multi-screen prompts produce inconsistent results. Generate screens individually and use the consistency pattern below. |
| **Descriptive color names + hex** | Write `Warm Terracotta (#C75B3F)` not just `#C75B3F`. Descriptive names improve Stitch's color interpretation. |
| **Realistic content** | Use plausible names, prices, and copy. "Grilled Salmon — $24" not "Item 1 — $X". Realistic content produces better layouts. |
| **Specify viewport** | Always include target dimensions: `Mobile viewport: 390×844 (iPhone 14)` or `Desktop viewport: 1440×900`. |
| **No implementation details** | Describe what the user sees, not how to build it. "A card with rounded corners" not "A div with border-radius: 12px". |

## DESIGN.md Format

Every project should have a `DESIGN.md` at its docs root. This is the single source of truth for visual decisions, and its sections get injected into Stitch prompts.

### Canonical Structure

```
# DESIGN.md

## Visual Theme & Atmosphere
Physical/sensory description of the overall feel.
Use language like "daylight on stone", "warm oak shelf",
"linen tablecloth texture". Avoid abstract jargon.

## Color Palette & Roles

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Primary Background | Warm Linen | #FAF6F1 | Page and screen backgrounds |
| Surface | Light Oak | #F0E8DC | Cards, elevated panels |
| Primary Action | Terracotta | #C75B3F | CTAs, active states |
| ... | ... | ... | ... |

Every color must have a Role (what job it does), a Name
(physical/descriptive), a Hex (exact value), and a Usage
(where it appears).

## Typography Rules
Font families, size scale, weight rules, line-height ratios.

## Spacing & Radius
Base unit, spacing scale, border-radius tokens.

## Component Patterns
Reusable patterns: buttons, cards, inputs, navigation,
modals, toasts, empty states.

## Shadow & Depth
Elevation levels and their shadow definitions.
Which elements are elevated vs flat.

## Accessibility Constraints
Contrast requirements, focus indicators, touch target
minimums, reduced motion policy.
```

### Writing Style for DESIGN.md

- **Use physical, descriptive language** — "Like light oak shelving" is better than "A warm beige surface"
- **Be specific about hex values** — every color gets a hex code, no exceptions
- **Define roles, not just values** — "Primary Action" tells you when to use it; "#C75B3F" alone does not
- **Keep it scannable** — tables for colors, bullet lists for rules, headings for sections
- **Update it as designs evolve** — DESIGN.md is a living document, not a one-time artifact

## Consistency Patterns

### Feed-Forward Pattern

When generating multiple screens, use this sequence to maintain visual consistency:

1. **Generate anchor screen** — Pick the most visually complex or representative screen first. Generate it with `generate_screen_from_text` and iterate until it meets the design system.

2. **Extract design context** — Use `get_screen` on the anchor screen to retrieve its design details. This captures the specific visual decisions Stitch made (exact spacing, shadows, component rendering).

3. **Prepend to subsequent prompts** — For every following screen, include the extracted design context at the top of the prompt:
   ```
   REFERENCE DESIGN (match this visual style exactly):
   [extracted design context from anchor screen]

   NEW SCREEN:
   [5-element prompt for the new screen]
   ```

4. **Verify at end** — After generating all screens, visually compare them. If drift occurred, use `edit_screens` to bring outliers back in line with the anchor.

### DESIGN.md Injection

The Color Palette, Typography, Spacing, and Component Patterns sections from DESIGN.md must be included in every generation prompt. This is non-negotiable — Stitch has no memory between calls, so the design system must be restated each time.

**Injection format**:
```
DESIGN SYSTEM:
[paste relevant DESIGN.md sections here]

SCREEN:
[5-element prompt]
```

### Cross-Screen Verification

After generating a batch of screens:
1. List all screens with `list_screens`
2. Retrieve each with `get_screen`
3. Check for consistent: color usage, typography hierarchy, spacing rhythm, component styling
4. Use `edit_screens` to fix any drift

## Generation Strategy

### Budget Awareness

Stitch provides two generation modes with monthly limits:

| Mode | Monthly Limit | Use For |
|------|--------------|---------|
| **Standard** | 350 generations | Iteration, exploration, layout testing, rapid prototyping |
| **Experimental** | 50 generations | High-fidelity output, final mockups, presentation-quality screens |

### Strategy Rules

- **Start with Standard** — use Standard mode for all initial exploration and iteration. Switch to Experimental only for final polish.
- **Treat Stitch as an accelerator, not a final renderer** — Stitch output is a design reference and communication tool, not pixel-perfect production art. The code is the final artifact.
- **Iterate incrementally** — generate a base screen, then use `edit_screens` for targeted changes. Each edit is cheaper than a full regeneration.
- **Regenerate selectively** — if only the header is wrong, edit just the header. Don't regenerate the entire screen.
- **Batch planning** — before a generation session, list all screens needed and prioritize. Generate the most important screens first in case you hit budget limits.

### When Not to Generate

Skip Stitch generation when:
- The change is purely textual (copy update)
- The component already has a well-established pattern in the design system
- The design spec is clear enough that engineering doesn't need a visual reference
- Budget is running low and the screen is low-priority

## Known Limitations

Understanding Stitch's limitations prevents wasted generations and misset expectations.

| Limitation | Impact | Workaround |
|------------|--------|------------|
| **Visual hierarchy may be flat** | Headlines, body text, and labels can render at similar visual weight | Explicitly call out size and weight differences in prompts: "Page title at 32px bold, section headers at 20px semibold, body at 16px regular" |
| **Cannot apply brand automatically** | Stitch has no persistent design system memory | Inject DESIGN.md into every prompt (see Consistency Patterns) |
| **Placeholder icons** | Icons may not match your icon set | Accept placeholders; specify icon names in prompt for documentation |
| **No animation** | Output is static; transitions and motion cannot be previewed | Document animations in the design spec; Stitch shows resting states only |
| **Static HTML/CSS output** | Generated screens are visual references, not production code | Use as a spec for engineering, not a code source |
| **Multi-screen drift** | Colors, spacing, and typography can drift between separate generations | Use feed-forward pattern with anchor screen and design context extraction |
| **Complex interactions** | Hover states, modals, and multi-step flows render poorly in single screens | Generate each state as a separate screen; annotate transitions in the design spec |
| **Responsive behavior** | Stitch generates for one viewport at a time | Generate separate screens for mobile (390px) and desktop (1440px) viewports |

## Stitch Tool Reference

These are the core Stitch MCP tools. Actual names may carry a namespace prefix (e.g., `mcp__stitch__`). Always discover via `ToolSearch` before use.

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `list_projects` | List all Stitch projects | Start of session — find existing project or confirm need for new one |
| `create_project` | Create a new Stitch project | Once per design pipeline run; name should match the feature/product |
| `get_project` | Retrieve project details | After creation to confirm settings, or to resume a previous session |
| `list_screens` | List all screens in a project | Before generating to see what exists; after generating to verify batch |
| `get_screen` | Retrieve a single screen's details | Extract design context for feed-forward; review a specific generation |
| `generate_screen_from_text` | Generate a new screen from a text prompt | Primary generation tool — follow the 5-element prompt structure |
| `edit_screens` | Modify an existing screen | Targeted changes to fix drift, adjust layout, or iterate on details |
| `generate_variants` | Generate alternative versions of a screen | Explore options for a specific screen; compare approaches before committing |

**Namespace note**: The tool names above are base names. In practice, they may appear as `mcp__stitch__generate_screen_from_text` or similar depending on the MCP server configuration. Use `ToolSearch query: "+stitch"` to discover the exact names in the current environment.

---

*This skill is a shared dependency. Changes here affect all design pipeline commands. Update with care.*
