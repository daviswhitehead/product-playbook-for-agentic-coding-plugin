# Session Checkpoint
**Date**: 2026-06-20 02:27
**Branch**: daviswhitehead/google-tasks-mcp-plugin

## Current Task
Enable Claude to create Google Tasks as a cross-project, reusable capability in the plugin repo. Shipped as PR #49.

## Status
- **Done this session**:
  - Confirmed no first-party Google Tasks MCP connector exists (Gmail/Drive/Calendar/Chat/People only; `tasksmcp.googleapis.com` 404s) — no-code path unavailable.
  - Built new sibling plugin `plugins/google-tasks/`: zero-dependency stdio MCP server exposing `create_google_task` + `list_google_task_lists`.
  - Pivoted implementation from custom OAuth/REST → wrapping the existing `gog` CLI (Option C), reusing gog's Keychain auth; no Google Cloud Console setup, no secrets stored by the plugin.
  - Verified live against a real Google account (create + read-back + list); cleaned up all test tasks.
  - Fixed two bugs found in testing: `tasklists`-key list parsing; and addressed a security finding (argv flag smuggling) via `--` option terminator + listId charset validation + `--flag=value` form.
  - Opened PR #49.
- **In progress**: none — feature complete and verified.
- **Blocked on**: nothing.

## Key Decisions
- **Wrap `gog` instead of custom OAuth (Option C)**: reuses existing, trusted auth infra (also used by OpenClaw), eliminates Cloud Console setup, keeps the plugin secret-free, while still exposing a structured MCP tool.
- **Standalone sibling plugin** (mirrors `openai-image-gen`) rather than folding into the main product-playbook plugin — keeps the orthogonal capability independently installable.
- **Security**: list id is a positional → passed after `--`; title/notes/due are `--flag=value` (safe values, allow leading `-`).

## Open Questions
- claude.ai cannot reach a local stdio server, so Tasks remains Claude Code-only until/unless Google ships a first-party remote Tasks connector. Acceptable per the goal's framing; revisit if a connector appears.

## Next Steps
1. Review/merge PR #49.
2. After merge: update the marketplace, enable the `google-tasks` plugin, restart Claude Code.
3. Optional: add `complete_google_task` / due-time support if needed (currently create + list only).

## Hot Files (created this session)
- `plugins/google-tasks/mcp/server.mjs`: zero-dep MCP stdio server (handshake, tools/list, tools/call, in-flight drain on stdin close).
- `plugins/google-tasks/mcp/google-tasks-client.mjs`: thin wrapper over `gog` (binary resolution, `--` terminator, listId validation, JSON unwrap incl. `tasklists`).
- `plugins/google-tasks/.mcp.json`, `.claude-plugin/plugin.json`, `commands/setup.md`, `skills/google-tasks/SKILL.md`, `README.md`.
- `.claude-plugin/marketplace.json`: registered the plugin.

## Context the Next Session Needs
- Activation requires a one-time user step: `gog auth add <email> --services tasks` (browser consent; token in Keychain), then restart Claude Code. The MCP server resolves `gog` from `/opt/homebrew/bin` etc. (handles Claude Code's minimal PATH); override with `GOG_BIN`. Multi-account: set `GOOGLE_TASKS_ACCOUNT`.
- gog quirk: a `--title` value starting with `-` must use `--title=value` form (already handled in the client).
