---
title: "Legacy-site revival via Opus subagents with return contracts"
date: 2026-08-28
trigger: chat-session
analysis-depth: standard
category: workflow
tags: [subagents, delegation, opus, legacy-modernization, railway, django, token-budget]
severity: medium
module: "session-orchestration"
---

# Legacy-site revival via Opus subagents with return contracts

## Context

One session took `softmox/themenu` — a friend's dead 2016 site (Python 2.7 /
Django 1.10, killed by Heroku's free-tier shutdown) — from archaeology to live
deployment (Railway) with a PR back to the owner (softmox/themenu#98). Two Opus
subagents did the heavy phases (modernize ~170k tokens, deploy ~140k) at the
user's request to conserve budget; the orchestrator stayed light (fork/clone,
plan doc, verification spot-checks, one inline bug fix, PR).

## Key insights

1. **Return contracts made delegation verifiable.** Each subagent prompt ended
   with an explicit structured report requirement: (a) commits made, (b) final
   state, (c) behavior-affecting decisions, (d) verification evidence with
   status codes, (e) left broken/skipped, (f) exact commands to reproduce. The
   (e) clause is the load-bearing one — it's where the deploy agent surfaced a
   pre-existing calendar 500 that became a real fix, and where "browser JS never
   clicked through" stayed visible instead of being laundered into "all
   verified." Cheap orchestrator spot-checks (re-run `manage.py check`, curl the
   live URL) confirmed the reports without re-doing the work.

2. **Phase-per-agent beats one mega-agent.** Modernize and deploy each fit in
   one agent's context with a crisp goal, constraints ("no pushes", "no other
   platforms", "stop and report if blocked"), and a fallback ladder
   ("if django-registration is disproportionately painful, acceptable fallbacks
   are…"). Neither fallback was needed, but naming them let the agents commit to
   the hard path without thrashing.

3. **Write the tool-rejection rationale into the committed plan.** The user
   preferred familiar tools (Railway/Vercel/Supabase). The plan doc records not
   just "Railway" but *why Vercel was rejected* (serverless Python vs Django's
   migrations/static/long-lived process) and where Supabase would slot in. That
   one paragraph prevents relitigating the choice in the PR review and in every
   future session.

4. **Commit the plan into the target repo, not the workspace.** For
   fix-someone-else's-repo work, `docs/revival-plan.md` on the PR branch means
   the plan travels with the PR — the owner reviews the reasoning alongside the
   diff, and no context is stranded in a Conductor workspace they can't see.

## Actionable improvements

- **Plugin candidate (deferred, not executed)**: the return-contract pattern
  (a–f above, especially "left broken/skipped") could be codified in the
  `autonomous-execution` skill or `/playbook:work-multiple` as default guidance
  for delegating phases to subagents. Deferred because one session is a single
  data point; promote if the pattern proves out again.
- **Portable workflow → `/lore`**: "revive a dead legacy site" (fork →
  agent-modernize → agent-deploy → PR-back) is cross-project and cross-harness —
  if wanted as a reusable skill, forge it via `/lore` from `.specstory/history`,
  not as a plugin command.
- CLAUDE.md measured 277 lines this session (soft limit 200, hard 300) — no
  addition made here; flag for opportunistic trim in a future plugin session.
