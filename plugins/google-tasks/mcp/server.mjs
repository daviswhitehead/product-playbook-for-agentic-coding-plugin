#!/usr/bin/env node
/**
 * Minimal, zero-dependency Model Context Protocol (MCP) server for Google Tasks.
 *
 * Transport: stdio, newline-delimited JSON-RPC 2.0 (the MCP stdio convention).
 * Tools:
 *   - create_google_task(title, notes?, due?, listId?)
 *   - list_google_task_lists()
 *
 * Registered by the plugin's .mcp.json so it's available in every Claude Code
 * session where the `google-tasks` plugin is enabled (cross-project).
 *
 * The server starts and lists its tools WITHOUT credentials; credentials are
 * only required when a tool is actually called. This keeps the tool discoverable
 * and makes the protocol handshake verifiable before OAuth consent is granted.
 */

import { createTask, listTaskLists, GogError } from './google-tasks-client.mjs';

const PROTOCOL_VERSION = '2025-06-18';
const SERVER_INFO = { name: 'google-tasks', version: '1.0.0' };

const TOOLS = [
  {
    name: 'create_google_task',
    description:
      'Create a task in the user\'s Google Tasks. Defaults to their default task list. ' +
      'Use this whenever the user asks to add a to-do, reminder, or task to Google Tasks.',
    inputSchema: {
      type: 'object',
      properties: {
        title: { type: 'string', description: 'The task title (required).' },
        notes: { type: 'string', description: 'Optional notes / description for the task.' },
        due: {
          type: 'string',
          description:
            'Optional due date. Accepts YYYY-MM-DD or full RFC3339 (e.g. 2026-06-20T00:00:00.000Z). ' +
            'Note: Google Tasks only stores the date portion.',
        },
        listId: {
          type: 'string',
          description: 'Optional task list ID. Omit to use the default list. Get IDs via list_google_task_lists.',
        },
      },
      required: ['title'],
    },
  },
  {
    name: 'list_google_task_lists',
    description: 'List the user\'s Google Tasks lists (id + title). Useful for choosing a non-default listId.',
    inputSchema: { type: 'object', properties: {} },
  },
];

// ---- JSON-RPC plumbing -----------------------------------------------------

function send(msg) {
  process.stdout.write(JSON.stringify(msg) + '\n');
}

function result(id, res) {
  send({ jsonrpc: '2.0', id, result: res });
}

function error(id, code, message) {
  send({ jsonrpc: '2.0', id, error: { code, message } });
}

function textResult(id, text, isError = false) {
  result(id, { content: [{ type: 'text', text }], isError });
}

async function handleToolCall(id, params) {
  const name = params?.name;
  const args = params?.arguments ?? {};
  try {
    if (name === 'create_google_task') {
      const task = await createTask(args);
      const title = task?.title ?? args.title;
      const summary =
        `Created Google Task "${title}"` +
        (args.due ? ` (due ${task?.due ?? args.due})` : '') +
        (task?.id ? `\nTask id: ${task.id}` : '') +
        (task?.selfLink ? `\nLink: ${task.selfLink}` : '');
      return textResult(id, summary);
    }
    if (name === 'list_google_task_lists') {
      const lists = await listTaskLists();
      const lines = lists.map((l) => `- ${l.title} (id: ${l.id})`).join('\n');
      return textResult(id, lists.length ? `Your Google Tasks lists:\n${lines}` : 'No task lists found.');
    }
    return error(id, -32601, `Unknown tool: ${name}`);
  } catch (err) {
    // Errors are returned as tool errors (isError) so the agent sees an
    // actionable message rather than a transport failure. GogError messages are
    // already user-facing (install/auth hints), so they pass through verbatim.
    const prefix = err instanceof GogError ? '' : 'Google Tasks error: ';
    return textResult(id, `${prefix}${err.message}`, true);
  }
}

async function handleMessage(msg) {
  const { id, method, params } = msg;

  // Notifications (no id) — acknowledge by doing nothing.
  if (id === undefined || id === null) {
    return;
  }

  switch (method) {
    case 'initialize':
      return result(id, {
        protocolVersion: params?.protocolVersion || PROTOCOL_VERSION,
        capabilities: { tools: {} },
        serverInfo: SERVER_INFO,
      });
    case 'ping':
      return result(id, {});
    case 'tools/list':
      return result(id, { tools: TOOLS });
    case 'tools/call':
      return handleToolCall(id, params);
    default:
      return error(id, -32601, `Method not found: ${method}`);
  }
}

// ---- stdin line buffering --------------------------------------------------

// Track in-flight async work so we don't exit (on stdin close) while a tool
// call's network request is still pending.
let pending = 0;
let stdinEnded = false;

function track(promise, msg) {
  pending++;
  Promise.resolve(promise)
    .catch((err) => {
      if (msg && msg.id != null) error(msg.id, -32603, `Internal error: ${err.message}`);
    })
    .finally(() => {
      pending--;
      if (stdinEnded && pending === 0) process.exit(0);
    });
}

let buffer = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => {
  buffer += chunk;
  let nl;
  while ((nl = buffer.indexOf('\n')) !== -1) {
    const line = buffer.slice(0, nl).trim();
    buffer = buffer.slice(nl + 1);
    if (!line) continue;
    let msg;
    try {
      msg = JSON.parse(line);
    } catch {
      continue; // ignore malformed lines
    }
    track(handleMessage(msg), msg);
  }
});

process.stdin.on('end', () => {
  stdinEnded = true;
  if (pending === 0) process.exit(0);
});
