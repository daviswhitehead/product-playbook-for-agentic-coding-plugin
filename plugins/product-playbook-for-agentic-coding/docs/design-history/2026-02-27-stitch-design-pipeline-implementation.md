# Stitch Design Pipeline — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a 6-command visual design pipeline to the product playbook plugin, powered by Google Stitch MCP.

**Architecture:** All changes are markdown command/skill files within the existing plugin structure. The shared `stitch-integration` skill encodes Stitch best practices; 4 new commands and 2 enhanced commands form a pipeline that chains via "Next Steps" sections. Pipeline routing in `product-requirements` and `help` connects the design pipeline to the existing 4-phase workflow.

**Tech Stack:** Claude Code plugin system (markdown commands, skills, templates), Google Stitch MCP tools

**Design Doc:** `docs/plans/2026-02-27-stitch-design-pipeline-design.md`

---

## Key Paths

```
Plugin root:  ~/.claude/plugins/marketplaces/product-playbook-marketplace/plugins/product-playbook-for-agentic-coding/
Abbreviation: $PLUGIN
```

All file paths below use `$PLUGIN` as shorthand. Expand to the full path when implementing.

---

### Task 1: Create the shared `stitch-integration` skill

**Files:**
- Create: `$PLUGIN/skills/stitch-integration/SKILL.md`

This skill is referenced by all 6 commands. It must exist first.

**Step 1: Write the skill file**

Create `$PLUGIN/skills/stitch-integration/SKILL.md` with this content:

```markdown
---
name: stitch-integration
description: Shared patterns for using Google Stitch MCP tools. Referenced by design pipeline commands (design-system, design-spec, mockups, design-critique, design-to-code, design-verify). Use this skill when any playbook command needs to interact with Stitch.
---

# Stitch Integration Patterns

This skill provides shared knowledge for all playbook commands that interact with Google Stitch MCP.

## Tool Discovery

Before calling any Stitch tool, discover available tools:

1. Use ToolSearch with query "stitch" to find available Stitch MCP tools
2. Common tool names: `create_project`, `get_project`, `list_projects`, `list_screens`, `get_screen`, `generate_screen_from_text`, `edit_screens`, `generate_variants`, `extract_design_context` (actual names may vary by MCP server configuration)
3. If no Stitch tools are found, inform the user: "Stitch MCP is not configured. Install it with: `claude mcp add -t http stitch <stitch-mcp-url>` or see https://stitch.withgoogle.com/docs/mcp/setup"

## Prompt Construction Rules

Every Stitch prompt must follow the **5-element structure**:

1. **Purpose statement** (one line): "Design a [screen type] for [platform] that [primary function]"
2. **Design system block**: Injected from DESIGN.md — colors with descriptive names + hex, typography, spacing, shadows
3. **Core components list**: Specific UI/UX terminology — "navigation bar", "call-to-action button", "card layout", "floating action button" (never vague terms like "menu at top" or "main button")
4. **Layout description**: Explicit structure with dimensions — "single column, centered, max-width 720px, 48px top padding"
5. **Visual styling + mood**: Brand personality adjectives — "warm", "restrained", "Japandi-styled", "inviting"

### Critical Rules

- **One change per prompt**: Never mix layout changes and UI component changes in the same prompt
- **One screen per generation**: Each `generate_screen_from_text` call produces one screen
- **Descriptive color names**: "Warm Terracotta (#A06840) — primary CTA fills" not just `#A06840`
- **Include realistic content**: Use real example data, never lorem ipsum
- **Specify viewports explicitly**: Desktop (1440x900), Mobile (375x812), Tablet (768x1024)

## DESIGN.md Format

