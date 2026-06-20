#!/bin/bash
#
# sync-version.sh — Bump a plugin's version everywhere it must match, in one step.
#
# WHY THIS EXISTS:
#   Plugin updates are *version-keyed*. Claude Code's marketplace auto-update only
#   re-pulls a plugin when its version number changes. A content change shipped at
#   an unchanged version silently NEVER reaches users' installs — even with
#   autoUpdate enabled. And the version lives in TWO files that must agree:
#     - plugins/<name>/.claude-plugin/plugin.json   (the plugin's own version)
#     - .claude-plugin/marketplace.json             (the marketplace entry version)
#   If they drift, installs and the marketplace listing disagree. This script
#   updates both together so they can't.
#
# USAGE:
#   scripts/sync-version.sh <new-version> [plugin-name]
#
#   <new-version>   e.g. 0.22.0  (semver: MAJOR.MINOR.PATCH)
#   [plugin-name]   defaults to "product-playbook-for-agentic-coding"
#
# AFTER RUNNING:
#   1. Add a "## [<new-version>] - YYYY-MM-DD" section to CHANGELOG.md
#   2. Run scripts/validate-plugin.sh (consistency is enforced there + in CI)
#   3. Commit, push, and merge to main — the bump is what triggers propagation.

set -euo pipefail

NEW_VERSION="${1:-}"
PLUGIN_NAME="${2:-product-playbook-for-agentic-coding}"

if [ -z "$NEW_VERSION" ]; then
    echo "ERROR: missing <new-version>"
    echo "Usage: scripts/sync-version.sh <new-version> [plugin-name]"
    exit 1
fi

if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: '$NEW_VERSION' is not a valid semver (expected MAJOR.MINOR.PATCH, e.g. 0.22.0)"
    exit 1
fi

# Run from repo root regardless of where invoked.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

PLUGIN_JSON="plugins/${PLUGIN_NAME}/.claude-plugin/plugin.json"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"

if [ ! -f "$PLUGIN_JSON" ]; then
    echo "ERROR: $PLUGIN_JSON not found (is the plugin name '$PLUGIN_NAME' correct?)"
    exit 1
fi

# Use python3 for safe JSON edits (preserves structure, no regex foot-guns).
OLD_VERSION="$(python3 - "$PLUGIN_JSON" "$MARKETPLACE_JSON" "$PLUGIN_NAME" "$NEW_VERSION" <<'PY'
import json, sys
plugin_path, market_path, plugin_name, new_version = sys.argv[1:5]

with open(plugin_path) as f:
    plugin = json.load(f)
old = plugin.get("version")
plugin["version"] = new_version
with open(plugin_path, "w") as f:
    json.dump(plugin, f, indent=2)
    f.write("\n")

with open(market_path) as f:
    market = json.load(f)
found = False
for entry in market.get("plugins", []):
    if entry.get("name") == plugin_name:
        entry["version"] = new_version
        found = True
with open(market_path, "w") as f:
    json.dump(market, f, indent=2)
    f.write("\n")

if not found:
    sys.stderr.write(f"WARNING: no marketplace.json entry named '{plugin_name}' — only plugin.json was updated\n")
print(old or "(unset)")
PY
)"

echo "Synced '$PLUGIN_NAME': $OLD_VERSION -> $NEW_VERSION"
echo "  updated: $PLUGIN_JSON"
echo "  updated: $MARKETPLACE_JSON"
echo ""
echo "Next steps:"
echo "  1. Add '## [$NEW_VERSION] - $(date +%Y-%m-%d)' to CHANGELOG.md"
echo "  2. scripts/validate-plugin.sh"
echo "  3. Commit + push + merge to main (the version bump is what propagates the update)."
