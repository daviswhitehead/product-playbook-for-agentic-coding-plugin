---
name: playbook:close-project
description: Close out a completed project — produce planned-vs-implemented diff, move to done/, clean loose artifacts, and trigger retrospective. Don't use mid-project (use /playbook:work) or for sessions still in flight (use session-checkpoint skill).
argument-hint: "[optional: project name or path]"
recommended-mode: edit
thinking-depth: think
---

# Close Project

You are facilitating the **end-of-project lifecycle ritual** — every project that ships needs a closing pass that catches status drift, archives loose artifacts, and triggers the retrospective. Without this ritual, completed projects linger in `to-do/` or `in-progress/` indefinitely, planning docs drift from reality, and one-off backfill/migration JSONs accumulate at the repo root.

## When to Use This Command

Use when **all of the following are true**:
- All planned tasks are at a final disposition (done / blocked / deferred / cancelled)
- The gate task (if any) has closed (with explicit GO, NO-GO, or Conditional GO + named follow-ups)
- The work has shipped or is committed/merged
- The project still lives in `projects/in-progress/` or `projects/to-do/`

If any of those is false, this is not closing time. Use `/playbook:work` to finish the work, or `/playbook:critique` if the gate isn't ready to close.

## Your Goal

Produce a clean handoff: the project moves out of the active tray, the planning docs reflect what shipped, loose artifacts have a canonical home, and a retrospective is queued (or completed) to extract durable learnings.

## Process

### Step 1: Locate the Project

1. Identify the project directory (from `$ARGUMENTS` or by asking the user).
2. Confirm the directory currently lives in `projects/in-progress/[name]/` or `projects/to-do/[name]/`.
3. List contents — note the canonical docs (PRD, tech-plan, tasks, brainstorms) and any orphan files at the repo root that look related (JSON reports, screenshots, TSVs, resume files, scratch outputs).

### Step 2: Produce `planned-vs-implemented.md` (Gap Analysis)

This is the **default close-project artifact**. It catches status drift, deferred items, and unplanned scope creep.

For each major component in the tech plan and tasks document, classify as one of:
- ✅ **As planned** — built and shipped per the original spec
- 🔄 **Modified** — built, but the design changed; note what drove the deviation
- ⏭️ **Deferred** — explicitly postponed (with reason and tracking)
- ⚠️ **Status drift** — task summary table marked one status, reality differs (this is a high-signal finding — surface it loudly)
- ❌ **Dropped** — decided not to ship; note why

Write the diff to `projects/[in-progress|to-do]/[name]/planned-vs-implemented.md` with one section per phase and a summary table at the top. Include:
- Counts (e.g., "24 ✅, 3 🔄, 2 ⏭️, 1 ⚠️")
- Any task whose row in the summary table disagrees with reality (the most common drift)
- Any acceptance criteria that closed but were never actually verified (e.g., a gate metric that read `null`)

This file becomes input to the retrospective in Step 5.

### Step 3: Reconcile Planning Docs

For each item flagged as ⚠️ status drift in Step 2:
1. Update the row in the tasks summary table to reflect reality.
2. Add a brief completion note in the task detail section (date + link to the artifact that proves completion).
3. If the completion is non-obvious (e.g., the work happened in a sibling branch or under a different task ID), add a one-line cross-reference.

For any gate task whose metric was unmeasurable when the gate closed:
1. Note the instrumentation gap explicitly in the gate task.
2. Either fix the instrumentation now (preferred) or add an explicit follow-up task to a future project.

### Step 4: Archive Loose Artifacts

Sweep the repo root and the project directory for orphan files belonging to this project:
- JSON / JSONL reports (backfill, eval, dry-run)
- PNG / JPG screenshots
- TSV / CSV exports
- Resume / progress files (e.g., `.backfill-progress.json`)
- Scratch SQL / one-off scripts

For each:
1. Determine the canonical home — most projects benefit from a `[project-dir]/artifacts/` subdirectory. Persistent artifacts that other projects might reuse (e.g., backfill report templates) belong under a top-level `agent/backfill/reports/` or similar canonical location, gitignored if appropriate.
2. Use `git mv` for tracked files, `mv` for untracked. **Never `rm`** — if a file isn't worth archiving, ask the user before deleting.
3. If you create a new canonical directory (e.g., `agent/backfill/reports/`), add a `.gitkeep` documenting the naming convention and a `.gitignore` rule for the contents.

### Step 5: Move the Project to `done/`

`git mv projects/[in-progress|to-do]/[name] projects/done/[name]`

**Move, never copy.** `git mv` does this correctly; copy-then-commit does not, and afterwards the difference is invisible unless you look for it. `forgot-password` and `illustration-batch` were copied, so they lived in **both** `in-progress/` and `done/` for ~3.7 months — while every Step 7 checklist item still read as passing, because "project lives under `done/`?" was *true*.

Any cross-references in CLAUDE.md, README, or learnings docs need their paths updated. Step 7 asserts all of this — don't hand-verify it.

### Step 6: Trigger the Retrospective

Confirm with the user whether to run the retrospective inline:
- **Yes (recommended for projects ≥ 2 weeks)** — invoke `/playbook:learnings` with trigger type "project completion" and depth "deep." The `planned-vs-implemented.md` produced in Step 2 becomes Pre-Check A input.
- **No (defer)** — leave a `RETROSPECTIVE-PENDING.md` placeholder in the project dir and a tracked task elsewhere. **Do not skip retrospectives for projects ≥ 2 weeks** — every retro to date has surfaced patterns the standard development pass missed.

### Step 7: Final Sanity Check

**Run the check — do not answer these from memory:**

```bash
"${CLAUDE_PLUGIN_ROOT}"/scripts/verify-close-project.sh <project-name>
```

It asserts, and exits non-zero on any failure:

| Assertion | Why it's mechanical, not a checkbox |
|---|---|
| `projects/done/<name>/` exists | The project landed |
| **`projects/{in-progress,to-do}/<name>/` are GONE** | The assertion whose absence cost 3.7 months. A copy leaves both, and every prose checkbox still passes |
| No living references to the old path | Excludes `done/` — historical references there are fine |
| `planned-vs-implemented.md` present | The close-out artifact exists |
| Merged PRs carry a proof-of-completion comment | Best-effort; skipped cleanly without `gh` or auth |

Paste its output into the close-out summary. The agent answering a checklist is the same one that just did the move, which is exactly why this is a script.

Then confirm by hand the things a script can't judge:
- [ ] No tasks left in "Not Started" or "In Progress" status (every task has a final disposition)
- [ ] No status drift between summary table and task detail sections
- [ ] No orphan project artifacts at repo root
- [ ] Retrospective triggered or explicitly deferred with a tracking task

## Handoff to Retrospective

If Step 6 ran the retrospective inline, the close-project workflow ends when the learnings doc lands. If deferred, this command's output is the planned-vs-implemented diff plus a queued retro task.

---

*Use this command to close the loop. Without it, the project tray fills with phantom in-flight work and the team loses the discipline of clean handoffs.*
