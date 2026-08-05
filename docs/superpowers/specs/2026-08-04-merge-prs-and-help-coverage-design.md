# Design: `/playbook:merge-prs` + help.md drift guard

**Date**: 2026-08-04
**Status**: Approved, implementing
**Ships in**: 0.26.0

## Problem

Two problems, both surfaced by the same question ("is there a workflow for carefully
autonomously merging open PRs?").

**1. No multi-PR merge workflow exists.** The capability has been exercised twice by hand
(`docs/checkpoints/2026-07-17-merge-open-prs.md`, 4 PRs; `2026-07-26-merge-open-prs-v1.md`,
9 PRs) and the procedure is written down in three disconnected places:

- `/playbook:monitor-pr` — single-PR CI-to-green, owns the merge mechanics
- `CLAUDE.md` → "Merging multiple open PRs (stacked bumps)" — the ordering procedure, as prose
- `docs/learnings/2026-07-17-merging-stacked-prs-across-worktrees.md` — the evidence

Nothing composes them. Every run re-derives the orchestration from prose.

**2. `commands/help.md` drifts.** Six real commands were missing from it (`close`,
`close-project`, `emergent`, `foundations`, `monitor-pr`, `research-synthesis`), plus
`hello`/`help` themselves. Zero phantom entries — the failure is **omission only**.
Root cause: help.md hand-duplicates data that already lives in each command's frontmatter,
and adding a command has no step that touches help.md. README.md has the same drift
(missing `close-project`, `emergent`, `monitor-pr`, `hello` as table rows).

## Piece 1: `/playbook:merge-prs`

### Shape

A **command** at `commands/workflows/merge-prs.md` — user-invoked, matching `monitor-pr`'s
house style. It is the *orchestration* layer only: per-PR CI triage is delegated to
`/playbook:monitor-pr`, which in turn delegates failure analysis to `/playbook:debug-ci`.
No logic is duplicated across the three.

### Autonomy envelope: one gate up front

Chosen over per-PR gating and full autonomy. The expensive judgment (is this draft
complete? does this PR ship without its WIP? include the stranded work?) is all
front-loaded into triage; once those calls are made the remaining execution is mechanical
and long-running. Per-PR gating re-interrupts the user ~9 times for decisions already
made. Full autonomy removes the one step where human judgment genuinely mattered.

### Portability

The stacked-version-bump procedure is specific to this repo. The command **detects**
whether the repo has version-guard machinery (CLAUDE.md conventions, a sync/bump script, a
guard workflow) and only layers per-PR bumps in when it finds it. Without one, it is
simply an ordered merge queue. No hardcoded paths.

### Flow

| Step | What |
|---|---|
| 0 | Preflight — `gh auth status`, record starting branch, map `git worktree list`, read CLAUDE.md, detect version-guard machinery, check `deleteBranchOnMerge` |
| 1 | Enumerate all open PRs including drafts |
| 2 | Triage each → **MERGE / FIX-THEN-MERGE / SKIP / ESCALATE**, each with a stated reason |
| 3 | Order the queue — oldest-first, overridden by file-overlap dependencies; assign one patch version per PR if a guard exists |
| 4 | **The gate** — write the plan to a file, present it, wait for approval |
| 5 | Execute — per PR: claim branch safely → merge main in → bump + CHANGELOG → local validation → push → `/playbook:monitor-pr` to green → proof-of-completion comment → merge → verify remote branch died → re-checkout → tick off in plan |
| 6 | Exceptions — skip, don't halt |
| 7 | Report — merged / skipped-with-reasons / final version / final main SHA / leftover branches |

### Design decisions

**The plan file must not leave the working tree dirty.** A dirty working tree is one of two
documented triggers for `gh pr merge --delete-branch` half-failing and leaving the remote
branch alive (`monitor-pr` Step 4, corrected 2026-07-26). Default: write to
`docs/merge-plans/YYYY-MM-DD-merge-plan.md` and add that path to `.git/info/exclude`
— local, uncommitted, portable to any git repo, keeps the tree clean. Alternative offered:
commit it. Step 5 additionally asserts `git status --porcelain` is empty before each merge.

**A broken PR skips, it does not halt the queue.** Halting everything because PR 4 of 9
developed a conflict is the failure mode worth designing out — the remaining 5 are
independent and already approved.

**Branch claiming is worktree-aware.** `gh pr checkout` fails when any worktree of the
shared repo holds the branch. Verify the other checkout is clean and at the PR head, then
work from a temp branch and `git push origin HEAD:<branch>`. Never disturb the other
worktree — it may be a live agent session.

**Branch deletion is verified, not assumed.** Treat any non-empty error from
`gh pr merge --delete-branch` as "the remote branch probably survived" and check with
`git ls-remote` (authoritative), not `git branch -r` (stale cache).

## Piece 2: help.md drift guard

### Fix: validate, don't generate

Extend `scripts/validate-plugin.sh` with a bidirectional coverage check:

- every command's `name:` appears in help.md → catches omission (the observed failure)
- every `/playbook:x` in help.md resolves to a real command → catches rename/delete drift
- every command appears as a **table row** in README.md → catches the same drift on the
  second surface (table row, not prose mention: `close-project` was mentioned in README
  prose while absent from every table)

`plugin-guard.yml` already runs `validate-plugin.sh` on every PR, so this needs no new CI
wiring.

### Rejected: generating help.md from frontmatter

Would require adding a `category:` field to all 39 commands, and the valuable part of
help.md is human judgment — *which* command for *which* situation, plus the workflow
recipes. None of that is derivable from frontmatter. A generator would either destroy that
content or become a template-with-holes. A coverage check makes drift unmergeable while
leaving the curation intact, for ~40 lines in a script that already exists.

### Content fixes

help.md gains the 6 missing commands + `hello`/`help` + `merge-prs`. README gains
`close-project`, `emergent`, `monitor-pr`, `hello`, `merge-prs` as table rows. The new
check then enforces both surfaces — including the new command, so the two pieces of this
change validate each other.

## Version

New command + new validation → **MINOR**: `0.25.2` → `0.26.0`.

## Out of scope

- Sweeping the ~20 stale remote branches noted in the 2026-07-26 checkpoint
- Extending coverage checks to agents/skills (same class of drift, not observed yet)
- Any change to `monitor-pr` or `debug-ci` beyond referencing them
