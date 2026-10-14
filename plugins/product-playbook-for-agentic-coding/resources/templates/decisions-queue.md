# Decisions queue: [Project name]

<!-- The ONE channel from agents to the founder for this project (projects/<state>/<project>/decisions-queue.md).
     Agents append here instead of asking mid-task, keep working on unblocked items, and send it as one
     daily packet (morning). A live interrupt is only for a production or spend outage.
     Before adding a row, verify the claim yourself: installed tools, current limits, prior answers in
     the transcript and project docs. A question the agent could have answered costs a founder turn.
     `#` is the decision id. Every row also gets a decision line in decisions.jsonl when it is added, and
     its `answer` when it moves to Decided (shape, ids, files and stand-in hook: the playbook's
     resources/templates/decision-line.md). Delivery rows are `W-<n>`; explore, review and QA rows keep
     their own ids. Rendered options list their screenshots in the line's `images`. He may answer with a
     reason after the pick ("B, simpler"): record it as `why` (`why_basis: stated`); never ask for one. -->

**Decision rights:** [link to the approved block] · **Packet sent:** [date/time of last send]

## Open

| # | Question (one line) | Recommendation and why | Reversible? | Blocks | Asked | Default on |
|---|---------------------|------------------------|-------------|--------|-------|------------|
| W-1 | [...] | [what I'd do; the cost of being wrong] | yes / no | [task ids or "nothing"] | [date] | [asked + 48 h, or "never" if irreversible or founder-only] |

<!-- Reversible items (copy, defaults, sequencing inside the approved spec, which of two approved options)
     take the recommendation after 48 h of founder silence. Irreversible or founder-only items
     (data-writing migrations, auth, secrets, spend, flag flips, the spec itself) never default. -->

## Decided

| # | Decision | By | Date | How (founder answer / approved by default after 48 h) |
|---|----------|----|------|--------------------------------------------------------|
