# QA round [N]: [Project name]

<!-- projects/<state>/<project>/qa-round-<N>.md. Runs on the INTEGRATION BRANCH, before PRs open, not after
     merge. Agents pass every row they can first (browser automation, real-device or simulator checks,
     screenshots); the founder gets only rows that need irreducible taste. A founder row is never left open
     indefinitely: after 48 h without an answer the agent records the default it applied.
     /playbook:close-project (verify-close-project.sh) refuses while any founder row reads `open`. -->

**Branch:** [integration branch @ sha] · **Devices:** [e.g. desktop Chromium, iOS Simulator Safari, a real phone] · **Started:** [date]

| # | Check | Owner | Device / surface | Status | Opened | Evidence / decision |
|---|-------|-------|------------------|--------|--------|---------------------|
| 1 | [what to look at, and what "right" looks like] | agent | [device] | open | [date] | [screenshot / recording / test name] |
| 2 | [taste call only a human can make] | founder | [device] | open | [date] | [link to what to look at; the agent's recommendation] |

<!-- Owner: agent | founder.  Status: open | pass | fail | fixed | decided.
     Keep the Owner and Status cells as single bare words so the close-out check can read them.
     When a founder row passes 48 h with no answer, set Status to `decided` and write
     "default applied <date>: <what>" in the last column. -->

## Findings fixed this round
- [#] [what changed] — [commit]
