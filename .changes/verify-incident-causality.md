---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Added
- **`/playbook:learnings` — verify an incident's causal claim against an authoritative timeline before writing it into an addendum.** An addendum's core sentence is causal, and it gets written from what you remember doing, in the order you remember doing it — a reconstruction that fuses adjacent events into a cause. Once wrong causality is in the doc it is load-bearing: later readers inherit it and the fix gets aimed at the wrong mechanism. Adds the one-call check (`gh api .../issues/<N>/timeline`, `git log --format=%cI`, `git reflog --date=iso`), instructions to correct the user if the wrong version was already reported, and guidance to record a verified ordering with an unresolved cause rather than asserting a confident wrong mechanism — preferring fixes that hold under every surviving hypothesis.
