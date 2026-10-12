---
plugin: product-playbook-for-agentic-coding
bump: minor
---

### Added
- **Decision rights at approval** — the REVIEW.md template and the PRD template carry a Decision Rights block the founder fills once per project: agents merge everything except data-writing migrations, auth, secrets and spend; new surfaces ship dark behind flags with the flip as the founder's gate; reversible picks take a 48-hour default; one daily packet (`decisions-queue.md`, new template) instead of blocking asks; verify before asking. In the project that prompted this, 55% of the 10.6-day calendar was waiting on the founder or idle.
- **Self-resume in `autonomous-execution`** — state in `project-state.md` (new template), checkpointed at every state change; check `CLAUDE_CODE_RETRY_WATCHDOG` / a `StopFailure` hook once per machine; no sub-agent waits on CI with a hot context (it ends with `NEXT:` and the lead arms a watcher); a fixed restart procedure. 47.6 h of that project was "limit already reset, nobody typed continue".
- **QA round before merge** — `qa-round.md` template and tasks Task N.4 run QA on the integration branch before PRs open (agents first, founder only for taste, real-device checks); `verify-close-project.sh` refuses while any founder row is still `open`.
- **Delivery ledger** — `/playbook:close-project` Step 2b emits `delivery-ledger.md` (calendar buckets, founder turns, PRs, CI minutes, dollars, re-runs by cause) compared against the previous project, calling the project's generator if it has one; `/playbook:learnings` starts project retros from it; the verify script requires it.

### Changed
- **PR shape** — tech-plan and tasks plan one integration branch, reviewed once, shipped as one PR per risk class with each PR's cost (CI cycles, eval runs); no stacked PRs (replaces "stack only when a founder gate would block").
- **Testing in three lanes** — deterministic gate with a wall-time budget, live-model lane once per agent change set, health lane as preflight; local runs only the touched tests when CI runs the full suite (`work` Step 7b rewritten); every new test names the risk it protects.
- **Models from the project's registry** (role → alias, set the Agent tool's `model` explicitly) and a **machine-wide heavy lock** with at most 3 heavy workspaces per machine and a preflight.
- CI now runs `test-close-project-checks.sh` (18 cases).
