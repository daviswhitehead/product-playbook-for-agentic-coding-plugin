---
title: "Merging stacked guard-blocked PRs across shared worktrees"
date: 2026-07-17
trigger: chat-session
analysis-depth: standard
category: workflow
tags: [git, worktrees, gh-cli, version-bump, plugin-guard, conductor, parallel-agents]
severity: medium
module: "release-process"
---

# Merging stacked guard-blocked PRs across shared worktrees

## Context

Session goal: merge all 4 open PRs (#51–#54). All were red on exactly one check — the
version-bump guard — because none bumped the plugin version. Two of the four PR branches
were also checked out in *other* worktrees of the shared repo (the `~/GitHub` main
checkout and a leftover `/private/tmp` worktree), and this repo is worked on by parallel
Conductor agent sessions.

## Key Learnings

### 1. Stacked guard-blocked PRs → sequential per-PR patch bumps

Multiple open content PRs can't all pass the guard at once (each needs a bump, and they
can't share a version number). The clean pattern: merge oldest-first, one patch version
per PR — merge `origin/main` into the PR branch, `scripts/sync-version.sh <next-patch>`,
CHANGELOG section, push, wait for guard, merge, repeat against the new main. Proven here
as 0.22.1 → 0.22.4 with zero conflicts and a 1:1 CHANGELOG↔PR mapping. Promoted to
CLAUDE.md ("Merging multiple open PRs").

### 2. PR branches held by other worktrees

`gh pr checkout` fails with "already used by worktree at <path>" when any worktree of the
shared repo holds the branch. Don't disturb the other checkout (it may be a live agent
session): verify it's clean and at the PR head, then work from a temp branch
(`git checkout -b tmp/prN origin/<branch>` … `git push origin HEAD:<branch>`). Promoted
to `/playbook:monitor-pr` Step 3.

### 3. `gh pr merge --delete-branch` silently switches your checkout

