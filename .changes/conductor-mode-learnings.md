---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Added
- **`autonomous-execution` — "Conductor mode: resource budget" for parallel subagents on one machine** (pointer from `/playbook:work-multiple`). Waves of ≤4 full-install subagents with a `df -h` + session-limit pre-flight, a shared mkdir lock serializing heavy steps (commit hooks, push, `ci:local`, full suites, `npm ci`), rules written once in a brief every agent reads, `pending manager review` packet verdicts only the conductor flips, and proof runs treated as side-effecting. Evidence: on 2026-10-05 eight parallel Opus agents filled a 98%-full disk, wedged Docker, drove load to 570 and exhausted the account session limit by noon; a test reached real `gh`, a probe wrote a real PostHog insight, and dry-run state got committed and blocked the cron host's pull.
- **`/playbook:git-pr` — create the PR from the branch that holds the commits.** `gh pr create` without `--head` uses the current branch; a checkout back to the workspace branch first opened a PR from the wrong branch (chef-chopsky #1226 → #1229).
- **`/playbook:learnings` — "standard, mined from this session" option** when SpecStory is thin but the session is long (it surfaced the 2026-10-06 retro's three highest-value findings), and Step 10 Part B now treats a mid-turn "what should I say about how this went?" as Part B input.
