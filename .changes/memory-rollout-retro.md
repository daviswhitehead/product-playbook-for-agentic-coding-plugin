---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Changed
- **autonomous-execution: a watcher reports either way** — every background wait loop ends with a state line (`DONE`, `RECOVERED`, `STILL_DOWN at <time>`) inside its own time limit; a loop that exits only on success went silent through a 7-hour outage.
- **learnings: check for a parallel retro first** — search open `learnings` PRs and branches, scope to the window they don't cover, link instead of restating, and stay out of the files they edit.
