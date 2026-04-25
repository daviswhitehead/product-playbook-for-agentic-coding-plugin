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

1. Run `git status`.
2. If there are uncommitted changes:
   - Show a brief summary (files changed, not full diffs)
   - Offer to commit. If the user approves, draft a commit message and commit.
3. If the working tree is clean: skip silently.

## Phase 2: Task Cleanup

1. Search for an active tasks document:
   - Check `docs/superpowers/plans/*-tasks.md`
   - Check `projects/*/tasks.md`
   - Check `docs/tasks.md`
2. If a tasks document exists:
   - Scan for `in_progress` tasks. For each: is the work done? Mark completed or note what's left.
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
4. Write to `docs/checkpoints/latest.md` using the session-checkpoint format:

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

## Context the Next Session Needs
<Non-obvious knowledge that would take time to re-discover>
```

5. Commit the checkpoint: `git add docs/checkpoints/ && git commit -m "chore: session checkpoint"`

## Phase 4: Learn Flow

1. If `--quick` or `--skip-learnings` was passed: skip this phase.
2. Otherwise, ask:
   > "Any learnings from this session worth capturing? (Or type 'skip' to close out.)"
3. If the user has input: invoke `/playbook:learnings` with `chat-session` trigger.
4. If the user skips: proceed to Phase 5.

## Phase 5: Summary

Present a one-line status per phase:

```
Session closed.

Git: [Committed 3 files / Clean / 2 uncommitted (noted)]
Tasks: [2 completed, 1 carried forward / No tasks document]
Handoff: Saved to docs/checkpoints/latest.md
Learnings: [Captured / Skipped]
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

The command should always produce a useful summary, even if every phase is skipped (meaning: the session was clean with nothing to close out).

## Relationship to Existing Components

| Component | Relationship |
|-----------|-------------|
| `session-checkpoint` skill | Close-out writes to the same `docs/checkpoints/latest.md` format. The skill provides the format spec; this command orchestrates when and how it's written. |
| `learnings` command | Close-out invokes learnings as its final phase. Learnings remains standalone for mid-session capture. |
| `autonomous-execution` skill | Already recommends checkpoints every 3 tasks. Close-out handles the end-of-session case. |
