# Changesets

A **changeset** is one file describing one change: which plugin it touches, how big the
version bump should be, and the CHANGELOG prose. PRs add a changeset instead of editing
the version.

## Why this exists

The version is a single monotonic counter on `main`, but PRs are parallel. When every PR
had to bump the version itself, N open PRs could not all be correct at once — they would
all claim the same next number — so merges had to serialize, one patch version per PR, and
each PR's version-file edits conflicted with every other PR's.

Worse, that conflict was doing load-bearing safety work nobody designed: `check-version-bump.sh`
compares against the **merge base**, so it verifies "this branch bumped since it forked,"
not "main's version will increase." A branch forked at 0.26.1 bumping to 0.26.2 passed the
guard even when `main` had already reached 0.26.4. The only thing stopping that merge from
dragging main's version *backwards* was git conflicting on the version lines — the same
friction everyone was trying to get rid of.

A changeset is a **new file per PR**, so it cannot conflict. Any number of PRs merge in any
order. The version is computed once, on `main`, by `scripts/release.sh`.

## Writing one

Create `.changes/<short-slug>.md`:

```markdown
---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **What changed** — why it mattered, and what it prevents now.
```

- `plugin` — directory name under `plugins/`. Defaults to `product-playbook-for-agentic-coding`.
- `bump` — `patch` | `minor` | `major`, per CLAUDE.md's rules (MINOR for new commands/agents/skills,
  PATCH for fixes and doc updates, MAJOR for breaking changes).
- Body — goes into CHANGELOG.md verbatim, under its `###` heading. Write it for the person
  who will read it in six months, not for the diff.

The slug is only a filename; anything unique works. `pr-<number>` or a short description
both read fine.

## Releasing

After merging (one release covers any number of merged PRs):

```bash
scripts/release.sh          # consumes .changes/*, bumps, writes CHANGELOG, deletes changesets
git add -A && git commit -m "chore: release <version>" && git push
```

`scripts/release.sh --dry-run` shows what it would do without touching anything.

Between a merge and the release, CI on `main` fails with "unreleased changesets" — that is
the forcing function. Propagation is version-keyed, so content sitting on `main` at an
unchanged version has not reached a single user's install; a red main is the loud version
of a problem that used to be silent.
