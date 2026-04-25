---
name: playbook:emergent
description: Capture emergent in-flight scope (user-reported bug or new requirement mid-project) as a micro-PRD before implementing
argument-hint: "<one-line summary>"
---

# Emergent Scope: Micro-PRD

You are facilitating a **lightweight, in-flight capture** of scope that was not in the original PRD. The goal is to get just enough on paper that the implementation, tests, and learnings stay legible later — without slowing the user's momentum.

## When to use

Run this command when, mid-project, the user reports something the original PRD/tech-plan did not cover:

- A production bug they want fixed in this branch
- A new requirement that surfaced from real usage
- A scope expansion that "feels obviously right" but wasn't planned

The agent-activity-ux project (2026-04-24) shipped Wave 3 (`delete_recipe` tool + multi-action prompt rules) with no PRD or integration test. It worked, but the absence left a gap when later sessions tried to understand *why* the rules existed. This command is the cheap retroactive cure.

## What this command produces

A short markdown file at `projects/[status]/[project-name]/emergent/[short-name].md` with these sections — and ONLY these sections. Do not pad. Do not generate boilerplate.

```markdown
---
name: <short-name>
date: <YYYY-MM-DD>
trigger: <bug-report | new-requirement | scope-expansion>
linked-pr: <PR number, if known>
linked-tasks: <task IDs from tasks.md, if any>
---

# <Title>

## Trigger
<One paragraph: what the user said, what they observed, why this surfaced now.>

## Decision
<2–4 bullets: what we are doing about it. Be specific — name files, tools, prompt rules, API changes.>

## Test
<Single bullet: how we will verify this in code (integration test name, E2E spec, manual probe). If "manual only", explicitly say so and explain why automation is deferred.>

## Out of scope
<Bullets for things the user might assume are included but aren't. Skip if N/A.>
```

## Process

### Step 1 — Restate the trigger

Echo back to the user what you heard, in 2–3 sentences. Get explicit confirmation before writing anything. Misstatements at this step propagate into the doc.

### Step 2 — Propose the decision

Draft the **Decision** bullets and present them to the user. Do not implement yet. The point of this command is to confirm the *what* before the *how*.

### Step 3 — Identify the test

Before agreeing on a decision, name the test that will catch a regression. If you cannot name a test, that is itself a finding — push back on the user before proceeding. The agent-activity-ux retro flagged "no integration test" as a process miss; this step closes the gap.

### Step 4 — Write the doc

Write the file using the template above. Keep it under one screen. If a section runs long, that is signal it belongs in the original PRD/tech-plan, not here.

### Step 5 — Update `project-state.md`

Add a single line under "Emergent scope" in `projects/[status]/[project-name]/project-state.md`:

```markdown
- <date>: <short-name> — <one-line summary>. See `emergent/<short-name>.md`.
```

### Step 6 — Hand off to implementation

Tell the user: *"Micro-PRD captured at `<path>`. Ready to implement?"* Wait for explicit go-ahead before changing code.

## What this command is NOT

- **Not a substitute for `/playbook:product-requirements`** for net-new features. If the emergent scope is large enough to need a tech plan or critique, escalate — recommend a real PRD instead of this micro-PRD.
- **Not a license to skip tests.** The Test section is required, not optional. If the user explicitly authorizes manual-only verification, document the *reason* in that bullet.
- **Not retroactive.** If the emergent work is already shipped, capture it as a learnings entry, not a micro-PRD.

## Example

**User:** "Hey, the agent can't delete recipes mid-conversation — when I ask it to remove one, it just edits the existing one. Can we fix this?"

**Agent (after Step 1–3):**
- Trigger: User cannot delete recipes via chat. Production bug observed in 3 chats today.
- Decision: (1) Add `delete_recipe` tool to agent. (2) Update prompt rules to allow multi-action turns (create + edit + delete). (3) Update `getToolDisplayName`/`getClientToolSummary` for the new tool.
- Test: New integration test `agent/tests/integration/delete-recipe.test.ts` covering create-then-delete in a single turn.
- Out of scope: Bulk deletion UI, undo, soft-delete semantics.
