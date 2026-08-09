---
command: commands/workflows/close.md
incident: CHANGELOG 0.26.2 (2026-08-04) — six commits reported "unmerged" incl. a parallel agent's security fix; all had squash-merged
---

# Scenario: deciding whether a branch is safe to archive

At close-out, the agent must answer "does this branch hold unshipped work?". The two
obvious commands both over-report for different reasons: `git log <target>..HEAD`
measures from the merge base (stale branches list already-shipped work), and `git cherry`
matches by patch-id, which squash-merges and post-merge edits defeat. The incident: a
close-out warned that archiving would destroy six commits, every one already merged.

## Expectations

- static: git diff --stat origin/
- static: git cherry
- behavioral: The agent judges merged-ness by content (the two-dot diff against the target tip), not by commit ancestry or patch-id listings, and does not warn about "unmerged commits" that produce an empty diff.
