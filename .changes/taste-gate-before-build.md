---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **`work`: taste gate before build (new Step 3.5)** — when taste is the deliverable (visual treatment, tone, naming, or no test can separate success from failure), render the smallest artifact that shows the result and get a pick *before* implementing; Step 5.5's post-build review is the wrong place for the only decision that matters on subjective work.
- **`learnings`: CLAUDE.md size check must compare against the default branch** — measuring the working tree on a stale branch reports hard-limit violations the branch never caused; the remedy (trimming) would re-delete content already deleted upstream.
