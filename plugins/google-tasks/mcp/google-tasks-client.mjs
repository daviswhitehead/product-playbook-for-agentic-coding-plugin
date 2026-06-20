/**
 * Google Tasks client backed by the `gog` CLI (gogcli).
 *
 * Rather than implementing OAuth + REST ourselves, we shell out to `gog`, which
 * already manages Google OAuth (its own client + macOS Keychain token store) and
 * covers the Tasks API. This reuses the same auth infrastructure used elsewhere
 * (e.g. OpenClaw) and avoids any Google Cloud Console setup.
 *
 * Zero npm dependencies — uses Node's built-in child_process.
 *
 * Optional environment overrides:
 *   GOG_BIN                 Path to the gog binary (else auto-resolved / PATH).
 *   GOOGLE_TASKS_ACCOUNT    Account email to pass as `--account` (else gog default).
 */

import { execFile } from 'node:child_process';
import { existsSync } from 'node:fs';

export class GogError extends Error {}

// MCP servers are often spawned with a minimal PATH (no /opt/homebrew/bin), so
// resolve the binary explicitly instead of relying on PATH lookup alone.
const GOG_CANDIDATES = [
  process.env.GOG_BIN,
  '/opt/homebrew/bin/gog',
  '/usr/local/bin/gog',
  '/usr/bin/gog',
].filter(Boolean);

let resolvedBin = null;
function gogBin() {
  if (resolvedBin) return resolvedBin;
  resolvedBin = GOG_CANDIDATES.find((p) => existsSync(p)) || 'gog'; // fall back to PATH
  return resolvedBin;
}

/**
 * Run gog with the given flag args, plus any trailing *positional* args placed
 * after a `--` option terminator. The `--` ensures user-controlled positionals
 * (e.g. a list id) can never be parsed as gog flags (argv flag smuggling),
 * regardless of their content. execFile uses no shell, so flag *values* are
 * already safe; this protects the positionals.
 */
function runGog(args, positionals = []) {
  const account = process.env.GOOGLE_TASKS_ACCOUNT;
  const full = [...args, '--json', '--no-input'];
  if (account) full.unshift('--account', account);
  if (positionals.length) full.push('--', ...positionals);

  return new Promise((resolve, reject) => {
    execFile(gogBin(), full, { timeout: 30_000, maxBuffer: 4 * 1024 * 1024 }, (err, stdout, stderr) => {
      if (err && err.code === 'ENOENT') {
        return reject(new GogError(
          'The `gog` CLI was not found. Install it (e.g. `brew install gogcli`) or set GOG_BIN to its path, ' +
          'then run the one-time setup (the /google-tasks:setup command).'
        ));
      }
      if (err) {
        const detail = (stderr || stdout || err.message || '').trim();
        // Heuristic: auth/scope problems → point at setup.
        if (/invalid_grant|no tokens|unauthor|auth|scope|consent|login/i.test(detail)) {
          return reject(new GogError(
            `gog is not authorized for Google Tasks yet (or the token expired).\n${detail}\n\n` +
            'Run the one-time setup:\n' +
            '  gog auth add <your-email> --services tasks   (or the /google-tasks:setup command)'
          ));
        }
        return reject(new GogError(`gog command failed: ${detail}`));
      }
      try {
        resolve(stdout.trim() ? JSON.parse(stdout) : {});
      } catch {
        reject(new GogError(`Could not parse gog JSON output: ${stdout.slice(0, 500)}`));
      }
    });
  });
}

// gog JSON may wrap the payload in an envelope; dig out the meaningful object.
function unwrap(out) {
  if (out && typeof out === 'object' && !Array.isArray(out)) {
    if (out.result !== undefined) return out.result;
    if (out.task !== undefined) return out.task;
    if (out.data !== undefined) return out.data;
  }
  return out;
}

/**
 * Create a task in the given list (defaults to the user's default list `@default`).
 * @param {{title:string, notes?:string, due?:string, listId?:string}} input
 */
export async function createTask({ title, notes, due, listId } = {}) {
  if (!title || !String(title).trim()) {
    throw new GogError('title is required to create a task');
  }
  const list = listId && String(listId).trim() ? String(listId) : '@default';
  // listId is a positional arg; validate it to a safe id charset as defense in
  // depth (the `--` terminator in runGog already prevents flag smuggling).
  if (list !== '@default' && !/^[A-Za-z0-9_@.:-]{1,256}$/.test(list)) {
    throw new GogError('Invalid listId (must match a Google Tasks list id).');
  }
  // Use --flag=value form so values that legitimately start with "-" (e.g. a
  // task titled "- review PR") bind correctly; gog's parser rejects "-…" values
  // passed as a separate token. execFile (no shell) keeps each "--flag=value" a
  // single safe argv element. The list id is passed as a positional after `--`.
  const args = ['tasks', 'add', `--title=${String(title)}`];
  if (notes) args.push(`--notes=${String(notes)}`);
  if (due) args.push(`--due=${String(due)}`);
  return unwrap(await runGog(args, [list]));
}

/** List the user's task lists (array of {id, title, ...}). */
export async function listTaskLists() {
  const out = unwrap(await runGog(['tasks', 'lists', 'list']));
  if (Array.isArray(out)) return out;
  // gog wraps the lists under `tasklists`; other Google clients use `items`.
  for (const key of ['tasklists', 'items', 'lists']) {
    if (Array.isArray(out?.[key])) return out[key];
  }
  return [];
}
