---
plugin: product-playbook-for-agentic-coding
bump: patch
---
### Changed
- **Instrumented-task gate: the non-null read must come from the path under change** (`autonomous-execution` skill, `close` Phase 2). A metric fed by several producer paths (header link, gate sheet, OAuth callback) is satisfiable in aggregate by a fixture from a path nobody touched — chef-chopsky's "≥1 attributed signup" guard stayed green for two months while the guest-first path attributed nothing. Slice the consuming query by path; standing guards assert per path.
