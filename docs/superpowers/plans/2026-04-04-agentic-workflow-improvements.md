# Agentic Workflow Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve the playbook's handling of long autonomous runs by adding plan reconciliation, compaction-aware checkpointing, and structured mid-rollout communication — three patterns validated by OpenAI's Codex prompting guide.

**Architecture:** These are targeted additions to 6 existing files (no new files). Each change is 10-30 lines. The changes are independent of each other and can be applied in any order.

**Tech Stack:** Markdown (plugin command/skill definitions)

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `plugins/.../commands/workflows/work-multiple.md` | Modify | Add reconciliation step, checkpoint triggers, mid-rollout communication |
| `plugins/.../commands/workflows/work.md` | Modify | Add end-of-project reconciliation step |
| `plugins/.../skills/autonomous-execution/SKILL.md` | Modify | Add checkpoint integration, skill design principle |
| `plugins/.../agents/workflow/delivery-agent.md` | Modify | Add checkpoint awareness, mid-rollout communication |
| `plugins/.../resources/templates/tasks.md` | Modify | Add Project Reconciliation section |
| `plugins/.../commands/workflows/tasks.md` | Modify | Reference reconciliation in task creation guidance |
| `.claude-plugin/plugin.json` (inner) | Modify | Bump version to 0.18.0 |
| `CHANGELOG.md` | Modify | Add 0.18.0 entry |

All paths are relative to `plugins/product-playbook-for-agentic-coding/` unless noted.

---

### Task 1: Add Plan Reconciliation to work-multiple.md

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md`

This is the highest-impact change. Currently work-multiple has Step 4 "Provide Completion Summary" which lists what happened, but doesn't force a sweep of ALL tasks. Tasks can silently drift to "forgotten."

- [ ] **Step 1: Add Step 3.5 "Reconcile All Tasks" between Step 3 (Handle Blockers) and Step 4 (Completion Summary)**

Insert after the "### Step 3: Handle Blockers" section and before "### Step 4: Provide Completion Summary":

```markdown
### Step 3.5: Reconcile All Tasks (Before Stopping)

**CRITICAL**: Before producing the completion summary, sweep EVERY task in the Tasks Document — not just the ones you worked on. For each task, assign a final disposition:

| Disposition | Meaning | When to Use |
|-------------|---------|-------------|
| **Done** | Completed this session with all acceptance criteria met | Task was implemented and validated |
| **Blocked** (with reason) | Cannot proceed without external input | Missing dependency, unclear requirement, external service issue |
| **Deferred** (with reason) | Deliberately skipped | Too risky for autonomous execution, out of scope for this session |
| **Cancelled** (with reason) | No longer needed | Superseded by another task, requirement changed |
| **Not Reached** | Session ended before getting to this task | Ran out of time/context, lower priority |

**Why this matters**: Without explicit reconciliation, the most common failure mode in long autonomous runs is silent task loss — the agent completes 8/10 tasks, stops, and nobody notices 2 tasks were never addressed. Every task must have an explicit disposition.

Update the Tasks Document with dispositions before producing the summary.
```

- [ ] **Step 2: Verify the step numbering is consistent**

Read the file and confirm Step 3.5 fits between Step 3 and Step 4 without numbering conflicts.

- [ ] **Step 3: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md
git commit -m "feat(work-multiple): add plan reconciliation step

Forces explicit disposition (Done/Blocked/Deferred/Cancelled/Not Reached)
for every task before producing completion summary. Prevents silent task
loss in long autonomous runs.

Inspired by OpenAI Codex prompting guide's reconciliation pattern."
```

---

### Task 2: Add Plan Reconciliation to work.md

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/work.md`

work.md handles single-task execution but also has an end-of-project flow in the "Next Steps" section. The reconciliation belongs there.

- [ ] **Step 1: Add reconciliation to the end-of-project flow**

In the "## Next Steps" section at the bottom of the file, the current flow is:

```
Implement (all tasks done)
  ↓
