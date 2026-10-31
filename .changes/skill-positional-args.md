---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **`/playbook:close` cost line read 0 job-min when invoked with arguments** — the skill loader replaced the awk field `$1` with a word of the arguments, turning the sum into an unset variable. `close.md` and `monitor-pr.md` now use `$NF`, and `validate-plugin.sh` fails on a positional parameter in an awk one-liner.

### Changed
- **`close`: a small session writes a dated checkpoint and leaves `latest.md` alone** when other workspaces have live work, so it doesn't displace a larger handoff.
- **`learnings`: read the session JSONL before reporting on an aborted turn** — elided messages can be heartbeats rather than work.
