---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Added
- **`/playbook:merge-prs` — flag a queued PR that edits the command driving the run.** A command's instructions are loaded at invocation, so merging a fix to `merge-prs.md` or `monitor-pr.md` does nothing for the sweep in progress: it keeps executing the pre-fix rule to the last PR. The exposure is correlated rather than incidental — a PR fixing `merge-prs.md` is almost always merged *by* `merge-prs.md`, so this class of fix is systematically delivered under the exact conditions it was written for. Triage now runs a one-line detection (`gh pr diff <N> --name-only | grep -E 'commands/workflows/(merge-prs|monitor-pr)\.md'`); a hit means read the behavioral change out of the diff, hand-apply it for the rest of the run, and report it. The final report also now states that a merged command fix is not live until the version bumps, the install pulls it, and the command is invoked again. Observed twice (2026-07-26, 2026-09-13), benign both times, and previously recorded only as a parenthetical inside an unrelated correction note.
