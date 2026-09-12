---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Added
- **`/playbook:debug` — read the whole failure artifact, not your grep of it.** A grep answers the question you asked, and a confidently wrong diagnosis is the usual result of asking a narrow one. When a step writes a failure artifact, open it whole (`sort -u <errors-file>`) and count the *distinct* error classes before naming a cause — fixing one of four is indistinguishable from fixing none.
- **`/playbook:debug` — N identical failures across N retries is a signature, not flakiness.** If every attempt fails the same way, the retry loop has no feedback edge: it is resampling byte-identical input, not converging. Genuine flakiness produces varied failures. If you cannot name what differs between attempts, `maxAttempts` is a cost multiplier, not a reliability feature.