Automated Testing
  ↓
Local Review
  ↓
CI Maximizing
  ↓
Create PR
  ↓
Learnings
```

Insert a "Reconcile All Tasks" step between "Implement (all tasks done)" and "Automated Testing":

```markdown
Implement (all tasks done)
  ↓
Reconcile All Tasks — Sweep every task in the Tasks Document and assign a final disposition:
  Done | Blocked (reason) | Deferred (reason) | Cancelled (reason)
  Update the Tasks Document before proceeding. No task should be left without a status.
  ↓
Automated Testing — Run full test suite, lint, typecheck, build
  ↓
Local Review — Walk through the feature yourself (browser, endpoints, etc.)
  ↓
CI Maximizing — Push and ensure all CI checks pass. Use `/playbook:debug-ci` if failures occur.
  ↓
Create PR — Use `/playbook:git:create-pr` or `gh pr create`
  ↓
Learnings — Use `/playbook:learnings` to capture what you learned
```

- [ ] **Step 2: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/commands/workflows/work.md
git commit -m "feat(work): add reconciliation step to end-of-project flow

Ensures every task gets an explicit disposition before moving to testing
and PR creation. Matches the reconciliation pattern added to work-multiple."
```

---

### Task 3: Add Checkpoint Triggers to work-multiple.md

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md`

session-checkpoint exists but is completely disconnected from work-multiple. Long autonomous runs (5+ tasks) will hit context compaction and lose working memory.

- [ ] **Step 1: Add checkpoint trigger to Step 2 "Execute Tasks in Sequence"**

After the "6. **Move to Next Task**" item in Step 2, add a new item:

```markdown
7. **Checkpoint (Every 3 Tasks)**
   - After completing every 3rd task, write a session checkpoint using the `session-checkpoint` skill pattern
   - Write to `docs/checkpoints/latest.md` with: current task, what's done, key decisions, next steps, hot files
   - This preserves context across compaction events in long autonomous runs
   - **Skip** if fewer than 3 tasks remain
```

- [ ] **Step 2: Add session-checkpoint to the Available Tools Discovery section**

In the "## Available Tools Discovery" section, update item 4:

```markdown
4. **Skills**: Domain expertise via Skill tool (autonomous-execution, **session-checkpoint**)
```

- [ ] **Step 3: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md
git commit -m "feat(work-multiple): integrate session-checkpoint every 3 tasks

Triggers checkpoint writes during long autonomous runs to preserve context
across compaction events. References session-checkpoint skill."
```

---

### Task 4: Add Mid-Rollout Communication Pattern to work-multiple.md

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md`

Currently work-multiple only communicates at the very end (completion summary). During a 30-minute autonomous run, the user gets zero signal. Add a structured cadence.

- [ ] **Step 1: Add communication cadence to Step 2**

After the checkpoint item (added in Task 3), add:

```markdown
8. **Status Update (Between Tasks)**
   - After completing each task, emit a brief structured update:
     ```
     ✓ Task [X.Y] done — [one-line summary of what was built/fixed]
     → Next: Task [X.Y] — [one-line description]
     Progress: [N/M tasks] | Blocked: [N] | Deferred: [N]
     ```
   - Keep updates to 3 lines max. The user should be able to glance at progress without reading paragraphs.
   - Do NOT summarize what you're about to do in detail — just the task name and progress count.
```

- [ ] **Step 2: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/commands/workflows/work-multiple.md
git commit -m "feat(work-multiple): add structured mid-rollout status updates

Emits 3-line progress updates between tasks so the user can track
autonomous execution without waiting for the final summary.

Pattern from OpenAI Codex prompting guide's mid-rollout communication."
```

---

### Task 5: Add Checkpoint and Communication to delivery-agent.md

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/agents/workflow/delivery-agent.md`

The delivery agent is a lighter-weight version of work.md used for subagent dispatch. It lacks any concept of checkpoints or structured updates.

- [ ] **Step 1: Add a "Long-Running Session Patterns" section before "## Key Principles"**

```markdown
## Long-Running Session Patterns

