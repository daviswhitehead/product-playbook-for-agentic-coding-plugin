---
name: playbook:design-verify
description: Compare running implementation against Stitch mockups and produce a visual diff report
argument-hint: "[app URL or 'localhost'] [path to mockups manifest]"
recommended-mode: edit
thinking-depth: normal
---

# Design Verification

You are facilitating a **structured visual comparison** between a running implementation and its Stitch mockup source of truth. Adopt the perspective of a **QA Design Reviewer** as the lead, with support from a Frontend Architect and a Design Systems Engineer.

This command is the final gate in the design pipeline. It catches visual drift — spacing, color, typography, layout, and component discrepancies — between what was designed and what was built. It produces an actionable diff report with severity-ranked discrepancies and fix suggestions.

## Limitation

This is **structured visual analysis, not pixel-diff tooling**. It catches spacing, color, typography, and layout drift through careful side-by-side comparison. It treats Stitch mockups as **design intent**, not pixel-perfect truth. Minor rendering differences between Stitch's static HTML and a live application (anti-aliasing, font rendering, sub-pixel rounding) are expected and should not be flagged.

## Your Goal

Help the user produce a **design verification report** that:
1. Captures the current state of the implementation at each screen/route
2. Retrieves the corresponding Stitch mockup for each screen
3. Performs a structured comparison across layout, spacing, typography, color, components, and responsive behavior
4. Produces an actionable diff report with severity, location, and fix suggestions

## Available Tools Discovery

Before proceeding, inventory available tools:

### Required: Browser Automation (Playwright)

Use `ToolSearch query: "+playwright screenshot"` to discover Playwright tools for capturing screenshots of the running application.

If Playwright tools are not found, check if the user can provide screenshots manually. The command can still run with user-provided screenshots, but automated capture is strongly preferred for consistency and repeatability.

### Required: Stitch MCP

Use `ToolSearch query: "+stitch"` to discover Stitch tools. The primary tool needed is `get_screen` to retrieve mockup screenshots for comparison.

If Stitch tools are not found, check if the user has mockup images saved locally (e.g., from a previous `/playbook:mockups` run). If neither Stitch nor local images are available:

> **Stitch MCP or local mockup images are required for `/playbook:design-verify`.**
> This command compares implementation against mockups. Install the Stitch MCP plugin, or provide mockup images, then re-run.

### Required: stitch-integration Skill

Load the `stitch-integration` skill via the Skill tool. This provides conventions for working with Stitch screen output and the `get_screen` tool.

### Optional: Other Tools

- **Commands**: `/playbook:design-to-code` (to review the component map), `/playbook:work` (to fix discrepancies)
- **Agents**: Specialized agents via Task tool (if available)
- **MCP Tools**: Other external service integrations via ToolSearch

## Prerequisites

Before starting, locate these project artifacts:

1. **Mockups manifest** — search for `projects/*/mockups-manifest.md`. This maps screen names to Stitch screen IDs and defines the verification scope. If the user passed a manifest path as an argument, use that.
2. **Component map** (if exists) — search for `projects/*/component-map.md`. This maps Stitch elements to file paths, enabling precise fix suggestions.
3. **DESIGN.md** — search for `projects/*/DESIGN.md` or `DESIGN.md` at the repo root. This provides the token reference for color and spacing verification.
4. **App URL** — the user must provide either a URL (e.g., `https://staging.example.com`) or `localhost` (which will be resolved to the local dev server URL, typically `http://localhost:3000`).

If no mockups manifest and no mockup images are available:

> **No mockups found.**
> This command compares implementation against Stitch mockups. Run `/playbook:mockups` first to generate screens, then re-run `/playbook:design-verify`.

## Process

### Step 1: Capture Implementation

Take screenshots of the running application at each route and viewport that corresponds to a Stitch mockup.

**Resolve the app URL:**
- If the user said `localhost`, check for a running dev server (default `http://localhost:3000`). If not running, suggest `npm run dev` or the project's equivalent.
- If the user provided a URL, verify it is reachable.

**Screenshot matrix** — for each screen in the mockups manifest, capture at two viewports:

