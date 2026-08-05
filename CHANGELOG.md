# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.26.1] - 2026-08-04

### Fixed
- **`/playbook:merge-prs` Step 4: `.git/info/exclude` fails inside a git worktree** — The
  snippet ran `mkdir -p .git/info`, which assumes `.git` is a directory. In a worktree
  (Conductor workspaces, `git worktree add`) `.git` is a **file** containing a `gitdir:`
  pointer, so the command aborts with `Not a directory` and the plan file is never excluded
  — leaving the working tree dirty, which is itself one of the two triggers for
  `gh pr merge --delete-branch` half-failing.

  Now resolves the path with `git rev-parse --git-common-dir` and verifies with
  `git check-ignore`. Common-dir rather than `--git-dir` because `info/exclude` lives in the
  common directory, shared across worktrees — which is also where git actually reads it from.

  Found on the command's first real run, in exactly the environment it was written for.

## [0.26.0] - 2026-08-04

### Added
- **`/playbook:merge-prs` — autonomous open-PR backlog clearing** — The capability had been
  exercised twice by hand (4 PRs in 2026-07, 9 PRs in 2026-07-26) with the procedure split
  across three places that nothing composed: `/playbook:monitor-pr` owned the per-PR merge
  mechanics, CLAUDE.md held the stacked-bump ordering as prose, and a learnings doc held the
  evidence. Every run re-derived the orchestration.

  The command triages every open PR (including drafts — draft status is frequently neglect,
  not intent), classifies each **MERGE / FIX-THEN-MERGE / SKIP / ESCALATE** with a stated
  reason, orders the queue, then presents **one merge plan for one approval**. After that
  gate it runs unattended. All human judgment is spent once, up front, where it belongs;
  what follows is mechanical and long-running.

  Design points that came from the two hand-run sessions:
  - **Skip, don't halt.** A PR that breaks its triage assumptions mid-run is skipped and
    reported; the remaining approved PRs still merge. Forfeiting eight good merges because
    the fourth developed a conflict is the failure mode this prevents.
  - **The plan file must not dirty the working tree.** A dirty tree is one of two known
    triggers for `gh pr merge --delete-branch` half-failing and leaving the remote branch
    alive. The plan goes to `docs/merge-plans/` with the path added to `.git/info/exclude`
    (local, uncommitted, works in any git repo), and Step 5 asserts a clean tree before each
    merge.
  - **Version-guard machinery is detected, not assumed.** Sequential stacked bumps are
    specific to repos with a version guard; the command looks for one and skips the whole
    layer when absent.
  - Worktree-aware branch claiming, and branch deletion verified with `git ls-remote` rather
    than assumed.

  It delegates per-PR CI work to `/playbook:monitor-pr` (which delegates failure analysis to
  `/playbook:debug-ci`) rather than reimplementing either.