> ⚠️ **The second sentence below is WRONG — corrected 2026-07-26.** The remote branch is
> **not** deleted when the local delete fails; neither branch is. Text kept as written for
> the historical record. See the [2026-07-26 addendum](#2026-07-26-second-incident-addendum--learning-3-was-factually-wrong).

After deleting the PR branch it checks out the default branch and pulls — in a
parallel-agent workspace this strands the session on `main` without warning. Re-checkout
your working branch after merging. ~~If another worktree holds the branch, the local delete
fails harmlessly (remote still deleted), leaving that checkout on a remote-less branch.~~
Promoted to `/playbook:monitor-pr` Step 4.

### Bonus observation

Conductor renames the workspace branch when a session is named (reflog showed
`renamed refs/heads/daviswhitehead/puebla to refs/heads/daviswhitehead/merge-open-prs`) —
if `git checkout <remembered-branch>` fails mid-session, check `git reflog` for a rename
before assuming the branch is gone.

## Action Items

- [x] CLAUDE.md: "Merging multiple open PRs (stacked bumps)" section
- [x] `/playbook:monitor-pr`: worktree-held-branch pattern (Step 3) + post-merge local-state note (Step 4)
- [x] Session memory: worktree pattern cached for future sessions

---

## 2026-07-26 second-incident addendum — Learning #3 was factually wrong

The same scenario recurred: a second merge-all-open-PRs session (9 PRs, #57–#67,
0.23.0 → 0.24.3) across the same shared worktrees. Learnings #1 and #2 held up
perfectly and made the session routine. **Learning #3 did not — half of it is false**,
and it had already been promoted into `/playbook:monitor-pr` Step 4, so the error
shipped to every install.

### The false claim

> "If another worktree holds the branch, the local delete fails harmlessly
> (remote still deleted), leaving that checkout on a remote-less branch."

The remote branch is **not** deleted. When another worktree holds the branch,
`gh pr merge --delete-branch` deletes **neither** branch — the local-delete error
ends the operation with the remote still alive.

### Evidence (verified both directions, one session, gh 2.88.0)

| Case | n | Remote branch after merge |
|---|---|---|
| `--delete-branch` succeeded | 6 | deleted (0 present) — correct |
| `--delete-branch` hit the worktree error | 3 | **still alive** |

Occurrences: #63 `improve/negative-test-every-guardrail`, #66
`fix/close-archive-detection`, #68 `chore/rescue-orphaned-transcripts`. Each needed a
manual `git push origin --delete`. Verified with `git ls-remote --heads` after
`git fetch --prune` — authoritative, not the local `git branch -r` cache.

### Why a wrong rule is worse than no rule

The claim doesn't merely fail to help — it **actively suppresses the check**. It says
"harmless," so you don't verify, so the surviving branch is never noticed. A missing
rule would have left normal curiosity intact. This is the "Is every rule still TRUE?"
demotion-checklist case (added 0.24.0) landing on the playbook's own docs.

### The systemic upgrade — fix it at the repo, not in prose

The stronger fix isn't a better instruction, it's removing the need for one. This repo
has **`delete_branch_on_merge: false`**, so GitHub never auto-deletes a merged head
branch. Enabling it makes the whole failure mode moot, including for web-UI merges.

**Honest scoping of the impact.** An audit found **24 stale remote branches**, all from
merged PRs back to 2026-04. Do *not* attribute all 24 to the gh bug — most predate it and
come from merges that simply never passed `--delete-branch`, compounded by
`delete_branch_on_merge: false`. Two distinct causes, one repo-level fix:

| Cause | Fix |
|---|---|
| `--delete-branch` half-fails when a worktree holds the branch | Verify + `git push origin --delete` (documented in Step 4) |
| Merges that never used `--delete-branch` at all | `delete_branch_on_merge: true` — covers both |

### Updated rule of thumb

| Signal | Old response | New response |
|---|---|---|
| `failed to delete local branch …used by worktree` | Ignore — "remote is still deleted" | `git ls-remote --heads origin <b>`; delete it yourself if present |
| Repo accumulating merged branches | (not covered) | Check `gh repo view --json deleteBranchOnMerge`; enable it |

### Addendum action items

- [x] `/playbook:monitor-pr` Step 4: claim corrected, verification snippet + repo-level fix added (0.24.4)
- [x] **Enable `delete_branch_on_merge`** — done 2026-07-27 on this repo *and* chef-chopsky; verified via `gh repo view --json deleteBranchOnMerge` and by three subsequent merges cleaning up their own branches
- [x] Sweep the stale remote branches — 21 remote + 7 local deleted 2026-07-27; 25 branches → 1

---

## 2026-07-27 third-incident addendum — the guard that green-lit a version *regression*

The branch sweep this addendum's action items called for turned up two findings that
belong here, one of them more serious than anything above.

### 1. The version-bump guard passed a BACKWARDS bump

`scripts/check-version-bump.sh` exists to protect version-keyed propagation. It compared
versions with a string inequality:

```bash
if [ "$cur_version" = "$base_version" ]; then   FAIL
else                                            OK: bumped $base -> $cur
```

So **any** change passed — including a decrease. Reproduced end-to-end:

```
OK: product-playbook-for-agentic-coding bumped 0.24.7 -> 0.23.0
Version-bump check PASSED.     EXIT CODE: 0
```

It printed the word "bumped" for a seven-release regression and exited green.

**This was not hypothetical.** PR #74 — a duplicate of the already-merged #59 — carried
exactly this: content identical to `main`, plus `"version": "0.23.0"`. It was open, and CI
was the only thing standing between it and `main`. It was caught by a human-style judgement
call ("this looks like a duplicate"), not by the guard built to catch it.

**Why backwards is worse than unchanged.** An unbumped change fails to propagate. A
*backwards* version makes every install already on the higher version stop updating until
the number climbs back past that high-water mark — a stall that outlasts the offending PR
and is invisible from the repo.

**Fix**: semver-aware `version_gt`, failing closed on malformed/empty input, with a distinct
`version went BACKWARDS` failure message. Negative-tested in both directions — 8 unit cases
(including `0.10.0 > 0.9.0`, which a string sort gets wrong) and 4 end-to-end runs:
backwards → exit 1, unchanged → exit 1, forward → exit 0, no-change → exit 0.

### 2. Branch sweeps need a content check and an open-PR check

Ancestry-based "is it merged?" is unreliable under squash-merge, which this repo uses.
`feat/instrumentation-acceptance-is-the-metric` reported unmerged with a 97-line diff while
being 100% present in `main`. Judging on ancestry alone would have been wrong in both
directions during one 25-branch sweep:

- Two branches the content check flagged as "has unique content" turned out to have PRs
  **opened mid-session** (#73, #74). Deleting a branch closes its PR — a list built an hour
  earlier would have silently killed both.
- One branch held the **only complete copy** of a session transcript that `main` had in
  truncated form, and only in its *local* ref — the remote copy was already truncated.

### Updated rule of thumb (cumulative)

| Signal | Response |
|---|---|
| Guard says "OK: bumped A -> B" | Confirm B > A. "Changed" ≠ "increased". |
| About to bulk-delete branches | Re-derive open PRs at delete time; compare file contents, not ancestry |
| Branch looks unmerged | Check content — squash-merge discards ancestry |
| Local branch ahead of its remote | The unique content may exist only locally |

### Why the earlier prevention rules were insufficient

Every rule above this line is about *branch* hygiene, and they worked. The regression slipped
through a different layer: a guard whose own comparison was wrong. Documentation cannot catch
that — only running the guard against the input it exists to reject can. This is the
"negative-test every guardrail" rule (0.24.0) applied to a guard that predates it.

### Third-addendum action items

- [x] `scripts/check-version-bump.sh`: reject non-increasing versions, semver-aware, fail closed
- [x] `/playbook:monitor-pr`: bulk-delete safety — open-PR check + content-not-ancestry check
- [ ] Audit the repo's other guards the same way — has `validate-plugin.sh` ever been run
      against input it should reject?

---

## 2026-08-04 fourth-incident addendum — the guard's *frame of reference*, and Learning #1 retired

A fourth merge-all-open-PRs session (4 PRs, #85/#81/#82/#83, 0.26.1 → 0.26.4), which then
went looking for why the stacked-bump dance was needed at all. Learnings #2 and #3 held.
**Learning #1 is now obsolete** — the pattern it recommends has been removed rather than
refined.

### First: auditing the pre-registered escalation (per `/playbook:learnings`)

The third addendum pre-registered:

> - [ ] Audit the repo's other guards the same way — has `validate-plugin.sh` ever been run
>       against input it should reject?

**Would it have caught this one? No.** Two reasons, and naming them is the point:

1. It aims at a **different guard**. The defect was in `check-version-bump.sh` — the guard
   the third addendum had just finished fixing and therefore treated as done.
2. More importantly, it prescribes the **wrong kind of test**. "Run it against input it
   should reject" varies the *input* while holding the *frame of reference* fixed. Every
   negative test written in 0.24.0 did exactly that: same base, different version values
   (backwards / unchanged / forward). The new defect lived in **which base was chosen**, so
   no amount of input-variation could surface it.

Same family — "a guard that does not actually check what it claims" — but a different
mechanism. Executing the pre-registered escalation would have produced a plausible-looking
non-fix: a freshly negative-tested `validate-plugin.sh` and an untouched real bug.

### The mechanism: a guard measured from the wrong reference

`check-version-bump.sh` compared the working tree against the **merge base**. That answers
*"did this branch bump since it forked?"* — not *"will main's version increase?"* Reproduced
in a scratch clone:

```
branch forked at 0.26.1, content change, bumped to 0.26.2
main meanwhile at 0.26.4
Version-bump check PASSED.        # and merging sets main's version BACKWARDS to 0.26.2
```

That is the *same regression class* the third addendum fixed, arriving through a door that
fix left open. The operator was made semver-aware; the operands were never questioned.

Second finding, worse in a quiet way: the **push-to-`main` invocation was vacuous**. The
workflow passes `origin/main` while `HEAD == origin/main`, so `merge-base(main, HEAD) == HEAD`
and it compared main against itself — reporting "unchanged" and passing under every possible
input. The repo believed it had a post-merge backstop. It had a no-op wearing a green check.

### The real lesson: the friction was load-bearing

The obvious read of "N PRs each need their own version" is *pointless ceremony, remove it*.
That read is wrong, and acting on it would have shipped the bug.

Because a stale PR and current `main` both edit the same `"version":` line, **git conflicts**
— and that conflict, not the guard, is what actually stopped a backwards version from
merging. Safety and friction were the same mechanism. Remove the conflicts naively (drop the
per-PR bump) and the only real protection disappears with them, leaving a guard that had
already been demonstrated to pass the failing case.

> **Before removing friction, establish what the friction was accidentally protecting.**
> Long-standing annoyances are load-bearing more often than they look, especially where they
> overlap a guard nobody has negative-tested along that axis.

The fix had to do both at once: changesets (a new file per PR — cannot conflict) *plus* a
two-mode guard that supplies the protection the conflicts had been providing by accident.

### Learning #1 is retired, not refined

> ~~Multiple open content PRs → merge oldest-first, one patch version per PR.~~

Correct for three sessions; now unnecessary. The version is a monotonic counter on `main`
while PRs are parallel writers — a plain write-conflict on a shared resource, and the
stacked-bump ritual was the manual serialization protocol working around it. Changesets
remove the contention: PRs declare `bump: patch|minor|major` in their own file, merge in any
order, and `scripts/release.sh` computes the number once on `main`.

**Merge freely, release once.** `main` is red between the first merge and the release, by
design — content on `main` at an unchanged version has reached zero installs, so the failure
is now loud instead of silent.

### Learning #3, refined again: the delete can be async

`--delete-branch` half-failed on both worktree-held branches, as the second addendum
predicts. But with `delete_branch_on_merge: true` (enabled 2026-07-27 by that same addendum),
the remote delete is **asynchronous** — an immediate `git ls-remote` reported the branch
alive, and it cleared on re-check seconds later. The second addendum's rule, applied
literally, now produces a *false* positive and sends you to delete a branch already being
reaped.

| Signal | Response |
|---|---|
| `--delete-branch` errors, `ls-remote` says the branch is alive | **Re-check once after a few seconds** before deleting by hand |

### Cumulative rule of thumb

| Signal | Response |
|---|---|
| A guard passes | Ask what it compares *against*, not just how it compares |
| A guard runs on the target branch | Confirm the invocation can fail at all — compute its comparison by hand once |
| Long-standing friction you want to remove | Find what it was accidentally protecting first |
| Negative tests exist | Check which axis they vary; the untested axis is where the bug is |

### Fourth-addendum action items

- [x] `scripts/check-version-bump.sh`: rewritten with PR mode + a non-vacuous main mode (#86)
- [x] Changesets (`.changes/` + `scripts/release.sh`) replace in-PR bumps (#86, released 0.27.0)
- [x] `scripts/test-version-checks.sh`: 20 cases, **varying the base**, not just the version
- [x] CLAUDE.md: "stacked bumps" section replaced with the changeset flow and this why
- [x] `/playbook:merge-prs`: classifies repos as changeset-style vs bump-in-PR style
- [ ] The third addendum's item is still open and still worth doing — but reframed: audit
      each guard by asking *what it compares against*, then negative-test **that** axis.
      `validate-plugin.sh`'s new command-surface check was built this way (verified in both
      directions before merge); the older sections of it were not.

---

## 2026-09-11 fifth-incident addendum — Learning #3's rule fires on the wrong axis

A fifth merge-all-open-PRs session (8 PRs, #93–#99/#101, 0.28.0 → 0.28.1). The changeset
flow from the fourth addendum worked exactly as designed — merge order was free, no version
conflicts, one release at the end. Learnings #2 and #3's *worktree* behaviour held.

**Learning #3 broke again — the fourth time this one rule has been wrong.** This time not
because the claim is false, but because its **trigger condition is too broad**, and that
cost a live PR its head branch.

### What happened

`gh pr merge 99 --squash --delete-branch` failed:

```
GraphQL: Base branch was modified. Review and try the merge again. (mergePullRequest)
```

(#101 had squash-merged seconds earlier.) The script then applied the rule as written —
*"treat any non-empty error as 'the remote branch probably survived'"* → `git ls-remote`
says 1 → `git push origin --delete`. That deleted the only remote copy of an unmerged PR's
head.

### The mechanism: a rule that keys on the presence of an error, never on which error

Every prior observation behind Learning #3 came from **post-merge cleanup** failures — a
worktree holding the branch (2026-07-26), a dirty working tree (same), async server-side
reaping (2026-08-04). In all of them the merge *succeeded* and only gh's local step broke.
The rule generalised correctly across those triggers — "don't pattern-match the message" —
and then over-generalised past the boundary of the family it was derived from:

| `gh pr merge` error class | Merge landed? | Correct response |
|---|---|---|
| Local cleanup failed (worktree / dirty tree / async reap) | **Yes** | Verify, delete the survivor |
| Merge itself rejected (`Base branch was modified`, not mergeable, checks red) | **No** | **Touch nothing.** Fix and retry |

The rule's text covers both rows and prescribes row 1's action for both.

**This is the fourth addendum's own lesson, arriving in prose instead of a shell script.**
That addendum's finding was: *a guard passes — ask what it compares **against**, not just
how it compares.* `check-version-bump.sh` varied the version while holding the base fixed.
Learning #3 varies the error *message* while holding "the merge succeeded" fixed. Same
defect — an untested axis — one layer up, in a command doc rather than a guard.

> **A prose rule has a frame of reference too.** When a rule says "treat *any* X as Y",
> ask what the X's you observed had in common that the rule no longer requires.

### Auditing the pre-registered escalation (per `/playbook:learnings`)

The fourth addendum left open:

> - [ ] Audit each guard by asking *what it compares against*, then negative-test **that** axis.

**Would it have caught this one? No** — it scopes itself to *guards*, meaning the executable
scripts in `scripts/`. The defect here is in a **command doc**, which nothing in the repo
executes or tests. Same family (an untested frame of reference), different medium.

**Would it have *caused* it? No** — orthogonal, not harmful. (Third branch per 0.28.1.)

Re-registered, widened past `scripts/`:

> **Next escalation:** when a prose rule in a command doc says "treat *any* A as B", list the
> concrete A's that produced it and check whether they share a precondition the rule dropped.
> Apply to the `merge-prs`/`monitor-pr` "any error" rules first — they have now been wrong
> four times, which is itself the signal.

### Recovery — worktrees share one object store

Fully recoverable, and worth knowing before it is needed. `git push --delete` removes only
the *remote* ref; the objects survive in any worktree, reflog, or remote-tracking ref that
still references them. All five worktrees of this repo share one object store, so:

```bash
git push origin 888a72f:refs/heads/improve/merge-prs-sweep-learnings
gh pr reopen 99
```

restored #99 at its original head SHA, and it re-merged cleanly as `0f7f933`. Total content
lost: none. **Do the restore before moving to the next PR** — objects unreferenced by any ref
are GC candidates.

### One more state nobody had documented: CLOSED-and-unmerged

When the failed merge was observed, `gh pr view 99 --json state,mergeCommit` already read
`CLOSED` with a **null** merge commit — *before* any branch deletion (GitHub's timeline puts
the close 28 seconds ahead of the `head_ref_deleted` event). So a failed `gh pr merge` can
leave a PR closed and unmerged, which no step in `merge-prs.md` anticipates; it assumes a
merge either succeeds or leaves the PR open.

Honest scoping: the *ordering* is verified from the timeline API. The exact cause of that
close is **not** — the close event lands within one second of #101's merge, which the
"`gh pr merge` closed it" hypothesis does not explain. Left unresolved deliberately rather
than asserted. It does not change the fix: read `state` + `mergeCommit` and require
`MERGED` before touching a branch, which is correct under every hypothesis.

### Updated rule of thumb (cumulative)

| Signal | Response |
|---|---|
| `gh pr merge` exits non-zero | **Read `state` + `mergeCommit` first.** Only `MERGED` + non-null sha makes the branch disposable |
| Error is a *cleanup* failure (worktree / dirty tree) | Merge landed — verify the remote branch, re-check for async reap, then delete |
| Error is a *merge* rejection (base modified / not mergeable / checks red) | Nothing merged — do not delete, do not prune. Fix and retry |
| You deleted a branch you shouldn't have | `git push origin <sha>:refs/heads/<branch>` + `gh pr reopen`; sibling worktrees share the object store |
| A rule says "treat *any* A as B" | Ask what the observed A's had in common that the rule stopped requiring |

### Fifth-addendum action items

- [x] `/playbook:merge-prs` Step 5.6: merge-verdict gate (verdict table) before any branch
      deletion; recovery recipe; anti-pattern entry
- [x] `/playbook:monitor-pr`: same gate added to the post-merge block — it is the one that
      actually runs per-PR
- [ ] The fourth addendum's guard audit, widened to prose rules (re-registered above)

---

## 2026-09-13 sixth-incident addendum — the run that ships a command-doc fix is the run least protected by it

A sixth merge-all-open-PRs session (1 PR, #102, 0.28.1 → 0.28.2). **Nothing went wrong.**
The changeset flow, the worktree rules, and the brand-new merge-verdict gate all behaved.
This addendum records a *latent* hazard noticed during the run, not a failure — and says so
plainly, because inflating a clean run into an incident is its own way of making a doc
untrustworthy.

### The observation

The only PR in the queue was #102, which rewrites the `--delete-branch` rule in
**`merge-prs.md` and `monitor-pr.md` — the two command docs driving the sweep that was
merging it.** A command's instructions are loaded when it is invoked, so merging #102
changed nothing about the run in progress. The sweep executed the *pre-fix* rule from the
first command to the last.

It was harmless this time only because no `gh pr merge` failed. Had one failed, the session
would have applied the exact rule #102 exists to remove — and deleted a live PR's head
branch while merging the fix for deleting live PRs' head branches.

### The mechanism: the exposure is correlated, not incidental

This is the part worth keeping. A PR that fixes `merge-prs.md` is, in this repo, almost
always merged *by* `merge-prs.md`. So the set of runs that ship a merge-prs fix is ~100%
runs that exercise merge-prs — the bug's blast radius and the fix's delivery vehicle are
the same code path. That is not bad luck; it is structural, and it means this class of fix
is systematically delivered under the conditions it was written for.

**It has now happened twice, and only the first was recorded** — as a parenthetical inside
a correction note in `monitor-pr.md`, never as a hazard with a prescribed response:

> *"The 4th arrived while merging the very PR that fixed this note — via the
> dirty-working-tree trigger rather than the worktree one, which is how the 'any error, not
> just the worktree message' generalization was found."* — 2026-07-26

| Date | Ran the pre-fix rule? | Outcome |
|---|---|---|
| 2026-07-26 | Yes | **Beneficial** — the live recurrence is what exposed the over-narrow "worktree message" framing |
| 2026-09-13 | Yes | **Benign** — no merge failed, and the gate was applied by hand |

Two for two, neither costly. The honest read is that this is **low severity, high
recurrence**: it will keep happening on every self-modifying command fix, and one day the
draw won't be benign.

### Full propagation is four stages, not one

The load-time lag is only the last link. For a marketplace-embedded plugin a command-doc
fix reaches an actual invocation after: (1) merge to `main`, (2) `release.sh` bumps the
version — auto-update is version-keyed, so an unbumped change reaches zero installs,
(3) the install pulls it (`claude plugin marketplace update && claude plugin update`), and
(4) the *next* invocation loads it. A session already holding the command is behind all four.

### Auditing the pre-registered escalation (per `/playbook:learnings`)

The fifth addendum registered:

> **Next escalation:** when a prose rule in a command doc says "treat *any* A as B", list the
> concrete A's that produced it and check whether they share a precondition the rule dropped.

**Was it executed? Yes**, by #102 — both "any error" rules are now scoped to a `MERGED`
verdict. Re-running the audit this session (`grep -rniE 'treat \*?any\*?|any non-empty'`
over `commands/` and `skills/`) returns only those two sites, both correctly scoped. The
escalation worked as designed.

**Would it have caught *this* finding? No.** Simulated against this session, the audit
inspects the *content* of rules and reports "no dropped precondition." The defect here is
not in what a rule says — it is in **when a rule arrives**. Same doc, different axis:
the fifth addendum was about a rule's frame of reference, this is about its delivery latency.

**Would it have caused it? No** — orthogonal.

### The fix

`merge-prs.md` Step 2 gains a self-modification check, because the detection is a one-liner
on data triage already has:

```bash
gh pr diff <N> --name-only | grep -E 'commands/workflows/(merge-prs|monitor-pr)\.md'
```

A hit means the PR edits the instructions driving this run. The response is not to skip it —
it is to **read the behavioral change out of the diff and apply it by hand for the rest of
the run**, flag it in the plan, and say so in the final report.

### Re-registered escalation

> **Next escalation:** if a third occurrence lands — or any occurrence where running the
> pre-fix rule actually costs something — stop treating this per-command. Generalize the
> check to *any* PR in the queue that modifies a command or skill file the session has
> invoked, and make the "apply it by hand" step a named, reported queue action rather than
> operator diligence. The signal to watch for is a report that says "applied the fix
> manually" without the plan having predicted it.

### Updated rule of thumb (cumulative)

| Signal | Response |
|---|---|
| A queued PR edits the command doc you are running | Loaded instructions are pre-fix. Extract its behavioral change and hand-apply for this run; note it in the plan and report |
| A command-doc fix merged and you expect it to be live | It is not, until version bump → install pull → next invocation. Four stages, not one |

---

## 2026-09-16 seventh-incident addendum — the rule this doc already had, in a place it never reached

Seventh `/playbook:merge-prs` run on this repo. Three open PRs; **#105** and **#106** merged
cleanly and released as **0.28.4**. The finding is **#104**, which should never have existed.

### What happened

#104 was queued **MERGE** by triage: complete diff, valid changeset, guard green, mine, no
review threads. Every triage signal said ship it. After `git merge origin/main` in Step 5.2,
its effective diff against `main` was *only* the changeset file — `close.md` on the branch had
become byte-identical to main's blob. The content had shipped **weeks earlier as #101**
(`bdfaa3d`), and the changeset body was already published verbatim at `CHANGELOG.md:38`.
Merging would have added a second changeset duplicating a released entry while changing no code.

It was caught **incidentally** — by reading a diff run for an unrelated reason. No step asked
the question.

### The mechanism: ancestry is not content, and squash-merge is where they diverge

The squash commit on `main` shares no history with the branch it replaced. So every
ancestry-shaped test reports a fully-landed branch as unmerged:

| Test | On #104's head (`9ffd757`) | Truth |
|---|---|---|
| `git merge-base --is-ancestor 9ffd757 origin/main` | NOT ANCESTOR | content is 100% in main |
| `git log --branches --remotes --not origin/main -- close.md` | lists it | " |
| `gh pr view` / mergeability / CI | all green, looks like new work | " |
| **content comparison of added lines vs `origin/main`** | **0 of 20 lines missing** | **correct** |

### The part that makes this a process failure, not an accident

**This doc already contains the rule.** The 2026-07-27 third addendum, §2 "Branch sweeps need
a content check and an open-PR check", states it plainly — *"Branch looks unmerged → Check
content — squash-merge discards ancestry."* It was written for **branch-deletion sweeps** and
never propagated to the other two operations that ask the same question.

Worse, the *upstream* cause is the same blind spot one command earlier. #104 was opened by a
2026-09-16 `/playbook:learnings` **Step A2** pre-check, which prescribes exactly
`git log --oneline --branches --remotes --not origin/main -- <file>` and reads its output as
a verdict. Re-running that command on 2026-09-16 returns **four** commits for `close.md`:

```
476240e  improve(close): treat cross-timezone checkpoint dates as ambiguous
a1cfb1f  improve(design-critique, close, learnings): critique the real component
9ffd757  improve(close): install worktree deps, never symlink them
75beacf  feat(close): org-deposit phase for agent-workforce repos
```

Checked by content, **all four are already in `main`** — a **4-of-4 false-positive rate**. The
command that exists to catch stranded fixes was manufacturing phantom ones, and `merge-prs`
triage had no check to catch what it manufactured.

So the same defect appeared at two stages of one pipeline, and the fix for it had been sitting
in this file for seven weeks.

### Auditing the pre-registered escalation (per `/playbook:learnings`)

The sixth addendum registered:

> **Next escalation:** if a third occurrence lands — or any occurrence where running the
> pre-fix rule actually costs something — stop treating this per-command. Generalize the
> check to *any* PR in the queue that modifies a command or skill file the session has
> invoked, and make the "apply it by hand" step a named, reported queue action.

**Did it fire? No.** No PR in this queue edited `merge-prs.md` or `monitor-pr.md`; the Step 2
check was run and returned clean. The trigger condition genuinely did not occur.

**Would it have caught this one?** Simulated against this queue: the generalized check
intersects each PR's changed files with *commands the session has invoked* — here
`{merge-prs.md, monitor-pr.md}`. #104 changes `close.md`, which this session had not invoked
at triage time. **It returns no hits, and #104 proceeds to MERGE.** So: no.

**Would it have caused it? No** — orthogonal axis. The sixth addendum is about *when a fix
arrives* (delivery latency); this is about *whether a fix is still needed* (landedness). Same
family — "merge-prs triage missed something" — different mechanism.

That distinction is the point the previous six addenda keep re-teaching: **a recurrence in the
same family is not the same mechanism.** Executing the pre-registered escalation here would
have produced a plausible-looking non-fix.

### The fix

Ship the content check as a **script**, not as prose in two places — per the rule #105 merged
into `learnings.md` the same day ("a technique that took a paragraph is usually a script that
takes one argument"):

- **`scripts/content-landed.sh <ref> [base]`** — exit 0 if every line the ref added is already
  present in the base, exit 1 if unique content remains. Treats `.changes/*.md` as *expected*
  to be absent, since `release.sh` deletes changesets once consumed — without that carve-out
  every merged PR looks unique.
- **`merge-prs.md` Step 2** gains an already-on-`main` triage bullet. Verdict on exit 0 is
  **SKIP**, not close — closing a PR remains an ESCALATE.
- **`learnings.md` Step A2** now labels its `git log` a *candidate list*, requires a
  per-candidate content confirmation, and adds a route for "already in main ⇒ not stranded".

The script was verified in both directions before shipping: `9ffd757` and `476240e` → exit 0
against `origin/main`; `476240e` → exit 1 against `bc6fbd7` (a base predating its merge);
bad-ref and no-arg → exit 2. A checker that only ever says "landed" passes the positive tests
alone, which is why the negative case was run.

### Re-registered escalation

> **Next escalation:** if a *fourth* operation turns out to ask "has this landed?" by ancestry,
> stop patching call sites. The rule is not per-command — it is that **ancestry is never a
> valid landedness test in a squash-merge repo**. Promote it to CLAUDE.md as a repo-level
> invariant and add a guard that greps command docs for the ancestry idioms
> (`--is-ancestor`, `--not origin/main`, `branch --merged`) used without an adjacent content
> check. Signal to watch for: any report describing a "stranded" or "unmerged" fix that turns
> out to be live.

### Updated rule of thumb (cumulative)

| Signal | Response |
|---|---|
| A queued PR edits the command doc you are running | Loaded instructions are pre-fix. Hand-apply its change for this run; note it in plan and report |
| A command-doc fix merged and you expect it to be live | It is not, until version bump → install pull → next invocation. Four stages, not one |
| **Any question of the form "did this land?"** | **Answer by content, never by ancestry — squash-merge discards ancestry. `--is-ancestor`, `--not origin/main`, and `branch --merged` are all candidate generators, not verdicts** |
| **A PR looks like complete, unmerged new work** | **Confirm against `main` by content before queueing it. Metadata cannot see a squash-merged duplicate** |
| **A changeset is the only file left in a PR's diff vs main** | **The content already landed. SKIP; do not close (ESCALATE)** |
| **A tool reports a fix as "stranded" / "never merged"** | **Verify before acting. Measured false-positive rate of the ancestry form on this repo: 4 of 4** |