### Session Checkpoints
When executing 3+ tasks in sequence, write a session checkpoint after every 3rd completed task:
- Write to `docs/checkpoints/latest.md`
- Include: current task, completed tasks, key decisions, next steps, hot files
- This preserves context if compaction occurs during long runs

### Status Updates
After completing each task, emit a brief status update:
```
✓ Task [X.Y] done — [one-line summary]
→ Next: Task [X.Y] — [one-line description]
```

Keep updates terse. The orchestrator or user should be able to glance at progress without parsing paragraphs.
```

- [ ] **Step 2: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/agents/workflow/delivery-agent.md
git commit -m "feat(delivery-agent): add checkpoint and status update patterns

Adds session checkpoint triggers (every 3 tasks) and structured status
updates between tasks. Aligns with work-multiple improvements."
```

---

### Task 6: Add Project Reconciliation Section to Tasks Template

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/resources/templates/tasks.md`

The tasks template should include a reconciliation section so every new tasks document starts with the structure needed for proper closure.

- [ ] **Step 1: Add "Project Reconciliation" section before the "Final Verification Checklist"**

Insert before `## Final Verification Checklist`:

```markdown
## Project Reconciliation

> **Complete this section when all planned work is done** (or when stopping work on this project). Every task must have an explicit final disposition — no task should be left in an ambiguous state.

| Task | Final Disposition | Notes |
|------|------------------|-------|
| Task 1.1 | Done / Blocked / Deferred / Cancelled | [Brief note] |
| Task 1.2 | Done / Blocked / Deferred / Cancelled | [Brief note] |

**Disposition Guide:**
- **Done**: Completed with all acceptance criteria met
- **Blocked** (with reason): Cannot proceed without external input
- **Deferred** (with reason): Deliberately postponed to a future session/PR
- **Cancelled** (with reason): No longer needed (requirement changed, superseded)

**Reconciliation Check:**
- [ ] Every task has a disposition (no tasks left as "Not Started" or "In Progress")
- [ ] Blocked/Deferred tasks have clear reasons and ownership
- [ ] Cancelled tasks have rationale documented
```

- [ ] **Step 2: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/resources/templates/tasks.md
git commit -m "feat(tasks-template): add project reconciliation section

Adds a standard reconciliation table and disposition guide to the tasks
template. Every new tasks document now starts with the structure needed
for proper closure."
```

---

### Task 7: Reference Reconciliation in tasks.md Command

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/commands/workflows/tasks.md`

The task creation command should mention that a reconciliation section will be created, so users know about it upfront.

- [ ] **Step 1: Add reconciliation mention to Step 4 "Complete the Document"**

In the "### Step 4: Complete the Document" section, add to the "Ensure all sections are filled" list:

```markdown
- Project Reconciliation section (pre-populated from template — completed at project end)
```

- [ ] **Step 2: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/commands/workflows/tasks.md
git commit -m "feat(tasks-cmd): reference reconciliation section in task creation

Mentions the Project Reconciliation section in the document completion
checklist so users know it exists from the start."
```

---

### Task 8: Integrate Checkpoint Reference in autonomous-execution Skill

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/skills/autonomous-execution/SKILL.md`

The autonomous execution skill should reference session-checkpoint as a companion skill for long runs.

- [ ] **Step 1: Add checkpoint integration to "Execution Patterns" section**

After "### Pattern 3: Incremental Validation", add:

```markdown
### Checkpoint Integration

For runs spanning 3+ tasks, use the `session-checkpoint` skill to preserve context:

- **Write checkpoints** every 3 completed tasks (or when context feels deep)
- **Write to** `docs/checkpoints/latest.md`
- **Include**: current task, decisions made, next steps, hot files
- **Why**: Context compaction destroys working memory. Checkpoints preserve decisions and rationale that git can't capture.

See the `session-checkpoint` skill for the full checkpoint format.
```

