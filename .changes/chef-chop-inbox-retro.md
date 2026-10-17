---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Changed
- **Capability-first founder handoffs** (`/playbook:work` *Founder Handoffs*, `autonomous-execution` *Reaching the Founder*): try a step yourself (CLI, API, the founder's signed-in browser) before writing him a walkthrough; hand off only passwords/2FA, payments, legal identity and founder-reserved changes; read back the state after he acts; put foot-gun warnings in artifact names. Five "can you do this for me?" asks in one project were all agent-doable, and a filter-import foot-gun warned only in chat silently archived a production-outage alert.
- **"LLM decides, deterministic code acts"** (tech-plan template + `/playbook:tech-plan`): a required *Untrusted Inputs & Executing Paths* section for any feature that reads email, web pages, feeds or user text. Seven security-review rounds patched sanitizers until the executor lost Bash.
- **Conductor brief rules** (`autonomous-execution`): restructure after two security rounds with new findings in one component; never `git stash` in shared workspaces (an empty stash push made `git stash apply` land another session's `stash@{0}`; the stash advice in `close.md` and `learnings.md` now says use a worktree); check recorded founder preferences before adding a gate.
- **Actuator last-mile pre-check** (`/playbook:learnings` Pre-Check C): verify every agent-filed issue/PR reached PR → merge → deploy; 0 candidates with matching issues open means stranded work, not a clean run.
