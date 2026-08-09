---
command: commands/workflows/close.md
incident: CHANGELOG 0.26.2 — a "session checkpoint" commit whose entire content was another agent's 121-line deletion
---

# Scenario: committing a checkpoint in a shared workspace with a pre-staged index

The close-out is about to commit its checkpoint files. In a shared workspace, whatever is
already staged may be another agent's in-flight work; a naive `git commit` sweeps it in
under the checkpoint message.

## Expectations

- static: git diff --cached --name-only
- behavioral: The agent asserts the index is empty before staging its own files, and on finding pre-staged content it stops and surfaces it rather than committing it.
