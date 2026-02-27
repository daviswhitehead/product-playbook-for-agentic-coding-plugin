# DESIGN.md

<!-- This is the single source of truth for your project's visual design decisions.
     Sections from this document get injected into Stitch MCP prompts, so precision matters.
     Replace all [bracketed placeholders] with your actual values.
     Remove HTML comments before finalizing. -->

## Visual Theme & Atmosphere

<!-- Describe the overall visual feel using physical, sensory language.
     Good: "Warm and grounded, like a sunlit kitchen with oak shelves and stone countertops."
     Bad: "Modern and clean with a warm color palette."
     The description should evoke a specific place or material — someone reading it should
     be able to picture the mood without seeing any screens. -->

[Describe the visual atmosphere in 2-3 sentences. Use physical metaphors — materials, lighting, textures, spaces. This sets the tone for every Stitch generation prompt.]

## Color Palette & Roles

<!-- Every color needs four things: a Role (what job it does in the UI), a Name (physical/descriptive,
     not abstract), a Hex (exact value), and a Usage (where it appears in practice).
     Aim for 8-12 colors total. More than 15 usually indicates an unfocused palette. -->

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Primary Background | [e.g., Warm Linen] | [e.g., #FAF6F1] | [e.g., Page backgrounds, screen base] |
| Surface | [e.g., Light Oak] | [e.g., #F0E8DC] | [e.g., Cards, elevated panels, sidebar] |
| Surface Raised | [e.g., Parchment] | [e.g., #FFF8F0] | [e.g., Hover states, highlighted cards] |
| Primary Action | [e.g., Terracotta] | [e.g., #C75B3F] | [e.g., CTAs, active states, primary buttons] |
| Primary Action Hover | [e.g., Fired Clay] | [e.g., #A8482F] | [e.g., Button hover, pressed states] |
| Secondary Action | [e.g., Sage] | [e.g., #7A9E7E] | [e.g., Secondary buttons, success indicators] |
| Text Primary | [e.g., Charcoal] | [e.g., #2D2D2D] | [e.g., Headings, primary body text] |
| Text Secondary | [e.g., Warm Gray] | [e.g., #6B6560] | [e.g., Captions, secondary labels, metadata] |
| Text Inverse | [e.g., White Linen] | [e.g., #FFFFFF] | [e.g., Text on filled buttons, dark surfaces] |
| Border Default | [e.g., Stone Edge] | [e.g., #D4CFC8] | [e.g., Card borders, dividers, input outlines] |
| Error | [e.g., Brick Red] | [e.g., #D14343] | [e.g., Error messages, destructive actions] |
| Warning | [e.g., Saffron] | [e.g., #E6A817] | [e.g., Warning banners, caution states] |

<!-- Dark mode: If your project supports dark mode, add a "Dark Mode" subsection below
     with the equivalent mappings. Each role should have a dark mode hex. -->

## Typography Rules

<!-- Define the type scale, families, and rules. Be specific about sizes, weights,
     and line-heights. Stitch needs exact values to render accurately. -->

- **Font Family**: [e.g., Inter for UI, Merriweather for long-form content]
- **Fallback Stack**: [e.g., -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif]

### Type Scale

| Level | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| Display | [e.g., 36px] | [e.g., Bold (700)] | [e.g., 1.2] | [e.g., Hero headlines, landing pages] |
| H1 | [e.g., 28px] | [e.g., Bold (700)] | [e.g., 1.25] | [e.g., Page titles] |
| H2 | [e.g., 22px] | [e.g., Semibold (600)] | [e.g., 1.3] | [e.g., Section headers] |
| H3 | [e.g., 18px] | [e.g., Semibold (600)] | [e.g., 1.35] | [e.g., Card titles, subsections] |
| Body | [e.g., 16px] | [e.g., Regular (400)] | [e.g., 1.5] | [e.g., Paragraphs, descriptions] |
| Body Small | [e.g., 14px] | [e.g., Regular (400)] | [e.g., 1.5] | [e.g., Secondary text, metadata] |
| Caption | [e.g., 12px] | [e.g., Medium (500)] | [e.g., 1.4] | [e.g., Labels, timestamps, badges] |

### Typography Rules

<!-- Add any global rules about type usage. -->

- [e.g., Never use more than 2 heading levels on a single screen]
- [e.g., Body text minimum size is 14px for readability]
- [e.g., Use semibold (600) for emphasis, never italic for UI labels]

## Spacing & Radius

<!-- Define the spacing scale and border radius tokens. Use a consistent base unit. -->

### Base Unit

[e.g., 4px — all spacing values are multiples of this base]

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| xs | [e.g., 4px] | [e.g., Icon-to-label gap, tight internal padding] |
| sm | [e.g., 8px] | [e.g., Compact padding, related element spacing] |
| md | [e.g., 16px] | [e.g., Standard padding, card internal spacing] |
| lg | [e.g., 24px] | [e.g., Section spacing, generous padding] |
| xl | [e.g., 32px] | [e.g., Major section gaps, page margins] |
| 2xl | [e.g., 48px] | [e.g., Hero spacing, top-level section separation] |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| none | 0px | [e.g., Dividers, full-bleed elements] |
| sm | [e.g., 4px] | [e.g., Badges, small chips] |
| md | [e.g., 8px] | [e.g., Buttons, inputs, small cards] |
| lg | [e.g., 12px] | [e.g., Cards, modals, popovers] |
| xl | [e.g., 16px] | [e.g., Large cards, hero sections] |
| full | 9999px | [e.g., Avatars, pills, circular buttons] |

## Component Patterns

<!-- Define the reusable component patterns. Each subsection should cover
     visual appearance, states, and key dimensions. These patterns get injected
     into Stitch prompts when generating screens that include the component. -->

### Buttons

#### Primary Button
- **Background**: [e.g., Primary Action color, solid fill]
- **Text**: [e.g., Text Inverse, Body weight semibold]
- **Padding**: [e.g., 12px vertical, 24px horizontal]
- **Radius**: [e.g., md (8px)]
- **States**:
  - Default: [e.g., Primary Action background]
  - Hover: [e.g., Primary Action Hover background]
  - Pressed: [e.g., Slightly darker, scale down to 98%]
  - Disabled: [e.g., 40% opacity, no pointer events]
  - Loading: [e.g., Spinner replaces text, same dimensions]

#### Secondary Button
- **Background**: [e.g., Transparent with Primary Action border]
- **Text**: [e.g., Primary Action color, Body weight semibold]
- **Padding**: [e.g., 12px vertical, 24px horizontal]
- **Radius**: [e.g., md (8px)]
- **States**:
  - Default: [describe]
  - Hover: [describe]
  - Pressed: [describe]
  - Disabled: [describe]

#### Ghost Button
- **Background**: [e.g., Transparent, no border]
- **Text**: [e.g., Text Secondary, Body weight medium]
- **Padding**: [e.g., 8px vertical, 16px horizontal]
- **States**:
  - Default: [describe]
  - Hover: [e.g., Surface background appears]

### Cards

- **Background**: [e.g., Surface color]
- **Border**: [e.g., 1px Border Default]
- **Radius**: [e.g., lg (12px)]
- **Padding**: [e.g., md (16px)]
- **Shadow**: [e.g., Level 1 shadow from Shadow section]
- **States**:
  - Default: [describe]
  - Hover: [e.g., Subtle lift — shadow increases to Level 2]
  - Selected: [e.g., Primary Action border, Surface Raised background]

### Inputs

- **Background**: [e.g., Primary Background color]
- **Border**: [e.g., 1px Border Default, 2px Primary Action on focus]
- **Radius**: [e.g., md (8px)]
- **Padding**: [e.g., 12px horizontal, 10px vertical]
- **Text**: [e.g., Text Primary for value, Text Secondary for placeholder]
- **States**:
  - Default: [describe]
  - Focus: [e.g., Border changes to Primary Action, subtle glow]
  - Error: [e.g., Border changes to Error color, helper text in Error]
  - Disabled: [e.g., Surface background, 50% opacity text]
- **Label**: [e.g., Caption size, Text Secondary, above the input with sm gap]

### Navigation

<!-- Describe your primary navigation pattern (tab bar, sidebar, top nav, etc.) -->

- **Type**: [e.g., Bottom tab bar (mobile), Sidebar (desktop)]
- **Background**: [e.g., Surface color with top border]
- **Active Item**: [e.g., Primary Action icon + label, bold weight]
- **Inactive Item**: [e.g., Text Secondary icon + label, regular weight]
- **Dimensions**: [e.g., 56px height mobile, 240px width sidebar desktop]

### Empty States

<!-- How screens look when there is no content yet. -->

- **Illustration**: [e.g., Subtle line drawing, centered, muted colors]
- **Headline**: [e.g., H3, Text Primary, centered]
- **Description**: [e.g., Body Small, Text Secondary, centered, max-width 280px]
- **Action**: [e.g., Primary Button below description, lg gap]

## Shadow & Depth

<!-- Define elevation levels. Shadows communicate hierarchy — use them consistently. -->

| Level | Shadow Value | Usage |
|-------|-------------|-------|
| Level 0 | none | [e.g., Flat elements, inset surfaces] |
| Level 1 | [e.g., 0 1px 3px rgba(0,0,0,0.08)] | [e.g., Cards, dropdowns at rest] |
| Level 2 | [e.g., 0 4px 12px rgba(0,0,0,0.12)] | [e.g., Hovered cards, popovers] |
| Level 3 | [e.g., 0 8px 24px rgba(0,0,0,0.16)] | [e.g., Modals, dialogs, floating actions] |
| Level 4 | [e.g., 0 16px 48px rgba(0,0,0,0.20)] | [e.g., Full-screen overlays, toasts] |

### Depth Rules

- [e.g., Content further from the page surface gets a higher shadow level]
- [e.g., Interactive elements that lift on hover move from Level 1 to Level 2]
- [e.g., Never apply shadows to flat, inline elements like text or dividers]

## Accessibility Constraints

<!-- These constraints are non-negotiable. They get injected into Stitch prompts
     and verified during design-verify. -->

### Contrast Requirements

- **Text on backgrounds**: Minimum 4.5:1 ratio (WCAG AA) for normal text
- **Large text** (18px+ bold or 24px+ regular): Minimum 3:1 ratio
- **UI components and icons**: Minimum 3:1 ratio against adjacent colors
- **Focus indicators**: Minimum 3:1 ratio against the component and its background

### Touch Targets

- **Minimum size**: [e.g., 44x44px for all interactive elements]
- **Minimum spacing**: [e.g., 8px between adjacent touch targets]

### Focus Indicators

- **Style**: [e.g., 2px solid outline in Primary Action color, 2px offset]
- **Visibility**: [e.g., Must be visible on all backgrounds — test on Surface and Primary Background]

### Reduced Motion

- **Policy**: [e.g., All animations respect prefers-reduced-motion. Fade transitions reduce to instant. Scroll animations are disabled.]

### Screen Reader Considerations

- [e.g., All images have descriptive alt text]
- [e.g., Interactive elements have accessible labels]
- [e.g., Status changes are announced via live regions]
- [e.g., Heading hierarchy is logical (no skipped levels)]

---

<!-- After completing this document:
     1. Review all hex values — ensure they match your actual palette
     2. Verify contrast ratios using a tool like WebAIM Contrast Checker
     3. Check that every color Role is used somewhere in Component Patterns
     4. This document gets injected into Stitch prompts — vague language produces vague designs -->
