# Session Checkpoint
**Date**: 2026-07-26 15:19 EDT
**Branch**: daviswhitehead/merge-open-prs-v1 (even with origin/main)

## Current Task
Merge all open PRs in the plugin repo, then close out. Complete — **zero open PRs**, main at
`af99548`, version **0.24.3**, local install refreshed to match.

## Status
- **Done this session**:
  - Merged **9 PRs** (#57, #58, #60–#66) as sequential stacked bumps, 0.23.0 → 0.24.3, one patch
    version per PR. Guard green on each; every merge carries a proof-of-completion comment.
  - Included the three drafts (#58, #64, #65) — each was complete, just left unmarked.
  - Rescued stranded WIP from a dormant checkout into **#66** and found the underlying bug was
    worse than described: the archive-detection check added in 0.23.5 had **never executed**.
  - Fixed a fatal `git log` snippet in #64 (`origin/main..--all` → `--branches --remotes --not
    origin/main`) and separated cited from derived thresholds in #65.
  - Refreshed the local plugin install 0.24.1 → 0.24.3 (two steps — see Out-of-Repo).
- **In progress**: nothing.
- **Blocked on**: nothing.

## Key Decisions
- **Merged the drafts.** All three were content-complete; draft status was neglect, not intent.
- **#61 merged as-is rather than waiting on its WIP.** A second session had independently
  reproduced both bugs it fixes, so shipping beat holding. Conflict with #57 resolved by
  narrowing `git add -f docs/checkpoints/` to the explicit file — directory-level force-add
  commits everything the repo deliberately ignores.
- **Left another session's uncommitted WIP untouched**, per the rule #64 added ("surface it,
  don't commit it"). Extracted it read-only into #66 instead. Source checkout never modified.
- **#65: kept both char and line thresholds.** They measure different failure modes — lines ≈
  instruction count (adherence), chars ≈ context cost. Labelled lines as cited (Anthropic:
  "target under 200 lines"; HumanLayer: 300 hard) and chars as derived (~80 chars/line
  assumption, which is far off for terse files).

## Open Questions
- **~20 stale remote branches** predate this session and were left alone. Sweep them?
- Two old stashes exist (`daviswhitehead/git-cleanup`, `main`), both tagged to **other**
  branches — deliberately not touched. Worth a look when their owners next surface.

## Next Steps
1. **Restart Claude Code** — this session still has 0.24.1 loaded; 0.24.3 applies on restart.
2. Discard the superseded WIP in `~/GitHub/product-playbook-for-agentic-coding-plugin`
   (`git checkout -- .`) — verified byte-identical to main, nothing to lose.
3. Expect the next `/playbook:learnings` in a repo with a large CLAUDE.md to demand a trim:
   0.24.3 cut the hard limit 40,000 → 24,000 chars. chef-chopsky was last at 39,985.

## Hot Files (modified this session)
- `plugins/.../commands/workflows/close.md`: step 4 tri-state archive detection; step 6
  `CKPT_FILES` explicit staging + ask-before-force-add.
- `plugins/.../commands/workflows/learnings.md`: Step A2 (check for unmerged fixes), CLAUDE.md
  budget math, new 16k/24k + 200/300-line thresholds.
- `plugins/.../commands/workflows/debug.md`: real-execution-context reproduction; probe the
  live system before blaming config.
- `plugins/.../skills/autonomous-execution/SKILL.md`: negative-test every guardrail.
- `plugins/.../commands/workflows/monitor-pr.md`: proof-of-completion at merge.
- `CHANGELOG.md`, both version manifests: 0.23.1 → 0.24.3.

## Out-of-Repo Changes (runtime / system / external)
- **Plugin install upgraded 0.24.1 → 0.24.3** at user scope. Required **two** commands — the
  first alone is not enough, which is the easy mistake:
  1. `claude plugin marketplace update product-playbook-marketplace` — refreshes the *catalog*
     only. After this the cache read 0.24.3 while the install still read 0.24.1.
  2. `claude plugin update product-playbook-for-agentic-coding@product-playbook-marketplace`
     — updates the actual install.
- New install path: `~/.claude/plugins/cache/product-playbook-marketplace/product-playbook-for-agentic-coding/0.24.3`
  (sha `af99548`). Verified by grepping the on-disk files for 0.24.2/0.24.3 content, not just
  the version string.
- **Rollback**: prior versions remain on disk (0.22.4, 0.22.5, 0.23.0, 0.23.3, 0.23.4, **0.24.1**).
  Revert by pointing `~/.claude/plugins/installed_plugins.json` back at the 0.24.1 path, or
  `claude plugin install ...@0.24.1`.
- Marketplace git checkout at `~/.claude/plugins/marketplaces/product-playbook-marketplace`
  moved `c7e0b78` → `af99548`.

## Context the Next Session Needs
- **Squash merges break ancestry checks.** `feat/instrumentation-acceptance-is-the-metric`
  reports "NOT an ancestor" of main and a 97-insertion three-dot diff, yet **0 lines** are
  missing from main — #59 was squash-merged. Answer "is it merged?" on *content*, never on
  `merge-base --is-ancestor` alone. This is exactly what #64's Step A2 exists to catch.
- **`gh pr merge --delete-branch` silently half-fails** when any worktree holds the branch: it
  errors on the local delete and leaves the **remote** branch alive too. Verify with
  `git ls-remote --heads` afterwards; I had to delete `fix/close-archive-detection` by hand.
- **Three worktrees share this repo.** `~/GitHub/...` (dormant, dirty, superseded) and
  `/private/tmp/wt-plugin3` both sit on merged branches. Their remote branches were left
  undeleted on purpose so those sessions aren't stranded.
- `/tmp/wt-close` is an unrelated pre-existing directory — **not** a worktree of this repo.
  Don't reuse that path.
- Repo convention tracks `.specstory/history/` transcripts (11 committed). Stage them
  explicitly; a stray `git add -A` swept one into #57 mid-session.
