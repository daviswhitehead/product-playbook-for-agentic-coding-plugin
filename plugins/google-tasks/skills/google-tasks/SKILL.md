---
name: google-tasks
description: This skill should be used whenever the user wants to add a to-do, reminder, action item, or task to Google Tasks — e.g. "add a task", "remind me to", "put X on my to-do list", "create a Google Task". It points to the create_google_task MCP tool and explains setup if it is not yet connected.
---

# Google Tasks

This plugin exposes a callable MCP server (`google-tasks`) with two tools, both
backed by the **`gog` CLI** (which handles Google OAuth via the macOS Keychain):

- **`create_google_task`** `(title, notes?, due?, listId?)` — create a task in the
  user's Google Tasks. Defaults to their default task list. This is the core capability.
- **`list_google_task_lists`** `()` — list the user's task lists (id + title), useful
  for choosing a non-default `listId`.

## When to use

Use `create_google_task` whenever the user asks to capture a to-do, reminder, or
action item in Google Tasks. Prefer the MCP tool over manually shelling out to `gog`.

- Date handling: `due` accepts `YYYY-MM-DD` or full RFC3339. Google Tasks stores
  only the date portion. Convert relative dates ("tomorrow") to an absolute date
  using the current date from context before calling.
- Default list: omit `listId` unless the user names a specific list. Call
  `list_google_task_lists` first only if you need a specific list's id.

## If the tool returns a setup/auth error

The tool error message is user-facing and says what to do. Typically the `gog` CLI
isn't installed or isn't authorized for the Tasks scope yet. Tell the user to run
the `/google-tasks:setup` command, whose core step is:

```bash
gog auth add <their-email> --services tasks
```

After setup, Claude Code must be restarted so the MCP server picks it up.

## Reusability

Because this is a plugin-bundled MCP server, the tools are available in **every**
project/session where the `google-tasks` plugin is enabled — no per-project setup.
Auth lives once in the Keychain (managed by gog).
