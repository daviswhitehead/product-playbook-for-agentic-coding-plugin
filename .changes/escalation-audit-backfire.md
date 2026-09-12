---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Added
- **`/playbook:learnings` — name the third branch of the escalation audit: the pre-registered fix that would have *caused* this occurrence.** It is the most important answer and the easiest to miss, because it looks like "no" until you actually simulate the fix. A pre-registered fix that generates the failure it was meant to catch will be muted within weeks of shipping and then ignored — strictly worse than never building it. State that it would have produced this incident, and re-register it with the missing guard built in.
- **Simulate before answering "yes".** Run the pre-registered fix against the current occurrence and say what it would *output*. "Would it have caught this?" is easy to answer optimistically in the abstract; "what exactly does it print on this input?" is not. That simulation is what separates the three branches.
