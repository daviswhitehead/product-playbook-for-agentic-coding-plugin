---
name: playbook:design-to-code
description: Transform Stitch screen HTML into project component scaffolds matching your codebase architecture
argument-hint: "[optional: Stitch screen ID or path to mockups manifest]"
---

# Design-to-Code Translation

You are facilitating the **translation of Stitch mockups into production component scaffolds** that match the target codebase's architecture, conventions, and design system. Adopt the perspective of a **Frontend Architect** as the lead, with support from a Design Systems Engineer and a Senior Engineer familiar with the codebase.

This command bridges the gap between visual design (Stitch screens) and working code. It produces scaffolded components that are structurally correct, properly placed, and wired to the project's design tokens — but intentionally stops short of full implementation. State management, data binding, API calls, and interaction logic belong in the `/playbook:work` phase.

## Your Goal

Help the user produce **70-80% complete component scaffolds** by:
1. Extracting the visual structure from Stitch screen HTML/CSS
2. Translating it into the project's framework, styling system, and component library
3. Reusing existing components wherever possible
4. Placing new components in the correct directories following project conventions

## Scope Boundary

**This command produces structural scaffolds. It does NOT implement:**
- State management (useState, Redux, Zustand, etc.)
- Data binding or API calls
- Interaction logic (event handlers beyond placeholder signatures)
- Navigation or routing
- Animation or transitions
- Error handling or loading states
- Tests

These concerns belong in the `/playbook:work` phase, where each task implements a specific slice of functionality on top of the scaffolds this command produces.

## Available Tools Discovery

Before proceeding, inventory available tools:

### Required: Stitch MCP

Use `ToolSearch query: "+stitch"` to discover Stitch tools. The primary tool needed is `get_screen` to retrieve screen HTML/CSS.

If Stitch tools are not found, check whether the user has a mockups manifest with saved HTML/CSS or can provide screen content directly. If neither is available:

> **Stitch MCP is required for `/playbook:design-to-code`.**
> This command extracts component structure from Stitch screen output. Install the Stitch MCP plugin, or provide screen HTML/CSS directly, then re-run.

### Required: stitch-integration Skill

Load the `stitch-integration` skill via the Skill tool. This provides conventions for working with Stitch screen output.

### Optional: Other Tools

- **Commands**: `/playbook:work` (to implement scaffolds), `/playbook:design-verify` (to verify implementation against mockups)
- **Agents**: Specialized agents via Task tool (if available)
- **MCP Tools**: Other external service integrations via ToolSearch

## Prerequisites

Before starting, locate these project artifacts:

1. **Mockups manifest** — search for `docs/projects/*/mockups-manifest.md`. This contains Stitch screen IDs and the generation context. If the user passed an argument (screen ID or manifest path), use that instead.
2. **DESIGN.md** — search for `docs/projects/*/DESIGN.md` or `DESIGN.md` at the repo root. This is the token translation reference (Stitch colors to project tokens).
3. **Component map** (if exists) — search for `docs/projects/*/component-map.md`. A previous run may have already started mapping components.

If no mockups manifest and no screen ID are provided:

> **No Stitch screens found.**
> This command translates Stitch mockups into code scaffolds. Run `/playbook:mockups` first to generate screens, then re-run `/playbook:design-to-code`.

## Process

### Step 1: Fetch Source

Retrieve the Stitch screen content to translate.

**If a mockups manifest was found:**
1. Parse the manifest for screen IDs, names, and priority levels.
2. For each screen (in priority order: P1 > P2 > P3), use `get_screen` to retrieve the screen's HTML, CSS, and any design metadata.
3. Report what was retrieved: screen count, names, and any screens that failed to fetch.

**If a single screen ID was provided:**
1. Use `get_screen` to retrieve the screen's HTML, CSS, and design metadata.
2. Report what was retrieved.

**If the user provided HTML/CSS directly:**
1. Accept it as-is and proceed to Step 2.

For each screen, capture:
- HTML structure (element hierarchy)
- CSS styles (colors, typography, spacing, layout)
- Component boundaries (visually distinct UI sections)
- Content (text, placeholder images, icons)

### Step 2: Analyze Codebase

Scan the target codebase to understand its architecture before writing any code. This step determines HOW the translation will work.

**Framework detection** — identify the primary framework:
- Search for `package.json` and check dependencies: React, React Native, Vue, Svelte, Angular, etc.
- Check for meta-frameworks: Next.js (`next.config.*`), Nuxt, SvelteKit, Expo
- Check for React Native Web (cross-platform setup)

**Styling system detection** — identify how styles are applied:
- Tailwind / NativeWind: `tailwind.config.*`, `nativewind` in dependencies
- CSS Modules: `*.module.css` files
- Styled Components / Emotion: `styled-components` or `@emotion` in dependencies
- CSS-in-JS: `style` props, `StyleSheet.create`
- Design tokens: `design-tokens.*` files, CSS custom properties

