---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Changed
- **design-critique: critique the real component when it already exists** — new Step 2b screenshots the implemented story headlessly at phone and desktop widths, presents the critique as a numbered list, and stops until the user picks; the loop (apply → re-screenshot → before/after) is the deliverable, not the document.
- **close: Phase 2 no longer skips silently without a tasks doc** — it adds a dated status line to the project's status/action-plan doc, and edits the copy on the branch being committed to rather than the workspace branch's (which can carry an unmerged docs PR's version).
- **learnings: path-scoped rules are a promotion target** — `.claude/rules/<topic>.md` with `paths:` frontmatter sits between CLAUDE.md and `docs/guides/` in the Track 1 decision tree; a paragraph-long technique is usually a one-argument script.
