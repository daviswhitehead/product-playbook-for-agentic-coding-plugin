---
name: playbook:review
description: Build or iterate the one-page REVIEW.md that lets a founder approve a whole project (PRD + prototype + components + tech plan) in one sitting. Approval on it is the gate for autonomous end-to-end delivery. Don't use before a PRD and tech plan exist (use /playbook:product-requirements and /playbook:tech-plan first), or for a single PR (post a proof-of-completion comment instead).
argument-hint: "[path to the project directory] [--round <n> \"<founder feedback>\"]"
recommended-mode: edit
thinking-depth: think-harder
---

# Project Review Page (the approval gate)

You are preparing a project for autonomous delivery. The founder will not read four documents; they will read **one page** and approve or redirect. Your job is to make that page complete enough that approval is a safe decision, and to iterate it until they write "approved".

## Why this exists

A multi-document review packet took too long to review and still missed decisions. One page with live links, plain "how it works" summaries and a short list of judgment calls let the founder approve an entire project in a few rounds, after which the agent delivered end-to-end without further gates (Chef Chop, "Bring your recipes", 2026-10-10). The founder's standing instruction: **approval on a fully fleshed-out REVIEW.md is the gate for autonomously delivering projects end-to-end.**

## Inputs

- `projects/<state>/<project>/product-requirements.md` (required)
- `.../tech-plan.md` (required) and `.../tasks.md` (if drafted)
- A clickable prototype (`.../prototype/index.html`, served locally) and a Storybook board story showing every planned component state — build them if missing; the review is not complete without something to click.
- Founder feedback from earlier rounds (if `--round` is given)

## Process

1. **Start from the template** `resources/templates/review.md`. Four assets, in this order: Product, Design, Components, Engineering.
2. **Write "How it works" per asset** as the user experiences the product — never a description of the document. Link each sentence or bullet to the requirement/ledger row it summarizes. Anchors live **inside heading lines** in the target docs (`### <a id="r3"></a>R3 — …`); add them where missing.
3. **List ≤10 judgment calls per asset.** For each: name the best-in-class answer, what you chose and why, what you cut, and the link. Lead Engineering with decisions that have long-term implications (schema, storage, public surfaces, recurring cost).
4. **Make everything clickable.** Live prototype URL, Storybook story id, screenshot folder, anchors. Start the servers and state at the top that they are running. Verify every anchor resolves (grep targets) before each round.
5. **Iterate locally.** Commit, but do not push, until approval. Each founder round: apply the feedback to **every** asset it touches (a design decision changes the PRD, the prototype, the board and the plan), strike through decided calls with the decision and date, and append an "Applied from round N" block quoting the feedback verbatim.
6. **On "approved":** record the approval and any conditions at the top, apply the conditions across all assets, mark PRD/plan/tasks approved, push, and start building per the tasks document. Founder-gated items stay gated (migrations/RLS, auth, spend, secrets, flag flips).

## Quality bar (check before each round)

- [ ] Every "How it works" describes behaviour, not artefacts
- [ ] ≤10 calls per asset; each names the best-in-class option and what was cut
- [ ] Every link and anchor resolves; servers are running
- [ ] PRD, prototype, board and plan agree (scan for stale terms after each round)
- [ ] Cost per PR and the running total appear in the Engineering drill-down
- [ ] No literal "like I'm five" phrasing; plain English, no jargon

## Output

`projects/<state>/<project>/REVIEW.md`, plus the aligned PRD / prototype / board / plan edits each round. Report to the founder in ≤5 lines: what changed, the open calls, what you need.
