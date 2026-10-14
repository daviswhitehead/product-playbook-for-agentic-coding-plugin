---
name: playbook:qa-round
description: Run a founder-facing QA round on built work. Agents run three passes first (user journeys, adversarial, real device), fix what they can, then hand the founder only taste calls and a short, pre-tested testing guide; his answers feed the taste ledger and any correction a rule could have predicted becomes a rule. Don't use for a single bug (use /playbook:debug) or before anything is built (use /playbook:explore).
argument-hint: "<project-dir> [--round <n>] [--prs <numbers or branches>] [--apply-markup] [--after-deploy]"
recommended-mode: auto-accept
thinking-depth: think-harder
---

# QA Round

You are running QA on work that is built (on the integration branch, or merged). The founder's pass is for taste, his real account and data, and what no agent can see. It is never the first time a step runs.

## Why this exists

In the round that shaped this command, every agent check passed and the founder still made eleven corrections in one morning on his iPad mini: the keyboard pushed the chat off screen, a sheet's grabber did nothing, press states stuck, content went stale after a page change, chrome he did not want. None of it shows in desktop Chromium or at a phone width. He also could not run four of the nineteen steps he was handed ("I don't know what I'm supposed to do for D6 or D7..."): all four were "after deploy" one-liners mixed into a pre-deploy guide. So: agents test on the founder's real device class first, the guide is short and concrete, after-deploy steps come after the deploy, and every correction he makes is a chance to fix the rule that missed it.

## Inputs

