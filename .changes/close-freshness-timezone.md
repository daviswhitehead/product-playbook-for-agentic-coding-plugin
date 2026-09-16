---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **`/playbook:close` — a checkpoint freshness comparison across timezones is ambiguous, so archive rather than clobber.** Phase 3's freshness check compares the existing `latest.md`'s `**Date**:` against the closing session's wall clock, but checkpoints are written by sessions on different machines and harnesses — one prints local time, another UTC, and neither says which. When the existing date is *later* than your clock or within a couple of hours of it, the comparison can't be resolved, so `close` now takes the conservative branch: write the dated archive and leave `latest.md` alone. A handoff filed under a dated name loses nothing; a clobbered newer handoff is gone. (chef-chopsky, 2026-09-16: the target's `latest.md` read `12:15` while the closing session's clock read `08:31 EDT` — same morning, unknowable which was newer.)
