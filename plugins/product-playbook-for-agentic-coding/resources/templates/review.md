# Review: [Project name]

> One page. The founder reads this instead of the PRD, the prototype, the component inventory and the tech plan — and approves the whole project here. Approval on a fully fleshed-out REVIEW.md is the gate for autonomous end-to-end delivery: once it says "approved", the agent builds every PR in the tasks document without further gates, except the standing founder-gated items (migrations/RLS, auth, spend, secrets, flag flips).

**Version:** [vN — aligned with PRD vX, prototype vY, the Storybook board and tech plan vZ (date)] · **Status:** [awaiting approval | APPROVED by <who> <date>: "<quote>"]

| # | Asset | Open it | Read time |
|---|---|---|---|
| 1 | [Product (PRD)](#1-product) | [`product-requirements.md`](./product-requirements.md) vX | ~15 min |
| 2 | [Design (prototype)](#2-design) | **[Open the prototype](http://localhost:PORT/index.html)** · vY · [screenshots](./prototype/shots/) | ~10 min |
| 3 | [Components (Storybook board)](#3-components) | **[Open the board](http://localhost:6006/?path=/story/<story-id>)** | ~5 min |
| 4 | [Engineering (tech plan)](#4-engineering) | [`tech-plan.md`](./tech-plan.md) vZ | ~10 min |

Servers must be running for the live links (prototype: `python3 -m http.server PORT` in `prototype/`; Storybook: `npm run storybook`). Say so at the top when they are.

---

## <a id="1-product"></a>1. Product

### How it works
[Plain prose describing how the *product* works for the user — not what the document contains. 1–2 short paragraphs or ≤8 bullets. Each bullet links to the requirement it summarizes: → [R3](./product-requirements.md#r3).]

### Judgment calls (≤10)
[Numbered. Each: the call, the default you chose and why, the alternative you rejected, the link. Strike through (~~…~~) calls once the founder decides them and record the decision inline with the date.]

1. **[Call]** — [default + why; what was cut]. → [R…](./product-requirements.md#r…)

### Drill-down
[Where the detail lives: sections, appendices (string ids, failure reasons), acceptance criteria. Links only.]

### Applied from round N (date)
[Verbatim founder feedback → what changed, per asset, with links. One block per review round; never delete earlier blocks.]

---

## <a id="2-design"></a>2. Design

### How it works
[Which flows the prototype plays, what the user sees at each step, what animates. Name the buttons to press.]

### Judgment calls (≤10)
### Drill-down
[Legend of prototype versions; screenshot index; research folder.]

---

## <a id="3-components"></a>3. Components

### How it works
[What is new, what is extended, what is reused unchanged — in words, as the user experiences them. The Storybook board shows every planned state visually; planned vs. reproduced vs. shipped are tagged on the board.]

### Judgment calls (≤10)
### Drill-down
[Story ids; component inventory table: name · new/extended/reused · which PR.]

---

## <a id="4-engineering"></a>4. Engineering

### How it works
[The system in one paragraph: data path, what is stored, what is flagged, what is gated.]

### Judgment calls (≤10)
[Lead with the decisions that have long-term implications (schema, storage, public surfaces, cost); link each to its ledger row → [A7](./tech-plan.md#a7).]

### Drill-down
[Simplification ledger (best-in-class → what we ship → why safe), PR map with cost per PR and running total, identifiers created, rollout.]

---

## Format rules (delete this section when the page is filled in)
- Anchors go **inside the heading line** (`## <a id="x"></a>Title`); a standalone anchor line forms an HTML block that swallows the heading.
- Every item the reader might want to inspect is a clickable link; verify every anchor exists (grep the targets) before each review round.
- Summaries describe how the *product* works, never what the document is. No "like I'm five" or similar literal phrasing.
- Keep the page iterating locally (no pushes) until the founder writes "approved"; then record the approval at the top, push, and start building.
- Name the best-in-class answer first, then what was cut to fit the team — for every judgment call.
