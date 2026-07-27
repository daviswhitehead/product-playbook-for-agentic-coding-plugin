---
name: playbook:close
description: Run a session close-out — checks for uncommitted work, cleans up tasks, writes handoff context, then captures learnings. Use when wrapping up a session or at natural stopping points.
argument-hint: "[--quick] [--skip-learnings]"
recommended-mode: auto-accept
thinking-depth: normal
---

# Session Close-Out

You are facilitating an end-of-session close-out. Run each phase in order. Skip any phase where there's nothing to do.

## Phase 1: Uncommitted Work Check

1. **Branch state check (do first)**: The current branch may not be a valid commit target for your close-out. Two common failure modes:

   **(a) Branch is merged.** If the current branch's PR is already merged, new commits on this branch will NOT reach the target.
   - `gh pr list --head $(git branch --show-current) --state merged --limit 1` (or check `git log <target>..HEAD` against a known squash-merge commit on the target).
   - If merged, warn the user and offer to branch off the target before committing:
     > "Current branch `<name>` is already merged into `<target>` (likely via squash). Any commits made here will be local-only. Want me to branch off `<target>` so the close-out commits reach production?"

   **(b) Branch was changed by another agent (parallel-agent workspaces — Conductor, git worktrees, etc.).** If multiple agents share a working directory, the current branch may have been switched while you were sleeping/waiting on tools. Detection:
   - `git branch --show-current` — does it match the branch *your* session has been working on? Compare against the branch you last pushed to, or the PR head you've been monitoring.
   - If unfamiliar, ask the user before committing anywhere: it likely belongs to another agent's in-flight work.
   - Stash any unrelated uncommitted changes (they may be the other agent's WIP) before switching back: `git stash push -m "other-agent-WIP" <paths>`. Restore after your work completes.

   **In both cases**, if the user approves, create a fresh branch off `origin/<target>` and continue close-out there. Cherry-pick later if needed. The skill previously assumed the current branch was always a valid commit target — both (a) (session continues after the main PR merges — close-out, follow-up docs, learnings) and (b) (parallel agents) violate that assumption.

2. Run `git status`.
3. If there are uncommitted changes:
   - Show a brief summary (files changed, not full diffs)
   - Offer to commit. If the user approves, draft a commit message and commit.
4. If the working tree is clean: skip silently.

5. **Stash check (do even when the working tree is clean and every commit is pushed).** A branch can have every commit in its PR yet still have work hiding in a `git stash` that vanishes when the worktree/branch is archived. "All commits pushed" ≠ "everything is safe." Run `git stash list` and look for entries whose label references the branch being closed (`stash@{N}: On <branch>: ...` or `WIP on <branch>: ...`).
   - **For each stash tagged to this branch**, decide: is it unique work or already superseded by what's committed? Compare the stash's file versions against current `HEAD` — a rebased/orphaned stash base makes `git diff <base>..<stash>` misleading, so diff `HEAD <stash>` per file instead. For large diffs, dispatch a subagent so the comparison doesn't flood context.
   - **If superseded** → safe to `git stash drop` (with the user's ok).
   - **If unique or uncertain** → preserve it durably BEFORE dropping — you likely didn't create it. Salvage to a branch and push: `git branch <archive-name> stash@{N} && git push -u origin <archive-name>`. Then it's captured off the stash list and off this worktree; the user can review/discard later.
   - **Leave stashes tagged to OTHER branches alone** — they're separate work streams; dropping them can destroy another effort's WIP.
   - This closes a real gap: the working-tree check above catches uncommitted changes but not stashes. A user asking "is everything in the PR / safe to archive?" needs both checked.

## Phase 2: Task Cleanup

1. Search for an active tasks document:
   - Check `docs/superpowers/plans/*-tasks.md`
   - Check `projects/*/tasks.md`
   - Check `docs/tasks.md`
2. If a tasks document exists:
   - Scan for `in_progress` tasks. For each: is the work done? Mark completed or note what's left.
   - **Instrumented-task check**: before marking complete any task whose acceptance includes "event fires", "metric captured", or "tracked in <analytics>", confirm you have runtime evidence (the event/metric actually landed in the truth surface — PostHog/analytics/the gate query). If you only have static evidence ("the code is wired"), mark it **"done pending runtime verification"**, not ✅. Do not let close-out launder an unverified claim into "complete." (See the autonomous-execution "Instrumented-Task Verification Gate".)
   - Scan for stale tasks (blocked with no recent activity). Propose deletion or deferral.
   - Note pending tasks as carryover.
   - Show a brief summary: "X completed, Y carried forward, Z stale."
3. If no tasks document found: skip silently.

## Phase 3: Handoff Context

1. Draft a handoff note:
   - **What was accomplished** this session (2-3 bullets)
   - **What's in progress** but not finished
   - **What's next** — the most logical next action
   - **Key decisions made** that affect future work
   - **Open questions** still needing answers

2. **Multi-phase project awareness**: If the session worked on a project with a defined plan (phases, milestones), add:
   - Phase completed this session
   - Blocker for next phase (if any)
   - Parallelizable work that can proceed without waiting

3. Create `docs/checkpoints/` directory if it doesn't exist.

4. **Archive the existing `latest.md` before writing over it.** In a parallel-agent repo
   (Conductor workspaces, git worktrees — the same setups Phase 1 already warns about),
   `latest.md` frequently holds *another workspace's* handoff. Overwriting it destroys work
   that isn't yours, silently, and the content is often not recoverable.

   ```bash
   # Is there an existing checkpoint, and is its content archived anywhere else?
   # Prints exactly one of: NO_EXISTING_CHECKPOINT | ALREADY_ARCHIVED | ARCHIVE_REQUIRED
   if [ ! -s docs/checkpoints/latest.md ]; then
     echo "NO_EXISTING_CHECKPOINT"
   else
     branch_line=$(sed -n '/^\*\*Branch\*\*:/p' docs/checkpoints/latest.md | head -1)
     if [ -z "$branch_line" ]; then
       echo "ARCHIVE_REQUIRED"   # can't identify it -> never assume it's safe to clobber
     elif grep -rlF -- "$branch_line" docs/checkpoints/ \
            | grep -qv '^docs/checkpoints/latest\.md$'; then
       echo "ALREADY_ARCHIVED"
     else
       echo "ARCHIVE_REQUIRED"
     fi
   fi
   ```

   - `NO_EXISTING_CHECKPOINT` → nothing to archive; go straight to step 5.
   - `ALREADY_ARCHIVED` → safe to overwrite in step 5 — **but run the freshness check below
     first.** "Archived somewhere" does not mean "older than you": a newer session's handoff
     can be both already archived and the one that should stay in `latest.md`.
   - `ARCHIVE_REQUIRED` → rename it first, do NOT overwrite:

   ```bash
   git mv docs/checkpoints/latest.md docs/checkpoints/<YYYY-MM-DD>-<topic-from-its-title>.md
   # (plain `mv` if it isn't tracked — which is the common case when the path is
   #  gitignored; see step 6. `git mv` on an untracked file fails with "bad source".)
   ```

   Three things this shape fixes, all of which broke the earlier one-liner:

   - **The branch line was interpolated into `grep` as a regex.** `**Branch**: <name>`
     starts with `**`, an invalid repetition operator — BSD `grep` (macOS default) and
     `ugrep` both abort with `repetition-operator operand invalid` / `empty (sub)expression`
     on *every* run, so the check never actually detected an archive. `-F` compares the
     literal string; `--` guards a pattern that starts with `-`.
   - **Empty/absent output was overloaded three ways** — "no `latest.md` at all", "exists
     but unarchived", and "the command errored" were indistinguishable, and the doc read all
     of them as "rename it first". On a first-ever close-out that means `git mv` on a
     nonexistent file (`fatal: bad source`, exit 128). Worse, a `latest.md` whose branch
     line was missing produced an *empty* grep pattern, which matches every file — reported
     as "already archived" and green-lit the overwrite. Each state now names itself.
   - **`sed -n '3p'` hardcoded the line number**, and `grep -v latest.md` was an unanchored
     regex (`.` matches any character). Match the `**Branch**:` line by pattern and exclude
     the file by exact path.

   Read the file's own `**Branch**:` line to name the archive — it usually identifies the
   workspace and topic. Only skip archiving if the existing checkpoint is demonstrably yours
   (its branch matches the one this session has been working on).

   **Freshness check before claiming `latest.md` (even when it's yours):** compare the
   existing checkpoint's `**Date**:` against the session being closed. In a multi-session
   workspace, `latest.md` may hold a NEWER session's handoff than the one you are closing
   (hit on chef-chopsky, 2026-07-25: close-out of a 7/08-7/20 arc found a 7/25 checkpoint
   from a successor thread). Overwriting the freshest handoff with an older-scoped one is
   backwards - in that case write YOUR checkpoint as the dated archive file
   (`docs/checkpoints/<date>-<topic>.md`) and leave `latest.md` untouched. `latest.md`
   should always be the most recent handoff for the workspace, not the most recently
   *written* one.

5. Write to `docs/checkpoints/latest.md` using the session-checkpoint format:

```markdown
# Session Checkpoint
**Date**: YYYY-MM-DD HH:MM
**Branch**: <current git branch>

## Current Task
<Active task from tasks document, or freeform description>

## Status
- **Done this session**: <bullet list>
- **In progress**: <what's partially complete>
- **Blocked on**: <any blockers>

## Key Decisions
- <Decision>: <rationale>

## Open Questions
- <Question needing input or research>

## Next Steps
1. <Most important next action>
2. <Second priority>
3. <Third priority>

## Hot Files (modified this session)
- `path/to/file`: <what changed and why>

## Out-of-Repo Changes (runtime / system / external — omit if none)
<Consequential changes git won't show: config files outside the repo (`~/.config/...`, `~/.<tool>/...`), installed package/tool versions, external service auth/state, infra. Include rollback pointers (backup paths, prior versions). Essential for ops/debugging/infra sessions where most real change happens outside the working tree.>

## Context the Next Session Needs
<Non-obvious knowledge that would take time to re-discover>
```

6. **Re-verify the branch, then commit the checkpoint — force-adding if the path is ignored.**

   ```bash
   git branch --show-current   # still the branch Phase 1 validated?

   # Stage ONLY the files this session wrote. Never `git add` the directory.
   CKPT_FILES=(docs/checkpoints/latest.md)
   # If step 4 archived a prior checkpoint, it MUST go in this list too — otherwise the
   # file you just rescued stays untracked under an ignored path, i.e. still expendable.
   CKPT_FILES+=(docs/checkpoints/<YYYY-MM-DD>-<topic>.md)   # omit if step 4 archived nothing

   # NOTE: check-ignore must test the FILE, not the directory. A `docs/checkpoints/`
   # pattern does NOT make `git check-ignore -q docs/checkpoints/` return true, even
   # though `git add` on that directory refuses. Testing the dir silently picks the
   # wrong branch here.
   if git check-ignore -q docs/checkpoints/latest.md; then
     # The repo ignores this path on purpose. ASK before overriding that, then:
     git add -f -- "${CKPT_FILES[@]}"
   else
     git add -- "${CKPT_FILES[@]}"
   fi
   git commit -m "chore: session checkpoint"
   ```

   Three failure modes this closes, the first two hit in a real run (chef-chopsky,
   2026-07-25):

   - **`docs/checkpoints/` is frequently gitignored** ("local resume state"). A plain
     `git add` then silently stages *nothing*, `git commit` reports nothing to commit, and
     the close-out reports success while the handoff exists only as an untracked file. Git
     treats ignored files as expendable, so **the next `git checkout` overwrites it without
     warning** — the checkpoint is gone with no reflog entry, because it was never an
     object.
   - **The branch can change between Phase 1 and here.** Phase 1's check is a point-in-time
     read; in a shared workspace another agent can switch branches while you are waiting on
     tools. Re-read it immediately before committing, and if it moved, re-run the Phase 1
     branch decision rather than committing to whatever branch you happen to be on.
   - **`git add -f` on the *directory* commits everything the repo deliberately ignored** —
     every other workspace's `latest.md` archive, scratch files, local resume state — and
     buries them in a commit labelled "session checkpoint". That is the same
     other-agent-clobbering failure step 4 exists to prevent, in the opposite direction.
     Force-add the explicit file list, never the directory.

   When the path is gitignored, force-adding overrides a deliberate repo decision, so
   **ask** rather than defaulting. If the user wants checkpoints to stay local, skip the
   commit and say so explicitly in the Phase 5 summary ("left local — path is gitignored")
   along with the fact that a `git checkout` can delete it. A repo keeping checkpoints local
   is a fine choice to make on purpose — just not one to arrive at by a silent no-op, and
   not one to silently overrule either.

## Phase 4: Learn Flow

1. If `--quick` or `--skip-learnings` was passed: skip this phase.
2. Otherwise, ask:
   > "Any learnings from this session worth capturing? (Or type 'skip' to close out.)"
3. If the user has input: invoke `/playbook:learnings` with `chat-session` trigger.
4. If the user skips: proceed to Phase 5.

## Phase 4.5: Forge Flow (optional)

Skip silently if `--quick` was passed, or if the `lore` skill is not installed (check `~/.claude/skills/lore` / `Skill` tool availability), or if `.specstory/history/` has no sessions.

Session close-out is a natural moment to turn accumulated work into reusable skills. If this session surfaced a *repeatable workflow you'd reuse across projects* (not a one-off), offer a lightweight nudge — do not run it for them:

> "This session looks like it had a reusable workflow. Want to run `/lore` to forge it (and other patterns in your history) into a cross-harness skill? It mines this project's `.specstory/history`."

`/lore` is interactive and user-driven — only point to it, never auto-invoke. If the user declines or there's nothing notable, skip silently.

## Phase 5: Summary

Present a one-line status per phase:

```
Session closed.

Git: [Committed 3 files / Clean / 2 uncommitted (noted)]
Tasks: [2 completed, 1 carried forward / No tasks document]
Handoff: docs/checkpoints/latest.md [committed <sha> / left local — path is gitignored]
         [archived prior checkpoint to <file>]
Learnings: [Captured / Skipped]
Skills: [Suggested /lore / Not applicable]
```

## Proactive Invocation

This command should be suggested (not auto-invoked) when:
- User signals session end ("thanks", "I'm done", "let's stop here", "that's all")
- A natural stopping point after completing the last requested task
- User asks "anything else before I go?"

Suggested format:
> Before you go — want me to run a quick close-out? I'll check for uncommitted work, update tasks, and write a handoff note.

## Graceful Degradation

Each phase is independent and fails gracefully:
- No git repo? Skip Phase 1.
- No tasks document? Skip Phase 2.
- No active project? Write handoff inline instead of to file.
- User declines learnings? Skip Phase 4.
- `lore` skill not installed, or no `.specstory/history`? Skip Phase 4.5 silently.

The command should always produce a useful summary, even if every phase is skipped (meaning: the session was clean with nothing to close out).

## Relationship to Existing Components

| Component | Relationship |
|-----------|-------------|
| `session-checkpoint` skill | Close-out writes to the same `docs/checkpoints/latest.md` format. The skill provides the format spec; this command orchestrates when and how it's written. |
| `learnings` command | Close-out invokes learnings as its final phase. Learnings remains standalone for mid-session capture. |
| `lore` skill (external, SpecStory) | Phase 4.5 points to `/lore` when a session surfaced a portable, reusable workflow. Close-out only suggests it; `/lore` is interactive and never auto-invoked. Learnings/improve-playbook handle plugin-specific gaps; `/lore` handles cross-harness skills. |
| `autonomous-execution` skill | Already recommends checkpoints every 3 tasks. Close-out handles the end-of-session case. |
