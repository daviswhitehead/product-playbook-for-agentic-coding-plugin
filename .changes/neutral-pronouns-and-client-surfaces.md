---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **Plugin prose no longer genders the founder** — commands, skills and templates called "the founder" he/his/him about 80 times, and agents carried it into real projects, writing "he/him" about a user who never stated pronouns. Every instance now says "the founder"/"the user" or they/them (the founder taste template's heading is now "How they review"). `scripts/validate-plugin.sh` now fails on whole-word he/him/his/himself/she/her/hers/herself in `plugins/**/*.md`, so it cannot creep back.

### Added
- **Client Surfaces section in the tech-plan template** — lists where the user will actually use or operate the work (apps, devices, agent harness), each marked confirmed by the user or assumed, and requires a live check of every capability the plan depends on and of any surface newer than the model's knowledge. A plan once assumed the phone surface would be Claude Code cloud sessions; the user then chose a newly released app whose capabilities were unverified.
