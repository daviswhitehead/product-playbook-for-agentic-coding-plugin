# project-state.md

<!-- One per project, at projects/<state>/<project>/project-state.md. The only thing that survives a
     stop (usage limit, credits, crash, compaction) is the repo, so this file is what a restarted run
     reads first. Update it at EVERY state change (task started, PR opened, check finished, decision
     recorded) and commit it. An index, not a wiki: under ~200 lines; detail lives in the PRD, plan,
     tasks and REVIEW.md. Reading a 2k-token state file costs about a tenth of resuming a long chat. -->

updated: [ISO time]   by: [lead | agent name]   head: [integration branch @ sha]
project: [slug]   decision-rights: [link to the Decision rights block in REVIEW.md or the PRD]   budget: [$N / spent $M · CI min N / M]

## Now
[One line: what is running right now and who owns it.]

## Next (queue)
<!-- Ordered. Each item is idempotent and starts by verifying the current state of its PR/branch. -->
| id | done means (one sentence) | owner role | depends on | status |
|----|---------------------------|------------|------------|--------|
| [T1] | [...] | [implementation] | [-] | [ready / blocked / done] |

## In flight
<!-- Lets a restart message a live sub-agent or know it died and re-dispatch the item. -->
| id | branch / worktree | PR # | head sha | last green check | sub-agent id + model |
|----|-------------------|------|----------|------------------|----------------------|

## Waiting on
<!-- founder | CI | quota | external. Founder items also go in decisions-queue.md. -->
| what | on whom | since | default if no answer in 48 h |
|------|---------|-------|------------------------------|

## Decisions (one line each)
- [date] [decision] — [link to rationale]

## Resume notes
[What a cold reader must know: invariants, contracts (testIDs, event names, paths), traps already hit, commands that work here.]
