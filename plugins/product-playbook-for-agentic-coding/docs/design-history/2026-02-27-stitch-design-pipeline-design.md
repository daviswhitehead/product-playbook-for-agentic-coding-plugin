# Stitch Design Pipeline — Design Document

**Status**: Approved
**Created**: 2026-02-27
**Owner**: Davis
**Scope**: Product Playbook Plugin (product-playbook-for-agentic-coding)

---

## Summary

Add a complete visual design pipeline to the product playbook plugin, powered by Google Stitch MCP. The pipeline fills the gap between product requirements and implementation — automating design system extraction, mockup prompt generation, batch screen generation, multi-persona visual critique, code scaffolding, and implementation verification.

### Pipeline Overview

```
Standard:  product-requirements → tech-plan → tasks → work
With UI:   product-requirements → design-system → design-spec → mockups → design-critique
           → tech-plan → tasks → work → design-verify
```

### What We're Building

| Item | Type | Description |
|------|------|-------------|
| `design-system` | NEW command | Extract/create canonical DESIGN.md from Stitch screens or codebase tokens |
| `design-spec` | ENHANCE existing | Add Stitch prompt generation step after engineering spec |
| `mockups` | NEW command | Batch-generate Stitch screens with consistency enforcement |
| `design-critique` | ENHANCE existing | Add Stitch screenshot fetching + new visual critique personas |
| `design-to-code` | NEW command | Transform Stitch HTML → project component scaffolds |
| `design-verify` | NEW command | Compare running implementation against Stitch mockups |
| `stitch-integration` | NEW skill | Shared Stitch patterns referenced by all commands |
| `design-system.md` | NEW template | Canonical DESIGN.md template |
| `product-requirements` | UPDATE routing | Route UI-heavy projects to design pipeline |
| `help` | UPDATE docs | Show full pipeline with design steps |

### Key Integration

The official Google Stitch agent skills (`design-md`, `enhance-prompt`, `react-components`, `stitch-loop`) handle atomic Stitch operations. Our playbook commands orchestrate these patterns into a product development workflow with quality gates, iteration loops, and cross-command chaining.

---

## Architecture

### Plugin File Changes

```
product-playbook-for-agentic-coding/
├── commands/workflows/
│   ├── design-spec.md          # ENHANCE — add Stitch prompt generation (Step 6)
│   ├── design-critique.md      # ENHANCE — add Stitch screenshot fetching + new personas
│   ├── design-system.md        # NEW
│   ├── mockups.md              # NEW
│   ├── design-to-code.md       # NEW
│   ├── design-verify.md        # NEW
│   ├── product-requirements.md # UPDATE — add design pipeline routing
│   └── help.md                 # UPDATE — show full pipeline
├── skills/
│   └── stitch-integration/
│       └── SKILL.md            # NEW — shared Stitch patterns
├── resources/templates/
│   └── design-system.md        # NEW — DESIGN.md template
└── .claude-plugin/
    └── plugin.json             # BUMP version (minor)
```

### Dependency Graph

```
stitch-integration (skill) ← referenced by all commands
design-system ← produces DESIGN.md
design-spec ← reads DESIGN.md, produces Stitch prompts
mockups ← reads prompts, produces Stitch screens + manifest
design-critique ← reads manifest, fetches screenshots, produces critique
  ↻ iterate: critique → mockups (regenerate affected screens) → critique
design-to-code ← reads manifest + screen code, produces component scaffolds
design-verify ← reads manifest + running app, produces diff report
```

---

## Stitch Best Practices (Encoded in Skill)

Distilled from official Stitch docs, Google forums, community experience, and the official Stitch agent skills.

### Prompt Construction

1. **5-element structure**: Every prompt must include purpose statement, core components list, layout language, visual styling, and dynamic content
2. **One change per prompt**: Never mix layout changes and UI component changes in the same prompt
3. **UI/UX terminology**: Use "navigation bar" not "menu at top", "call-to-action button" not "main button"
4. **Mood adjectives**: Add brand personality descriptors — "Japandi-styled", "warm", "restrained", "minimalist"
5. **Screen-by-screen**: For complex apps, start high-level then drill down per screen

