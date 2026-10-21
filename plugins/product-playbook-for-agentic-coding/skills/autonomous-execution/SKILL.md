---
name: autonomous-execution
description: Patterns for autonomous project execution with minimal human intervention. Use this skill when executing well-defined tasks autonomously, including validation strategies, stop conditions, and quality gates. Don't use when doing a single task interactively with the user, or when the project lacks a tasks document.
---

# Autonomous Execution

This skill provides patterns for executing projects autonomously while maintaining quality and knowing when to stop and ask for help.

## Prerequisites for Autonomous Execution

Before starting autonomous work, verify:

### Project Readiness
- [ ] **Tech Plan exists** - Architecture and sequencing documented
- [ ] **Tasks Document exists** - Granular tasks with acceptance criteria
- [ ] **REVIEW.md approved** - The one-page project review (`/playbook:review`) carries the founder's "approved"; without it, build only what the tasks doc marks as pre-approval work
- [ ] **Decision rights recorded** - The approved block (REVIEW.md or PRD "Decision Rights") says what agents may merge, what ships dark, the 48-hour default and the daily packet. Without it, every merge becomes a blocking question
- [ ] **`project-state.md` exists** - From `resources/templates/project-state.md`; a restart reads it first (see Self-Resume)
- [ ] **Success criteria defined** - Clear "done" definition
- [ ] **Tests exist** - Automated validation available
- [ ] **Quality gates configured** - Pre-commit hooks, CI checks

### Documentation Readiness
- [ ] **Project docs available** - CLAUDE.md, relevant docs
- [ ] **Troubleshooting guide exists** - Common issues documented
- [ ] **Stop conditions clear** - When to pause and ask

## Execution Patterns

### Pattern 1: Task-by-Task Execution

**When to use**: Standard execution for most projects

**Process**:
1. **Read task** - Understand requirements and acceptance criteria
2. **Plan approach** - Identify implementation strategy
3. **Implement** - Write code following project standards
4. **Self-validate** - Run tests, check acceptance criteria
5. **Update status** - Mark task complete, update progress
6. **Proceed to next** - Move to next task

**Validation Checkpoints**:
- After each task: Run relevant test suite
- After each phase: Run full test suite
- Before completion: Complete quality gate checklist

### Pattern 2: Phase-by-Phase Execution

**When to use**: Projects with clear phases (migrations, refactors)

**Process**:
1. Complete all tasks in current phase
2. Run phase-specific validation
3. Verify quality gates pass
4. Document learnings
5. Proceed to next phase only after validation

### Pattern 3: Incremental Validation

**When to use**: Large projects or risky changes

**Process**:
1. Make small, focused change
2. Validate immediately
3. Commit only if validation passes
4. Repeat with next small change

### Checkpoint Integration (Mandatory)

Two artifacts, two jobs. **`project-state.md`** is the project's durable state: update and commit it at **every state change** (task started, PR opened, check finished, decision recorded), so a stop at any point loses at most one step (see Self-Resume). **Session checkpoints** hand one session's working context to the next:

- **Write checkpoints** every 3 completed tasks — this is not optional
- **Write to** `docs/checkpoints/latest.md`
- **Include**: current task, decisions made, next steps, hot files
- **Also write before stopping** for any reason (blockers, session end, user interrupt)
- **Why**: Context compaction destroys working memory. Checkpoints are the only mechanism that preserves decisions and rationale across compaction events. Treat them as mandatory infrastructure, not a nice-to-have.

See the `session-checkpoint` skill for the full checkpoint format.

### Worktree Isolation

When running multiple independent tasks, consider whether to use git worktrees for isolation:

| Scenario | Recommendation | Reason |
|----------|---------------|--------|
| Sequential tasks in one subsystem | Stay on branch | Low isolation benefit, worktree overhead not worth it |
| Independent tasks across 2+ subsystems | Parallel worktrees | Tasks can't interfere with each other, enables parallel agents |
| Background maintenance tasks (lint fixes, doc updates) | Always use worktree | Keeps primary branch clean for feature work |
| Risky or experimental changes | Use worktree | Easy to discard without affecting main work |

