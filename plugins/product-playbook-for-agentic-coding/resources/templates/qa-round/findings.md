# QA round [N]: [Project name]

<!-- projects/<state>/<project>/qa/round-<N>/findings.md, written by /playbook:qa-round. The round's
     tracker: every check and every finding, with its owner and status. Runs on the INTEGRATION BRANCH,
     before PRs open, whenever it can; a round over merged PRs works the same way. Agents pass every row
     they can first (three passes: user journeys, adversarial, real device); the founder gets only rows
     that need irreducible taste, his real account, or what no agent can see.
     /playbook:close-project (verify-close-project.sh) reads this file: it refuses while any row's Status
     is `open` or `fail`, or while the Close-out lines below are unfilled. Delete this comment. -->

**Branch / PRs:** [integration branch @ sha, or PR numbers] · **Roles:** [guest, member, ...] · **Devices:** [desktop Chromium, iOS Simulator Safari at the founder's device size and phone size] · **Started:** [date]

| # | Finding or check | Owner | Device / surface | Status | Opened | Evidence / decision |
|---|------------------|-------|------------------|--------|--------|---------------------|
| 1 | [what to look at, and what "right" looks like] | agent | [device] | open | [date] | [screenshot / recording / test name; stub or live] |
| 2 | [taste call only the founder can make] | founder | [device] | open | [date] | [needs-founder.md item n; the agent's recommendation] |

<!-- Owner: agent | founder.  Status: open | fail | pass | fixed | filed | decided.
     fixed = changed on the branch (link the commit). filed = an issue with a link, out of this round's
     scope. decided = the founder ruled (needs-founder.md), or a founder row passed 48 h with no answer
     and you wrote "default applied <date>: <what>". Keep Owner and Status cells as single bare words so
     the close-out check can read them. -->

## Passes

| Pass | What ran | Environment | Result |
|------|----------|-------------|--------|
| 1. User journeys | [journeys per role, happy and edge] | [local production build; E2E stub; one live-agent run] | [n journeys, n findings] |
| 2. Adversarial | [hostile input, double submits, auth edges, read-only prod probes] | [...] | [...] |
| 3. Real device | [real-device-checklist.md rows] | [iOS Simulator, iOS <version>, <device>] | [...] |

## Learn step (corrections an earlier rule, check or template could have predicted)

| Founder correction | Rule / check / template that should have caught it | Edit made this round |
|--------------------|-----------------------------------------------------|----------------------|
| [his words] | [path] | [commit, or "none: <why>"] |

## Close-out

<!-- Fill every line before /playbook:close-project. A bracketed placeholder or an empty value fails
     the close-out check. "none: <why>" is a valid value. -->

- **Findings:** every row above is pass, fixed, filed or decided.
- **Taste ledger:** [rows <ids> appended to <ledger path>, or "none: <why>"]
- **Repeated corrections → rules:** [<correction he made twice> → <rule, check or guard path>, or "none: <why>"]
- **After-deploy guide:** [testing-guide-after-deploy.md, "Production, after deploy" line filled on <date>]