### Fixed
- **Command-surface drift, at the root cause** — Six real commands (`close`, `close-project`,
  `emergent`, `foundations`, `monitor-pr`, `research-synthesis`) were missing from
  `commands/help.md`, and four were missing from README's command tables. A command nobody
  can find is worth nothing regardless of how good it is.

  Root cause: both files hand-duplicate data that already lives in each command's
  frontmatter, and adding a command has no step that touches either file. `validate-plugin.sh`
  now enforces coverage **bidirectionally** — every command must appear in help.md and as a
  README table row, and every `/playbook:x` referenced in help.md must resolve to a real
  command. `plugin-guard.yml` already runs that script on every PR, so an unlisted command is
  now unmergeable.

  Generating help.md from frontmatter was considered and rejected: its value is the human
  judgment about which command fits which situation, which no frontmatter field encodes.
  Enforce coverage, leave the curation alone.

  Notes: the README check requires a **table row**, not a prose mention — `close-project` was
  named in README prose while absent from every table. The help.md check uses a `(?![\w-])`
  lookahead so `/playbook:work` is not considered covered by `/playbook:work-multiple`. And
  the coverage report is written to a temp file rather than captured through `$(...)`, because
  bash 3.2 (still macOS's default `/bin/bash`) mis-parses a heredoc containing apostrophes
  inside command substitution.

- Content backfill: help.md gains the six missing commands plus `help`/`hello`, new
  **Strategy Foundations**, **Close-Out**, **Pull Requests**, and **Meta** categories, and a
  "Clearing a PR Backlog" workflow recipe. README gains `close-project`, `emergent`,
  `monitor-pr`, `hello`, and a Pull Request Commands table.

## [0.25.2] - 2026-07-29

### Added
- **`/playbook:learnings` — guidance for autonomous invocation** — Every facilitation gate in the workflow assumes a human is present: Step 1 asks the trigger type, Steps 6 and 9.1 ask for batch approval, Step 10 Part B asks the user for process observations. Invoked autonomously (a cron, a delegated subagent, or a user saying "run it autonomously"), those gates have no one to answer them.

  The failure mode is **silent degradation, not an error**: the agent skips the question, picks a default nobody chose, and still reports success — the same "documented but never decided" pattern the workflow exists to prevent. Step 10 Part B is the worst case, since it's pure user input and historically produces the highest-value improvements.

  New section prescribes: answer each gate in writing with reasoning rather than skipping it; default to executing anything reversible and refusing anything that isn't; ship as draft PRs so the PR *becomes* the deferred approval gate; mine the session's earlier user redirections in place of Part B's questions; and state plainly in the summary which gates were auto-answered. An autonomous run that reads identically to a facilitated one is hiding the decisions it made on someone's behalf. (Found 2026-07-29, chef-chopsky, running this workflow autonomously.)

## [0.25.1] - 2026-07-29

### Fixed
- **`/playbook:close` Phase 3 — step 4's archive silently untracks `latest.md`, flipping the staging decision** — `docs/checkpoints/latest.md` is normally *tracked*, so an early `git ls-files --error-unmatch` correctly reports "tracked, a plain `git add` works." Then step 4's `git mv` renames it, and the `latest.md` written afterwards is a **new, untracked** file at an ignored path. The correct branch flips mid-phase, and the earlier check is stale exactly when it's consulted.

  Because `git add` aborts the *whole* invocation when any path is ignored, the already-staged rename then commits **alone** — yielding a "session checkpoint" commit containing the archive and not the handoff, with a clean exit code. The close-out reports success while the actual handoff sits untracked, one `git checkout` from deletion. (chef-chopsky, 2026-07-29.)

  Phase 3 step 6 now says to run `git check-ignore` on the file immediately before staging, and to verify the commit contains **both** files via `git show --stat HEAD` rather than trusting the exit code. Also clarifies that a repo with an ignored `docs/checkpoints/` but tracked checkpoints is the normal case — `.gitignore` never applies to already-tracked files — so force-adding there *restores* the repo's convention rather than overriding it, and doesn't warrant the "ask first" treatment.

## [0.25.0] - 2026-07-29

### Added
- **`SessionStart` hook — orientation without needing to be invoked** — The `session-start-status` skill exists because agents burn 10–30K tokens per session re-discovering the same context. But a skill only runs when someone remembers to invoke it, which makes "orient at session start" a suggestion rather than a behavior. `hooks/hooks.json` now runs `scripts/session-orientation.sh` unconditionally, gathering the deterministic half — branch and tracking state, uncommitted count, active `projects/in-progress/` dirs, latest checkpoint, last 3 commits, and any stashes tagged to this branch — with zero tool round-trips.

  It surfaces stashes because that is how work actually gets lost: every commit is pushed, the branch reads clean, and the stash goes with the archived worktree.

  Constraints, since this runs for every user in every session: fast (cheap git plumbing only), bounded (hard caps; 5 lines in practice), silent when irrelevant (no git repo, or no `projects/` and no `docs/checkpoints/` → prints nothing), and it always exits 0 so it can never fail a session. Opt out with `PLAYBOOK_NO_ORIENTATION=1`. The skill now defers to it and covers only the judgment half.

- **`scripts/verify-close-project.sh` — the assertion that was missing** — `/playbook:close-project` Step 7 asked *"Project lives under `projects/done/[name]/`?"*. That was **true** during the failure it should have caught: `forgot-password` and `illustration-batch` were copied rather than moved, so they existed in **both** `in-progress/` and `done/` for ~3.7 months with every checklist item passing.

  The missing assertion was never "did it land" but **"is the source gone"**. Step 7 is now a script that asserts it, plus no living references to the old path, the close-out artifact, and (best-effort, via `gh`) that merged PRs carry a proof-of-completion comment. A prose checkbox cannot catch this class, because the agent answering it is the same one that just performed the move.

- **Hook validation in `validate-plugin.sh`** — hooks are the one component that runs in every session without being invoked, so a malformed one degrades every session silently. The validator now checks `hooks.json` parses, and that every `${CLAUDE_PLUGIN_ROOT}` script exists and is executable. Verified to fail on all three (missing script, non-executable, bad JSON), not just to pass when healthy.

- **`scripts/test-close-project-checks.sh`** — 14 cases across both scripts, asserting both directions. The load-bearing case reproduces the exact 3.7-month bug shape and requires the checker to fail on it.

## [0.24.9] - 2026-07-29

### Fixed
- **`gh pr create` examples now pass `--draft` everywhere** — `/playbook:git:create-pr` has always documented draft-by-default, with an explicitly labelled non-draft exception. But three other places showed the bare form: `improve-playbook.md` (a copy-pasteable code block), `learnings.md` ("Use `gh pr create`"), and `work.md`'s flow diagram. An agent following any of those got a non-draft PR while believing it was following the playbook.

  This matters more than a style nit because of what a non-draft PR *silently skips*. In a tiered-CI repo, `ready_for_review` is a **one-shot** trigger — a PR born non-draft never fires it, so integration/E2E/eval jobs stay SKIPPED and the PR reads green having tested almost nothing. (chef-chopsky PR #294 sat six weeks that way, green, with agent evals SKIPPED the whole time.) The failure is invisible at exactly the moment you're most inclined to trust it.

  The labelled exception in `create-pr.md` is intentionally left alone. (Found 2026-07-29 while auditing whether a new `PreToolUse` guard that denies non-draft `gh pr create` would break existing playbook tooling.)

## [0.24.8] - 2026-07-27

### Fixed
- **`scripts/check-version-bump.sh` green-lit a version *regression*** — The guard that exists to protect version-keyed propagation compared versions with a string inequality (`cur != base`), so **any** change passed, including a decrease. It printed `OK: product-playbook-for-agentic-coding bumped 0.24.7 -> 0.23.0` and exited 0 — calling a seven-release regression a "bump".

  Not hypothetical: open PR #74 (a duplicate of the already-merged #59) carried content identical to `main` plus `"version": "0.23.0"`. CI was the only thing between it and `main`, and CI would have been green. It was caught by judgement, not by the guard built for it.

  A backwards version is worse than an unbumped one: installs already on the higher version stop updating until the number climbs back past that high-water mark, a stall that outlasts the offending PR and is invisible from the repo.

  Now uses a semver-aware comparison that fails closed on malformed or empty input, with a distinct `version went BACKWARDS` message naming the consequence. **Negative-tested in both directions**: 8 unit cases (including `0.10.0 > 0.9.0`, which a string sort gets wrong) and 4 end-to-end runs — backwards → exit 1, unchanged → exit 1, forward → exit 0, no-change → exit 0.

### Added
- **`/playbook:monitor-pr` — two mandatory checks before bulk-deleting branches** — (1) Deleting a branch closes its open PR, so re-derive the open-PR list *at delete time*, never from a list built earlier in the session. (2) Judge "merged" on **content, not ancestry** — squash-merge discards the branch's commits, so `git branch --merged` and `merge-base --is-ancestor` misreport in both directions.

  Both fired in one 25-branch sweep (2026-07-27): the content check flagged two branches ancestry called deletable, and both had PRs opened mid-session; a third held the only complete copy of a file `main` had truncated — and only in its *local* ref. Also notes to check whether a local branch is ahead of its remote before deleting the remote.

## [0.24.7] - 2026-07-27

### Added
- **`tasks` template — time-based gates state the evidence they're waiting for, not just a duration** — A gate written as "watch metric X for N hours" is really a *sample-size* gate wearing a clock. At low traffic the information value saturates long before the duration expires; at high traffic the clock can expire before enough samples arrive. Either way the number inherited from the plan stops tracking what the gate is actually for.

  Watch windows are now written as `[N hours] OR [the evidence] — whichever arrives first`, with the evidence named up front (e.g. "one full token-refresh cycle past the last pre-change session + ≥K post-change logins with 0 error events"). Early closure requires that stated evidence plus the gate owner's sign-off, and the decision line now records the rationale whenever the window deviates from its stated duration — in either direction. (Single-domain cutover, 2026-07-27: a 48h auth watch saturated in ~12h at 2-users/week scale.)

## [0.24.6] - 2026-07-27

### Added
- **`/playbook:close` step 4 — freshness check before claiming `latest.md`** — Step 4 previously only asked *whose* the existing checkpoint was; it never asked *when* it was written. In a multi-session workspace `latest.md` can hold a **newer** session's handoff than the one being closed, and overwriting the freshest handoff with an older-scoped one is backwards. Now compares the existing checkpoint's `**Date**:` against the closing session and, when the existing one is newer, writes the closing session's checkpoint as a dated archive and leaves `latest.md` alone. `latest.md` should be the most recent handoff for the workspace, not the most recently *written* one. (chef-chopsky, 2026-07-25: closing a 7/08–7/20 arc found a 7/25 checkpoint from a successor thread.)

  The `ALREADY_ARCHIVED` branch of the 0.24.2 tri-state check now points at the freshness check explicitly — "archived somewhere" does not imply "older than you", so a newer handoff could otherwise be archived *and* overwritten.

## [0.24.5] - 2026-07-26

### Fixed
- **`/playbook:monitor-pr` Step 4 — the `--delete-branch` half-fail isn't worktree-specific** — 0.24.4 (one version earlier, same session) described the trigger as "another worktree holds the PR branch". Too narrow: **any** failure in gh's post-merge local cleanup produces the same half-fail, leaving the remote branch alive. A second trigger was hit immediately — a **dirty working tree**, which blocks the switch to the default branch (`Please commit your changes or stash them before you switch branches. Aborting`).

  Found while merging PR #69, the very PR that corrected this note: its own merge hit the new trigger. Running total is 4 occurrences, of which 3 were the worktree case and 1 the dirty-tree case.

  Step 4 now lists both triggers with their distinct error messages and instructs treating *any* non-empty error from `gh pr merge --delete-branch` as "the remote branch probably survived — verify", rather than pattern-matching one message.

## [0.24.4] - 2026-07-26

### Fixed
- **`/playbook:monitor-pr` Step 4 stated a false fact about `gh pr merge --delete-branch`** — The note claimed that when another worktree holds the PR branch, the local-delete failure is "harmless (the remote branch is still deleted)". It is not: the operation deletes **neither** branch, ending with the remote branch alive. Because the PR *is* merged, the error reads as cosmetic and gets walked past.

  The wrong version was load-bearing — it explicitly told you the check was unnecessary, so the surviving branch was never noticed. A missing rule would have left normal curiosity intact. This is the "Is every rule still TRUE?" check added in 0.24.0 landing on the playbook's own documentation.

  **Verified in both directions in one session** (gh 2.88.0): 6 merges where `--delete-branch` succeeded left 0 remote branches; all 3 merges that hit the worktree error left the remote branch alive, each needing a manual `git push origin --delete`. Confirmed with `git ls-remote --heads` after `git fetch --prune`, not the local `git branch -r` cache.

  Step 4 now carries the corrected behavior, a verification snippet, and the repo-level fix that makes the failure mode moot: `delete_branch_on_merge: true` ("Automatically delete head branches") deletes the head branch on every merge, including web-UI merges. An audit of this repo — which has the setting `false` — found 24 stale remote branches from merged PRs going back to 2026-04, though most stem from merges that never passed `--delete-branch` at all rather than from the gh bug itself.

### Changed
- **`docs/learnings/2026-07-17-merging-stacked-prs-across-worktrees.md`** — dated second-incident addendum correcting Learning #3 (the origin of the false claim), with the evidence table, both root causes separated, and the systemic repo-level fix.

## [0.24.3] - 2026-07-26

### Changed
- **CLAUDE.md size thresholds lowered to match published guidance, and a line check added** (`/playbook:learnings` pre-check + Step 6 backstop, `learning-capture` skill) — was 32,000 / 40,000 chars with no line check; now **16,000 chars or 200 lines** (soft) and **24,000 chars or 300 lines** (hard, mandatory trim), whichever trips first.

  **Lines are the cited number; the char figures are an explicitly derived companion.** Anthropic's docs state: *"target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence."* HumanLayer treats 300 lines as a hard ceiling (their own root CLAUDE.md is under 60). The char figures assume ~80 chars/line, which holds for prose-heavy files and is far off for terse bullet lists — this plugin's own CLAUDE.md averages ~32 chars/line, so its line count binds long before its char count. The doc now says so plainly rather than presenting both as equally sourced.

  The two thresholds measure different failure modes and both are kept deliberately: lines ≈ instruction count (adherence), chars ≈ context cost. Frontier models follow roughly 150–200 instructions consistently and Claude Code's own system prompt already occupies ~50 of those slots, so instruction count is usually the binding constraint — which is why the old char-only check could pass a file already carrying several times the targeted instruction count.

- **Promotions past the soft limit follow "one in, one out"** — each new CLAUDE.md rule names a demotion or deletion candidate in the same edit.

**Note for existing projects**: this materially tightens the gate. A CLAUDE.md near the old 40,000-char ceiling is roughly 16,000 over the new hard limit, so the next `/playbook:learnings` run in such a repo will require trimming before it can promote anything. That forcing function is the intent, but it lands immediately.

## [0.24.2] - 2026-07-26

### Fixed
- **`/playbook:close` step 4 — the archive-detection check never actually ran** — The one-liner shipped in 0.23.5 interpolated the checkpoint's `**Branch**:` line straight into `grep` as a *regex*. A leading `**` is an invalid repetition operator, so BSD `grep` (the macOS default) aborts with `repetition-operator operand invalid` on **every** invocation — the check that exists to stop another workspace's handoff being overwritten has never once detected an archive. Replaced with a tri-state block printing exactly one of `NO_EXISTING_CHECKPOINT` / `ALREADY_ARCHIVED` / `ARCHIVE_REQUIRED`, using `grep -rlF --` (literal compare, and `--` guards a pattern starting with `-`) and matching the `**Branch**:` line by pattern instead of a hardcoded `sed -n '3p'`.

  Two further defects in the same one-liner, both now closed:
  - **Empty output was overloaded three ways** — "no `latest.md` at all", "exists but unarchived", and "the command errored" were indistinguishable, and the doc read all three as "rename it first". On a first-ever close-out that means `git mv` on a nonexistent file (`fatal: bad source`, exit 128).
  - **A blank line 3 produced an empty grep pattern, which matches every file** — reported as "already archived" and green-lit overwriting an irreplaceable handoff. This is the data-loss path the step was written to prevent, reachable whenever the checkpoint's line 3 happens to be blank.

  **Negative-tested in both directions** against four fixtures (no `latest.md`; unarchived; already archived; blank line 3 alongside an unrelated archive). The old form is wrong in all four — silent, fatal-erroring, fatal-erroring, and falsely "already archived" respectively; the new form returns the correct state in all four. Per the "negative-test every guardrail" rule added in 0.24.0.
- **Step 6 stages an explicit file list, never the directory** — `git add -f docs/checkpoints/` force-commits everything the repo deliberately ignored (other workspaces' checkpoints, local scratch state) under a "session checkpoint" label — step 4's clobbering failure in the opposite direction. Now uses a `CKPT_FILES` array that also carries any archive step 4 created, so the file just rescued doesn't stay untracked under an ignored path. Force-adding overrides a deliberate repo decision, so the step now says to **ask** rather than defaulting to it.
- **`git mv` caveat** — plain `mv` when the checkpoint isn't tracked, which is the common case under a gitignored path; `git mv` on an untracked file fails with "bad source".

## [0.24.1] - 2026-07-26

### Added
- **`/playbook:learnings` Step A2 — check whether the fix already exists, unmerged, before writing one** — The plugin track never asked this. The "'implemented' means MERGED, not written" rule already covered the codebase, but never pointed at the plugin repo — so a finding whose fix was already sitting in an open PR would get a duplicate written for it. A fix in an unmerged PR still produces the bug in every session, which is exactly why it reached the retrospective. Now greps unmerged branches, open PRs, and uncommitted WIP, and routes on the result: comment on the existing PR with the independent reproduction (a second real occurrence is the strongest argument for merging it) rather than duplicating; open the PR when a fix exists on a branch without one; **surface uncommitted WIP as at-risk, don't commit it** — it's likely another session's in-flight work. Also instructs using `git worktree add` rather than switching branches when the plugin checkout is dirty. Found by running `/playbook:learnings` on a real incident retro that hit two `close.md` bugs already fixed in open PR #61.

### Changed
- **`/playbook:learnings` CLAUDE.md size gate — trim to a budget, not to the limit** — The retrospective's own promoted content counts against the 40k ceiling, so trimming to 40,000 is trimming to failure; the target is `40,000 − addition − headroom`. Landing at 39,985 (15 chars of headroom) is a failed trim dressed as a pass. Also: re-measure after every edit, and expect condensing rewrites to *increase* size — rewriting a section "tighter" while folding in new content commonly nets positive, so a real trim means deleting or demoting, not rephrasing. Once two consecutive edits stop moving the number, demote a whole section to `docs/guides/` rather than nibbling at prose.

### Fixed
- **Step A2's own unmerged-fix query was a fatal parse error** — `git log --oneline origin/main..--all` exits with `fatal: bad revision 'origin/main..--all'`, so the check this step exists to perform would never have run. Corrected to `git log --oneline --branches --remotes --not origin/main`, which also avoids bare `--all` dragging in agent-harness checkpoint refs (Conductor writes hundreds per session). Verified by running both forms.

## [0.24.0] - 2026-07-26

### Added
- **`autonomous-execution` — "Negative-test every guardrail you add"** — promoted from an instrumentation-only acceptance criterion to a general principle covering ANY guard: lint rules, CI jobs, hooks, schema audits, quality gates, assertion helpers. A guard must be run twice — positive, and against the broken input it exists to catch — and seen to fail with an actionable message. Also warns about guards that become *unsatisfiable* by inheriting a production filter that removes their own fixture. Mirrored as a checkbox in the `tasks` template's Completion Verification.

  This rule was written down after a 2026-05-16 incident (a CI guardrail that never fired) and lived **only in a retrospective for two months** — so the next two guardrails repeated it, including one in the same session that produced this change. Documentation had already failed twice; this puts it in the workflow.

### Changed
- **`/playbook:learnings` demotion checklist — "Is every rule still TRUE?"** — trimming CLAUDE.md previously only looked for *resolved*, *niche*, *duplicated*, or *stale-milestone* content. It never asked whether a rule was still factually correct. Found 2026-07-25: CLAUDE.md told agents to add new E2E specs to Playwright's `testMatch`, but the config had become a deny-list where specs enroll automatically — an actively misleading rule costing context in every session. A wrong rule is worse than a missing one; delete rather than demote.
- **`/playbook:learnings` — trimming safety note** — back up CLAUDE.md before `git checkout -- CLAUDE.md`; it restores from the index and silently discards unstaged trims (hit during the 2026-07-25 retro, costing a full redo).

## [0.23.5] - 2026-07-26

### Fixed
- **`/playbook:close` Phase 3 — stop the checkpoint step from destroying handoffs** — Two failure modes, both hit in a real run (chef-chopsky, 2026-07-25) and independently reproduced a second time on 2026-07-26:
  - **New step 4 archives the existing `latest.md` before writing over it.** In a parallel-agent repo (Conductor workspaces, git worktrees) `latest.md` frequently holds *another workspace's* handoff; overwriting destroys work that isn't yours, silently and unrecoverably. Rename it to a dated archive unless it's demonstrably yours or already archived.
  - **Step 6 re-verifies the branch and force-adds when the path is gitignored.** `docs/checkpoints/` is frequently ignored as "local resume state", in which case plain `git add` stages nothing, `git commit` reports nothing to commit, and the close-out reports success while the handoff exists only as an untracked file — which the next `git checkout` deletes with no reflog entry. `git check-ignore` must test the *file*, not the directory (a `docs/checkpoints/` pattern does not make `check-ignore` on the directory return true, even though `git add` on it refuses). Phase 1's branch check is also re-read here, since another agent can switch branches while you're waiting on tools.
- **Phase 5 summary** now reports where the checkpoint actually landed (committed `<sha>` / left local because the path is gitignored) and any prior checkpoint archived, instead of unconditionally claiming "Saved to docs/checkpoints/latest.md".

## [0.23.4] - 2026-07-26

### Added
- **Proof-of-completion comment at every PR merge** — Canonical requirement in `/playbook:monitor-pr` Step 4: every PR (especially autonomously merged ones) gets a comment posted at merge time with (1) what shipped in plain language, (2) evidence it works (test output, green full-CI run link, SQL/API verification for schema/data changes, screenshots for UI), and (3) what was consciously deferred or overridden, with a pointer to where it's tracked — "nothing deferred" is a valid entry, silence is not. Autonomous merge authority is granted in exchange for this reviewable audit trail; green CI alone is not reviewable evidence. Referenced with one-liners from `/playbook:git:create-pr`, `/playbook:work`, `/playbook:work-multiple`, `/playbook:close-project`, the `delivery-agent`, and the `autonomous-execution` skill.

## [0.23.3] - 2026-07-25

### Added
- **`/playbook:debug` Step 3.1 — reproduce in the REAL execution context, not a simulation** — When the failure occurs under cron, CI, launchd, a container, or any headless/scheduled runner, reproduce it *there* (a temporary `* * * * *` cron entry writing to /tmp, a scratch CI job) — not in an interactive shell. Interactive shells and `env -i` simulations inherit session properties that env vars don't capture (macOS keychain access, GUI session state, credential helpers) and will false-pass; a fix "verified" only in a simulation is unverified. (2026-07: a Claude CLI keychain failure under cron passed every GUI-shell test for weeks; a real-cron test reproduced it in one minute.)

## [0.23.2] - 2026-07-25

### Added
- **`/playbook:debug` Step 3 — probe the running system before blaming configuration** — When a hypothesis implicates external config (OAuth client, DNS record, CDN rule, IAM policy, feature flag), find the single request that would return a different answer if the thing were configured correctly, and make it. Reading the repo tells you what *should* be true; the live service tells you what *is*. Includes verifying *which instance* you're talking to, and a hard rule: never hand a human step-by-step instructions to change external state on the strength of a config-file reading. (chef-chopsky, 2026-07-25: a `redirect_uri_mismatch` was root-caused from repo config and the user was walked through a Google Cloud Console change that was already correct — the preview pointed at a different Supabase project. A ~5-second probe of the live authorize endpoint disproved it, run only after the user pushed back with a screenshot.)
- **`/playbook:debug` Step 3 — treat never-executed paths as unimplemented** — A `catch`, retry, or fallback branch you have never watched run is untested code whatever it looks like; if a diagnosis depends on one having worked, make it fire once and read the output. (Same session: a CI fallback posted to a URL that had always 404'd, hidden behind a poll-count guard and a `::warning::` on a green job.)

### Changed
- **`/playbook:learnings` demotion checklist — try de-duplication first** — New first item: if a CLAUDE.md block restates an existing `docs/solutions/` or `docs/guides/` doc, condense it to a one-line pointer. It deletes duplication rather than knowledge, and usually frees enough budget to land the new rule in the same edit, so the trim/defer/skip decision never has to be surfaced. Also adds: grep for a CLAUDE.md heading before renaming it — other docs cite rules by heading text.

## [0.23.1] - 2026-07-25

### Added
- **`mobile-debugging` — Step 0 gate: verify the bug is actually mobile-specific** — Before any device-specific investigation, reproduce in a plain desktop browser at multiple viewport widths (e.g. 412px and 1440px). "Reported on a phone" says where someone *looked*, not where the bug *exists*; layout leaks, overflow bugs, and unstyled-content flashes are frequently universal and merely more prominent on a narrow viewport. If it reproduces at desktop width too, skip the device-testing setup and debug it locally. (chef-chopsky, 2026-07: an "Android Chrome rendering bug" reproduced identically in desktop Chromium at 412px *and* 1440px — the ngrok + physical-device setup would have been pure waste.)

### Changed
- **`/playbook:close` + `session-checkpoint` — committing a gitignored checkpoint** — Both now note that `git add docs/checkpoints/` fails with "paths are ignored" in repos that gitignore the directory: use `git add -f docs/checkpoints/latest.md` when `git ls-files docs/checkpoints/` shows checkpoints are tracked despite the ignore rule; when nothing there is tracked, the checkpoint is local-only by design and the commit is skipped.

## [0.23.0] - 2026-07-25

### Added
- **`tasks` template — `[INSTRUMENTATION]` task format** — Any task adding or changing an analytics event, metric, pixel, or telemetry now declares both **Emission** (where data is produced) and **Consumption** (the exact consuming query, its expected non-null result, and its actual pasted output). Acceptance is the metric reading correctly, not the event firing. Also requires the attribute to live on the same record the metric counts (or explicit justification for the join), plus a runnable regression check validated in *both* directions.

### Changed
- **Instrumentation acceptance = run the consuming query** (`autonomous-execution` skill, `delivery-agent`, `/playbook:work`, `tasks` template) — Emission and metric correctness are now explicitly two separate checks. The prior gate accepted "confirm it lands in the truth surface (PostHog/analytics/the metric query)", which let *emission* satisfy the whole gate — the exact loophole that fired. A 202 from the endpoint, a DevTools network request, a green unit test asserting the tracking call, and the event visible in a live-events stream are all compatible with a metric that reads zero forever.

  Fourth recurrence of this family (after Memory Phase 1 `null` gate metrics, the `summaries_generated=0` wiring gap, and acquisition `recipe_cta_clicked` at zero events for 12 days). This time an ad conversion pixel passed every emission check — SDK loaded on both hosts, event accepted 202, attribution param on the payload, person properties written correctly, unit tests green — and shipped. The consuming query read a property path the event never carried (the event is captured server-side; that path only exists on client captures), so every signup bucketed as "direct (no UTM)". Caught in a pre-launch audit one click before a paid campaign would have spent its full budget for zero attribution, which ad platforms cannot backfill.

## [0.22.5] - 2026-07-17

### Changed
- **`/playbook:monitor-pr` — shared-worktree mechanics** — Two additions from the merge-open-prs session: (1) Step 3 documents the "PR branch held by another worktree" pattern (`gh pr checkout` fails when any worktree of the shared repo holds the branch; verify the other checkout is clean, then temp branch + `git push origin HEAD:<branch>` — never disturb a possibly-live session's worktree); (2) Step 4 warns that `gh pr merge --delete-branch` silently switches the local checkout to the default branch — re-checkout your working branch afterwards in parallel-agent workspaces.

## [0.22.4] - 2026-07-11

### Changed
- **`/playbook:critique` Step 3.3b — execution-triage tags** — Every P0/P1 finding gets `[AUTONOMOUS]` (fix now, same session), `[BLOCKED-ON-HUMAN]` (explicit sign-off checklist in the synthesis), or `[DEFERRED-BY-DESIGN]` (name where it lands). Severity says how much a finding matters; the tag says who can act on it. From the memory-vocab overnight critique pass: two P0 security fixes landed autonomously the same night while two DB-write P0s were correctly held for human sign-off.
- **`/playbook:learnings` — "implemented" means MERGED** — The prior-learnings pre-check now verifies a prior fix reached the default branch (`git merge-base --is-ancestor` / `gh pr view`), not merely that a commit exists. The staging-migration-drift fix was fully implemented on a branch that never merged; six manual repair incidents followed.
- **`tasks` template — cron/pipeline wiring criterion** — Tasks whose output comes from a scheduled/pipeline entrypoint must include an integration test that drives the REAL entrypoint and asserts the persisted side effect — not a test that seeds the output artifact. Second recurrence of the wiring gap (`summaries_generated=0` invisible for 24 days).

## [0.22.3] - 2026-07-11

### Changed
- **`/playbook:close` Phase 1 — stash check on close-out** — New step that runs even when the working tree is clean and every commit is pushed: `git stash list` entries tagged to the branch being closed are classified unique-vs-superseded (diff `HEAD <stash>` per file — a rebased/orphaned stash base makes `<base>..<stash>` misleading), salvaged to a pushed branch before dropping when unique/uncertain, and other branches' stashes are left alone. "All commits pushed" ≠ "everything is safe."
- **`/playbook:learnings` branch-state pre-check** — Same stash check for standalone invocations; invocation from `/playbook:close` already covers it. From a real chef-chopsky close-out (2026-07-05) where a fully-pushed branch still held a 2-month-old WIP stash that would have been lost on archive.

## [0.22.2] - 2026-07-11

### Changed
- **`/playbook:monitor-pr` — SKIPPED checks are conditionally green** — Step 1 no longer counts `COMPLETED + SKIPPED` as unconditionally green. A short audit distinguishes legitimate path-filter skips from never-armed suites: if the PR's diff touches the skipped job's path filter, the suite never ran (most common cause: PR created non-draft, so the one-shot `ready_for_review` full-CI trigger never fired) — arm full CI and re-run before classifying. Step 4's terminal all-green state requires SKIPPED checks to have passed the audit. From chef-chopsky PR #294: 6 weeks all-green while integration tests and evals were silently SKIPPED.

## [0.22.1] - 2026-07-11

### Changed
- **`autonomous-execution` skill — Subagent Dispatch Hygiene** — New section for multi-agent / shared-workspace execution: commit-producing subagents must stage explicit paths only (never repo-root `git add -A`), dispatch prompts must name foreign uncommitted files as never-stage, and the controller verifies each commit's `--name-only` file list against the task surface before recording it complete. Also: per-task reviewers receive the design doc (not just the brief) when briefs derive from one. From the 2026-07-07 agent-workforce retro (3rd/4th shared-workspace staging incidents).
- **`tasks` template — default `[ACTIVATION]` task** — New "Activation & Wiring Verification" task included by default for anything that runs outside the repo after merge (cron, scheduled workflow, webhook, deployed service). Checklist requires evidence (read back the scheduler entry, confirm runtime config/deps, one end-to-end run from the runtime environment, failure-visibility check). 5th incident of the verify-cron/pipeline-wiring pattern.

## [0.22.0] - 2026-06-19

### Fixed
- **Plugin version drift across manifests** — `marketplace.json` had fallen 4 versions behind `plugin.json` (0.17.0 vs 0.21.0). Synced all manifests to a single version and backfilled the missing 0.20.0/0.21.0 CHANGELOG sections. The previously-shipped-but-undelivered "Out-of-Repo Changes" checkpoint work (committed at 0.21.0 without a version bump, so auto-update never re-pulled it) now ships under this release.

### Added
- **Release-propagation guardrails** — New `scripts/check-version-bump.sh` fails CI when any plugin's files change without a `plugin.json` version bump (the root cause of stale installs: auto-update is version-keyed, so content changes at an unchanged version silently never reach users). `scripts/validate-plugin.sh` now also asserts every `marketplace.json` entry's `version` matches the plugin's own `plugin.json` version. Both run on every PR to `main` via the new `.github/workflows/plugin-guard.yml`.
- **`scripts/sync-version.sh <version>`** — One command bumps `plugin.json` and the `marketplace.json` entry together so the two can never drift apart, and reminds you to update the CHANGELOG.

### Changed
- **CLAUDE.md / README — propagation model documented** — Versioning Requirements now explains that a version bump is the update trigger and a content change without a bump never propagates; the Quality Checklist references the new guard scripts. README "Updating the Plugin" documents the verified refresh path.

### Why
Driven by a sync session (2026-06-19): a content-only commit (`914709f`, the out-of-repo checkpoint feature) shipped at the same 0.21.0 version, so every local install silently stayed stale despite `autoUpdate: true`. Root cause: auto-update keys off the version number, and nothing enforced "content changed ⇒ version bumped." These guardrails make that failure mode impossible to merge.

## [0.21.0] - 2026-06-18

### Added
- **SpecStory Lore (`/lore`) routing across the session-analysis cluster** — `/playbook:improve-playbook`, `/playbook:identify-improvements`, `/playbook:learnings`, `/playbook:close`, and the `playbook-improvement-agent` now apply a shared decision boundary: gaps specific to *this* plugin → playbook track; knowledge to write down → docs; **portable, reusable-across-projects-and-harnesses workflows → `/lore`** (external [SpecStory Lore](https://github.com/specstoryai/getspecstory) skill, which forges such patterns into cross-harness `SKILL.md` packages from your own session history). `/playbook:close` gains an optional Phase 4.5 "Forge Flow" nudge. Lore is an optional external dependency — the playbook only *suggests* `/lore` and never auto-invokes it; all pointers are gated on Lore being installed. README "Forging Reusable Skills with Lore" section added.
- **`/playbook:monitor-pr`** — New autonomous PR-monitoring workflow. Watches CI to green, fixes failures locally first, and minimizes GitHub Actions minutes via a cost hierarchy (local validation > free rerun > expensive push). Codifies cache-friendly polling intervals, demote-and-re-promote for test/docs-only fixes, false-green sanity checks for path-filtered jobs, and `gh run rerun --failed` over empty-commit retriggers. Designed to be invoked after every PR submission as `/playbook:monitor-pr` (auto-detects PR from branch) or in a loop via `/loop /playbook:monitor-pr`.

### Changed
- **`/playbook:learnings` Step 9.3** — Plugin PR creation now requires a cross-repo URL resolution check: when the plugin PR description references codebase docs as evidence, those docs must be on the default branch before the plugin PR opens. If they only live on a feature branch, open a thin docs-only PR against the codebase first. Prevents dead-link reviewer friction observed in the 2026-05-18 memory-phase-2 close-out.
- **`/playbook:learnings` Pre-Promotion check (32k–40k CLAUDE.md band)** — When CLAUDE.md is between the 32k soft limit and the 40k hard limit, the agent must surface the trim/defer-to-guides/skip decision explicitly with a recommendation, instead of silently choosing. Closes a meta-retrospective gap where the choice was being made without user visibility.
- **`autonomous-execution` skill — Instrumented-Task Verification Gate** — A task whose acceptance includes "event fires" / "metric captured" / "tracked in <analytics>" can no longer be marked complete on a static/import check. Requires runtime evidence (synthetic event lands in the truth surface) or an explicit "unverified — needs runtime check" flag. Closes the long-deferred A4 from the 2026-05-27 acquisition learning; the same root cause had recurred across three projects.
- **`autonomous-execution` skill — Acknowledge Method Substitution** — If a task names a verification method (browser/E2E test) and the agent does a weaker one (code trace), it must say so explicitly, never report the substitution as if the named method ran.
- **`autonomous-execution` skill — "Sequenced later" ≠ "blocked"** — Distinguish a self-imposed soft sequencing preference from a hard external dependency; when idle on a soft "later", propose the next viable action instead of reporting a block and waiting.
- **`autonomous-execution` skill — Name the Bottleneck** — On parallel-track projects (agent builds infra while a human does the scary manual work), the agent must surface when its buildable backlog is outpacing the metric that defines success, rather than mining the backlog for more "safe" tasks.
- **`user-journey-testing` skill** — Added "a written E2E spec that never runs is zero coverage": part of "tested" is the spec being registered in the runner's `testMatch`/suite, run once locally, and confirmed in a CI log.
- **`session-checkpoint` skill** — Added "lead with state": open a resumed session by stating current state instead of waiting for the user to ask "where are we?"; status must reflect *verified* reality, not unverified `tasks.md` ✅ claims.
- **`/playbook:close` Phase 2** — Task cleanup now applies the instrumented-task gate: don't mark an instrumented task complete during close-out without runtime evidence; mark "done pending runtime verification" instead.
- **`session-checkpoint` skill + `/playbook:close` Phase 3** — Added an **"Out-of-Repo Changes"** element to the checkpoint format (kept consistent across both). Captures consequential changes git won't show — config files outside the repo (`~/.config/...`, `~/.<tool>/...`), installed package/tool versions, external service auth/state — with rollback pointers. The format previously tracked only in-repo "Hot Files", silently dropping the highest-signal context on ops/debugging/infra sessions, where most real change happens outside the working tree.
- **`/playbook:learnings` Pre-Check A (Gap Analysis)** — Added a **foundation/strategy consistency check**: compare execution not just against the project's own plan but against the upstream foundation/strategy docs it descends from, to catch "drift by omission" (a Tier-1 channel that silently vanished, a constraint quietly relaxed). Plus: check doc recency/authority before presenting a conflict as "drift" — usually one doc is just stale and needs an override note.

### Why
Captured during the 2026-05-18 memory-phase-2 2c.5–2c.8 close-out session (chef-chopsky PR #283). The user established a pattern of asking an agent to "monitor every PR autonomously while minimizing GitHub Actions minutes" — promoted from a repeated ad-hoc prompt to a first-class workflow. The two `learnings.md` changes came from the meta-retrospective on the same session.

**2026-06-18 OpenClaw runtime-outage session** — The checkpoint "Out-of-Repo Changes" element came from a long ops/debugging session that fixed a Mini Me / OpenClaw Codex outage. ~90% of the consequential changes were outside the repo (a `@openai/codex` upgrade, an OpenClaw `2026.2.3 → 2026.6.1` migration, OAuth re-auth, runtime config edits). The repo-only checkpoint format had no home for any of it — exactly the "would take time to re-discover" context the skill exists to preserve — so the handoff had to be hand-adapted. Promoted that adaptation into the format.

**2026-06-08 acquisition-engine deep retrospective** — The `autonomous-execution`, `user-journey-testing`, `session-checkpoint`, `close`, and `learnings` Pre-Check A changes came from a deep retrospective on chef-chopsky's 10-week acquisition project. Two root causes drove every finding: **comfort with proxies for real validation** — static checks substituting for runtime truth (T11 `recipe_cta_clicked` shipped zero events for 12 days after being marked done on "imports are clean"; the zero-event symptom was visible 6 weeks before root-cause and rationalized away as "no traffic") — and **building substituting for the scary manual work** (10 weeks of measurement infra, exactly one acquisition channel actually run). The foundation-consistency check and the recency-before-drift rule came from the meta-retrospective on this same session.

## [0.20.0] - 2026-04-22

### Added
- **`conciseness-check` skill** — Cross-pollinated from the ai-native-product-playbook, plus AGENTS.md principles 6 (Concise by Default) and 7 (Critique Before Checkpoint).
- **Methods Library (`resources/methods/`)** — 4 standalone thinking frameworks: Socratic Questioning, Strategy Kernel, Impact Estimation, Devil's Advocate.
- **`/playbook:close`** — Session close-out command with a 5-phase workflow (git check → task cleanup → handoff context → learnings → summary).

### Changed
- **Architectural patterns across the plugin** — `recommended-mode` and `thinking-depth` frontmatter added to all 36 commands, proactive invocation on 4 skills, completeness gates on `learnings` and `critique`, and method references in 4 commands. 48 files changed.

### Why
Cross-pollinated four workstreams (conciseness & AI-filler, methods library, session close-out, architectural patterns) from the ai-native-product-playbook into this plugin.

## [0.19.0] - 2026-04-26

### Added
- **`/playbook:close-project`** — New end-of-project lifecycle command that produces a planned-vs-implemented diff, reconciles status drift, archives loose artifacts, moves the project to `done/`, and triggers the retrospective. Closes the gap where projects lingered in `to-do/` or `in-progress/` indefinitely after the gate task closed.
- **`session-start-status` skill** — 5-bullet session-start orientation summary built from `tasks.md` + recent git log + last specstory tail. Targets the 10-30K tokens/session that multi-week projects burn on cold-start re-orientation.
- **`[GATE]` task type in tasks template** — Every gate task must now declare an `Instrumentation Source`, a `Dry-Run Query`, and a `Last Verified` date for each metric, plus a `Gate Dry-Run Sub-task` that runs the query and proves the metric returns a non-null number BEFORE the gate task is allowed to close. Prevents the "Conditional GO with one metric unmeasurable for 4 weeks" failure mode.
- **`planned-vs-implemented.md` template** — Default close-project artifact at `resources/templates/planned-vs-implemented.md`. Captures status drift, deferrals, unplanned scope, and dropped items in a single high-signal diff. Becomes input to retrospective Pre-Check A.

### Changed
- **`/playbook:critique` perspectives default** — Per-persona critique files now write to `.tmp/critiques/v[N]/` from the start, never touching the project directory by default. Only the synthesis lands in `[output]/`. `--keep-perspectives` opts into copying them to `[output]/perspectives/`. Replaces the previous "write then mv to archive/" pattern (which silently failed and let per-persona files accumulate in project trees — observed across 6 files in a single project).
- **`/playbook:tasks` Step 8.5** — New "Gate Task Discipline" sub-section that enforces use of the `[GATE]` task format and the dry-run sub-task for any metric-based gate.
- **`/playbook:learnings` Pre-Check A** — Now points at the new `planned-vs-implemented.md` template and recognizes when `/playbook:close-project` has already produced the artifact (read it instead of regenerating).

### Why
Driven by the Memory & Personalization Phase 1 retrospective (2026-04-26). Four systemic findings collapsed into these changes:
1. **Gates as checkboxes** — Task 32 closed with `$duration` literally unmeasurable for the entire 4-week window. The gate template didn't require instrumentation verification. → `[GATE]` task type + dry-run sub-task.
2. **No closing ritual** — project still lived in `to-do/` 4 weeks after the gate closed; 9 backfill JSONs + 4 PNGs at repo root. → `/playbook:close-project`.
3. **Critique scaffolding sprawl** — 6 per-persona critique files survived in the project tree, none referenced after synthesis. → critique writes to `.tmp/` by default.
4. **Cross-session re-orientation tax** — Doppler config rediscovered 4+ sessions; "how do I see what's stored" asked across 3+ sessions. → `session-start-status` skill.

## [0.18.0] - 2026-04-04

### Added
- **Plan Reconciliation** — New Step 3.5 in `work-multiple` and end-of-project flow in `work` that forces explicit disposition (Done/Blocked/Deferred/Cancelled) for every task before declaring work complete. Prevents silent task loss in long autonomous runs.
- **Compaction-Aware Checkpointing** — `work-multiple` and `delivery-agent` now trigger session checkpoints every 3 tasks during long runs. `autonomous-execution` skill references `session-checkpoint` as a companion.
- **Mid-Rollout Communication** — Structured 3-line status updates between tasks in `work-multiple` and `delivery-agent`. Users can track progress without waiting for the final summary.
- **Reconciliation Section in Tasks Template** — Every new tasks document now includes a Project Reconciliation table for tracking final dispositions.

### Changed
- `commands/workflows/work-multiple.md` — Added Steps 3.5 (reconciliation), checkpoint triggers, and status update cadence
- `commands/workflows/work.md` — Added reconciliation to end-of-project flow
- `agents/workflow/delivery-agent.md` — Added checkpoint and communication patterns
- `skills/autonomous-execution/SKILL.md` — Added checkpoint integration section
- `resources/templates/tasks.md` — Added Project Reconciliation section
- `commands/workflows/tasks.md` — Referenced reconciliation in task creation

### Rationale
Inspired by OpenAI's Codex prompting guide (March 2026), which identifies three key patterns for reliable long-running agent workflows:
1. **Reconcile every plan item** before finishing (Done/Blocked/Cancelled)
2. **Checkpoint context** to survive compaction in multi-hour sessions
3. **Structured mid-rollout updates** (brief acknowledgment → next steps → progress count)

These address the most common failure modes in autonomous execution: silent task loss, context amnesia after compaction, and user anxiety during long silent runs.

## [0.14.0] - 2026-02-02

### Added
- **Mobile Debugging Skill** - New skill for debugging mobile-specific issues:
  - Platform behavior differences table (iOS Safari vs Android Chrome)
  - Common mobile bug patterns with solutions:
    - Input covered by keyboard (iOS Safari scrollIntoView workaround)
    - Gray space below content (min-h-screen wrapper issue)
    - Flex layout not filling height (flex-1 vs h-full)
    - Textarea not shrinking on delete
    - Overscroll bounce prevention
  - Mobile debugging checklist
  - Testing requestAnimationFrame in Jest guidance
  - Real device testing recommendations

### Changed
- **Debugging Agent** - Added comprehensive mobile/viewport section:
  - Browser testing limitations documentation (Playwright can't simulate real mobile keyboard)
  - Platform behavior differences table
  - Common mobile bug patterns with solutions
  - Mobile debugging checklist
  - iOS Safari keyboard workaround pattern

### Rationale
Learned from a mobile keyboard fixes project that many mobile bugs only reproduce on real physical devices and require platform-specific solutions. iOS Safari and Android Chrome handle viewport/keyboard behavior completely differently, and CSS-only solutions don't work on iOS Safari.

## [0.13.0] - 2026-01-30

### Added
- **Multi-Persona Critique Workflow** - Complete system for running structured document critiques:
  - `/playbook:critique`: New command for parallel multi-persona document critiques with versioning, synthesis, and issue tracking
  - **Persona Library** (12 reusable personas):
    - **Strategy**: `product-manager`, `founder`, `board-member`, `investor`
    - **Design & Engineering**: `product-designer`, `software-engineer`, `technical-reviewer`, `creative-technologist`
    - **Marketing & Growth**: `marketing-strategist`, `marketing-manager`, `growth-marketer`
    - **Domain**: `domain-expert` (customizable for any field)
  - **Critique Synthesis Template**: P0/P1/P2 prioritization, cross-version comparison, launch readiness checklist, auto-generated tasks
  - **Issue Tracker Template**: Track issues across critique versions (Open → Fixed → Verified → Regressed)

### Changed
- Total commands now: 28 (was 27)
- Total templates now: 9 (was 7)
- New `resources/personas/` directory for reusable persona definitions
- README expanded with Multi-Persona Document Critique section

### Rationale
This workflow was identified by analyzing 5 coding sessions that ran iterative critique workflows on foundation documents (v3 → v4 → v5). Key friction points addressed:
1. **Persona re-specification**: Had to write out persona descriptions each time instead of referencing by name
2. **Version management**: Manual version incrementing and file renaming
3. **No synthesis template**: No standard P0/P1/P2 format with exit criteria
4. **No issue tracking**: Same issue flagged as "new" in each version
5. **No task generation**: Synthesis findings not automatically actionable

The new workflow enables: `/playbook:critique docs/foundations/` → parallel agents → synthesis with P0/P1/P2 → implement fixes → `/playbook:critique docs/foundations/ --rerun` → track resolution.

## [0.12.0] - 2026-01-29

### Added
- **Agent-Ready PRD System** - Complete overhaul of PRD workflow optimized for agentic engineering:
  - **New PRD Template** (`product-requirements-v2.md`): Comprehensive template with agent-ready checklist, structured acceptance criteria (Given/When/Then), technical context section, decision log, and explicit scope boundaries
  - **Two-Mode Command**: `/playbook:product-requirements` now supports `--autonomous` flag for context-based drafting and default interview mode
  - **PRD Drafting Agent** (`prd-drafting-agent`): Autonomous agent that drafts complete PRDs from available context

### Changed
- `/playbook:product-requirements` command completely rewritten with:
  - Autonomous mode for generating PRDs from existing context
  - Interview mode with "Agentic Engineer" persona for technical context gathering
  - Agent-Ready Checklist validation step
  - Technical Context section (integration points, data requirements, constraints, patterns)
- Total agents now: 9 (was 8)
- Total templates now: 7 (was 6)

### Rationale
PRDs must enable autonomous technical planning and implementation. The previous PRD structure left too much implicit—agents couldn't create tech plans without asking clarifying questions, and acceptance criteria weren't testable. The new structure ensures:
1. Every requirement has verifiable acceptance criteria (Given/When/Then)
2. Technical context is explicit (integration points, data, constraints, patterns)
3. Scope is unambiguous (explicit In/Out tables)
4. Decisions are logged with rationale (agents don't re-litigate)
5. Open questions are flagged as blockers

This closes the gap between "what to build" and "how to build it"—enabling true end-to-end autonomous engineering from PRD to shipped code.

## [0.11.0] - 2026-01-29

### Added
- **Meta-Improvement Command** (1 new):
  - `/playbook:improve-playbook`: Analyze coding sessions to identify patterns, compare against existing playbook capabilities, and implement improvements as a PR. This is a self-improving workflow that learns from how you use AI coding tools.
- **Meta-Improvement Agent** (1 new):
  - `playbook-improvement-agent`: Analyzes session history, identifies repeatable patterns, performs gap analysis against existing tools, and proposes well-designed solutions.

### Changed
- Total commands now: 27 (was 26)
- Total agents now: 8 (was 7)
- README expanded with Self-Improvement section explaining the meta-workflow
- Added command details for `/playbook:improve-playbook`

### Rationale
This meta-capability enables the playbook to continuously improve based on actual usage. The workflow:
1. Reads SpecStory session history from the current project
2. Identifies repeatable patterns in how you work
3. Compares patterns against existing playbook capabilities
4. Finds gaps where new tools would add value
5. Proposes solutions with evidence from sessions
6. Implements approved improvements
7. Creates a PR to the playbook repository

This closes the loop: use the playbook → identify patterns → improve the playbook → use the improved playbook.

## [0.10.0] - 2026-01-29

### Added
- **Document Workflow Commands** (3 new):
  - `/playbook:rubric-doc`: Generate documents based on a spec file with rubric/excellence criteria. Searches context directories and produces cited drafts.
  - `/playbook:refine-doc`: Incorporate new information or feedback into existing documents while maintaining consistency across related docs.
  - `/playbook:distill`: Create focused summaries or quick references from longer documents, optimized for specific purposes (interviews, presentations, etc).
- **Document Workflow Agents** (2 new):
  - `insight-extractor-agent`: Systematically extract and organize insights from source materials (interview notes, research, meeting notes) with proper citations.
  - `cross-reference-validator-agent`: Validate consistency across interconnected documents, checking links, definitions, and summaries.

### Changed
- Total commands now: 26 (was 23)
- Total agents now: 7 (was 4)
- README expanded with Document Workflow Commands section

### Rationale
These tools were identified by analyzing patterns across 30+ coding sessions in a job search preparation codebase. Common patterns included:
- Generating structured documents from specs/rubrics with citations
- Extracting insights from interview notes with source links
- Refining documents with stakeholder feedback while maintaining consistency
- Creating quick references for interviews and presentations
- Validating cross-references across interconnected documentation

## [0.9.0] - 2026-01-27

### Added
- **Help Command** (1 new):
  - `/playbook:help`: List all commands with decision tree for choosing the right one
- **Local Development Documentation**:
  - Worktree setup guide for fast plugin iteration
  - Local path installation instructions
  - Quick ideas capture workflow

### Changed
- Total commands now: 23 (was 22)
- README expanded with comprehensive development section

## [0.8.0] - 2026-01-26

### Added
- **Design Commands** (1 new):
  - `/playbook:design-spec`: Create high-fidelity design specifications for complex UI features
- **Templates** (1 new):
  - `design-spec.md`: Comprehensive design specification template

### Changed
- Total commands now: 22 (was 21)
- Total templates now: 6 (was 5)
- Playbook migration complete: all 103 files processed, playbook can be deprecated

## [0.7.0] - 2026-01-26

### Added
- **Review Commands** (1 new):
  - `/playbook:review-playbook`: Systematically review and optimize playbook/plugin with scoring rubric

### Changed
- Total commands now: 21 (was 20)
- Plugin now fully self-sufficient (playbook review capabilities included)

## [0.6.0] - 2026-01-26

### Added
- **Git Commands** (6 new):
  - `/playbook:git-commit`: Analyze changes and create conventional commits
  - `/playbook:git-pr`: Create pull requests with GitHub CLI
  - `/playbook:git-worktree`: Create git worktrees for parallel development
  - `/playbook:git-branch-worktree`: Create branch and worktree together
  - `/playbook:git-delete-branch`: Safely delete branches (local + remote)
  - `/playbook:git-move-changes`: Move uncommitted changes to new branch
- **Organization Commands** (1 new):
  - `/playbook:organize-files`: Organize project files by content analysis

### Changed
- Total commands now: 20 (was 12)
- Added Git Commands and Organization Commands sections to README

## [0.5.0] - 2026-01-26

### Added
- **Commands** (6 new):
  - `/playbook:debug-ci`: Debug CI/CD failures using GitHub CLI
  - `/playbook:prompt-coaching`: Real-time coaching on prompts
  - `/playbook:design-critique`: Facilitate design critiques for visual analysis
  - `/playbook:review-autonomy`: Review project readiness for autonomous execution
  - `/playbook:work-multiple`: Work autonomously on multiple tasks
  - `/playbook:identify-improvements`: Identify top 10 improvements from sessions

### Changed
- Expanded command documentation in README with categorized sections
- Total commands now: 12 (was 6)

## [0.4.0] - 2026-01-26

### Added
- Learning search integration in `/playbook:tech-plan`, `/playbook:work`, and `/playbook:debug`
- YAML frontmatter-based filtering for finding relevant learnings
- Validation script (`scripts/validate-plugin.sh`) for plugin quality checks
- CHANGELOG.md for tracking version history

### Changed
- Enhanced project context discovery with explicit learning search patterns
- Improved documentation with usage examples

## [0.3.0] - 2026-01-26

### Added
- **Skills** (3 new):
  - `codebase-docs-search`: Patterns for finding and using project documentation
  - `learning-capture`: Multi-trigger, dual-target learning capture patterns
  - `autonomous-execution`: Patterns for autonomous project execution
- **Agents** (4 new):
  - `product-discovery-agent`: Multi-persona product discovery facilitation
  - `solution-planning-agent`: Technical planning with architect perspective
  - `delivery-agent`: Systematic task execution with quality gates
  - `debugging-agent`: Verification-first debugging approach

### Changed
- Updated README with agents and skills documentation
- Updated project structure to include agents and skills directories

## [0.2.0] - 2026-01-25

### Added
- **Commands** (6 new):
  - `/playbook:product-requirements`: Draft product requirements with multi-persona discovery
  - `/playbook:tech-plan`: Create technical plan with architecture and sequencing
  - `/playbook:tasks`: Break down work into specific, actionable tasks
  - `/playbook:work`: Execute tasks from the tasks document
  - `/playbook:debug`: Systematic debugging workflow
  - `/playbook:learnings`: Capture learnings to improve docs and plugin
- **Templates** (5 new):
  - `product-requirements.md`: Product Requirements Document template
  - `tech-plan.md`: Technical Plan Document template
  - `tasks.md`: Tasks Document template
  - `learnings.md`: Learnings Document template
  - `debugging-session.md`: Debugging Session template

### Changed
- Restructured plugin for marketplace distribution
- Updated marketplace.json with correct schema

## [0.1.0] - 2026-01-25

### Added
- Initial plugin structure
- Core plugin files (plugin.json, README.md, CLAUDE.md, AGENTS.md)
- `/playbook:hello` test command
- Basic marketplace configuration

---

## Version History Summary

| Version | Date | Highlights |
|---------|------|------------|
| 0.18.0 | 2026-04-04 | Plan reconciliation, compaction-aware checkpointing, mid-rollout communication |
| 0.13.0 | 2026-01-30 | Multi-persona critique: `/playbook:critique` command, 5 personas, synthesis + issue tracker templates |
| 0.12.0 | 2026-01-29 | Agent-ready PRD system: new template, two-mode command, `prd-drafting-agent` |
| 0.11.0 | 2026-01-29 | Meta-improvement: `/playbook:improve-playbook` command and `playbook-improvement-agent` |
| 0.10.0 | 2026-01-29 | 3 new document workflow commands (rubric-doc, refine-doc, distill), 3 new agents |
| 0.9.0 | 2026-01-27 | 1 new command (help), local development documentation |
| 0.8.0 | 2026-01-26 | 1 new command (design-spec), 1 new template, playbook migration complete |
| 0.7.0 | 2026-01-26 | 1 new command (review-playbook), plugin fully self-sufficient |
| 0.6.0 | 2026-01-26 | 7 new commands (6 git commands, 1 organization command) |
| 0.5.0 | 2026-01-26 | 6 new commands (debug-ci, prompt-coaching, design-critique, review-autonomy, work-multiple, identify-improvements) |
| 0.4.0 | 2026-01-26 | Learning search integration, validation script |
| 0.3.0 | 2026-01-26 | 3 skills, 4 agents |
| 0.2.0 | 2026-01-25 | 6 commands, 5 templates |
| 0.1.0 | 2026-01-25 | Initial release |
