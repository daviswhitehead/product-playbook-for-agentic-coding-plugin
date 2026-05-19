---
name: playbook:monitor-pr
description: Monitor a PR's CI to green autonomously, iterating on failures with local-first fixes to minimize GitHub Actions minutes
argument-hint: "[optional: PR number — auto-detected from current branch if omitted]"
recommended-mode: auto-accept
thinking-depth: normal
---

# Monitor PR Until CI Passes

You are autonomously shepherding a pull request to all-green CI. **Cost discipline is the prime directive**: every push costs Actions minutes, so do as much validation locally as possible before triggering CI.

## Your Goal

Take a freshly opened (or just-pushed) PR and bring all CI checks to green — fixing failures along the way — while minimizing the number of remote runs.

## Cost Discipline (Read This Before Doing Anything)

The cost hierarchy of actions, cheapest first:

1. **Free**: read local code, read recent commits, read CLAUDE.md / project docs for CI semantics
2. **~Free** (API only, no Actions): `gh pr view`, `gh pr checks`, `gh run view --log-failed`
3. **Local CPU only**: `npm run ci:local` (or project equivalent)
4. **Free retrigger** (no new commit): `gh run rerun --failed <RUN_ID>`
5. **Expensive** (~12 min minimum): pushing a commit that triggers full CI
6. **Worst**: pushing a commit that fails CI again — wastes the run AND now the branch needs another fix

Rules that fall out of this hierarchy:

- **NEVER push without local validation passing first**. `npm run ci:local` (or project equivalent) must exit 0.
- **NEVER push an empty commit to retrigger**. Use `gh run rerun --failed` — it's free and re-runs only the failed jobs.
- **BATCH fixes** — if reading one failed log surfaces 3 root causes, fix all 3 in one commit, not three.
- **Demote-and-re-promote** for test-only / docs-only / lint-only fixes: `gh pr ready <PR> --undo` first so the next push runs fast-CI only (~8 min instead of ~25 min). Re-promote when ready for the full pipeline.
- **Read CLAUDE.md** for the project's specific CI semantics — draft-vs-ready behavior, path filters, `ci:full` labels, validation script names. They vary per repo and are load-bearing for cost decisions.

## Available Tools