- `<project-dir>`: `projects/<state>/<project>/`. The round lives in `qa/round-<n>/` (next free `n` unless `--round`).
- **What it covers** (`--prs`): merged PRs, open PRs, or local branches (default: the project's integration branch at HEAD).
- **Roles and surfaces that changed**: from the tasks doc, the PR diffs and `REVIEW.md`. List every role (e.g. guest, member, free at a limit, paid) and every surface.
- **The founder's devices**: from the project's founder taste file ("How he reviews"; see `resources/personas/founder.md` for how to find it). Unknown: queue the question and test desktop plus iPad and phone sizes meanwhile.
- **How to run the app the way production does**: the project's CLAUDE.md (production build and start command, seeded accounts, the E2E command, the iOS Simulator command).

Templates: `resources/templates/qa-round/` (`findings.md`, `needs-founder.md`, `testing-guide.md`, `testing-guide-after-deploy.md`, `real-device-checklist.md`).

## Step 1: Three agent passes, before the founder sees anything

Run them as parallel sub-agents with one shared brief (environment, accounts, where to save evidence, what not to touch); you verify their evidence yourself. Record every check and finding as a row in `findings.md`.

| Pass | Covers | How | Done when |
|---|---|---|---|
| **1. User journeys** | Every role through the happy path and the edges: limits at N-1, N and N+1 from every entry path, empty and first-run states, slow or offline network, page changes with overlays open | A **local production build** with seeded accounts; E2E (stubbed AI) for the deterministic parts; **one live-agent run** wherever the agent produces content | Each journey has a screenshot or a spec name, and says "stub" or "live" |
| **2. Adversarial** | Hostile input (script tags in titles, prompt-like user text, unicode, huge or empty fields), double clicks and parallel requests, auth edges (logged out, another user's object, expired session), storage cleared mid-flow | Local production build; **read-only** production probes, with writes and analytics blocked | Each case says "no finding" or links a finding |
| **3. Real device** | Touch, keyboard, viewport and gesture behavior on the founder's device (e.g. iPad Safari) and a phone | The iOS Simulator (skill `ios-simulator-testing`, real taps, `IOS_SIM_DEVICE` for the iPad) through `real-device-checklist.md` | Every checklist row has a reading with a positive control, or says why it could not run |

Fix what is clearly a bug on the branch as you go (status `fixed`, commit linked). File what is out of scope (`filed`, issue linked). Anything that needs a ruling goes to Step 2.

## Step 2: Outputs for the founder

1. **`needs-founder.md`**: only questions that need his judgment or hands. Each: the question in plain words, options with consequences, a recommendation, the consequence of the recommendation, and a screenshot for anything visual. Each is also a row in `decisions-queue.md` (reversible rows default after 48 h; founder-only rows never) and a decision line in `<project>/decisions.jsonl`: id `Q<round>-<n>` (item `n` of this round), `stage: qa-round`, the screenshots in `images` (`resources/templates/decision-line.md`, which also has the stand-in hook).
2. **`testing-guide.md`**: at most 10 concrete steps, each with the page, the exact control label, the screen to expect, and how an agent already tested it ("Nobody: <why>" when no agent could). **No after-deploy steps.** List the steps an agent fully covered under "Not in this guide, and why".
3. **The pre-tested rule is enforced.** Run the guard and fix every FAIL before sending:
   ```bash
   "${CLAUDE_PLUGIN_ROOT}"/scripts/check-testing-guide.sh projects/<state>/<project>/qa/round-<n>/testing-guide.md
   ```
4. **Cost checkpoint.** Before opening a PR or marking one ready for this round, state the CI and eval cost and the running total, and let the founder choose. Default to local review first: he reviews files and a local build, and fixes fold into the open PR rather than new ones.
5. Send it as one packet (the daily packet, or the project's channel): what was tested, how many findings were fixed, the decisions, the guide, in about five lines plus links.

## Step 3: The founder's markup round (`--apply-markup`)

When he answers (inline `<-- NOTE: -->` / `<-- QUESTION: -->` in the guide or `needs-founder.md`, queue answers, or a reply):

1. **Apply NOTEs everywhere, answer QUESTIONs in place** and keep them open until he confirms (`/playbook:refine-doc`, "Markup rounds"). Date the round in the project's decision log.
2. **Mark each ruling in `findings.md`** (`decided`, with his words), move queue rows to Decided, and fill `answer` and `answered` on each `Q<round>-<n>` line. A short reason after a pick ("1B, simpler") goes in `why` with `why_basis: stated`; never ask him for one.
3. **Append every ruling to the taste ledger**, with `agreement` marked honestly: a recommendation he took is `match`; a change he made to shipped design that nobody recommended is `override` of what shipped; his own idea is `founder-idea`. Schema and ledger path: `resources/templates/founder-taste.md`. Propose principle edits with the row ids as receipts.

## Step 4: Learn step (same round, not later)

For every correction he made, ask: could an earlier rule, check or template have predicted it? (A touch rule, the real-device checklist, a lint rule, a component guideline, this command.) If yes, **edit that rule, check or template in this round** and record it in `findings.md` "Learn step". A correction he has made **twice** must become a rule, check or guard; prose alone does not count. Report which corrections became which edits, and which had nothing that could have predicted them.

## Step 5: After the deploy (`--after-deploy`)

Only after the work is deployed:

1. An agent re-runs every remaining step on production, read-only wherever it can.
2. Write `testing-guide-after-deploy.md` (template) with its **"Production, after deploy"** line filled in: date, deployed sha or version, who re-ran it, the result. This is the only file allowed to contain after-deploy steps. Run the guard on it too.
3. Send it as its own short packet.

## Step 6: Close the round

Fill the Close-out lines in `findings.md`: every row `pass`, `fixed`, `filed` or `decided`; the taste-ledger rows appended (or "none: <why>"); repeated corrections turned into rules (or "none: <why>"); the after-deploy line filled. `/playbook:close-project` checks these mechanically (`verify-close-project.sh`) and refuses to close a project whose latest round is still open.

## Report

Five lines: what changed (findings fixed, filed, decided), what you need from the founder (the decisions and the guide, with its minutes), what's next (the deploy, the after-deploy pass, or close-out). State whether results were stub-based or live, and name the instrument for device results ("iOS Simulator, iOS <version>, iPad mini"), never "tested on iPad".