- [ ] **Step 2: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/skills/autonomous-execution/SKILL.md
git commit -m "feat(autonomous-execution): add checkpoint integration reference

Links to session-checkpoint skill for long-running autonomous sessions.
Recommends checkpointing every 3 tasks."
```

---

### Task 9: Bump Version and Update Metadata

**Files:**
- Modify: `plugins/product-playbook-for-agentic-coding/.claude-plugin/plugin.json`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Bump version to 0.18.0 in plugin.json**

Change `"version": "0.17.0"` to `"version": "0.18.0"`.

- [ ] **Step 2: Add CHANGELOG entry**

Add this entry at the top of CHANGELOG.md (after the header, before the 0.14.0 entry):

```markdown
## [0.18.0] - 2026-04-04

### Added
- **Plan Reconciliation** — New Step 3.5 in `work-multiple` and end-of-project flow in `work` that forces explicit disposition (Done/Blocked/Deferred/Cancelled) for every task before declaring work complete. Prevents silent task loss in long autonomous runs.
- **Compaction-Aware Checkpointing** — `work-multiple` and `delivery-agent` now trigger session checkpoints every 3 tasks during long runs. `autonomous-execution` skill references `session-checkpoint` as a companion.
- **Mid-Rollout Communication** — Structured 3-line status updates between tasks in `work-multiple` and `delivery-agent`. Users can track progress without waiting for the final summary.
- **Reconciliation Section in Tasks Template** — Every new tasks document now includes a Project Reconciliation table for tracking final dispositions.

### Changed
- `commands/workflows/work-multiple.md` — Added Steps 3.5 (reconciliation), checkpoint triggers, and status update cadence
- `commands/workflows/work.md` — Added reconciliation to end-of-project flow
- `agents/workflow/delivery-agent.md` — Added checkpoint and communication patterns
- `skills/autonomous-execution/SKILL.md` — Added checkpoint integration section
- `resources/templates/tasks.md` — Added Project Reconciliation section
- `commands/workflows/tasks.md` — Referenced reconciliation in task creation

### Rationale
Inspired by OpenAI's Codex prompting guide (March 2026), which identifies three key patterns for reliable long-running agent workflows:
1. **Reconcile every plan item** before finishing (Done/Blocked/Cancelled)
2. **Checkpoint context** to survive compaction in multi-hour sessions
3. **Structured mid-rollout updates** (brief acknowledgment → next steps → progress count)

These address the most common failure modes in autonomous execution: silent task loss, context amnesia after compaction, and user anxiety during long silent runs.
```

- [ ] **Step 3: Update the Version History Summary table in CHANGELOG.md**

Add row at the top of the table:

```markdown
| 0.18.0 | 2026-04-04 | Plan reconciliation, compaction-aware checkpointing, mid-rollout communication |
```

- [ ] **Step 4: Commit**

```bash
git add plugins/product-playbook-for-agentic-coding/.claude-plugin/plugin.json CHANGELOG.md
git commit -m "chore: bump version to 0.18.0 and update CHANGELOG

Adds entry for plan reconciliation, compaction-aware checkpointing,
and mid-rollout communication improvements."
```

---

## Self-Review

**Spec coverage:** All three improvements (reconciliation, checkpoints, communication) are covered across the relevant files. Each change is self-contained.

**Placeholder scan:** No TBDs, TODOs, or vague instructions. Every step has exact content to insert.

**Type consistency:** Disposition categories are consistent across all files: Done, Blocked, Deferred, Cancelled (with "Not Reached" added only in work-multiple where it applies to batch execution).

**Cross-file consistency:** The checkpoint pattern (every 3 tasks, write to `docs/checkpoints/latest.md`) is identical in work-multiple.md, delivery-agent.md, and autonomous-execution skill. The status update format is identical in work-multiple.md and delivery-agent.md.
