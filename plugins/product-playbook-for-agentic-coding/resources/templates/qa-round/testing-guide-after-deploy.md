# After the deploy: [Project] QA round [N] (about [m] minutes)

<!-- projects/<state>/<project>/qa/round-<N>/testing-guide-after-deploy.md. Written ONLY after the deploy,
     and only after an agent re-ran every step below on production (read-only wherever it can: no test
     writes, analytics blocked). Same table rules as testing-guide.md; the guard allows "after deploy"
     wording in this file only. /playbook:close-project refuses while the "Production, after deploy" line
     below still holds its placeholder. Delete this comment. -->

**Production, after deploy:** [YYYY-MM-DD · deployed sha or version · re-run by <agent> · result: n of n steps passed]

*Everything below is live on production now and an agent already ran it there.*

## 1. [Device and account] (about [m] min)

| # | Do | Expect | Agent test | Evidence |
|---|----|--------|------------|----------|
| A1 | 1. Open [production URL / page]. 2. Tap **[exact label]**. | [The screen you should see] | [Production re-run: what it read, when] | `[/abs/path/to/shot.png]` |
