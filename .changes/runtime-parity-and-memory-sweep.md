---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Improved
- **debug: the execution context includes how the process is started.** Reproduce with the production start command, preloads/instrumentation and behavior-changing flags, not `tsx`/`next dev`/the test runner. A fix that changes how a process boots is a runtime change: re-verify primary behavior under it. Found when Sentry's `--import` preload silently broke chat streaming, usage and tracing in production for ten weeks while every local run and test was green (chef-chopsky, 2026-10-06).
- **learnings: "broken since X" windows check lockfile + deploy-config history (the later of the two); escalation audits also ask whether an earlier occurrence's fix caused this one**, since a guard that requires a configuration locks in its side effects. A new pre-promotion step sweeps the agent's private memory for team-relevant gotchas that would otherwise never reach shared docs.
- **tech-plan template: Testing Strategy now asks for runtime parity and truth-surface acceptance**, so plans name which check runs the built artifact under the production start command and which production read proves an instrumented change.
- **work: Step 1.5 now includes a cost checkpoint** before every PR, ready-mark or expansion past the original ask (state the cost and running total; fold, don't fork; one expensive-path PR per change; bundle cheap paths; verify locally first; clean up worktrees on merge), plus a Short Status Updates principle. From a session where 11 PRs, 33 CI runs and 4 evals did work a batched plan would have done in about 4 PRs.
