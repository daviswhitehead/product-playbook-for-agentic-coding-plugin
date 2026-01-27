# Design Spec: [Project / Feature Name]

## TL;DR

*One paragraph describing what will change and the user-visible outcome.*

## Goals

- [ ] Goal 1
- [ ] Goal 2

## Non-goals

- [ ] Non-goal 1
- [ ] Non-goal 2

## References

- Product Requirements: [link/path] (optional)
- Design Critique: [link/path] (optional)
- Screenshots / Mockups: [links/paths]
- Design system / tokens: [links/paths]

## Content Structure & Hierarchy

### Primary user outcome
*What the user must be able to do / understand immediately.*

### Information architecture (IA)
*Describe the screen structure and what is primary vs secondary.*

### Component hierarchy
*List top-level components and their children.*

## Layout, Spacing, and White Space

### Grid and width constraints
- Content max width: [e.g., 768px]
- Page padding: [e.g., 16px mobile / 24px desktop]

### Vertical rhythm
- Message spacing / section spacing: [explicit px]
- Touch targets: [e.g., 44px minimum]

### Responsive rules
- Mobile rules:
- Tablet rules:
- Desktop rules:

## Visual Design

### Typography
- Font sizes:
- Line-height:
- Emphasis rules:

### Color
- Primary actions:
- Secondary actions:
- Text hierarchy:

### Texture and backgrounds
- Page background:
- Surface backgrounds:
- Optional brand texture (if any):

## Components (Spec Cards)

For each component:

### [Component Name]
- Purpose:
- States:
- Layout:
  - padding:
  - spacing:
  - sizing:
- Visual style:
  - typography:
  - colors:
  - backgrounds:
- Interaction:
  - hover/pressed/disabled/focus:
- Motion:
  - transition:
  - reduced motion:
- Accessibility:
  - labels:
  - keyboard:

## State Machines (Required for Interactive UX)

### [Area Name] State Machine

| State | What user sees | What user can do | Triggers / transitions |
|---|---|---|---|
| `state_a` |  |  |  |
| `state_b` |  |  |  |

## Motion / Animation Spec

### Animation principles
- When to animate:
- When not to animate:

### Exact timings
- Enter/exit: [ms]
- Hover/press: [ms]
- Loading/progress: [ms]

### Reduced motion behavior
- If reduced motion is enabled:

## Copy / Microcopy

- Empty state:
- Loading/progress:
- Error states:
- Success states:

## Accessibility

- Keyboard navigation:
- Screen reader / live regions:
- Contrast:
- Reduced motion:

## Instrumentation Hooks (Optional but recommended)

Define the events/timestamps we should emit for performance and regression tracking:
- [ ] Event 1: name + when + properties
- [ ] Event 2: name + when + properties

## Edge Cases & Failure States

- Slow network:
- Partial results:
- Retry behavior:
- Refresh/resume behavior:

## Acceptance Criteria (Pixel + Behavior)

- [ ] Criterion 1 (visual)
- [ ] Criterion 2 (behavioral)
- [ ] Criterion 3 (accessibility)

## Engineering Map (Where changes live)

- Likely files/components:
- New components to add:
- Tests to update/add:

## Open Decisions

1. [Decision]: options + recommendation
2. [Decision]:

## Decision Log

- [DATE] [Decision] → [Outcome]