**When NOT to use worktrees:**
- Tasks that depend on each other's output
- Tasks that modify shared state (same config files, same database schema)
- When the project is small enough that all tasks touch the same files

## Self-Resume (required for work longer than one sitting)

Work stops when a session stops: a usage-limit window, exhausted credits, a crash, a quit app. If nothing resumes it, the founder becomes the resume button. In one measured project, six usage-limit stops lasted 4.5 h in total, and the sessions then sat **47.6 h after the limit had reset**, waiting for someone to type "continue". State in files plus a harness that waits makes any restart cheap: a fresh run reading a 2k-token state file costs about a tenth of re-sending a long chat's context.

1. **State lives in files.** At project start create `project-state.md` (template `resources/templates/project-state.md`: Now / Next / In flight / Waiting on / Decisions / Resume notes). Checkpoint it at every state change and commit it. Write each sub-agent's id, model, branch and PR into "In flight".
2. **Check the harness once per machine.** In Claude Code, `CLAUDE_CODE_RETRY_WATCHDOG=1` (the `env` block of user settings) makes a session wait out a usage-limit window in-process and carry on at the reset; verify with `echo $CLAUDE_CODE_RETRY_WATCHDOG` in a new session. A `StopFailure` hook (matcher `rate_limit|billing_error`) can record stops the watchdog can't cover (credits, killed sessions) and start a fresh headless run from `project-state.md`; use the project's resumer script if it ships one. If neither is set up, tell the founder the exact settings lines once; do not proceed assuming "continue" will be typed.
3. **On a limit stop, do nothing clever.** Write the state file and end the turn; don't retry in a loop. If the harness can't resume (credits, billing), send ONE notification saying what the founder must do and write `Waiting on: founder (credits)` into the state file. Prevention for credit stops is the model choice: keep long-running leads off credit-metered models.
4. **No waiting sub-agents.** A task whose duration is dominated by waiting (CI, a deploy, a long local suite, a human) is not given to an agent that holds a large context: every poll after a 5-minute gap re-sends the whole cached context (in one project this pattern cost about $500, the largest avoidable agent cost). The sub-agent finishes with a final line `NEXT: <the event it needs>` (e.g. `NEXT: CI run 123 completes on <sha>`); the lead arms a background watcher (`gh run watch`, a `Monitor`, a background task, or the project's merge sweep) and the completion notification restarts work with a small context.
5. **Restart procedure.** State file → verify every "In flight" PR head and CI by id (`gh pr view`, `git status`) → continue the first unblocked item in "Next". Every queue item is idempotent and starts by verifying current state. Report what changed, not what you remember, and never ask "should I continue?".

## Reaching the Founder (one channel, verified first)

- **Try it before handing it off.** Before writing the founder a walkthrough, attempt the step yourself (CLI, API, or browser automation through his signed-in browser). Only passwords and 2FA, payments, legal identity and founder-reserved changes go to him, and you read back the state after he acts (`/playbook:work`, *Founder Handoffs*). *(chef-chopsky, 2026-10-11 → 10-17: five "can you do this for me?" asks in one project, all agent-doable.)*
- **Verify before asking.** Before any question reaches the founder, check the claim yourself: installed tools, current limits and quotas, prior answers in the transcript and project docs. *(A lead once asked the founder to install a tool he had confirmed installed six days earlier; five PRs waited about ten hours.)*
- **Queue, don't block.** Questions go into `decisions-queue.md` (template `resources/templates/decisions-queue.md`) with your recommendation, whether it is reversible, and what it blocks; each row also gets a decision line in `<project>/decisions.jsonl` (id `W-<n>`; shape, `images` and the stand-in hook in `resources/templates/decision-line.md`). Then keep working on unblocked items. The queue goes out as **one daily packet**; a live interrupt is only for a production or spend outage.
- **Unattended runs may advance discovery to the next founder gate, and no further.** For a project in discovery (a `discovery:` line in `project-state.md`), run one stage of `/playbook:explore <project-dir> --unattended`; it ingests answers, stops at once if a blocking row is still open, and otherwise runs one stage, leaves its questions in `decisions-queue.md` (plus `discovery/decisions.jsonl`) and ends with `NEXT:`. Taste picks are never defaulted by an agent before 48 h, and costly or founder-only ones never; discovery is committed locally, never pushed or opened as a PR.
- **Apply the 48-hour default.** A reversible item takes your recommendation after 48 h of founder silence, recorded as "approved by default" in the queue and the owning artifact, and as `answer: "default after 48 h"` on its decision line. Irreversible and founder-only items (per the Decision Rights) never default.
- **Take his answer as given.** In the queue, a Slack-style reply or a packet he answers with a pick, sometimes with a short reason after it ("B, simpler"). Record the pick as the line's `answer` and the reason as `why` (`why_basis: stated`). Never ask him for a reason.
- **Merge within the Decision Rights.** PRs the block lets agents merge, merge once their checks have run green on the current head, with a proof-of-completion comment. Don't ask "may I merge?" for something already delegated.

## Self-Validation Strategies

### Task-Level Validation

After completing each task:

1. **Run relevant tests**:
   - Unit tests for logic changes
   - Integration tests for API/service changes
   - E2E tests for user-facing changes

2. **Check acceptance criteria**:
   - Review each criterion
   - Verify all can be marked complete
   - Document any deviations

3. **Run quality checks**:
   - Type checking
   - Linting
   - Build verification

4. **Update task status**:
   - Mark acceptance criteria complete
   - Add completion notes
   - Update status to "Complete"

### Instrumented-Task Verification Gate (do NOT close on a static check)

If a task's acceptance criterion includes **"event fires", "metric captured", "instrumentation added", or "tracked in <analytics tool>"**, the task **cannot be marked complete on a static/import check** ("the code calls `capture()`", "imports are clean"). Code-is-wired ≠ behavior-verified.

Before marking such a task ✅, require ONE of:
1. **Runtime evidence AND metric evidence** — the two-part rule below, OR
2. **An explicit unverified flag** surfaced to the user: *"Code is wired but I could not verify the event fires at runtime — needs a runtime check before this is truly done."*

Never silently equate the two. This failure mode has recurred across three projects (Memory Phase 1 gates closed with `null` metrics; acquisition T10/T11/T12 closed with zero/deprecated events — `recipe_cta_clicked` logged **zero events for 12 days** after being marked done on "imports are clean"). The symptom of a miss is "No data recorded" for a *shipped* event — treat that as instrumentation-suspect, not "no traffic," and fire a synthetic event to disambiguate.

#### Emission and the metric are two separate checks

"It landed in the analytics tool" is **emission**, not the metric. Verify both:

1. **Emission** — fire the event yourself (synthetic click / incognito + DevTools network filter) and confirm it arrives.
2. **The metric** — run the query, dashboard, or report that **consumes** the data and confirm it returns a **correct non-null value**. Paste that output as the evidence.

**When the metric has more than one producer path, the non-null read must come from the path under change.** A metric like "signups by channel" is fed by several code paths (header link, gate sheet, OAuth callback). An aggregate check — "at least one row resolves" — is satisfiable by any of them, including an old fixture from a path nobody touched. Slice the consuming query by the path (an `entry_type`, a surface, a source field) and read the value for **the path this task changed**, produced by **the runtime production uses** (start command, preloads/instrumentation, behavior-changing flags) — a local dev server or test runner is a different program; a standing guard over such a metric asserts per path, not in aggregate. *(chef-chopsky, 2026-09-18: a "≥1 attributed signup" guard stayed green for two months while the guest-first path — every real conversion — attributed nothing; the two attributed rows were pre-flight fixtures from the header link. chef-chopsky, 2026-10-06: a token-usage fix read a real, non-null reply from the local DB on the right path, but production runs `node --import instrument.js` while local runs `tsx`, and the first production reply was still `usage: null`.)*

Step 2 is the one that gets skipped, and skipping it is invisible. A 202 from the endpoint, a network request in DevTools, a green unit test asserting the tracking call, and the event visible in a live-events stream are **all** compatible with a metric that reads zero forever.

> A conversion pixel passed step 1 completely — SDK loaded on both hosts, event accepted 202, attribution param on the payload, person properties written correctly, unit tests green — and was marked done. The consuming query read a property path the event never carried (the event is captured server-side; that path only exists on client captures), so every signup bucketed as "direct (no UTM)". Nothing had run the query against a real attributed signup, so code review couldn't see it. Found in a pre-launch audit, one click before a paid campaign would have spent its full budget for zero attribution — which ad platforms cannot backfill.

Two habits that prevent this class:
- **Put the attribute on the same record the metric counts.** Joins and person-property lookups are where NULLs and read-time races hide.
- **Make the consuming query a runnable check** that fails on an empty/null result, and validate it in **both** directions — a check that doesn't fail when pointed at the old broken version is a rubber stamp, not a guard.

If no consumer exists yet, the task is not done: write the query.

### Negative-test every guardrail you add (a check that can't fail is not a check)

**Applies to ANY guard, not just instrumentation**: lint rules, CI jobs, pre-commit hooks, schema/migration audits, quality gates, assertion helpers, smoke checks.

Before marking a guard-adding task complete, you must have run it **twice**:

1. **Positive** — against correct input. It passes.
2. **Negative** — against the broken input it exists to catch. **It fails, with an actionable message that names the fix.**

If you have not seen it fail, you have not tested it — you have only observed that it is silent, and silence is what a no-op looks like too.

Also check the guard can't become **unsatisfiable**. A check that derives its query/config from production code can inherit a filter that removes the very fixture it needs, and then fails forever for a reason unrelated to what it guards. That trains people to ignore it, which is worse than having no guard.

> Real incidents. (a) A metrics verifier inherited the production query's internal-account exclusion — the only attributed fixture was a test account that filter removed, so it failed on production with a message *indistinguishable from the real bug*. (b) An ESLint rule and a CI check were both authored, and only the passing direction was ever exercised; the negative case was assumed.
>
> This rule was written down after an earlier incident (a CI guardrail that never fired) and lived **only in a retrospective for two months**, so the next guardrail repeated it. That is why it is here, in the workflow, and not only in a doc.

**Cheap pattern**: temporarily revert the fix (or point the guard at the old/broken version), run the guard, confirm red + read the message, restore. Paste both outcomes as the completion evidence.

### Acknowledge Method Substitution (don't silently downgrade verification)

If a task names a **specific verification method** (e.g., "browser automation / E2E test of the full flow") and you cannot or do not perform it, you must **say so explicitly** — never substitute a weaker method (a code trace, a line-number citation, a manual read) and report it as if the named method was performed. State: *"The task asked for an E2E run; I did a code trace instead because <reason>. This is weaker — the browser test still needs to run."* For E2E specs specifically, "wired into the test runner's `testMatch`/suite + seen running in CI" is part of done — a spec file that exists but never runs is zero coverage.

### Phase-Level Validation

Tests live in three lanes (the project's test-portfolio policy wins where it exists): a **deterministic gate** (lint, typecheck, unit, deterministic integration, stubbed E2E; must stay under a wall-time budget), a **live-model lane** (evals, live-model checks; once per agent-behaviour change set, not per PR), and a **health lane** (quota, billing, tracing caps; a preflight and cron, never inside the gate).

After completing each phase:

1. Run phase-specific validation (if script exists)
2. Run the deterministic tests the phase touched locally; let CI run the full suite once at ready. Run a suite locally in full only when CI doesn't run it or you are reproducing a CI failure (under the heavy lock)
3. Run the live-model lane once for the phase's agent-behaviour changes, not per task
4. Verify all quality gates pass
5. Document any learnings or issues

Flakiness is handled by the portfolio, not by re-running: a test that fails without a code cause gets an owner and a fix-or-delete deadline. Every new test names the risk it protects and sits at the lowest layer that can fail for that bug.

## Stop Conditions

**CRITICAL**: Stop and ask for help when encountering:

### Immediate Stop (Blockers)
| Condition | Action |
|-----------|--------|
| Tests fail 3+ times | Stop, document issue |
| Architectural decision needed | Irreversible: queue it in `decisions-queue.md`, switch to unblocked work. Reversible: take your recommendation, log it with the 48 h default |
| External dependency blocked | Stop that item, record it under "Waiting on", report it in the packet |
| Quality gate failure (can't fix) | Stop, seek help |
| Ambiguous requirements | Verify against the PRD/REVIEW.md first; if still open, queue it and continue elsewhere |
| Same tool fails 2+ times | Switch strategy, don't brute-force |
| Security review finds new issues in the same component twice | Stop patching sanitizers and allowlists; restructure the component (tech plan § *Untrusted Inputs & Executing Paths*) |
| Unsure about platform capability | Say "I'm not sure, let me verify" — don't state as fact |

### Pause and Evaluate
| Condition | Action |
|-----------|--------|
| Unexpected complexity | Assess scope, consider asking |
| Breaking changes detected | Evaluate impact, may need input |
| Performance regression | Investigate, may need guidance |
| Security concerns | Always ask before proceeding |

### "Sequenced later" is NOT "blocked"

Distinguish a **soft sequencing preference you set** ("do the blog last", "warm outreach after polish") from a **hard external dependency** (missing API key, unmerged upstream PR, a gate that genuinely can't be evaluated yet). A self-imposed "later" is something you can revisit and propose to pull forward; it is not a blocker. When you find yourself idle because of a soft "later", **propose the next viable action** rather than reporting a block and waiting. (Found: agent reported "blog is blocked" and idled until the user said *"We're sitting here idle. Just answer."* — it had mistaken its own sequencing note for an external dependency.)

### How to Stop Gracefully

When stopping:

1. **Document current state**:
   - What was attempted
   - What failed
   - What was learned

2. **Update task status**:
   - Mark as "Blocked" or "In Progress"
   - Add blocker notes

3. **Create summary**:
   - Brief description of issue
   - What was tried
   - What's needed to proceed

## Name the Bottleneck — Don't Let Building Substitute for the Scary Work

Autonomous execution has a seductive failure mode: the agent's track is **always** productive. There is always more to build, refactor, document, or instrument. When a project has parallel tracks — "the agent builds infrastructure while the human does the hard manual thing (outreach, sales, recruiting users, a scary conversation)" — the agent can ship indefinitely while the metric that actually defines success stays at zero. The project *looks* productive (tasks closing, PRs merging) while nothing that matters moves.

**The check**: periodically ask *"is my buildable backlog outpacing the metric that defines success?"* If the infrastructure is largely done and the constraint is now the human's manual work, **say so plainly** instead of mining the backlog for more safe tasks:

> "The measurement infrastructure is ~90% built. The bottleneck is no longer engineering — it's getting real traffic through the funnel. Continuing to build is lower-value than unblocking that. What's blocking the outreach?"

Don't let an always-available build queue become a comfortable proxy for harder, scarier real-world validation. (Found: acquisition-engine — 10 weeks of measurement infrastructure shipped, exactly **one** acquisition channel actually run. The agent never surfaced that the bottleneck had shifted; the founder later named it: *"building felt safer than posting."*)

## Subagent Dispatch Hygiene (Multi-Agent / Shared-Workspace Execution)

When executing via dispatched subagents (implementer-per-task patterns) — especially in shared working directories (Conductor workspaces, git worktrees used by parallel sessions):

### Commit-surface verification (every commit-producing dispatch)

1. **Dispatch instruction**: every subagent that commits must stage **explicit paths only** (`git add <files>`, or at widest `git add -A <task-dir>`). Never `git add -A` / `git commit -am` at repo root — in a shared workspace, foreign uncommitted files (another session's WIP) get silently swept into the commit.
2. **Name the foreign files**: if the working tree contains uncommitted files from another session, list them in every dispatch prompt as never-stage.
3. **Controller verification**: before recording a task complete, verify the reported commit's `git show --stat --name-only <sha>` against the task's expected file surface. A commit touching files outside the surface is a **failed task** requiring history repair (amend + `rebase --onto` + force-push), not a bookkeeping note.

> Origin: 2026-07-07 agent-workforce retro — a fix-subagent's repo-wide staging swept another session's files into a commit; caught only at final whole-branch review, requiring history rewrite. Two prior shared-workspace incidents existed; per-incident recovery rules did not prevent the third.

### Reviewer context (plan-derived tasks)

When task briefs are derived from a design doc, give per-task **reviewers the design doc reference, not just the brief**. Plans narrow designs; implementers faithfully transcribe the narrower version; only a reviewer holding the design catches the fidelity gap. (Two contract gaps in the same retro were caught exactly this way; briefs alone would have passed both.)

### Conductor mode: resource budget (parallel subagents on one machine)

One conductor session directing N subagents, each in its own worktree with full dependency installs, shares one disk, one CPU, one Docker daemon and one account session limit. Budget them:

- **Pre-flight every wave**: `df -h` (each worktree with installed deps costs GBs), the account's remaining session allowance, the heavy lock's holder, and the number of workspaces running heavy work. Use the project's preflight script if it has one. Don't launch into a near-full disk, a near-spent limit, or a machine already at the heavy-workspace cap.
- **Waves of ≤4** full-install subagents, or staggered starts, and **at most 3 workspaces running heavy work at once on one machine** (across all sessions, not per session). (2026-10-05: eight Opus agents at once filled a 98%-full disk → Docker wedged → every pre-commit hook that needs local services failed → load average 570 → account session limit exhausted by noon; two agents died mid-task.)
- **One heavy step at a time, across the whole machine** — commit (runs hooks), push, `ci:local`, full suites, `npm ci`, Docker restarts, simulators, dry-runs that spawn Claude. **One lock path per machine**, outside every worktree, so all workspaces and sessions see the same lock (a later retro found six different "shared" lock folders in use, so none of them serialized anything). Prefer the project's lock script if it has one, ideally wired into its heavy npm scripts so nobody has to remember to wrap them. Otherwise a mkdir lock, held for ONE command, never across a CI wait:
  ```bash
  L="${HEAVY_LOCK:-$HOME/.agent-locks/heavy}"; mkdir -p "$(dirname "$L")"
  until mkdir "$L" 2>/dev/null; do sleep 20; done
  echo "<agent-name> $(pwd) $(date +%H:%M:%S)" > "$L/owner"
  # ... your ONE heavy command ...
  rm "$L/owner"; rmdir "$L"
  ```
  A lock dir older than ~25 min means its owner died: remove it and take it. Light work (reading, editing, one small test file, `gh` calls) takes no lock.
- **Local runs only the tests a change touches** when CI runs the full suite; the laptop is not a second CI. Review servers run from their own worktree, never one a suite is rebuilding.
- **Write the rules once** in a brief file every agent reads first (where to work, secrets, hooks, the lock, delivery steps); task prompts carry only the task. Rules repeated per prompt drift.
- **The brief also carries three rules from repeat incidents** (chef-chopsky, 2026-10-11 → 10-17):
  - **Two security-review rounds with new findings in one component → restructure, don't patch.** This is "after 2 failed attempts, switch strategies" applied to security. *(Seven review rounds across two features patched sanitizers and allowlists until the executor was rebuilt so no LLM had Bash.)*
  - **Never `git stash` in a shared or parallel workspace.** The stash stack is shared by every worktree and session. Set work aside with a WIP commit or a new worktree. *(`git stash push -- <file>` on an already-committed file creates no stash, so the captured SHA was empty, and `git stash apply $SHA` then applied another session's `stash@{0}`.)*
  - **Before adding a gate, block, or "skip if missing" behavior, check the founder's recorded preferences** (taste file, CLAUDE.md, agent memory). *(An agent made founder notes a gate for blog posts, "no notes → no posts"; the founder corrected it to additive, matching his recorded "metrics steer, never block" rule.)*
- **Delegate building from the first mockup round, and verify it yourself.** Option sheets, renders, prototypes and components are built by sub-agents with a written brief; the conductor holds the plan, opens every screenshot itself before anything reaches the founder, and banks judgment calls in `decisions-queue.md` instead of asking mid-task. In one project the mockups and prototype were built in the main agent, and the cost of discovery could never be measured.
- **Record main-agent and sub-agent tokens per stage** in `project-state.md` (its cost table): sub-agent tokens from each sub-agent result's usage, main-agent tokens from the harness (`/cost`, or the scheduler's measured run cost). Mark each figure measured or estimated, and write `unknown`, never `0`.
- **Packets carry `pending manager review`.** Subagents write the review verdict as pending; the conductor flips it to approved only after its own review, and the merge step refuses while any verdict is pending. A subagent never self-approves.
- **Proof runs are not side-effect free.** A unit test reached the real `gh`; a probe wrote a real PostHog insight; dry-runs mutated tracked runtime state files that were then committed, and the cron host's `git pull` refused. Block real external clients in test setup, and diff `git status` after any proof run before staging — runtime state never rides along in a commit.
- **Shared machine services belong to the conductor.** Docker, a local database, simulators: a subagent never quits, restarts or resets them. It probes, reports, and keeps doing light work with commits pending. A failing preflight means hold the heavy steps, not stop all work. Put these rules in the brief: a rule that lives only in the conductor's memory never reaches a subagent. (2026-10-14: a subagent quit a soft-locked Docker on a CPU-starved machine; nothing recovered until a reboot.)
- **Two sides of one contract need one integration run from the real starting state.** When parallel subagents build both sides of an interface (a command and its scheduler, a producer and its consumer), each side's own tests use its own fixtures. Before calling either done, run one end-to-end dry run on the real host, starting from exactly what a human creates (an empty project, a brief only). (2026-10-14: an overnight runner and the command it calls were both green; the runner read a file the command only creates on its first run, and every fixture already had it. A no-spend dry run on the real host found it.)
- **A lever proposed from a small sample carries its n.** Before recommending "X is the biggest lever" from fewer than about 30 observations, state the n and the interval, and frame it as a hypothesis to test. (2026-10-14: "pictures are the biggest lever" and "confidence ≥0.7 is right 9 of 11 times" both failed on re-run.)
- **Open each PR from the worktree that holds its commits**, before any `git checkout` back to a workspace branch (`/playbook:git-pr` Step 1).
- **Five rules from a one-day, five-PR batch** (chef-chopsky, 2026-10-20 → 10-21; `docs/learnings/2026-10-21-autonomous-quick-wins-batch.md`):
  - **Every sub-agent PR body carries `Closes #N`** for each issue it ships. Without it, 16 issues stayed open after five merges and were closed by hand.
  - **The conductor runs a code review (e.g. `/code-review <pr> medium`) on every sub-agent PR before marking it ready, and sends the findings back to the same sub-agent.** Three PRs produced 27 findings, several probed live on the branch (a signed-in user stuck on the login page, `rice≈ricotta` fuzzy matching, steps renumbered from 2); the sub-agents' own green suites had not caught them.
  - **A task that adds a new external text source feeding an LLM stage says so in its prompt and applies the untrusted-text gate up front** (closed vocabulary or templates for anything persisted into the stage's inputs, length and charset caps, a prompt line marking the fields as data). The background security review is the backstop, not the design.
  - **When a gate script refuses a PR the written policy would allow, diff the script against the policy before paying for another run.** A flat "merge-base > 24 h" rule cost a full CI run on a four-line CI fix the policy's own freshness clause permitted; it was the second time a gate script was stricter than its policy in two weeks.
  - **Draft → ready ordering:** after `gh pr update-branch` on a draft, let the draft's fast-CI run settle before `gh pr ready`, or the ready run's full eval is cancelled by the superseded one; then watch the executing eval run, not the one that reused a content hash.


- **Model choice comes from the project's model registry** (e.g. `docs/guides/model-strategy.md`: role → model alias, why, last evaluated, what evidence would change it). Name the role in every brief and pass its alias as the Agent tool's `model` parameter; **omitting `model` inherits the lead's model**, so a lead on the most expensive model silently spawns expensive sub-agents. Pick the model at session start: switching mid-session re-writes the whole cache at the new price. Aliases follow the newest model in a family, so an alias change is a silent promotion; the registry is re-evaluated (with evals, not taste) when new models ship. Without a registry, the default tiering: the strongest model for anything that edits code or docs, reviews, triages, or writes a packet; a mid-tier model (e.g. Sonnet) for mechanical work (log reading, data gathering, building triage tables); **no agent at all** for waiting (CI, deploys, humans: see Self-Resume rule 4). Fewer subagents (the waves rule above) saves more than cheaper ones.

## Quality Gates

### Pre-Commit Gates
Before each commit, discover and run project-specific validation (from CLAUDE.md / package.json):
- Discover: `ci:local` > `test:pre-push` > individual commands, plus the tests the change touches. Full suites (`test:verify`) belong to CI at ready, not to every commit
- If composite script exists (e.g., `npm run ci:local`): run it instead of individual commands
- Run with explicit Bash timeout (300000ms) if validation takes >2 minutes

At minimum verify:
- [ ] No skipped tests (.skip)
- [ ] No focused tests (.only)
- [ ] Linting passes
- [ ] Type checking passes
- [ ] Unit tests pass

### Pre-Phase Gates
Before proceeding to next phase:
- [ ] All phase tasks complete
- [ ] Phase validation passes
- [ ] Full test suite passes
- [ ] All pre-commit gates pass

### Pre-Completion Gates
Before marking project complete:
- [ ] All tasks complete
- [ ] All acceptance criteria met
- [ ] All tests passing
- [ ] No regressions
- [ ] Documentation updated
- [ ] Any merged PR carries a proof-of-completion comment — what shipped, evidence it works, what was deferred (`/playbook:monitor-pr` Step 4). Mandatory for autonomously merged PRs: merge authority is granted in exchange for this audit trail.

## Progress Tracking

### After Each Task

1. Mark acceptance criteria checkboxes
2. Add completion notes
3. Update task status
4. Update "Current Focus" to next task

### Metrics to Track
- Completion percentage (tasks done / total)
- Phase completion status
- Test coverage (maintain or improve)
- Quality gate status

## Troubleshooting Common Issues

### Tests Fail After Changes
1. Review test output for specific failures
2. Check if changes broke test assumptions
3. Verify test data/fixtures are correct
4. Run tests in isolation
5. Check if dependencies changed

### Quality Gates Block Commit
1. Read error message carefully
2. Fix the specific issue
3. Re-run checks locally
4. Don't bypass - fix root cause

### Unclear Acceptance Criteria
1. Review task description and context
2. Check tech plan for guidance
3. Review similar completed tasks
4. **Stop and ask** if still unclear

## Best Practices

### Code Quality
- Follow project standards and existing patterns
- Write tests when possible
- Keep changes small and focused
- Document decisions in completion notes

### Validation
- Validate early and often
- Run the touched tests on every change; the full suite once at ready, in CI
- Don't proceed if gates fail
- Verify acceptance criteria are actually met

### Progress Management
- Update status after every task
- Document learnings as you go
- Track blockers explicitly
- Celebrate completed tasks

### Communication
- Write clear completion notes
- Ask when stuck (don't waste time)
- Share learnings
- Be transparent about deviations

## Integration with Playbook

This skill supports:
- `/playbook:explore --unattended` - Discovery, one stage per run, to the next founder gate
- `/playbook:work` - Primary execution command
- `/playbook:tasks` - Task document management
- `/playbook:learnings` - Post-execution capture

## Success Criteria

Autonomous execution is successful when:
- [ ] All tasks complete
- [ ] All tests passing
- [ ] Quality gates pass
- [ ] No regressions
- [ ] Documentation updated
- [ ] Ready for review

---

*Autonomous execution requires discipline: validate often, stop when uncertain, document everything.*
