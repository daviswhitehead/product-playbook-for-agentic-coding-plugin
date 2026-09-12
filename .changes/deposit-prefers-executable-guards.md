---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Added
- **`/playbook:close` — check whether the charter already said it before depositing another charter line.** The common case is not that the guidance was missing; it is that it was already there, correctly worded, and inert. When the charter already covers the rule, adding a second, more emphatic sentence is the failure mode, not the fix — the real finding is that a *prose* rule governed something only *code* can enforce. Deposit an executable guard (non-zero exit, CI check, hook, lint rule) and edit the charter only to record that the lever is now wired.