| Viewport | Dimensions | Name |
|----------|------------|------|
| Desktop | 1440 x 900 | `[screen]-desktop.png` |
| Mobile | 375 x 812 | `[screen]-mobile.png` |

**Capture process** (using Playwright browser tools):
1. Navigate to the route for each screen
2. Wait for the page to be fully loaded (network idle, no loading spinners)
3. Capture a full-page screenshot at each viewport size
4. Save screenshots to `projects/[project-name]/verification-screenshots/`

**If Playwright is not available**, ask the user to provide screenshots manually. Provide the exact viewport dimensions and routes needed.

**Report what was captured:**
- Number of screens captured
- Viewports captured per screen
- Any routes that failed to load or timed out

### Step 2: Fetch Mockups

Retrieve the Stitch mockup images for comparison.

**From Stitch MCP:**
1. Parse the mockups manifest for screen IDs
2. For each screen, use `get_screen` to retrieve the mockup image/details
3. Save mockup images alongside implementation screenshots for side-by-side reference

**From local files:**
If mockup images are already saved locally (from a previous `/playbook:mockups` run), locate them and use them directly.

**Establish screen pairs** — match each implementation screenshot to its corresponding mockup:

```
Screen Pairs:
- Home (desktop): implementation/home-desktop.png <-> mockup/home-screen-id
- Home (mobile): implementation/home-mobile.png <-> mockup/home-mobile-screen-id
- Menu (desktop): implementation/menu-desktop.png <-> mockup/menu-screen-id
- [etc.]
```

If a mockup does not have a mobile variant, note it as "desktop-only mockup" and compare only the desktop implementation screenshot.

### Step 3: Structured Comparison

For each screen pair (implementation screenshot vs. mockup), perform a structured analysis across six dimensions. This is the core of the verification.

**For each screen pair, analyze:**

#### 1. Layout
- Overall page structure: header, body, footer placement
- Content flow: vertical vs. horizontal, grid vs. flex
- Section ordering: does the implementation match the mockup's visual hierarchy?
- Responsive behavior: does the mobile layout adapt appropriately vs. the desktop layout?

#### 2. Spacing
- Padding within containers (cards, sections, headers)
- Margins between sections
- Gap between repeated elements (list items, grid cells, card groups)
- Overall whitespace rhythm: is it consistent with the mockup's breathing room?
- Compare against DESIGN.md spacing tokens if available

#### 3. Typography
- Font sizes: are headings, body text, and captions at the correct scale?
- Font weights: bold, semibold, and regular applied correctly?
- Line height: does text have the same density/openness as the mockup?
- Text color: correct semantic token usage (primary, secondary, muted)?
- Hierarchy: is the visual importance order preserved?

#### 4. Color
- Background colors: do surfaces match the mockup's palette?
- Text colors: correct token usage for each text level?
- Accent colors: CTAs, active states, highlights matching the design system?
- Border colors: correct tokens for dividers and outlines?
- Compare hex values against DESIGN.md if available — flag any raw color usage that should be a token

#### 5. Components
- Button styles: shape, size, color, text treatment
- Card styles: corners, shadows, borders, padding
- Input styles: borders, focus states, placeholder styling
- Navigation: structure, active states, icons
- Icons: correct icon choices, consistent sizing
- Any component that visually differs from the mockup

#### 6. Responsive Behavior
- Does the mobile implementation reorganize content appropriately?
- Are touch targets large enough (44x44px minimum)?
- Does content reflow rather than shrink?
- Are any desktop-only elements hidden on mobile (and vice versa)?
- Is horizontal scrolling avoided on mobile?

### Step 4: Diff Report

For each discrepancy found in Step 3, produce a structured entry with severity, location, and a fix suggestion.

**Severity levels:**

| Level | Meaning | Action |
|-------|---------|--------|
| **P0** | Broken layout, missing sections, wrong page structure, accessibility failure | Must fix before release |
| **P1** | Wrong colors, incorrect typography scale, significant spacing errors, missing components | Should fix — impacts design quality |
| **P2** | Minor spacing differences, slight color shade variations, small typography weight mismatches | Polish item — fix if time permits |
| **P3** | Sub-pixel rendering differences, minor shadow variations, negligible whitespace differences | Acceptable — expected implementation vs. mockup variance |

