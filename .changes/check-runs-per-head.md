---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Changed
- **`/playbook:monitor-pr` and `/playbook:merge-prs` now judge CI per head sha, not from `gh pr checks`.** `gh pr checks` mixes results from cancelled/superseded workflow runs into one list — a PR whose ready-for-review run got concurrency-cancelled by a fresh push shows the dead run's jobs as `fail` next to the live run's `pending`, and a monitor that trusts it starts "fixing" failures that never happened on the current code. The authoritative read is `gh api repos/<o>/<r>/commits/<headRefOid>/check-runs`.
- **A `skipped` load-bearing suite is not green.** Path filters evaluate the push event, not the PR's files, so a required job can silently skip on an update-branch merge push even when the PR's files match its filter. Force it onto the current head before treating the PR as validated. (Found chef-chopsky 2026-08-22: three PRs in one merge queue misread this way.)

### Fixed
- **`/playbook:learnings` now points at the real plugin paths.** In the plugin *repo* commands and skills live nested under `plugins/<plugin-name>/`, not at the repo root — `find <repo>/plugins -name "<command>.md"` beats guessing.
