# Google Tasks plugin

Lets Claude Code create and manage **Google Tasks** on your behalf, via a minimal,
**zero-dependency** MCP server that wraps the [`gog` CLI](https://formulae.brew.sh/formula/gogcli)
(gogcli). Once enabled, the tools are available in **every project** — the
integration lives in the plugin, not in any product repo.

## What you get

A bundled MCP server (`google-tasks`) exposing two tools:

| Tool | Signature | Purpose |
|------|-----------|---------|
| `create_google_task` | `(title, notes?, due?, listId?)` | Create a task (core capability). Defaults to your default list. |
| `list_google_task_lists` | `()` | List your task lists (id + title). |

The server has no npm dependencies — it shells out to `gog`, which already manages
Google OAuth (its own client + macOS Keychain token store) and the Tasks API.

## Why wrap `gog` instead of a connector or custom OAuth?

- Google ships first-party remote MCP connectors for Gmail, Drive, Calendar, Chat,
  and People — but **not** Google Tasks (`tasksmcp.googleapis.com` does not exist).
  So the no-code connector path isn't available for Tasks.
- `gog` already handles Google auth (and is used elsewhere, e.g. OpenClaw), so
  wrapping it means **no Google Cloud Console setup** and one shared credential
  store. We expose it as a structured, schema'd MCP tool so Claude calls it
  directly instead of guessing CLI syntax.

> **claude.ai note:** claude.ai can only use *remote* connectors, so it cannot
> reach this local stdio server (nor the local `gog` binary). This plugin enables
> Google Tasks in **Claude Code** across all your projects. If Google ships a
> first-party Tasks connector, prefer that for claude.ai.

## One-time setup

1. **Install gog** (if not already): `brew install gogcli`, then
   `gog config set keyring_backend keychain` (avoids TTY/keyring prompts).
2. **Authorize the Tasks scope** (incremental if you already use gog):
   ```bash
   gog auth add whitehead.davis@gmail.com --services tasks
   ```
   Approve in the browser; the token is stored in your Keychain. Verify with
   `gog auth list` (should list `tasks`).
3. **Restart Claude Code**, then ask: *"Add a Google Task to follow up Friday."*

(Or run the `/google-tasks:setup` slash command, which walks through the same steps
and includes a self-test.)

## Configuration (optional env vars)

| Var | Purpose |
|-----|---------|
| `GOOGLE_TASKS_ACCOUNT` | Account email passed to gog as `--account` (for multi-account setups). Defaults to gog's default account. |
| `GOG_BIN` | Explicit path to the `gog` binary. Otherwise auto-resolved (`/opt/homebrew/bin/gog`, `/usr/local/bin/gog`, …, then PATH). |

No secrets are stored by this plugin — auth is delegated entirely to gog/Keychain.

## Files

```
google-tasks/
├── .claude-plugin/plugin.json   # plugin manifest
├── .mcp.json                    # registers the stdio MCP server (${CLAUDE_PLUGIN_ROOT}/mcp/server.mjs)
├── commands/setup.md            # /google-tasks:setup
├── skills/google-tasks/SKILL.md # tells Claude when/how to use the tools
└── mcp/
    ├── server.mjs               # zero-dep MCP stdio server
    └── google-tasks-client.mjs  # thin wrapper over the gog CLI
```

## Verify manually

```bash
# Protocol handshake + tool discovery (no auth needed):
printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{}}}' \
  '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' \
  | node mcp/server.mjs

# Live create (after gog is authorized for tasks):
gog tasks add @default --title "test task from Claude — delete me" --json
```
