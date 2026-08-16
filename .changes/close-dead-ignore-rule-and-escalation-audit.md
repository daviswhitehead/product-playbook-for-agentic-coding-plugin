---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **`close`: notice dead ignore rules; `learnings`: audit pre-registered escalations** — a gitignored path with tracked files means the rule is dead, so stop re-litigating force-adds; and a recurrence doc's "next escalation" encodes a mechanism assumption that must be re-verified before executing the planned fix.
- **`close`: test every staged path; refuse to commit a dirty index** — `git check-ignore` says nothing about already-tracked paths, and a pre-dirtied index can sweep another agent's in-flight work into a "session checkpoint" commit.
- **`close`: verify merged-ness against the target tip, not the merge base** — `git log <target>..HEAD` over-reports on stale branches and `git cherry` is defeated by squash-merges; use `git diff --stat origin/<target> HEAD`.
- **`close`: name the no-upstream/no-PR branch, and preserve what's on it** — a never-pushed workspace branch with no PR dies with the workspace; push its commits to a named ref before branching away, and re-check before committing, not only at Phase 1.