**Component library detection** — identify base component libraries:
- gluestack UI, shadcn/ui, Material UI, Ant Design, Chakra, etc.
- Custom component libraries in the codebase

**Directory structure analysis** — identify the component organization pattern:
- Atomic design: `atoms/`, `molecules/`, `organisms/`
- Feature-based: `features/[feature]/components/`
- Flat: `components/`
- Other patterns: `ui/`, `shared/`, `common/`

**Naming conventions** — detect patterns:
- File naming: PascalCase, kebab-case, camelCase
- Component naming: function vs. const, default vs. named exports
- TypeScript: strict mode, interface vs. type, prop patterns

**Report the analysis** before proceeding:

```
Codebase Analysis:
- Framework: [detected framework]
- Styling: [detected styling system]
- Component Library: [detected library]
- Directory Pattern: [detected pattern]
- Naming Convention: [detected convention]
- TypeScript: [strict/standard/none]
- Key Directories: [list of component directories]
```

### Step 3: Build Translation Map

Create a concrete mapping from Stitch HTML/CSS to the project's framework and styling system. This map governs every translation decision in Steps 4-5.

**Element translation** — map HTML tags to framework components:

| Stitch HTML | Project Component | Notes |
|-------------|-------------------|-------|
| `<div>` | `<View>` | React Native / RN Web |
| `<span>`, `<p>`, `<h1>`-`<h6>` | `<Text>` | With appropriate style classes |
| `<img>` | `<Image>` | Include both `alt` and `accessibilityLabel` |
| `<input>` | `<TextInput>` or component library equivalent | |
| `<button>` | `<Button>` from component library or custom | |
| `<a>` | `<Link>` or `<Pressable>` | Depends on navigation setup |

Adapt the table to the detected framework. React DOM projects keep HTML tags; React Native translates them; Vue uses its own component patterns.

**Style translation** — map CSS values to the project's token system:

| Stitch CSS | Project Token | Example |
|------------|---------------|---------|
| `background: #FAF6F1` | `bg-surface-base` | Map hex to semantic token |
| `color: #1a1a1a` | `text-ink-primary` | Map to text token |
| `font-size: 24px` | `text-2xl` | Map to type scale |
| `padding: 16px` | `p-4` | Map to spacing scale |
| `border-radius: 12px` | `rounded-xl` | Map to radius token |
| `box-shadow: ...` | `shadow-md` | Map to shadow token |

Use DESIGN.md (if available) as the authoritative reference for token mappings. When a Stitch color does not have an exact token match, find the closest semantic token and note the deviation.

**Layout translation** — map CSS layout to framework patterns:

| Stitch CSS | Project Pattern | Notes |
|------------|-----------------|-------|
| `display: flex; flex-direction: column` | `className="flex flex-col"` | Or `<VStack>` if using component library |
| `display: flex; flex-direction: row` | `className="flex flex-row"` | Or `<HStack>` |
| `display: grid; grid-template-columns: ...` | `className="grid grid-cols-..."` | Web-only; RN needs flex alternative |
| `gap: 16px` | `className="gap-4"` | Check RN support |
| `position: fixed` | Platform-specific | RN uses absolute + SafeAreaView |

**Present the translation map** to the user for review before proceeding. The map directly affects every component scaffold.

### Step 4: Map to Existing Components

Before creating any new components, scan the codebase for existing ones that match Stitch screen elements. **Reuse over create.**

1. **Inventory existing components** — use Glob and Grep to catalog components in the detected component directories. Build a quick reference:
   - Component name
   - File path
   - Brief purpose (from JSDoc, component name, or file content)

2. **Match Stitch elements to existing components** — for each distinct UI element in the Stitch screens:
   - Check if an existing component serves the same purpose
   - Check if an existing component could serve the purpose with minor props/variants
   - Only flag as "new component needed" if nothing suitable exists

3. **Produce an element coverage report**:

```
Element Coverage:
- [Stitch element] -> [ExistingComponent.tsx] (exact match)
- [Stitch element] -> [ExistingComponent.tsx] (needs new variant/prop)
- [Stitch element] -> NEW (no existing component matches)
```

**Rule**: If an existing component covers 80% of what a Stitch element needs, extend it with a new prop or variant rather than creating a duplicate.

### Step 5: Scaffold New Components

For elements flagged as "NEW" in Step 4, create component scaffolds following the project's detected conventions.

**For each new component:**

1. **Determine placement** — use the directory structure from Step 2:
   - Simple, single-purpose UI elements: atoms directory
   - Composed elements combining multiple atoms: molecules directory
   - Full feature sections or page-level layouts: organisms directory
   - Follow whatever naming the project uses (atoms/molecules/organisms, or feature folders, etc.)

