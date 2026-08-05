---
name: playbook:merge-prs
description: Triage every open PR, get one approval on a merge plan, then merge the whole queue autonomously — sequential version bumps, per-PR CI-to-green, verified branch cleanup
argument-hint: "[optional: PR numbers to limit scope, e.g. \"57 58 61\"]"
recommended-mode: auto-accept
thinking-depth: deep
---

# Merge Open PRs

You are clearing a repository's open-PR backlog. This command is the **orchestration**
layer: it decides *what* gets merged and *in what order*, then drives each PR through
`/playbook:monitor-pr`, which owns the per-PR CI and merge mechanics.

## Your Goal

Take every open PR, triage it, present one merge plan, and — after a single approval —
merge the approved queue to completion without further questions.

## The One Gate (Read This Before Doing Anything)

**All human judgment is spent once, at Step 4.** Everything before it is analysis;
everything after it is mechanical execution. This split is the whole point of the command:

- Triage is where the expensive calls live — is this draft complete or abandoned? does
  this PR ship without the WIP it references? whose branch is this?
- Execution is long-running and boring — merge main in, bump, validate, push, wait for CI,
  merge, verify. Nobody should babysit that.

So: **do not ask the user anything after Step 4 succeeds.** If you hit something the plan
didn't anticipate, apply Step 6 (skip and continue), don't stop and ask. The one exception
is Step 6's escalation list — genuinely unsafe territory, where stopping is correct.

## Available Tools

- `/playbook:monitor-pr` — per-PR CI-to-green, proof-of-completion comment, merge
  mechanics. **Call into it. Do not reimplement it.**
- `/playbook:debug-ci` — systematic CI failure analysis. `monitor-pr` already delegates
  here; you should not call it directly.
- `gh` CLI — `pr list`, `pr view`, `pr diff`, `pr comment`, `pr merge`, `repo view`
- `git worktree list`, `git ls-remote` — the two commands that keep you out of trouble in
  a parallel-agent workspace

## Process

### Step 0: Preflight

1. **Verify `gh` is authed**: `gh auth status`. Stop if not — nothing downstream works.

2. **Record where you started**: `git branch --show-current`. Write it down. You will be
   moved off this branch without warning (Step 5.7) and must return to it.

3. **Map the worktrees**: `git worktree list`. Any branch checked out in another worktree
   cannot be `gh pr checkout`'d, and may belong to a **live agent session**. This map
   drives Step 5.1.

4. **Read CLAUDE.md / AGENTS.md / project conventions** for:
   - Local validation commands (`ci:local`, `test:verify`, etc.)
   - Draft-vs-ready CI behavior, path filters, `ci:full` label semantics
   - Merge-method policy (squash vs merge commit) and any forbidden patterns
   - **Release/versioning rules** — see next item

5. **Detect version-guard machinery.** Some repos fail CI unless every change bumps a
   version, which forces PRs to merge *sequentially with distinct versions*. Look for:
   - A versioning section in CLAUDE.md (search: `version`, `bump`, `propagat`)
   - A bump script (`scripts/sync-version.sh`, `npm version`, `bumpversion`, …)
   - A guard workflow in `.github/workflows/` that diffs versions against the base branch

   **If found**: the queue is *stacked* — each PR needs its own version, assigned in Step 3.
   **If not found**: skip all version-bump handling. Most repos don't have this. Do not
   invent it.

6. **Check auto-delete**: `gh repo view --json deleteBranchOnMerge`. If `false`, every
   merge in this run risks leaving an orphan branch (Step 5.6). Note it for the report and
   recommend flipping it — it fixes the failure mode permanently, including for web merges.

### Step 1: Enumerate

```bash
gh pr list --state open --limit 100 \
  --json number,title,author,isDraft,createdAt,headRefName,baseRefName,mergeable,labels
```

**Include drafts.** Draft status is frequently neglect rather than intent — the 2026-07-26
run found all three drafts content-complete and merged them. Triage decides; enumeration
does not pre-filter.

If PR numbers were passed as arguments, restrict to those. Otherwise take everything.

### Step 2: Triage Each PR

This is the careful part. For each PR, gather:

```bash
gh pr view <N> --json title,body,isDraft,mergeable,mergeStateStatus,statusCheckRollup,\
reviewDecision,author,headRefName,files,comments,reviews
gh pr diff <N> --name-only
```

Assess, and **write down the reasoning** — it goes in the plan:

- **What it actually changes.** Read the diff, not just the title. A PR whose description
  and diff disagree is an ESCALATE.
