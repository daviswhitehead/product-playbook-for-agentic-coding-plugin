---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **`debug`: a regression test you haven't seen fail isn't a test** — Step 8 now requires running each new test against the pre-fix code and reading *which* tests go red, not just that some did; generalizes the autonomous-execution guard rule to the far more common bug-fix case, with a corollary for environmental mechanisms (keep one test at the real layer and verify it pre-fix too).