### Design System Consistency

6. **DESIGN.md injection**: Include design system block at the top of every prompt
7. **Descriptive color names + hex**: "Warm Terracotta (#A06840) — primary CTA fills" not just `#A06840`
8. **Natural language over CSS**: Translate technical values into physical/descriptive language
9. **Feed-forward pattern**: Generate anchor screen first → extract design context → prepend to all subsequent prompts
10. **Known weakness**: Multi-screen consistency is Stitch's primary challenge — DESIGN.md + extract_design_context are the mitigations

### Generation Strategy

11. **Standard mode for iteration** (350 generations/month) — use for exploration and refinement
12. **Experimental mode for fidelity** (50 generations/month) — reserve for final versions
13. **Treat as accelerator**: Stitch produces starting points, not pixel-perfect final output
14. **Incremental refinement**: Tackle one concern at a time, verify, then move to next
15. **Regenerate selectively**: If one screen drifts, regenerate that screen only (don't redo the batch)

### Known Limitations

16. **Visual hierarchy**: Stitch may produce flat hierarchy — critique step catches this
17. **Brand guidelines**: Cannot be applied automatically — DESIGN.md is the workaround
18. **Placeholder icons/labels**: Sometimes renders as generic — note in critique
19. **Interaction/animation**: No support — must be specified in engineering design spec only
20. **Code is static HTML/CSS**: Needs transformation for any framework (React Native, Vue, etc.)

---

## Command Designs

### 1. `/playbook:design-system` (NEW)

**Purpose**: Extract or create a canonical DESIGN.md from existing screens or project tokens.

**Why first**: Every other command depends on having a design system doc.

**Inputs** (auto-detected):
- Existing Stitch project screens → `extract_design_context` + `get_screen`
- Existing codebase design tokens (e.g., `design-tokens.ts`, `tailwind.config.ts`)
- Existing design docs (e.g., `design-spec-prompts.md` system sections)
- Manual input → guided interview

**Process**:
1. **Discover sources** — scan for Stitch projects (via `list_projects`), codebase token files, and existing design docs
2. **Extract** — pull design DNA from each source using Stitch `extract_design_context` + file reads
3. **Translate** — convert technical values to Stitch-optimized natural language following the `design-md` skill pattern: "Warm Terracotta (#A06840) — primary CTA fills, used sparingly" not `bg-terracotta-500`
4. **Synthesize** — merge all sources into canonical DESIGN.md:
   - Visual Theme & Atmosphere
   - Color Palette & Roles (descriptive name + hex + functional purpose)
   - Typography Rules
   - Spacing & Radius
   - Component Patterns (buttons, cards, inputs, navigation)
   - Shadow & Depth
   - Accessibility Constraints
5. **Drift detection** — if both Stitch screens and codebase tokens exist, flag inconsistencies between them
6. **Save** — write to `projects/[project]/DESIGN.md`

**Output**: DESIGN.md that can be injected directly into Stitch prompts.

**Next Steps**: "Design system documented. Proceed to `/playbook:design-spec` to generate screen prompts, or `/playbook:mockups` if prompts already exist."

---

### 2. `/playbook:design-spec` (ENHANCE existing)

**Purpose**: Read a PRD and generate per-screen Stitch-optimized prompts alongside the engineering design spec.

**What changes**: Add Step 6 (Stitch prompt generation) after existing Steps 1-5. The engineering spec is unchanged; the prompts are an additive output.

**Inputs**:
- PRD (required) — `projects/[project]/product-requirements.md`
- DESIGN.md (recommended) — injected into every prompt; if missing, suggest `/playbook:design-system` first
- Design critique (optional) — incorporates findings if one exists

**New Step 6 — Generate Stitch Prompts**:

For each screen identified in the spec:
1. Extract screen purpose, components, layout, and states from the spec
2. Structure into Stitch 5-element format:
   - Purpose statement (one line)
   - DESIGN SYSTEM block (from DESIGN.md)
   - Core components list with specific UI/UX terminology
   - Layout description with explicit structure
   - Visual styling with mood adjectives
   - Dynamic content / example data
3. Include viewport specifications: desktop (1440x900), mobile (375x812)
4. Include dark mode guidance if DESIGN.md defines it
5. One prompt per screen, one concern per prompt
6. Prioritize prompts (P1, P2, P3) matching PRD priority
7. Save as `projects/[project]/design-spec-prompts.md` or append to design spec as "## Stitch Prompts" section

**Prompt template** (based on Stitch best practices):
```markdown
## Prompt N: [Screen Name] (Priority [N])

### Context
[What this screen does and who sees it — from PRD]

### Design System
[Injected from DESIGN.md — colors, typography, spacing, shadows]

### What to Design
[Platform]: [viewport dimensions]

**[Section 1]** ([position]):
- [Component]: [specific UI/UX terminology], [dimensions], [token colors]
- [Component]: ...

**[Section 2]** ([position]):
- ...

### Content Examples
[Realistic example data — not lorem ipsum]

### Visual Tone
[Mood adjectives and brand voice — 2-3 sentences]
```

**Output**: Engineering design spec + per-screen Stitch prompts.

**Next Steps**: "Design spec and Stitch prompts generated. Proceed to `/playbook:mockups` to batch-generate screens."

---

### 3. `/playbook:mockups` (NEW)

**Purpose**: Batch-generate Stitch screens from prompts with automatic consistency enforcement.

**Inputs**:
- Stitch prompts (required) — from `design-spec-prompts.md`
- DESIGN.md (recommended) — for post-generation consistency verification
- Existing Stitch project ID (optional) — reuse or create new

**Process**:
1. **Setup** — create Stitch project via `create_project` or use existing
2. **Generate anchor screen** — generate highest-priority (P1) screen first via `generate_screen_from_text`
3. **Extract design context** — call `extract_design_context` on anchor screen to capture its DNA
4. **Generate remaining screens** — for each subsequent prompt, prepend extracted design context for consistency (feed-forward pattern)
5. **Verify each screen**:
   - Fetch screenshot via `get_screen` for visual reference
   - Fetch code via `get_screen` for later use by `design-to-code`
   - Log generation metadata
6. **Consistency check** — compare extracted context from final screen against anchor; flag drift
7. **Save manifest** — write `projects/[project]/mockups-manifest.md`:
   - Stitch project ID
   - Per-screen: screen ID, prompt used, screenshot path, code reference, generation order
   - Consistency notes
   - Generation date and mode used

**Stitch rules encoded**:
- One screen per `generate_screen_from_text` call
- Standard mode for iteration, experimental for final pass
- Feed-forward design context from anchor screen
- Selective regeneration (one screen, not whole batch)

**Output**: Stitch project with generated screens + manifest doc.

**Next Steps**: "Screens generated. Proceed to `/playbook:design-critique` for visual feedback, or `/playbook:tech-plan` if designs look good."

---

### 4. `/playbook:design-critique` (ENHANCE existing)

**Purpose**: Run multi-persona visual critique on generated mockups with automatic Stitch screenshot fetching.

**What changes**: Auto-fetch Stitch screenshots instead of asking user to share them manually. Add two new critique personas (Mobile UX Specialist, Brand Consistency Reviewer). Add cross-screen analysis step.

**Inputs**:
- Mockups manifest (recommended) — from `/playbook:mockups`
- OR Stitch project/screen IDs (manual)
- OR user-provided screenshots
- DESIGN.md (recommended) — ground truth for brand consistency checks

**Enhanced Process**:

1. **Auto-gather visuals** — if manifest exists, fetch all screen images via `get_screen`, save to project folder
2. **Per-screen 5-perspective critique** (2 existing + 1 enhanced + 2 new):
   - **Product Designer** — visual hierarchy, information architecture, typography, color, spacing. ENHANCED: compare against DESIGN.md tokens, flag deviations
   - **User Researcher** — mental models, task flows, confusion points, learnability (unchanged)
   - **Accessibility Expert** — contrast ratios, touch targets (44x44px min), WCAG compliance, color-alone info (unchanged)
   - **Mobile UX Specialist** (NEW) — responsive behavior, thumb zones, scroll depth, keyboard avoidance, viewport-specific issues
   - **Brand Consistency Reviewer** (NEW) — compare across all screens for font consistency, color palette drift, spacing rhythm, component reuse
3. **Cross-screen analysis** (NEW) — compare all screens together: navigation consistency, shared component divergence, typography scale drift
4. **Synthesize** — prioritized feedback with severity:
   - P0: Blocking — must fix before proceeding
   - P1: Important — should fix, significantly impacts UX
   - P2: Minor — polish item
   - P3: Nice-to-have
5. **Iteration recommendations** — for each P0/P1: suggest specific prompt modification and whether to regenerate
6. **Save** — `projects/[project]/design-critique.md`

**Iteration loop**: If P0/P1 issues found → suggest modified prompts → re-run `/playbook:mockups` for affected screens → re-critique.

**Output**: Prioritized critique with actionable feedback and regeneration recommendations.

**Next Steps**: "If P0/P1 issues remain: iterate mockups. If converged: proceed to `/playbook:tech-plan`."

---

### 5. `/playbook:design-to-code` (NEW)

**Purpose**: Transform Stitch HTML into project component scaffolds matching existing architecture.

**Inputs**:
- Stitch screen IDs or mockups manifest (required)
- Target framework (auto-detected from codebase)
- DESIGN.md (recommended) — maps Stitch colors to project tokens

**Process**:
1. **Fetch source** — get HTML/CSS code for each screen via `get_screen`
2. **Analyze codebase** — scan existing components, detect framework (React Native + NativeWind + gluestack), component structure (atoms/molecules/organisms), token system
3. **Build translation map**:
   - HTML tags → React Native: `<div>` → `<View>`, `<p>` → `<Text>`, `<img>` → `<Image>`, `<button>` → `<Pressable>`
   - CSS/Tailwind → NativeWind + semantic tokens: `bg-white` → `bg-surface-raised`, `text-gray-900` → `text-ink-primary`
   - Inline styles → token references
   - CSS layout → React Native flex patterns
4. **Map to existing components** — check existing atoms/molecules before creating new ones
5. **Scaffold new components**:
   - Follow project conventions (functional components, TypeScript interfaces, JSDoc, accessibility)
   - Place in correct directory (atoms/molecules/organisms)
   - Use semantic tokens only (never raw colors)
   - Add `alt` + `accessibilityLabel` for images
   - Generate proper TypeScript interfaces with `Readonly` props
6. **Write component map** — document which Stitch elements mapped to which components
7. **Save** — scaffolds to codebase, map to `projects/[project]/component-map.md`

**Scope boundary**: Produces 70-80% scaffolds. Does NOT implement state management, data binding, API calls, or interaction logic. That's `/playbook:work`.

**Output**: Component scaffolds + component map.

**Next Steps**: "Components scaffolded. Use `/playbook:work` for state and interactions. Run `/playbook:design-verify` after implementation."

---

### 6. `/playbook:design-verify` (NEW)

**Purpose**: Compare running implementation against Stitch mockups, produce a visual diff report.

**Inputs**:
- Running app URL or dev server (required)
- Mockups manifest with screen IDs (required)
- Component map (optional) — focuses comparison

**Process**:
1. **Capture implementation** — Playwright screenshots at each route, at each viewport (desktop 1440x900, mobile 375x812)
2. **Fetch mockups** — Stitch screen images via `get_screen`
3. **Structured comparison** per screen pair:
   - Layout: positioning, grid structure, alignment
   - Spacing: margins, padding, gaps
   - Typography: sizes, weights, line heights, hierarchy
   - Color: fills, text colors, accent usage, token compliance
   - Components: button styles, card shapes, inputs, navigation
   - Responsive: mobile vs desktop, breakpoint behavior
4. **Diff report** per discrepancy:
   - What: specific description ("Metadata chips: 16px gap in mockup, 8px in implementation")
   - Where: file path + line if detectable from component map
   - Severity: P0 (visually broken) → P3 (minor polish)
   - Fix: specific class/style change suggestion
5. **Save** — `projects/[project]/design-verification.md`

**Limitation**: Structured visual analysis, not pixel-diff tooling. Catches spacing, color, typography, and layout drift. Treats mockups as design intent, not pixel-perfect truth.

**Output**: Prioritized diff report with fix suggestions.

**Next Steps**: "Fix P0/P1 discrepancies, re-run to confirm convergence. When clean, the design pipeline is complete."

---

## Shared Skill: `skills/stitch-integration/SKILL.md`

Referenced by all 6 commands. Encodes:

1. **Tool discovery** — find Stitch MCP tools (namespace detection, fallback patterns)
2. **Prompt construction rules** — 5-element format, one-change-per-prompt, UI/UX terminology, mood adjectives
3. **DESIGN.md format** — canonical structure with natural-language + hex pattern
4. **Consistency patterns** — anchor screen → extract context → feed forward
5. **Known limitations** — multi-screen drift, visual hierarchy, placeholder icons, static code output
6. **Mode guidance** — Standard (350/mo) for iteration, Experimental (50/mo) for fidelity
7. **Tool reference** — `list_projects`, `create_project`, `list_screens`, `get_screen`, `get_project`, `generate_screen_from_text`, `extract_design_context` with parameters and usage patterns

---

## Pipeline Updates

### `product-requirements.md` — Routing Update

Add to Step 0 routing logic: when project involves significant UI (new pages, new components, visual redesign), route to design pipeline before tech-plan:

```
design-system → design-spec → mockups → design-critique → tech-plan → tasks → work → design-verify
```

### `help.md` — Pipeline Documentation

Show both flows:
```
Standard pipeline:
  product-requirements → tech-plan → tasks → work → learnings

UI-enhanced pipeline:
  product-requirements → design-system → design-spec → mockups → design-critique
  → tech-plan → tasks → work → design-verify → learnings
```

---

## Testing Plan

Test the entire pipeline end-to-end against the **Chef Chopsky Recipes feature**:

1. `/playbook:design-system` — extract from existing `design-spec-prompts.md` + `design-tokens.ts` + `tailwind.config.ts`
2. `/playbook:design-spec` — read recipes PRD → generate prompts for all 6 screens (sidebar, recipe detail, preview card, nav sidebar, home page, collection page)
3. `/playbook:mockups` — batch-generate all screens in Stitch
4. `/playbook:design-critique` — run visual critique, iterate if needed
5. `/playbook:tech-plan` — plan implementation referencing approved mockups
6. `/playbook:tasks` + `/playbook:work` — implement with `design-to-code` scaffolding
7. `/playbook:design-verify` — compare implementation against mockups

Success criteria: the full pipeline produces usable mockups and component scaffolds for the recipes feature without manual prompt writing.

---

## References

- [Stitch Prompt Guide — Google AI Forum](https://discuss.ai.google.dev/t/stitch-prompt-guide/83844)
- [Google Stitch Tutorial — Codecademy](https://www.codecademy.com/article/google-stitch-tutorial-ai-powered-ui-design-tool)
- [Maintaining Style Consistency — Google AI Forum](https://discuss.ai.google.dev/t/how-to-maintain-style-consistency/116160)
- [Stitch Agent Skills — GitHub](https://github.com/google-labs-code/stitch-skills)
- [Google Stitch Review — Index.dev](https://www.index.dev/blog/google-stitch-ai-review-for-ui-designers)
- [Introducing Stitch — Google Developers Blog](https://developers.googleblog.com/stitch-a-new-way-to-design-uis/)