- `/playbook:debug-ci` — invoke for systematic failure analysis when CI is red. Don't duplicate its logic; call into it.
- `gh` CLI — `pr view`, `pr checks`, `run view --log-failed`, `pr ready [--undo]`, `run rerun --failed`
- `ScheduleWakeup` (or the project's equivalent loop primitive) — for cache-friendly polling
- Project's local validation: `npm run ci:local`, `test:verify`, etc.

## Process

### Step 0: Inputs and Setup

1. **Determine the PR number**:
   - From the `[PR number]` argument if provided
   - Otherwise: `gh pr list --head $(git branch --show-current) --json number --jq '.[0].number'`
   - If still no PR found: report to the user, stop. (Maybe they meant to push first.)

2. **Verify `gh` is authed**: `gh auth status`

3. **Read CLAUDE.md / project conventions** for:
   - Local validation commands (`ci:local`, `test:verify`, etc.)
   - Draft-vs-ready CI behavior (fast CI vs full CI)
   - Path-filter rules (which heavy jobs are skipped under what conditions)
   - `ci:full` label semantics (sticky vs one-shot)
   - Forbidden patterns (e.g., "NEVER use `git push --no-verify`")

   These are non-negotiable per-project rules — internalize them before acting.

### Step 1: Snapshot Current State

```bash
gh pr view <N> --json statusCheckRollup,state,isDraft,mergeable,headRefOid
gh run list --branch <BRANCH> --limit 5 --json databaseId,name,status,conclusion,createdAt,event
```

Classify each check into one of:

| State | Action |
|---|---|
| `COMPLETED` + `SUCCESS` / `SKIPPED` / `NEUTRAL` | green — count it |
| `IN_PROGRESS` / `QUEUED` | waiting — go to Step 2 |
| `COMPLETED` + `FAILURE` / `CANCELLED` / `TIMED_OUT` | red — go to Step 3 |

If **all green and nothing waiting**: jump to Step 4 (terminal).
If **anything waiting and nothing red**: Step 2 (poll).
If **anything red**: Step 3 (fix) — even if other things are still running, start preparing the fix.

### Step 2: Poll at Cache-Friendly Intervals

Anthropic prompt cache TTL is 5 minutes. Sleeping past 300s pays a cache miss on the next wake-up. Pick intervals at natural breakpoints:

| Time remaining for the slowest in-progress job | Wakeup interval | Why |
|---|---|---|
| < 5 min | 270s | Stay in cache |
| 5–60 min | 1200–1800s | One cache miss buys a long wait |
| > 60 min | 3000–3600s | Worst-case cap |

**Don't poll faster than the slowest currently-running job's typical duration.** That's pure waste. Typical durations:

| Job type | Typical |
|---|---|
| Lint + typecheck + build | 2–4 min |
| Unit tests (frontend + agent) | 3–6 min |
| Integration tests | 5–10 min |
| E2E tests (per shard) | 5–15 min |
| Agent evals | 5–15 min |
| Vercel/Railway preview build | 3–8 min |

If you scheduled a 270s wakeup but the only in-progress job is Agent Evals (typically 10 min), you've burned cache for nothing. Pick the actual horizon.

### Step 3: Triage and Fix Failures

**Pull ALL failed logs first** before forming any hypothesis. Sharded `fail-fast: true` workflows often have multiple distinct failures masked by the first one:

```bash
# List all failed jobs across all recent runs on this branch
gh run list --branch <BRANCH> --limit 5 --json databaseId,conclusion,name \
  --jq '.[] | select(.conclusion == "failure") | "\(.databaseId) \(.name)"'

# Pull each failed-job log to a file
gh run view <RUN_ID> --log-failed > /tmp/failed-<RUN_ID>.log
```

Read each log end-to-end, not just the first error.

#### 3a. Triage (delegate to `/playbook:debug-ci` Step 0)

For each failure, classify:

- **Is the failure related to this PR's changes?** `git diff --name-only origin/<base>...HEAD` — if the failing test/file isn't in the diff, it's likely flaky or pre-existing.
- **Is it a known flaky test?** Search project docs for the test name; check recent CI history (`gh run list --status failure --limit 20`).
- **Is it an environment/infra issue?** Rate limits, network blips, secret-rotation timing, etc.

If the failure is **flaky** or **unrelated to this PR**: do NOT push a fix to this PR. Rerun with `gh run rerun --failed <RUN_ID>` (free) and surface the flake to the user for separate triage.

#### 3b. Reproduce Locally

- Run the SPECIFIC failing test locally with the same arguments CI used.
- If it passes locally, look for env differences: Doppler/secrets, Node version, OS, FS case-sensitivity, time zone, locale.
- If you can't reproduce locally AND it's a one-off failure on a normally-stable test: re-run with `gh run rerun --failed`, NOT a new commit.

#### 3c. Fix Root Cause, Not Symptom

Per CLAUDE.md "Structural Solutions Before Visual Patches": analyze the root cause before patching. A test timeout is rarely fixed by increasing the timeout; a flaky test is rarely fixed by adding a retry. Find the actual race / state leak / wrong assumption.

#### 3d. Validate Locally (NON-NEGOTIABLE)

Before pushing:

```bash
npm run ci:local    # or the project's equivalent — must exit 0
```

If the failure was specifically E2E or integration, also run that test class locally:

```bash
npm run test:e2e      # or the project's equivalent
npm run test:integration
```

If `ci:local` is still red, you have not fixed the problem. Do not push.

#### 3e. Push Minimal Commit

- Stage only the fix files (not the whole working tree).
- Use Conventional Commits (`fix:`, `chore:`, etc.).
- One logical fix per commit when possible.
- Push and return to Step 1.

### Step 3.5: Demote-and-Re-Promote (Test-Only / Docs-Only Fixes)

If your fix is **test-only, docs-only, or lint-only** AND the PR is currently non-draft, demote first:

```bash
gh pr ready <PR> --undo   # → next push runs fast-CI only (~8 min)
git push
# wait for fast-CI to pass via Step 2 polling
gh pr ready <PR>          # → re-promote, fires full CI for final confidence check
```

This saves ~17 min per iteration. **Do NOT use this for behavioral code changes** — bypassing integration/E2E on real code is technical debt and the user has explicitly forbidden it in many projects (check CLAUDE.md).

### Step 4: Terminal State — All Green

When `gh pr view --json statusCheckRollup` shows 0 non-success/skip checks:

1. **Confirm** `mergeable: MERGEABLE` and `state: OPEN`.
2. **Check the user's original prompt** for "merge ready" or "ready to review" language. If present and `isDraft: true`, run `gh pr ready <PR>` and wait for the full-CI run that triggers.
3. **Report back** with:
   - PR URL
   - Number of iteration commits added during monitoring (0 is the ideal)
   - Estimated Actions minutes consumed (runs × typical durations)
   - Whether `isDraft` is now false (relevant if user said "merge ready")
   - Confirmation it's ready to merge (and if user pre-approved, run `gh pr merge --squash --delete-branch`)

### Step 5: False-Green Sanity Check

Before declaring victory, verify that **path-filtered heavy jobs actually ran on the same head commit** as the fast-CI passes. Per CLAUDE.md's documented learnings on path-filtered false-greens:

- If only `frontend/**` changed → confirm Frontend E2E ran on this head SHA, not a previous one
- If only `agent/**` changed → confirm Agent Evals + Agent Integration ran on this head SHA
- If a "fix commit" only touched test files → confirm the heavy jobs ran AGAINST that commit, not the prior code commit (this is the documented false-green class)

```bash
gh run list --branch <BRANCH> --limit 10 --json headSha,name,conclusion \
  --jq '.[] | "\(.headSha[0:8]) \(.conclusion) \(.name)"'
```

If a heavy job's `headSha` doesn't match the PR's `headRefOid`, that "green" is a false green — re-push or rerun against the current head.

## Anti-Patterns (Don't Do These)

| Anti-pattern | Why it's wrong |
|---|---|
| Polling every 60s when the longest in-progress job is ~10 min | Burns prompt cache and your context for no signal |
| Pushing without `ci:local` passing | "Hope CI catches it" wastes a full run on a 5-second local check |
| Empty-commit retrigger | `gh run rerun --failed` is free and re-runs only the failed jobs |
| One commit per failure across multiple distinct failures | Read all logs first; fix together |
| `git push --no-verify` | Bypasses the local quality gates that are there for a reason. CLAUDE.md typically forbids this; never use it without explicit user approval. |
| Declaring victory on path-filtered greens | A fast-CI green on a no-code-change commit doesn't validate the actual code change. Confirm heavy jobs ran on the current head. |
| Adding `ci:full` label and then a docs commit on top | Wastes a full-CI run on a docs change. Demote-and-re-promote instead. |

## When to Escalate to the User

- **3+ failed push iterations on the same root cause** — you have the wrong mental model; ask before continuing.
- **A failure that introduces a new flaky test** — capture for project docs / `/playbook:learnings`, don't just rerun until it passes.
- **Actions minutes consumed exceeds 2× the typical PR budget** (e.g., 5+ full-CI runs on a normal PR) — surface the cost so the user can choose to abandon.
- **A failure that fundamentally changes the PR's scope or design** — get user input before reshaping the PR.

## After Completion

Suggest `/playbook:close` for session close-out. If any non-obvious failure modes surfaced (especially flaky or path-filter-related), suggest `/playbook:learnings` to capture them — these are the most expensive class of CI lessons because they repeat across PRs.

---

## Usage Pattern

The most common invocation, right after `/playbook:work` or `/playbook:create-pr` completes:

```
/playbook:monitor-pr
```

(No arguments — auto-detects PR from current branch.)

When monitoring a specific PR:

```
/playbook:monitor-pr 283
```

Combine with `/loop` for true autonomous operation across CI's long-tail timelines:

```
/loop /playbook:monitor-pr
```

This re-invokes the command at each `ScheduleWakeup` until the PR is green.
