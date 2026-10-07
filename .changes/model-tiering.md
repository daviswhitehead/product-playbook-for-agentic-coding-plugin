---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Added
- **`autonomous-execution` — model tiering rule in "Conductor mode"**: strongest model for judgment/editing subagents, mid-tier only for mechanical verification (CI watching, log reading, data gathering, suites, triage tables), no smallest tier; fewer subagents beats cheaper ones. Founder decision 2026-10-07 (chef-chopsky).
