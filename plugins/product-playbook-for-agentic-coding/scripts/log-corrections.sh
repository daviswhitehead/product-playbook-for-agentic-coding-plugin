#!/usr/bin/env bash
#
# UserPromptSubmit hook — queue user-correction moments for the improvement loop.
#
# Corrections ("no, use X", "don't do that", "that's wrong") are the highest-signal
# learning source and the easiest to lose: by session end they're forgotten, and
# transcript mining finds them late or never. This hook catches them at the moment they
# happen and appends them to ~/.claude/playbook-corrections.log for the weekly
# improvement run to triage (see IMPROVEMENT.md).
#
# Precision over recall, deliberately: only prompts that OPEN with a correction shape are
# queued, because a mid-prompt "no" is usually prose. Tune recall later if the weekly
# run's triage shows the queue is too quiet.
#
# Same constraints as log-playbook-usage.sh (runs on every prompt for every user):
# silent on stdout (UserPromptSubmit stdout injects into context), bounded, always exit 0.
# Stores at most the first 200 chars of a matched prompt; withholds the snippet entirely
# if it looks secret-shaped. Opt out with PLAYBOOK_NO_CORRECTION_LOG=1.

set -uo pipefail

[ "${PLAYBOOK_NO_CORRECTION_LOG:-}" = "1" ] && exit 0
command -v python3 >/dev/null 2>&1 || exit 0

LOG_FILE="${HOME}/.claude/playbook-corrections.log"
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || exit 0

HOOK_INPUT="$(cat 2>/dev/null || true)"
export HOOK_INPUT

python3 - "$LOG_FILE" <<'PY' 2>/dev/null || true
import datetime, json, os, re, sys

try:
    data = json.loads(os.environ.get("HOOK_INPUT") or "{}")
except Exception:
    sys.exit(0)

prompt = (data.get("prompt") or "").strip()
if not prompt or prompt.startswith("/"):
    sys.exit(0)  # slash commands are not corrections

# High-precision correction openers only.
CORRECTION = re.compile(
    r"^(no[,.\s]|nope\b|don'?t\b|do not\b|stop\b|that'?s (wrong|not)\b|"
    r"not that\b|undo\b|revert\b|wrong[,.\s]|instead[,\s]|i said\b|again[,:\s])",
    re.IGNORECASE,
)
if not CORRECTION.match(prompt):
    sys.exit(0)

snippet = " ".join(prompt.split())[:200]
# Withhold secret-shaped content rather than persisting it.
SECRETISH = re.compile(
    r"(api[_-]?key|secret|password|passwd|bearer|authorization|token)\s*[:=]|"
    r"[A-Za-z0-9+/_-]{40,}",
    re.IGNORECASE,
)
if SECRETISH.search(snippet):
    snippet = "[snippet withheld - secret-shaped content]"

ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
repo = os.path.basename(data.get("cwd") or os.getcwd())
with open(sys.argv[1], "a") as f:
    f.write(f"{ts}\t{repo}\t{snippet}\n")
PY

# Bound the log: keep the newest 2000 lines once it passes ~512 KB.
if [ -f "$LOG_FILE" ] && [ "$(wc -c < "$LOG_FILE" | tr -d ' ')" -gt 524288 ]; then
    tail -n 2000 "$LOG_FILE" > "${LOG_FILE}.tmp" 2>/dev/null && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

exit 0