- **Is it complete?** Unfinished WIP, `TODO` markers, commented-out code, a description
  promising work the diff doesn't contain. A draft that is complete is a MERGE candidate;
  a non-draft that is incomplete is not.
- **CI state.** Green / red / never ran. Red-on-one-known-check (e.g. a version guard that
  every unbumped PR trips) is FIX-THEN-MERGE, not SKIP.
- **Mergeability.** `CONFLICTING` means it needs a main merge in Step 5.2 — expected, not
  disqualifying.
- **Unresolved review threads.** Unaddressed review feedback is an ESCALATE. Merging past
  a human's open question is not yours to do.
- **Authorship.** Someone else's PR is an ESCALATE unless the user's invocation clearly
  covers it (e.g. they said "merge all my PRs" and it's a bot's, or they named it).
- **File overlap with other open PRs.** Record the overlapping paths — Step 3 needs them.

Classify each as exactly one of:

| Verdict | Meaning |
|---|---|
| **MERGE** | Complete, green or trivially fixable, no open questions |
| **FIX-THEN-MERGE** | Needs a specific, named fix first (bump, main merge, lint) — state which |
| **SKIP** | Not ready, with a reason the user can act on |
| **ESCALATE** | Requires a decision you shouldn't make — surfaced in the plan, defaults to not merging |

Every verdict carries a one-line reason. "Looks fine" is not a reason.

### Step 3: Order the Queue

Default: **oldest first** (by `createdAt`). Then apply two overrides:

1. **File-overlap dependencies.** When two PRs touch the same paths, the one the other
   builds on goes first — otherwise the second inherits a conflict you'll resolve blind.
   If neither depends on the other, keep them adjacent so the conflict resolution is fresh
   in context.
2. **Small and green before large and red.** Early merges move `main` forward; cheap ones
   first means later PRs rebase onto more settled ground.

**If Step 0.5 found version-guard machinery**, assign each PR its own version now —
sequential patch bumps from the current version, one per PR, in queue order. This is what
makes a stacked queue mergeable: the guard can't be satisfied by a shared version number,
and it keeps the CHANGELOG↔PR mapping 1:1.

### Step 4: The Gate — Write and Present the Merge Plan

**Write the plan to a file**, so a queue interrupted at PR 4 resumes instead of
re-deriving. Default path: `docs/merge-plans/YYYY-MM-DD-merge-plan.md`.

**The plan file must not dirty the working tree.** A dirty tree is one of two known
triggers for `gh pr merge --delete-branch` half-failing and leaving the remote branch
alive. So, after writing it:

```bash
# NOT ".git/info/exclude" — in a git worktree (Conductor, `git worktree add`) .git is a
# FILE pointing at the real gitdir, so that path fails with "Not a directory". Ask git.
EXCLUDE="$(git rev-parse --git-common-dir)/info/exclude"
mkdir -p "$(dirname "$EXCLUDE")"
grep -qxF 'docs/merge-plans/' "$EXCLUDE" 2>/dev/null || echo 'docs/merge-plans/' >> "$EXCLUDE"
git check-ignore -q docs/merge-plans/ && echo "excluded OK"
git status --porcelain    # MUST be empty before Step 5
```

`info/exclude` is local and uncommitted, so this works in any repo without touching a
shared `.gitignore`. Use `--git-common-dir`, not `--git-dir`: `info/exclude` lives in the
common directory and is shared across all worktrees, which is also what git actually reads.
If the user would rather commit the plan, commit it — either way the tree ends clean.

The plan contains, per PR: number, title, verdict + reason, assigned version (if any),
required fix (if FIX-THEN-MERGE), and a status column starting at `pending`.

**Present it and stop.** Show the queue in order, the SKIP/ESCALATE list with reasons, and
the version range. Ask once:

> Approve this queue? I'll merge all N in order without further questions.

Wait for approval. If the user amends the queue, update the file and re-present. **Nothing
in Step 5 runs before explicit approval.**

### Step 5: Execute the Queue

For each PR in order. Every sub-step matters; the hazards below are all observed, not
theoretical.

**5.1 — Claim the branch safely.** If the Step 0.3 worktree map shows another worktree
holds this branch, **do not disturb it** — it may be a live session. Verify it's clean and
at the PR head (`git -C <path> status --short`), then work from a temp branch:

```bash
git fetch -q origin
git checkout -b tmp/pr<N> origin/<headRefName>
```

Otherwise `gh pr checkout <N>` is fine.

**5.2 — Bring in main.** `git merge origin/main`. Resolve conflicts yourself; you have the
triage context. When resolving, prefer the narrowest correct resolution — the 2026-07-26
run hit a conflict where a directory-level `git add -f docs/checkpoints/` would have
force-committed everything the repo deliberately ignores; the fix was narrowing to the one
explicit file.