The canonical design system document follows this structure (adapted from Google's `design-md` skill pattern):

```
# DESIGN.md

## Visual Theme & Atmosphere
[2-3 sentences describing the overall mood, style references, and feeling]

## Color Palette & Roles
| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Page background | Warm White Oak | #FAFAF8 | Primary surface, like light oak |
| Card/sidebar | Oak Cabinetry | #F5F0EB | Elevated surfaces |
| Primary CTA | Warm Terracotta | #A06840 | Buttons, accents — used sparingly |
...

## Typography Rules
- Display: [Font], [weight] — [usage]
- Body: [Font], [weight] — [usage]
- Scale: H1 [size], H2 [size], Body [size], Caption [size]

## Spacing & Radius
- Base unit: [N]px grid
- Component padding: [N]px
- Section spacing: [N]px
- Card radius: [N]px, Control radius: [N]px

## Component Patterns
### Buttons
[Description with tokens]
### Cards
[Description with tokens]
### Inputs
[Description with tokens]

## Shadow & Depth
- Soft: [value] — [usage]
- Raise: [value] — [usage]

## Accessibility Constraints
- Minimum touch target: 44x44px
- Text contrast: 4.5:1 minimum for body
- Focus states: [description]
```

Use descriptive, physical language: "like light oak", "daylight on stone", "warm near-black". Avoid generic terms.

## Consistency Patterns

### Feed-Forward (Multi-Screen Consistency)

Stitch's known weakness is multi-screen consistency. Mitigate with:

1. **Generate anchor screen first** — the highest-priority, most representative screen
2. **Extract design context** — call `extract_design_context` on the anchor screen
3. **Prepend to subsequent prompts** — include extracted context at the top of every subsequent `generate_screen_from_text` call
4. **Verify at end** — extract context from final screen, compare against anchor for drift

### DESIGN.md Injection

Every prompt should include the DESIGN.md content as a "Design System Reference" block. This is the primary consistency mechanism.

## Generation Strategy

- **Standard mode** for iteration (350 generations/month) — use for exploration and refinement
- **Experimental mode** for fidelity (50 generations/month) — reserve for final versions
- **Treat output as accelerator**: Stitch produces starting points, not pixel-perfect final output
- **Iterate incrementally**: One concern at a time, verify, then next
- **Regenerate selectively**: If one screen drifts, regenerate only that screen

## Known Limitations

- **Visual hierarchy**: May produce flat hierarchy — critique step catches this
- **Brand guidelines**: Cannot apply automatically — DESIGN.md is the workaround
- **Placeholder icons/labels**: Sometimes renders generic — flag in critique
- **Animation/interaction**: No support — specify in engineering design spec only
- **Code output**: Static HTML/CSS — needs framework transformation
- **Multi-screen drift**: Primary challenge — use feed-forward + DESIGN.md to mitigate

## Stitch Tool Reference

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `list_projects` | Browse existing projects | — |
| `create_project` | Create new project | name, description |
| `get_project` | Get project metadata | projectId |
| `list_screens` | List screens in project | projectId |
| `get_screen` | Get screen metadata, code, screenshot | screenId |
| `generate_screen_from_text` | Generate screen from prompt | projectId, prompt |
| `edit_screens` | Edit existing screen | screenId, prompt |
| `generate_variants` | Generate variations of a screen | screenId |
| `extract_design_context` | Extract design DNA from screen | screenId |

Note: Actual tool names may have a namespace prefix (e.g., `mcp__stitch__`). Use ToolSearch to discover the exact names.
```

**Step 2: Verify the file was created correctly**

Read back the file and confirm:
- Frontmatter has `name: stitch-integration` and `description`
- All 6 sections are present (Tool Discovery, Prompt Construction, DESIGN.md Format, Consistency Patterns, Generation Strategy, Known Limitations, Tool Reference)

**Step 3: Commit**

```bash
git add skills/stitch-integration/SKILL.md
git commit -m "feat(plugin): add stitch-integration shared skill

Shared patterns for Stitch MCP tool usage, prompt construction,
DESIGN.md format, consistency enforcement, and known limitations.
Referenced by all design pipeline commands."
```

---

### Task 2: Create the DESIGN.md template

**Files:**
- Create: `$PLUGIN/resources/templates/design-system.md`

**Step 1: Write the template**

Create `$PLUGIN/resources/templates/design-system.md` with placeholder structure matching the format defined in the stitch-integration skill. Use `[bracketed placeholders]` for all values. Include comments explaining what goes in each section.

The template should mirror the DESIGN.md Format section from the skill, with `<!-- instructions -->` comments guiding the agent on how to fill each section.

**Step 2: Verify the file**

Read back and confirm all sections from the skill's DESIGN.md Format are present as placeholders.

**Step 3: Commit**

```bash
git add resources/templates/design-system.md
git commit -m "feat(plugin): add DESIGN.md template for design system extraction"
```

---

### Task 3: Create `/playbook:design-system` command

**Files:**
- Create: `$PLUGIN/commands/workflows/design-system.md`

**Step 1: Write the command**

Create the file with frontmatter:
```yaml
---
name: playbook:design-system
description: Extract or create a canonical DESIGN.md from Stitch screens, codebase tokens, or guided interview
argument-hint: "[optional: project name or path to existing design tokens]"
---
```

Content should follow the design doc's Command 1 specification exactly:
- Goal section explaining this is the foundation for all other design commands
- Available Tools Discovery section (same pattern as existing commands — check for Stitch MCP, other commands, agents, skills)
- Reference to the `stitch-integration` skill: "Load the `stitch-integration` skill for Stitch-specific patterns"
- Process with 6 steps: Discover sources → Extract → Translate → Synthesize → Drift detection → Save
- For the "Discover sources" step: scan for Stitch projects via `list_projects`, scan codebase for `design-tokens.*`, `tailwind.config.*`, existing `DESIGN.md` or `design-spec-prompts.md`
- For the "Translate" step: explicitly reference the DESIGN.md Format from the stitch-integration skill — use descriptive names + hex, physical language
- For "Drift detection": compare Stitch-extracted tokens against codebase tokens, output a diff table
- Output location: `projects/[project]/DESIGN.md` (ask user for project name)
- Use the template from `resources/templates/design-system.md`
- Next Steps section: "Design system documented. Proceed to `/playbook:design-spec` to generate screen prompts, or `/playbook:mockups` if prompts already exist."

**Step 2: Verify**

Read back and confirm: frontmatter is correct, all 6 process steps present, references stitch-integration skill, Next Steps chains to design-spec/mockups.

**Step 3: Commit**

```bash
git add commands/workflows/design-system.md
git commit -m "feat(plugin): add /playbook:design-system command

Extracts or creates canonical DESIGN.md from Stitch screens,
codebase tokens, or guided interview. Foundation for all design
pipeline commands."
```

---

### Task 4: Enhance `/playbook:design-spec` command

**Files:**
- Modify: `$PLUGIN/commands/workflows/design-spec.md`

**Step 1: Read the current file**

Read `$PLUGIN/commands/workflows/design-spec.md` to confirm current content (should be 106 lines, Steps 0-5).

**Step 2: Add Stitch prompt generation step**

After existing Step 5 (Validate completeness) and before the "## Next Steps" section, add:

```markdown
### Step 6: Generate Stitch Prompts (Optional — requires Stitch MCP)

If Stitch MCP tools are available (check via ToolSearch for "stitch"), generate per-screen mockup prompts.

**Load the `stitch-integration` skill** for prompt construction rules and DESIGN.md format.

**Prerequisites check:**
- DESIGN.md exists for this project? If not, suggest: "Run `/playbook:design-system` first to create a DESIGN.md. This ensures consistent mockup generation."
- If user wants to proceed without DESIGN.md, extract design system info from the spec itself.

**For each screen identified in the design spec:**

1. **Extract from spec**: screen purpose, components list, layout structure, states, viewport requirements
2. **Structure as Stitch 5-element prompt** (from stitch-integration skill):
   - Purpose statement (one line)
   - DESIGN SYSTEM block (from DESIGN.md, or extracted from spec)
   - Core components with UI/UX terminology
   - Layout with explicit dimensions and structure
   - Visual styling with mood adjectives matching brand voice
3. **Include specifics**:
   - Viewport: desktop (1440x900) and/or mobile (375x812) as separate prompts
   - Realistic example content (from the spec's copy/microcopy section)
   - Dark mode guidance if DESIGN.md defines it
4. **Priority**: Tag each prompt P1/P2/P3 matching the spec's priority
5. **One prompt per screen, one concern per prompt**: Never combine screens or mix layout + component changes

**Save prompts** to `projects/[project-name]/design-spec-prompts.md` with this structure:

```
# [Project] — Stitch Prompts

Generated from design spec on [date].
DESIGN.md: [path or "not used"]

## Design System Reference (Include with Every Prompt)
[DESIGN.md content or extracted system]

## Prompt N: [Screen Name] (Priority [N])
### Context
[From spec]
### What to Design
[5-element structured prompt]
### Visual Tone
[Mood and brand voice]
```

If Stitch MCP is not available, skip this step and note: "Stitch prompts not generated — Stitch MCP not configured. Install it to enable mockup generation."
```

**Step 3: Update the Next Steps section**

Replace the existing Next Steps with:

```markdown
## Next Steps

After the design spec:
- If Stitch prompts were generated: proceed to `/playbook:mockups` to batch-generate screens
- If architecture work is next: proceed to `/playbook:tech-plan`
- If tasks are next: proceed to `/playbook:tasks`
- If implementation begins: use `/playbook:work`
```

**Step 4: Update the Inputs section**

Add to the existing Inputs list:
```markdown
- DESIGN.md from `/playbook:design-system` (recommended for Stitch prompt generation)
```

**Step 5: Verify**

Read back and confirm: original Steps 0-5 unchanged, new Step 6 added, Next Steps updated, Inputs updated.

**Step 6: Commit**

```bash
git add commands/workflows/design-spec.md
git commit -m "feat(plugin): enhance design-spec with Stitch prompt generation

Add Step 6 that generates per-screen Stitch-optimized prompts from
the engineering design spec. Uses DESIGN.md for consistency and
follows 5-element prompt structure from stitch-integration skill."
```

---

### Task 5: Create `/playbook:mockups` command

**Files:**
- Create: `$PLUGIN/commands/workflows/mockups.md`

**Step 1: Write the command**

Frontmatter:
```yaml
---
name: playbook:mockups
description: Batch-generate Stitch screens from prompts with automatic design consistency enforcement
argument-hint: "[optional: path to design-spec-prompts.md or Stitch project ID]"
---
```

Content following the design doc's Command 3 specification:
- Goal: batch-generate screens with consistency
- Available Tools Discovery: check for Stitch MCP tools, stitch-integration skill
- Prerequisite: Stitch prompts from `/playbook:design-spec` or user-provided
- If no Stitch MCP: error with setup instructions
- Process:
  1. Setup — `create_project` or use existing
  2. Generate anchor screen — highest priority first via `generate_screen_from_text`
  3. Extract design context — `extract_design_context` on anchor
  4. Generate remaining — prepend extracted context to each subsequent prompt (feed-forward)
  5. Verify each — fetch screenshot + code via `get_screen`, log metadata
  6. Consistency check — extract context from final screen, compare against anchor
  7. Save manifest — `projects/[project]/mockups-manifest.md`
- Manifest format: Stitch project ID, table of screens (ID, name, prompt used, generation order, notes), consistency assessment, date
- Iteration guidance: if a screen looks off, user can ask to regenerate just that screen
- Next Steps: `/playbook:design-critique` for feedback, or `/playbook:tech-plan` if designs look good

**Step 2: Verify**

Read back, confirm all 7 process steps, manifest format, Next Steps.

**Step 3: Commit**

```bash
git add commands/workflows/mockups.md
git commit -m "feat(plugin): add /playbook:mockups command

Batch-generates Stitch screens with feed-forward consistency
enforcement. Produces a mockups manifest for downstream commands."
```

---

### Task 6: Enhance `/playbook:design-critique` command

**Files:**
- Modify: `$PLUGIN/commands/workflows/design-critique.md`

**Step 1: Read current file**

Read to confirm current structure (5 steps, 5 perspectives).

**Step 2: Add Stitch auto-fetch to Step 2 (Gather Visual References)**

Replace Step 2 with an enhanced version that:
- First checks for a mockups manifest (`projects/[project]/mockups-manifest.md`)
- If found: auto-fetches all screen images via Stitch `get_screen` tool, saves to project folder
- If not found: falls back to existing behavior (ask user to share screenshots)
- Also checks for DESIGN.md to use as ground truth for brand consistency

**Step 3: Add two new critique personas to Step 4**

After the existing 5 perspectives (Designer, User Researcher, Technical Advisor, Business Stakeholder, and user observations capture), add:

```markdown
#### 6. Mobile UX Specialist Perspective
Ask about:
- Responsive behavior across breakpoints
- Thumb zone accessibility (bottom nav, FABs in reach zone)
- Scroll depth and content prioritization on small screens
- Keyboard avoidance for input-heavy screens
- Touch target sizing (44x44px minimum)
- Viewport-specific layout differences

#### 7. Brand Consistency Reviewer Perspective
Ask about:
- Font consistency across all reviewed screens
- Color palette adherence to DESIGN.md (if available)
- Spacing rhythm consistency (same gaps, padding, margins)
- Component reuse (are buttons, cards, inputs visually identical across screens?)
- Icon style consistency
- Overall "does this feel like one product?" assessment
```

**Step 4: Add cross-screen analysis after Step 4**

Add between existing Step 4 and Step 5:

```markdown
### Step 4b: Cross-Screen Analysis (when reviewing multiple screens)

If multiple screens were reviewed, perform a holistic comparison:
- **Navigation consistency**: Does nav look/behave the same across all screens?
- **Shared components**: Are buttons, cards, inputs identical across screens?
- **Typography scale**: Is the type hierarchy consistent (H1 always same size)?
- **Color drift**: Any screens using slightly different shades for the same token?
- **Spacing rhythm**: Same vertical/horizontal rhythm across screens?

Flag any systemic issues that wouldn't be caught reviewing screens individually.
```

**Step 5: Enhance Step 5 (Synthesize) with severity levels**

Update the synthesis to use priority levels:
```markdown
- **P0 Blocking**: Must fix before proceeding (accessibility failures, broken layout, brand violations)
- **P1 Important**: Should fix, significantly impacts UX
- **P2 Minor**: Polish items for later
- **P3 Nice-to-have**: Suggestions for consideration
```

For P0/P1 items, include a regeneration recommendation: "Modify prompt to [specific change] and regenerate via `/playbook:mockups`."

**Step 6: Update Next Steps**

Replace with:
```markdown
## Next Steps

Once the Design Critique is complete:
1. **If P0/P1 issues remain**: Iterate — modify prompts per recommendations, re-run `/playbook:mockups` for affected screens, then re-critique
2. **If converged**: Proceed to `/playbook:tech-plan` for implementation planning
3. Use findings to refine DESIGN.md if systemic design system issues were found (via `/playbook:design-system`)
4. Or proceed to `/playbook:design-spec` if the critique reveals the need for more detailed specifications
```

**Step 7: Verify**

Read back, confirm: Stitch auto-fetch in Step 2, 7 critique perspectives, cross-screen analysis step, severity levels in synthesis, updated Next Steps.

**Step 8: Commit**

```bash
git add commands/workflows/design-critique.md
git commit -m "feat(plugin): enhance design-critique with Stitch integration

Add auto-fetch from Stitch mockups manifest, two new critique
personas (Mobile UX Specialist, Brand Consistency Reviewer),
cross-screen analysis, and severity-based synthesis with
regeneration recommendations."
```

---

### Task 7: Create `/playbook:design-to-code` command

**Files:**
- Create: `$PLUGIN/commands/workflows/design-to-code.md`

**Step 1: Write the command**

Frontmatter:
```yaml
---
name: playbook:design-to-code
description: Transform Stitch screen HTML into project component scaffolds matching your codebase architecture
argument-hint: "[optional: Stitch screen ID or path to mockups manifest]"
---
```

Content following design doc's Command 5:
- Goal: bridge Stitch HTML output to project's component architecture
- Available Tools Discovery: Stitch MCP, codebase scanning
- Reference stitch-integration skill for tool usage
- Process:
  1. Fetch source — `get_screen` for HTML/CSS
  2. Analyze codebase — scan for framework (React/React Native/Vue/etc), component library, styling system, directory structure (atoms/molecules/organisms or similar)
  3. Build translation map — HTML→framework components, CSS→styling system tokens, layout→framework patterns
  4. Map to existing components — check existing components before creating new ones
  5. Scaffold new components — follow detected project conventions (TypeScript interfaces, accessibility, JSDoc, naming)
  6. Write component map — document Stitch element → project component mapping
  7. Save — components to codebase, map to `projects/[project]/component-map.md`
- Scope boundary: "This produces 70-80% scaffolds. It does NOT implement state management, data binding, API calls, or interaction logic. That is the `/playbook:work` phase."
- Next Steps: `/playbook:work` for implementation, `/playbook:design-verify` after implementation

**Step 2: Verify**

Read back, confirm all 7 steps, scope boundary, Next Steps.

**Step 3: Commit**

```bash
git add commands/workflows/design-to-code.md
git commit -m "feat(plugin): add /playbook:design-to-code command

Transforms Stitch HTML output into project component scaffolds
by analyzing codebase conventions, building translation maps,
and reusing existing components where possible."
```

---

### Task 8: Create `/playbook:design-verify` command

**Files:**
- Create: `$PLUGIN/commands/workflows/design-verify.md`

**Step 1: Write the command**

Frontmatter:
```yaml
---
name: playbook:design-verify
description: Compare running implementation against Stitch mockups and produce a visual diff report
argument-hint: "[app URL or 'localhost'] [path to mockups manifest]"
---
```

Content following design doc's Command 6:
- Goal: close the loop — compare implementation against design intent
- Available Tools Discovery: Stitch MCP for mockup images, Playwright (or browser tools MCP) for implementation screenshots
- Process:
  1. Capture implementation — Playwright screenshots at each route + viewport (desktop 1440x900, mobile 375x812)
  2. Fetch mockups — Stitch screen images via `get_screen`
  3. Structured comparison — per screen pair, analyze: layout, spacing, typography, color, components, responsive
  4. Diff report — per discrepancy: what, where (file path if known), severity (P0-P3), fix suggestion
  5. Save — `projects/[project]/design-verification.md`
- Limitation note: "This is structured visual analysis, not pixel-diff tooling. It catches spacing, color, typography, and layout drift. It treats Stitch mockups as design intent, not pixel-perfect truth."
- Next Steps: "Fix P0/P1 discrepancies, re-run to confirm. When clean, design pipeline complete."

**Step 2: Verify**

Read back, confirm all 5 steps, limitation note, Next Steps.

**Step 3: Commit**

```bash
git add commands/workflows/design-verify.md
git commit -m "feat(plugin): add /playbook:design-verify command

Compares running implementation against Stitch mockups with
structured visual analysis across layout, spacing, typography,
color, and responsive behavior."
```

---

### Task 9: Update `/playbook:product-requirements` routing

**Files:**
- Modify: `$PLUGIN/commands/workflows/product-requirements.md`

**Step 1: Read current file**

Read to find the Step 0 routing logic and the Next Steps section.

**Step 2: Add design pipeline routing to Step 0**

In the routing options presented to the user (the numbered list), add a sub-note under option 1:

```markdown
1. **New feature / major addition** — Needs full discovery, planning, and task breakdown
   Examples: new page, new integration, new data model, new user flow
   → Full pipeline: PRD → Tech Plan → Tasks → Work → Learnings
   → **If UI-heavy**: PRD → Design System → Design Spec → Mockups → Design Critique → Tech Plan → Tasks → Work → Design Verify → Learnings
```

**Step 3: Update Next Steps section**

Add design pipeline guidance after the existing step 4:

```markdown
5. **If project involves significant UI** (new pages, visual redesign, new component patterns):
   - Run `/playbook:design-system` to extract or create DESIGN.md
   - Then `/playbook:design-spec` to generate engineering spec + Stitch prompts
   - Then `/playbook:mockups` to batch-generate screens
   - Then `/playbook:design-critique` for multi-persona visual feedback
   - Iterate until converged, then proceed to `/playbook:tech-plan`
```

**Step 4: Verify**

Read back, confirm: routing option 1 updated, Next Steps updated with design pipeline guidance.

**Step 5: Commit**

```bash
git add commands/workflows/product-requirements.md
git commit -m "feat(plugin): add design pipeline routing to product-requirements

Route UI-heavy projects through the design pipeline
(design-system → design-spec → mockups → design-critique)
before tech planning."
```

---

### Task 10: Update `/playbook:help` with design pipeline

**Files:**
- Modify: `$PLUGIN/commands/help.md`

**Step 1: Read current file**

Read to find the Design section and Typical Workflows section.

**Step 2: Update the Design section table**

Replace the existing Design section with:

```markdown
### Design Pipeline
| Command | When to Use |
|---------|-------------|
| `/playbook:design-system` | Extract or create a DESIGN.md (foundation for consistency) |
| `/playbook:design-spec` | Create detailed UI spec + generate Stitch mockup prompts |
| `/playbook:mockups` | Batch-generate Stitch screens with consistency enforcement |
| `/playbook:design-critique` | Multi-persona visual critique on mockups |
| `/playbook:design-to-code` | Transform Stitch HTML into project component scaffolds |
| `/playbook:design-verify` | Compare implementation against Stitch mockups |
```

**Step 3: Update the "Want feedback on designs?" quick reference**

Replace with:

```markdown
**Designing UI for a feature?**
→ `/playbook:design-system` - Extract your design system into DESIGN.md
→ `/playbook:design-spec` - Create spec + generate Stitch mockup prompts
→ `/playbook:mockups` - Batch-generate Stitch screens
→ `/playbook:design-critique` - Multi-persona visual feedback on mockups
→ `/playbook:design-to-code` - Transform mockups into component scaffolds
→ `/playbook:design-verify` - Compare implementation against mockups
```

**Step 4: Add UI-enhanced workflow to Typical Workflows**

Add after the existing "New Feature Development" workflow:

```markdown
### UI Feature Development (with Design Pipeline)
```
1. /playbook:product-requirements  → Define the feature
2. /playbook:design-system         → Extract/create DESIGN.md
3. /playbook:design-spec           → Engineer spec + Stitch prompts
4. /playbook:mockups               → Batch-generate Stitch screens
5. /playbook:design-critique       → Visual critique (iterate until converged)
6. /playbook:tech-plan             → Plan implementation
7. /playbook:tasks                 → Break into tasks
8. /playbook:design-to-code        → Scaffold components from mockups
9. /playbook:work                  → Implement (repeat)
10. /playbook:design-verify        → Compare against mockups
11. /playbook:git-commit           → Commit changes
12. /playbook:git-pr               → Create PR
13. /playbook:learnings            → Capture what you learned
```
```

**Step 5: Verify**

Read back, confirm: Design Pipeline section updated, quick reference updated, new workflow added.

**Step 6: Commit**

```bash
git add commands/help.md
git commit -m "feat(plugin): add design pipeline to help documentation

Add all 6 design commands to help reference, quick reference,
and a new UI Feature Development workflow showing the full
design-enhanced pipeline."
```

---

### Task 11: Bump plugin version

**Files:**
- Modify: `$PLUGIN/.claude-plugin/plugin.json`

**Step 1: Read current version**

Confirm current version is `0.15.0`.

**Step 2: Bump to `0.16.0`**

This is a minor version bump (new commands added). Update the version field and add "design-pipeline" and "stitch" to keywords.

**Step 3: Verify**

Read back and confirm version is `0.16.0`, new keywords present.

**Step 4: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "chore(plugin): bump version to 0.16.0

New: design-system, mockups, design-to-code, design-verify commands
Enhanced: design-spec (Stitch prompts), design-critique (auto-fetch + new personas)
New skill: stitch-integration
Pipeline routing in product-requirements and help"
```

---

### Task 12: End-to-end verification

**Step 1: Verify all files exist**

List all new and modified files:
```bash
ls -la $PLUGIN/skills/stitch-integration/SKILL.md
ls -la $PLUGIN/resources/templates/design-system.md
ls -la $PLUGIN/commands/workflows/design-system.md
ls -la $PLUGIN/commands/workflows/mockups.md
ls -la $PLUGIN/commands/workflows/design-to-code.md
ls -la $PLUGIN/commands/workflows/design-verify.md
ls -la $PLUGIN/commands/workflows/design-spec.md
ls -la $PLUGIN/commands/workflows/design-critique.md
ls -la $PLUGIN/commands/workflows/product-requirements.md
ls -la $PLUGIN/commands/help.md
ls -la $PLUGIN/.claude-plugin/plugin.json
```

**Step 2: Verify cross-references**

Check that every command:
- References the `stitch-integration` skill where appropriate
- Has a "Next Steps" section that chains to the correct next command
- Has correct frontmatter (name matches `playbook:*` pattern, description present)

**Step 3: Verify pipeline chain**

Trace the full pipeline and confirm each command's Next Steps points correctly:
```
product-requirements → design-system → design-spec → mockups → design-critique
                                                                      ↻ iterate
                                                        design-critique → tech-plan
                                                                         → design-to-code → work → design-verify
```

**Step 4: Commit any fixes**

If any cross-reference issues found, fix and commit.

---

## Summary

| Task | Type | File | Description |
|------|------|------|-------------|
| 1 | Create | `skills/stitch-integration/SKILL.md` | Shared Stitch patterns skill |
| 2 | Create | `resources/templates/design-system.md` | DESIGN.md template |
| 3 | Create | `commands/workflows/design-system.md` | Design system extraction command |
| 4 | Modify | `commands/workflows/design-spec.md` | Add Stitch prompt generation step |
| 5 | Create | `commands/workflows/mockups.md` | Batch screen generation command |
| 6 | Modify | `commands/workflows/design-critique.md` | Add Stitch auto-fetch + new personas |
| 7 | Create | `commands/workflows/design-to-code.md` | Screen-to-component scaffolding command |
| 8 | Create | `commands/workflows/design-verify.md` | Implementation vs mockup comparison command |
| 9 | Modify | `commands/workflows/product-requirements.md` | Add design pipeline routing |
| 10 | Modify | `commands/help.md` | Add design pipeline documentation |
| 11 | Modify | `.claude-plugin/plugin.json` | Bump version to 0.16.0 |
| 12 | Verify | All files | Cross-reference and pipeline chain verification |
