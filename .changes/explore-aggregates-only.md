---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Changed
- **`/playbook:explore` grounding uses aggregate usage data only** (counts, rates, funnels), never raw user-generated text. An unattended discovery run has a shell, so user-written text is a prompt-injection path into it.
