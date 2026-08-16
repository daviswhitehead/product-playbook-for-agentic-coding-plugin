# Session Checkpoint
**Date**: 2026-07-27 10:06 EDT
**Branch**: daviswhitehead/merge-open-prs-v1 (even with origin/main)

## Current Task
Merge all open PRs, capture learnings, and clean up branches/worktrees. **Complete** —
zero open PRs, **one** remote branch (`main`), version **0.24.7**, local install matching.

## Status
- **Done this session** (continuation of the 2026-07-26 arc; see
  `2026-07-26-merge-open-prs-v1.md` for the earlier half):
  - Merged **#73** (0.24.7, evidence-based watch windows) and **closed #74** as a duplicate.
  - **Captured the learnings** that produced #69 (0.24.4) and #70 (0.24.5) — a false claim
    in the playbook's own `monitor-pr.md`.
  - **Rescued orphaned content twice**: #68 (5 never-committed transcripts, one 127 KB) and
    #72 (a transcript truncated in main, full copy only on a local branch).
  - **Swept branches 25 → 1.** 21 remote + 7 local deleted, all verified by *content*.
  - `delete_branch_on_merge` enabled on both repos; verified working on three merges since.
- **In progress**: nothing.
- **Blocked on**: nothing.

## Key Decisions
- **Closed #74 rather than merging it.** Its only content not already in main was
  `"version": "0.23.0"` — merging would have rolled the plugin back seven patch releases
  and, because propagation is version-keyed, silently stalled every install until the
  version climbed back past 0.23.0.
- **Verified branch staleness by content, not ancestry.** Squash-merges discard commit
  ancestry, so `git branch --merged` and `merge-base --is-ancestor` both report false
  negatives. Content comparison caught two branches with live PRs that the earlier list
  would have deleted.
- **Kept the `~/GitHub` checkout, switched it to `main`.** Its `.git` is a *directory* —
  it is the primary clone all other worktrees hang off, not a scratch worktree.
- **Left both stashes alone** — they belong to other branches.

## Open Questions
- Two old stashes (`daviswhitehead/git-cleanup`, `main`) hold lines not literally present in
  main — but they predate PR #10, and those files have been rewritten many times since, so
  "absent" likely means "reworded", not "lost". Worth a look by whoever owns them; **they
  live in the shared `.git`, so archiving this worktree cannot lose them.**
- `docs/superpowers/plans/2026-04-13-*-tasks.md` is a fully reconciled April project. Delete
  or leave as history?

## Next Steps
1. Nothing blocking. The repo is clean: 1 branch, 0 open PRs, versions in lockstep.
2. If archiving this workspace: everything is pushed — see "Context" for the verification.
3. Consider whether the April tasks doc still earns its place.

## Hot Files (modified this session)
- `plugins/.../commands/workflows/monitor-pr.md`: the `--delete-branch` correction (0.24.4)
  and its generalization to any local-cleanup error (0.24.5).
- `plugins/.../resources/templates/tasks.md`: evidence-based watch windows (0.24.7).
- `plugins/.../commands/workflows/close.md`: freshness check (0.24.6, via #71).
- `docs/learnings/2026-07-17-merging-stacked-prs-across-worktrees.md`: dated addendum
  correcting Learning #3, plus a strikethrough on the original wrong sentence.
- `CHANGELOG.md` + both manifests: 0.24.3 → 0.24.7.

## Out-of-Repo Changes (runtime / system / external)
- **`delete_branch_on_merge` set to `true`** on `daviswhitehead/product-playbook-for-agentic-coding-plugin`
  **and** `daviswhitehead/chef-chopsky` (by the user). Verified via
  `gh repo view --json deleteBranchOnMerge`. This is the systemic fix for the stale-branch
  backlog. Rollback: untick "Automatically delete head branches" in Settings → General.
- **Plugin install upgraded 0.24.3 → 0.24.7** at user scope, in four steps across the
  session. Still requires **two** commands each time — `claude plugin marketplace update`
  refreshes only the catalog; `claude plugin update <plugin>@<marketplace>` moves the install.
- Install path: `~/.claude/plugins/cache/product-playbook-marketplace/product-playbook-for-agentic-coding/0.24.7`
  (sha `5d317a0`). Prior versions remain on disk (0.22.4 → 0.24.6) for rollback.
- **`~/GitHub/product-playbook-for-agentic-coding-plugin` switched from
  `improve/close-checkpoint-durability` to `main`** and pulled. It was clean before and after.
- Removed scratch worktree `/private/tmp/wt-plugin3`.
- **21 remote + 7 local branches deleted.** GitHub keeps deleted branches restorable.

## Context the Next Session Needs
- **Slash-command skills DO reload from disk mid-session.** The `/playbook:close` invoked at
  10:00 today carried the 0.24.6 freshness check merged ~an hour earlier, without a restart.
  An earlier claim in this session that a restart was required was wrong. (The plugin's
  *version-keyed* propagation still needs `claude plugin update`; that is a separate thing
  from whether a session re-reads the installed files.)
- **Squash merges break every ancestry-based "is it merged?" check.** Compare file contents.
  `feat/instrumentation-acceptance-is-the-metric` reported unmerged with a 97-line diff while
  being 100% present in main.
- **`gh pr merge --delete-branch` half-fails on ANY local-cleanup error** — worktree holding
  the branch *or* a dirty working tree — leaving the remote branch alive. 5 occurrences today.
  Now moot here thanks to `delete_branch_on_merge`, but still true on repos without it.
- **Check for open PRs before bulk-deleting branches.** Deleting a branch closes its PR. Two
  PRs (#73, #74) opened mid-session and would have been silently closed by a sweep built from
  a stale list.
- `/tmp/wt-close` is an unrelated pre-existing directory, **not** a worktree of this repo.
- Repo convention tracks `.specstory/history/`. Stage transcripts explicitly — a `git add -A`
  swept one into #57 earlier in this arc.
