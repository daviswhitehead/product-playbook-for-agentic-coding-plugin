---
name: session-checkpoint
description: Persist working context across sessions and context compaction events. Write checkpoints at session end, read at session start. Prevents re-orientation tax from context amnesia.
---

# Session Checkpoint

## Problem

Context compaction and session boundaries destroy working memory. Agents spend 10-15 minutes per session re-reading files and re-discovering state. Across a project, this compounds into hours of wasted effort.

## When to Write a Checkpoint

- **End of session**: Before the user ends a conversation
- **Before context gets long**: If you've been working for a while and the conversation is deep, proactively write a checkpoint
- **Before switching tasks**: Capture current state before moving to a different area
- **When asked**: User says "save checkpoint", "capture state", "I'm done for now"

## When to Read a Checkpoint

- **Start of every session**: Read `docs/checkpoints/latest.md` before reading tasks.md or other project docs
- **After context compaction**: If you notice you've lost context, check for a checkpoint
- **When resuming work**: User says "where were we?", "continue", "pick up where we left off"

## Checkpoint Format

Write to `docs/checkpoints/latest.md` (always overwritten) and optionally archive to `docs/checkpoints/YYYY-MM-DD-HHMM.md`:

```markdown
# Session Checkpoint
**Date**: YYYY-MM-DD HH:MM
**Branch**: <current git branch>
**PR**: <PR number if applicable>

## Current Task
<Task ID and description from tasks.md, or freeform description>

## Status
- **Done this session**: <bullet list of what was accomplished>
- **In progress**: <what's partially complete>
- **Blocked on**: <any blockers>

## Key Decisions
- <Decision>: <rationale> (important — these are lost in compaction)

## Open Questions
- <Question that needs user input or research>

## Next Steps
1. <Most important next action>
2. <Second priority>
3. <Third priority>

## Hot Files (modified this session)
- `path/to/file.ts`: <what changed and why>

## Context the Next Session Needs
<Anything non-obvious that would take time to re-discover. E.g., "The streaming endpoint returns correlation_id in the last SSE event, not as a header" or "Integration tests need AGENT_PORT=3031 to avoid conflicts">
```

## How to Use

### Writing (proactive)
When the session is wrapping up or getting long:
1. Create `docs/checkpoints/` directory if it doesn't exist
2. Write `docs/checkpoints/latest.md` with the format above
3. Optionally archive: copy to `docs/checkpoints/YYYY-MM-DD-HHMM.md`
4. Commit the checkpoint: `git add docs/checkpoints/ && git commit -m "chore: session checkpoint"`

### Reading (at session start)
1. Check if `docs/checkpoints/latest.md` exists
2. If yes, read it FIRST — before tasks.md, before exploring the codebase
3. Use it to orient: pick up the current task, understand decisions made, avoid re-reading hot files
4. If the checkpoint is stale (>3 days old or branch has changed significantly), note this and do fresh orientation instead

## Key Principles

- **Brevity over completeness**: A 20-line checkpoint that captures the right things is better than a 100-line dump
- **Decisions are the highest-value content**: Code changes are in git. Decisions and rationale are lost in context compaction.
- **Next steps should be actionable**: "Continue with Task 5.3" is better than "Keep working on the feature"
- **Don't duplicate git**: The checkpoint captures context that git diff/log doesn't — decisions, blockers, non-obvious knowledge