**Diff entry format:**

```markdown
### [P0/P1/P2/P3] — [Brief description]

**What**: [Specific description of the discrepancy]
**Where**: [Screen name, section, and file path if known from component map]
**Mockup**: [What the mockup shows]
**Implementation**: [What the implementation shows]
**Fix suggestion**: [Concrete action — token to use, class to change, component to adjust]
```

**Example entries:**

```markdown
### P1 — Hero section uses raw white instead of surface token

**What**: Hero background is `#FFFFFF` instead of the design system's surface-base token
**Where**: Home screen (desktop), hero section — `components/organisms/HeroSection.tsx:12`
**Mockup**: Warm linen background (#FAF6F1)
**Implementation**: Pure white (#FFFFFF)
**Fix suggestion**: Change `bg-white` to `bg-surface-base` in HeroSection.tsx

### P2 — Card padding slightly tighter than mockup

**What**: Menu cards have 12px internal padding vs. mockup's 16px
**Where**: Menu screen (desktop), menu card grid — `components/molecules/MenuCard.tsx:28`
**Mockup**: 16px padding (consistent with spacing scale `p-4`)
**Implementation**: 12px padding (`p-3`)
**Fix suggestion**: Change `p-3` to `p-4` in MenuCard.tsx
```

### Step 5: Save

Write the full verification report to: `projects/[project-name]/design-verification.md`

**Report format:**

```markdown
# Design Verification Report — [Project Name]

**Date**: [current date]
**App URL**: [URL used for capture]
**Mockups Source**: [mockups manifest path or "manual"]
**Design System**: [DESIGN.md path or "none"]

## Summary

| Severity | Count |
|----------|-------|
| P0 (Blocking) | [n] |
| P1 (Important) | [n] |
| P2 (Minor) | [n] |
| P3 (Acceptable) | [n] |

**Overall Assessment**: [Clean / Minor polish needed / Significant gaps remain]

## Screen-by-Screen Results

### [Screen Name] — Desktop (1440x900)

[Diff entries for this screen at desktop viewport]

### [Screen Name] — Mobile (375x812)

[Diff entries for this screen at mobile viewport]

## [Repeat for each screen]

## Cross-Screen Issues

[Any issues that appear across multiple screens — e.g., consistent wrong token usage, systemic spacing errors, typography scale drift]

## Verification Screenshots

Implementation screenshots saved to: `projects/[project-name]/verification-screenshots/`

| Screen | Viewport | File |
|--------|----------|------|
| Home | Desktop | `home-desktop.png` |
| Home | Mobile | `home-mobile.png` |
| [etc.] | [etc.] | [etc.] |
```

Confirm the report path with the user before writing.

## Key Principles

- **Mockups are design intent, not pixel truth** — Stitch produces static HTML previews. Minor rendering differences (anti-aliasing, font hinting, sub-pixel rounding) are inherent to the format difference and should be P3 at most.
- **Tokens over values** — when a color or spacing discrepancy is found, the fix should reference the project's design token, not a raw hex or pixel value. This prevents future drift.
- **File paths are actionable** — whenever possible, include the specific file and line number in the fix suggestion. The component map from `/playbook:design-to-code` is the key reference for this.
- **Severity drives priority** — P0 and P1 issues should be fixed before the feature ships. P2 items are polish. P3 items are informational and do not require action.
- **Responsive is not optional** — if the mockups include both desktop and mobile viewports, the verification must cover both. Mobile-only drift is still drift.

## Next Steps

Report complete. Proceed based on findings:
- **P0/P1 issues found**: Fix the discrepancies using `/playbook:work`, then re-run `/playbook:design-verify` to confirm fixes
- **Only P2/P3 remaining**: Design pipeline is effectively complete. Capture what worked and what didn't with `/playbook:learnings`
- **When clean**: The design-to-implementation pipeline is verified end-to-end. Capture learnings with `/playbook:learnings`, then proceed to final testing and PR
