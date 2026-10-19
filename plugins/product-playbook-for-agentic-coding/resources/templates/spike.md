# Spike [n]: [the question, as a question]

<!-- projects/<state>/<project>/spikes/<n>-<slug>.md. A spike answers ONE question the plan must not
     assume, before the plan is written. Time-box it. It ends with an answer and a consequence for the
     plan, never with "it depends". Throwaway code stays out of the delivery branch. Delete this comment. -->

**Why the plan can't assume this:** [what breaks, or which decision flips, if the guess is wrong]
**Time box:** [e.g. 1 hour] · **Date:** [YYYY-MM-DD] · **By:** [agent / model]

## What I checked

| Check | How (file:line, command, query, doc URL) | Result |
|-------|------------------------------------------|--------|
| [e.g. are the tabs real routes?] | [`app/recipes/[id]/page.tsx:42`] | [no: scroll anchors on one page] |

## Answer

[One paragraph. Mark each claim **verified** (you ran or read it) or **assumed** (you didn't).]

## Consequence for the plan

- [What the tech plan now does, or does not do, because of this answer]
- [Any decision for the founder it creates: default, alternative, consequence]

## If this spike evaluates a tool, model or vendor for a product decision

<!-- Delete this section for ordinary "does X exist / work" spikes. -->

- **Adoption rule, written before any result:** [e.g. "adopt for a given judgment only if accuracy is within 2 points of the incumbent AND p50 latency ≤ 200 ms"]. Fill the results in against it; don't adjust it after seeing them.
- **Base rate on real history:** run the incumbent, and the candidate, over stored real inputs (past messages, events, records), not only a golden set. Report: [decision fires on N of M inputs] → [traffic per month] × [rate] = **[informative events per month]**. If that number is single digits, the replay *is* the experiment: decide from it rather than building a live shadow or A/B that will take months to say anything.
- **Eval hygiene:** criteria examples must not quote golden-set items (leakage), and a question's instructions and criteria must not contradict each other. Re-score after any wording fix.
- **Data flow:** if the candidate is a new processor of user data, the disclosure (privacy policy, DPA) ships and is confirmed live before any production call.

## Not checked

- [What a reader might think this spike covers but it doesn't]
