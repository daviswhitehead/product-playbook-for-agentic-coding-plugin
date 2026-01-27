---
name: playbook:design-spec
description: Create a high-fidelity design specification for complex UI features
argument-hint: "[optional: project name or feature]"
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

## Inputs (Optional)

- Product Requirements Document (recommended, not required)
- Design Critique from `/playbook:design-critique` (optional)
- Screenshots / competitor references (optional)
- Existing design system/tokens (recommended if available)

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
2. Recommend saving images in `docs/projects/[project-name]/`.
3. Use clear filenames (e.g., `agent-reply-states.png`, `composer-states.png`).
4. Capture short notes for each image: what it shows and why it matters.

*(Optional)* If images are huge and hard to view in tooling, suggest exporting a smaller JPG alongside the original PNG.

### Step 2: Locate or create the template

1. Check if a design spec already exists for this project
2. If not, use the design-spec template from this plugin's `resources/templates/`
3. Create it at: `docs/projects/[project-name]/design-spec.md`

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

## Next Steps

After the design spec:
- If architecture work is next: proceed to `/playbook:tech-plan`
- If tasks are next: proceed to `/playbook:tasks`
- If implementation begins: use `/playbook:work`
