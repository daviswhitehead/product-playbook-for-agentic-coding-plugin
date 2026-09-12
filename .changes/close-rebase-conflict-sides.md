---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **`/playbook:close` — `git rebase`'s `--ours`/`--theirs` are the opposite of merge intuition, so name conflict sides by ref instead.** During a rebase, HEAD is the branch being rebased *onto*, so `--ours` is the work that landed on the target and `--theirs` is your own replayed commit. A close-out resolving a `latest.md` collision "in favor of the newer session" via `git checkout --theirs` therefore keeps the *older* handoff and clobbers the newer one — the exact outcome the freshness rule forbids, reported as a successful resolution. The step now instructs naming the side by ref (`git checkout origin/<target> -- <file>`) and verifying with `git show --stat HEAD`.
