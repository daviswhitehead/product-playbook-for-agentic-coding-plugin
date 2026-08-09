#!/usr/bin/env bash
#
# UserPromptSubmit hook — append-only usage log for /playbook:* commands.
#
# review-playbook's <36/60 removal threshold and IMPROVEMENT.md's pruning rule both ask
# "which commands actually get used?", and until this hook nothing recorded an answer —
# pruning ran on intuition while the command surface grew monotonically. This writes one
# tab-separated line (UTC timestamp, command, repo basename) per /playbook:* mention to
# ~/.claude/playbook-usage.log, so "unused for a month" becomes a grep, not a guess.
#
# Design constraints, because this runs on every prompt for every user:
#   - Silent: UserPromptSubmit stdout is injected into the session's context, so this
#     prints NOTHING on any path.
#   - Fast and bounded: one python3 invocation, log auto-truncates past ~1 MB.
#   - Never fails the session: every path exits 0.
#   - No prompt content is stored — only the command names matched, so nothing
#     sensitive the user typed alongside a command can leak into the log.
#
# Opt out with PLAYBOOK_NO_USAGE_LOG=1.

set -uo pipefail

[ "${PLAYBOOK_NO_USAGE_LOG:-}" = "1" ] && exit 0
command -v python3 >/dev/null 2>&1 || exit 0

LOG_FILE="${HOME}/.claude/playbook-usage.log"
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || exit 0

# Capture the hook's stdin JSON before the heredoc below claims stdin for the
# python program itself (python3 - reads its *script* from stdin).
HOOK_INPUT="$(cat 2>/dev/null || true)"
export HOOK_INPUT

python3 - "$LOG_FILE" <<'PY' 2>/dev/null || true
import datetime, json, os, re, sys

try:
    data = json.loads(os.environ.get("HOOK_INPUT") or "{}")
except Exception:
    sys.exit(0)

prompt = data.get("prompt") or ""
commands = sorted(set(re.findall(r'/(playbook:[a-z0-9][a-z0-9-]*)', prompt)))
if not commands:
    sys.exit(0)

ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
repo = os.path.basename(data.get("cwd") or os.getcwd())
with open(sys.argv[1], "a") as f:
    for cmd in commands:
        f.write(f"{ts}\t{cmd}\t{repo}\n")
PY

# Bound the log: keep the newest 5000 lines once it passes ~1 MB.
if [ -f "$LOG_FILE" ] && [ "$(wc -c < "$LOG_FILE" | tr -d ' ')" -gt 1048576 ]; then
    tail -n 5000 "$LOG_FILE" > "${LOG_FILE}.tmp" 2>/dev/null && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

exit 0