2. **Generate the scaffold** following detected conventions:
   - TypeScript interfaces for props (with JSDoc comments)
   - Correct import style (named vs. default, component library imports)
   - Framework-appropriate component structure (functional component, correct hook patterns)
   - Styling using the project's system (Tailwind classes, styled-components, etc.)
   - Accessibility attributes (ARIA labels, roles, semantic structure)
   - Placeholder callbacks for interaction props (`onPress`, `onChange`, etc.) — signature only, no implementation

3. **Apply the translation map** from Step 3:
   - Replace all Stitch HTML elements with framework components
   - Replace all CSS values with project tokens
   - Replace layout CSS with framework layout patterns

4. **Mark scaffold boundaries** — add clear comments where implementation work begins:

```typescript
// TODO: [playbook:work] Add state management
// TODO: [playbook:work] Wire to API / data layer
// TODO: [playbook:work] Implement interaction logic
// TODO: [playbook:work] Add error handling
// TODO: [playbook:work] Add loading states
```

**Scaffold template** (adapt to detected framework/conventions):

```typescript
import { View, Text } from 'react-native';

interface ComponentNameProps {
  /** Brief description of the prop */
  title: string;
  /** Callback when the user interacts */
  onPress?: () => void;
}

/**
 * Brief description of the component's purpose.
 * Scaffolded from Stitch screen: [screen name]
 */
export function ComponentName({ title, onPress }: ComponentNameProps) {
  return (
    <View className="[translated-styles]">
      <Text className="[translated-styles]">{title}</Text>
      {/* TODO: [playbook:work] Implement child components and interaction */}
    </View>
  );
}
```

### Step 6: Write Component Map

Document the full translation from Stitch screen elements to project components. This map is the key reference for the `/playbook:work` phase and for `/playbook:design-verify` to trace discrepancies back to source.

**Component map format**:

```markdown
# Component Map — [Project Name]

**Generated from**: [mockups manifest path or screen IDs]
**Date**: [current date]
**Framework**: [detected framework]
**Styling**: [detected styling system]

## Translation Map Summary

| Stitch CSS/HTML | Project Equivalent | Notes |
|-----------------|-------------------|-------|
| `<div>` | `<View>` | React Native Web |
| `bg-white` | `bg-surface-base` | Semantic token |
| [etc.] | [etc.] | [etc.] |

## Screen: [Screen Name]

| Stitch Element | Project Component | File Path | Status |
|----------------|-------------------|-----------|--------|
| Hero section | `HeroSection.tsx` | `components/organisms/HeroSection.tsx` | New (scaffolded) |
| Menu card | `MenuCard.tsx` | `components/molecules/MenuCard.tsx` | Existing (reused) |
| CTA button | `Button.tsx` | `components/atoms/Button.tsx` | Existing (new variant added) |

### New Components Created
- `HeroSection.tsx` — [brief description]
- [etc.]

### Existing Components Reused
- `Button.tsx` — [how it was reused, any new props]
- `MenuCard.tsx` — [direct reuse, no changes]
- [etc.]

### Token Mapping Notes
[Any color/spacing/typography translations that were ambiguous or approximate]

## [Repeat for each screen]
```

### Step 7: Save

1. **Component scaffolds** — write to the codebase in the directories determined in Step 5. Confirm each file path with the user before writing.
2. **Component map** — save to `docs/projects/[project-name]/component-map.md`. If the user has not specified a project name, ask for one.
3. **Summary** — present what was created:
   - Number of new components scaffolded (with file paths)
   - Number of existing components reused
   - Number of existing components extended (new variants/props)
   - Any token mappings that need manual review

Confirm all file paths with the user before writing.

## Key Principles

- **Reuse over create** — always check for existing components before scaffolding new ones. Extending an existing component with a new prop is better than creating a near-duplicate.
- **Match the codebase, not the mockup** — the scaffolds must follow the project's conventions (naming, directory structure, import style, TypeScript patterns), not Stitch's HTML structure. The mockup provides visual intent; the codebase provides implementation patterns.
- **Semantic tokens over raw values** — never carry raw hex colors or pixel values from Stitch CSS into component code. Always translate to the project's token system. If a token does not exist, flag it rather than hard-coding the value.
- **Accessibility from the start** — scaffolds must include ARIA labels, semantic roles, and accessibility props. Do not defer accessibility to the implementation phase.
- **70-80% is the target** — scaffolds should be structurally complete and visually correct but intentionally leave logic implementation for `/playbook:work`. Over-scaffolding (adding state management, API calls) creates throwaway code.

## Next Steps

Scaffolds created. Proceed to:
- `/playbook:work` to implement state management, data binding, interaction logic, and tests on top of the scaffolds
- `/playbook:design-verify` after implementation to compare the running application against the original Stitch mockups
