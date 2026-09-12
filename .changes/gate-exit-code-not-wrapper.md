---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Added
- **`/playbook:close` — gate-verdict check: read the gate's own exit code, not a proxy for it.** Before marking complete any task whose acceptance is "CI green" or "the suite passes", confirm you read the real verdict. Three proxies routinely lie: a background-task notification reports the *wrapper shell's* exit status (`cmd > log 2>&1; echo "EXIT=$?"` ends on a successful `echo`, so a failing run is announced as "completed, exit code 0"); Playwright exits 0 when a test is `flaky`; and a green path-filtered CI check can mean "passed *or* never ran". Same shape as the instrumented-task check — do not let close-out launder a proxy signal into "verified."
