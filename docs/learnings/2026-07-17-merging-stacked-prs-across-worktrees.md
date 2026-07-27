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
- [ ] **Enable `delete_branch_on_merge` on this repo** — repo setting, needs owner action
- [ ] Sweep the 24 stale remote branches (two are held by live worktrees — leave those)
