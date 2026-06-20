---
title: "Integrating an external service: connector-first, then wrap an authed CLI"
date: 2026-06-20
trigger: chat-session
analysis-depth: standard
category: integration
tags: [mcp, oauth, cli-wrapper, google-tasks, gog, argument-injection, security]
severity: medium
module: plugins/google-tasks
---

## Context

Goal: let Claude create Google Tasks as a cross-project capability in the plugin
repo. Delivered as the `google-tasks` plugin (PR #49) — a zero-dependency stdio
MCP server wrapping the `gog` CLI.

## Key learnings

### 1. Integration triage order (most valuable insight)

When asked to integrate an external service, evaluate in this order — each rung is
cheaper and more maintainable than the next:

1. **Official no-code connector?** Check first. (Here: Google ships first-party MCP
   connectors for Gmail/Drive/Calendar/Chat/People — but *not* Tasks;
   `tasksmcp.googleapis.com` 404s. Verify the specific service, not the family.)
2. **Existing authenticated CLI/tool to wrap?** If the user already has a tool that
   handles auth (here: `gog`, with OAuth + Keychain), wrap it. Reuses trusted auth,
   stores **no secrets**, and skips provider setup (no Google Cloud Console OAuth
   client). This was the chosen path (Option C).
3. **Custom OAuth/REST?** Last resort — most code, most secrets to manage, most
   maintenance. We built this first, then deleted it in favor of wrapping `gog`.

The pivot from (3) → (2) only happened because the user mentioned "openclaw uses
gog." **Lesson: ask early what tooling already exists in the user's environment
before writing custom auth.**

### 2. Safely wrapping a CLI from a tool (argv flag smuggling)

A background security review caught argv flag smuggling. When shelling out to a CLI
with agent/user-controlled values:

- **Positionals** (e.g. a list id) can be parsed as flags if they start with `-`.
  Defenses: place them after a `--` option terminator, **and** validate against a
  charset. Both, not either.
- **Flag *values*** passed via `execFile` (no shell) cannot smuggle flags — but the
  parser may still reject a value starting with `-` unless passed as `--flag=value`
  (single argv element). Do **not** blanket-reject leading `-` on free-text fields
  like a task title ("- review PR" is legitimate).
- Always use `execFile`/array args, never a shell string.

### 3. Operational gotchas worth remembering

- MCP servers spawned by the harness may have a **minimal PATH** — resolve external
  binaries explicitly (checked `/opt/homebrew/bin`, … then PATH; `GOG_BIN` override).
- A zero-dependency stdio MCP server (newline-delimited JSON-RPC) must **drain
  in-flight async work before exiting on stdin close**, or one-shot calls lose their
  response.
- Verify wrapped-CLI JSON shapes against the real tool, not assumptions: `gog`
  returns task lists under `tasklists`, not `items` — a bug only live testing caught.

## What this is NOT

Items 1–2 are portable, cross-harness patterns → candidates for `/lore`, not a new
playbook command. No playbook workflow change was warranted by this (smooth) session.
