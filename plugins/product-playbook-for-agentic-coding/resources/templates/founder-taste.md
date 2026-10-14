# Founder taste: [Founder name], [Product]

<!-- Default home: docs/foundations/founder-taste.md. A project that already keeps a founder profile
     elsewhere points at it instead, with one line in CLAUDE.md or AGENTS.md:
       Founder taste: <profile path> §<section>; ledger: <ledger path>
     resources/personas/founder.md loads the Principles section below (not the ledger) whenever a
     founder-persona review runs: /playbook:explore before each queue, /playbook:critique,
     /playbook:qa-round. Delete this comment. -->

**Ledger:** `[docs/foundations/taste-ledger.jsonl]` (rows appended by `/playbook:learnings` Step 10 and `/playbook:qa-round`) · **Last updated:** [date] · **Projects in the ledger:** [n]

## How to read this

- Principles come from the founder's decisions, not from interviews. Each cites ledger row ids that **support** it and rows that **contradict** it. A principle with no receipts is an opinion: mark it tentative.
- Tag each line **[F]** (he stated it) or **[R]** (revealed by his decisions; ranks below [F]). Where a principle conflicts with a stated founder policy or a later dated decision, those win.
- A principle from one project is **provisional** until a second project replicates it.
- Each principle has a **scope** line saying where it stops (for example "UI chrome only; never weakens safety behavior").
- Baseline: how often the agent's recommendation matched his explicit pick, by category. Where it is low (often visual and interaction calls), render options; don't predict.

## Principles

**Strongly supported (3 or more rows)**
1. **[Principle in one line.]** Scope: [where it stops]. For: [ids]. Against: [ids or none]. **[R]**

**Tentative (1 or 2 rows, or mixed)**
- [Principle]. [ids].

## How he reviews

- **Devices:** [e.g. iPad mini in Safari, plus desktop. Name what he does NOT test on.]
- **Format:** [e.g. marks up docs inline with `<-- NOTE: -->` / `<-- QUESTION: -->`; decides visual questions from pictures, not prose; answers option codes like "B2 and D1".]
- **Words he has banned:** [e.g. jargon, a brand shortening]

## Agreement baseline

| Category | Matched / explicit picks | Last updated |
|----------|--------------------------|--------------|
| product-scope | [n / n] | [date] |
| visual-taste | [n / n] | |
| interaction-design | [n / n] | |

## Ledger row schema (one JSON object per line, append-only)

| Field | Values |
|-------|--------|
| `id` | `<project prefix>-<nnn>`, never reused |
| `project`, `date`, `ref`, `source` | project folder; day he settled it; pointer inside the project (e.g. `D02-3`); file, PR or thread it came from |
| `question`, `options`, `recommended`, `decided`, `why` | as presented; `recommended` is null if the agent only asked; quote his words in `decided` and `why` where possible |
| `agreement` | `match`, `override`, `founder-idea`, `accepted` (approved in a batch; not `match`), `unreviewed`, `no-recommendation`, `dropped` |
| `category` | `visual-taste`, `interaction-design`, `copy-naming`, `product-scope`, `information-architecture`, `technical`, `process`, `risk-safety` |
| `reversibility` | `cheap`, `moderate`, `costly` |
| `shown_as` | `rendered` (drawn when he decided), `prose` |
| `why_basis` | `stated`, `inferred`, `none` |
| `decider` | `proxy` (an informed stand-in could have decided from the docs and principles), `founder` |
| `blind_testable` | true only for `match` or `override` with 2+ options and a recommendation |
| `supersedes`, `notes` | optional |

Never edit or delete a row; correct one by appending a row with `supersedes`. Mark `agreement` honestly.
