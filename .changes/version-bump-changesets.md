---
plugin: product-playbook-for-agentic-coding
bump: minor
---

### Changed
- **Version bumps move out of PRs and onto `main` (changesets)** — PRs now add a file under
  `.changes/` declaring `bump: patch|minor|major` plus its CHANGELOG prose, instead of editing
  the version. `scripts/release.sh` consumes those files on `main`, computes each plugin's new
  version (highest bump type wins), updates `plugin.json` + `marketplace.json` + `CHANGELOG.md`,
  and deletes the changesets.

  **Root cause this fixes.** The version is a single monotonic counter on `main`, but PRs are
  parallel writers. Requiring each PR to advance it made N open PRs mutually exclusive — they
  all wanted the same next number — which forced serialized merges (one patch version per PR:
  0.22.1→0.22.4 in 2026-07, 0.23.0→0.24.3 across nine PRs in 2026-07-26, 0.26.1→0.26.4 today)
  and made every PR's version-file edits conflict with every other PR's. A changeset is a new
  file, so it cannot conflict; merge order is free and one release covers the whole batch.

### Fixed
- **`check-version-bump.sh` was checking the wrong thing, and its `main` run could never fail** —
  It compared the working tree against the **merge base**, which verifies "this branch bumped
  since it forked", not "main's version will increase". A branch forked at 0.26.1 and bumped to
  0.26.2 passed the guard even when `main` had already reached 0.26.4 — and merging it would drag
  the version *backwards*, the exact failure the guard's own comments warn about. The only thing
  preventing that was git conflicting on the version lines, i.e. the friction above was doing
  load-bearing safety work nobody designed. Separately, the push-to-`main` invocation compared
  `main` against itself, always reported "unchanged", and could not fail under any input, so
  there was no post-merge backstop at all.

  The script now has two modes. **PR**: the changed plugin must declare a changeset (a hand bump
  is still accepted, with a nudge). **main**: fails while changesets sit unreleased, and fails if
  plugin content changed without the version increasing versus the previous commit — a real
  backstop that catches a duplicate or backwards version however it arrived.

### Added
- **`scripts/test-version-checks.sh`** — 20 cases across both scripts in a sandbox repo,
  including the two the old guard was structurally blind to: content merged at an unchanged
  version, and a version moving backwards on `main`.
- **`/playbook:merge-prs` distinguishes the two release styles** — Step 0.5 now classifies a repo
  as changeset-style or bump-in-PR style. Changeset repos skip per-PR version assignment entirely
  and run a single release after the queue drains (new Step 5.9); bump-in-PR repos keep the
  stacked behaviour and get told in the final report that changesets are the fix. Step 5.6 also
  learned that server-side branch auto-delete is asynchronous, so a branch that looks like it
  survived should be re-checked once before deleting by hand.
