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

After deleting the PR branch it checks out the default branch and pulls — in a
parallel-agent workspace this strands the session on `main` without warning. Re-checkout
your working branch after merging. If another worktree holds the branch, the local delete
fails harmlessly (remote still deleted), leaving that checkout on a remote-less branch.
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
