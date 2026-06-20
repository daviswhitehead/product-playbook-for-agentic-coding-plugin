---
name: google-tasks:setup
description: One-time setup to let Claude create Google Tasks (authorizes the gog CLI for the Tasks scope)
argument-hint: "[your-email]"
---

# Connect Google Tasks

This plugin's `create_google_task` MCP tool is backed by the **`gog` CLI**, which
manages Google OAuth for you (its own client + macOS Keychain token store). There
is **no Google Cloud Console setup** — you just authorize the Tasks scope once.

## 1. Install gog (if needed)

```bash
brew install gogcli   # provides the `gog` binary
gog config set keyring_backend keychain   # avoids TTY/keyring prompts
```

## 2. Authorize the Tasks scope

If you already use gog for Calendar/Gmail, you still need to add the **tasks**
scope (re-auth is incremental):

```bash
gog auth add whitehead.davis@gmail.com --services tasks
```

A browser opens for consent; the refresh token is stored in your Keychain.
Verify:

```bash
gog auth list          # should show "tasks" among the scopes
```

## 3. Self-test (end-to-end)

```bash
gog tasks add @default --title "test task from Claude — delete me" --json
```

Confirm it appears in Google Tasks, then delete it.

## After setup

Restart Claude Code so the MCP server is live, then just ask:
**"Add a Google Task to buy milk tomorrow."** Claude calls `create_google_task`,
which runs `gog tasks add` under the hood.

> Multiple Google accounts? Set `GOOGLE_TASKS_ACCOUNT=<email>` in your environment
> so the MCP server targets the right one (otherwise gog's default account is used).