**5.3 — Version bump + CHANGELOG** (only if Step 0.5 found guard machinery). Use the
repo's own script with this PR's assigned version, then add the matching CHANGELOG section.
One version, one PR, one CHANGELOG entry.

**5.4 — Validate locally, then push.** Run the project's local validation to exit 0 *before*
pushing. Pushing an unvalidated commit burns a CI run and leaves the branch needing another
fix — the worst square on the cost hierarchy. Then:

```bash
git push origin HEAD:<headRefName>     # works from temp branch or real branch alike
```

**5.5 — Drive CI to green.** Hand off to `/playbook:monitor-pr <N>`. It owns polling, cost
discipline, failure triage, and the proof-of-completion comment. Do not duplicate it.

**5.6 — Merge, then verify the branch actually died.**

```bash
gh pr merge <N> --squash --delete-branch     # match the repo's merge-method policy
git fetch -q origin --prune
git ls-remote --heads origin <headRefName> | wc -l    # MUST be 0
```

**Treat any non-empty error from `gh pr merge --delete-branch` as "the remote branch
probably survived."** The merge succeeds, the local cleanup fails, and the operation
deletes *neither* branch — but because the merge worked, the message reads as cosmetic.
If the branch survived, finish it: `git push origin --delete <headRefName>`. Check with
`git ls-remote` (authoritative), not `git branch -r` (stale local cache).

**5.7 — Return to your branch.** `gh pr merge --delete-branch` silently checks out the
default branch and pulls. In a parallel-agent workspace this strands the session. Re-checkout
the Step 0.2 branch, and delete `tmp/pr<N>` if you made one.

**5.8 — Tick it off.** Update the plan file: status `merged`, record the new `main` SHA.
This is what makes the run resumable.

### Step 6: Exceptions — Skip, Don't Halt

A PR that breaks its triage assumptions mid-run (a new conflict, someone pushed to it, CI
red for a reason `monitor-pr` can't fix, local validation that won't go green) is
**skipped, not halted on**. Mark it `skipped` in the plan with what happened, and continue
to the next PR. The remaining PRs are independent and already approved; forfeiting them
because one went bad is the failure mode this step exists to prevent.

**Stop the whole queue only for**:

- `gh` auth loss or repo-level permission failure — nothing further will work
- A merge that lands broken code on `main` (post-merge CI on `main` goes red) — fix or
  revert that before merging anything else onto a broken base
- Evidence another agent or human is actively pushing to `main` mid-run
- Three consecutive PRs failing for unrelated reasons — the plan's assumptions are stale;
  re-triage rather than grinding through

### Step 7: Final Report

- **Merged**: number, title, version, merge commit
- **Skipped**: number + what happened + what would unblock it
- **Escalated**: the decisions that were never yours to make
- **Final state**: `main` SHA, final version, open-PR count (should be the escalated +
  skipped set)
- **Leftovers**: any remote branch that survived its merge, any `tmp/pr*` still around
- **Repo hygiene**: if `deleteBranchOnMerge` was `false`, say so and recommend flipping it

## Anti-Patterns (Don't Do These)

- **Re-asking after Step 4.** The gate was the deal. Skip and report instead.
- **Halting the queue on one bad PR.** Step 6 exists for this.
- **Reimplementing `monitor-pr`.** CI polling, failure triage, and the proof-of-completion
  comment live there.
- **Assuming `--delete-branch` worked.** Verify with `git ls-remote`, every time.
- **Touching another worktree's checkout.** Read it, never write it.
- **Inventing version bumps** in a repo with no version guard.
- **Merging past an unresolved review thread.** That's an ESCALATE, always.
- **Pushing before local validation passes.** Burns CI minutes and compounds the fix.
- **Force-adding directories** during conflict resolution. Name the file.

## When to Escalate to the User

Surface in the plan (Step 4) rather than deciding yourself:

- PRs authored by someone else
- Unresolved review threads
- A PR whose description and diff disagree
- A PR that would revert or supersede another open PR
- Anything touching auth, secrets, payments, migrations, or production config

## After Completion

Suggest `/playbook:learnings` if the run surfaced anything new about the repo's merge
mechanics, and `/playbook:close` if this was the session's main work.

## Usage Pattern

```
/playbook:merge-prs              # triage everything, one plan, one approval
/playbook:merge-prs 57 58 61     # limit the queue to these PRs
```

Pairs with `/playbook:monitor-pr` (single PR) — use that when you have one PR to shepherd,
this when you have a backlog.
