#!/bin/bash
#
# check-version-bump.sh — Fail if a plugin's files changed without a version bump.
#
# WHY THIS EXISTS:
#   Claude Code marketplace auto-update is *version-keyed*: a plugin only re-installs
#   on users' machines when its version number changes. So a content change shipped
#   at an unchanged version silently never propagates — installs stay stale forever.
#   This check makes that mistake impossible to merge: if any tracked file under a
#   plugin directory differs from the base branch, that plugin's plugin.json version
#   MUST also differ.
#
# USAGE:
#   scripts/check-version-bump.sh [base-ref]
#     base-ref   git ref to diff against (default: origin/main)
#
# Exit 0 = all changed plugins bumped their version (or nothing changed).
# Exit 1 = a plugin changed but its version did not bump.

set -uo pipefail

BASE_REF="${1:-origin/main}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
FAILURES=0

# Resolve the base ref; if it isn't present (shallow CI clone), try to fetch it.
if ! git rev-parse --verify --quiet "$BASE_REF" >/dev/null; then
    git fetch --quiet origin "${BASE_REF#origin/}" 2>/dev/null || true
fi
if ! git rev-parse --verify --quiet "$BASE_REF" >/dev/null; then
    echo -e "${YELLOW}WARNING: base ref '$BASE_REF' not found — skipping version-bump check.${NC}"
    exit 0
fi

MERGE_BASE="$(git merge-base "$BASE_REF" HEAD 2>/dev/null || echo "$BASE_REF")"

version_of() {  # version_of <git-ref-or-WORKING> <path>
    local ref="$1" path="$2" content
    if [ "$ref" = "WORKING" ]; then
        [ -f "$path" ] || return 1
        content="$(cat "$path")"
    else
        content="$(git show "$ref:$path" 2>/dev/null)" || return 1
    fi
    printf '%s' "$content" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("version",""))' 2>/dev/null
}

echo "Checking version bumps against $BASE_REF (merge-base ${MERGE_BASE:0:8})..."
echo "-------------------------------------------"

shopt -s nullglob
for plugin_json in plugins/*/.claude-plugin/plugin.json; do
    plugin_dir="$(dirname "$(dirname "$plugin_json")")"   # plugins/<name>
    name="$(basename "$plugin_dir")"

    # Did anything under this plugin change vs the merge-base?
    if git diff --quiet "$MERGE_BASE" -- "$plugin_dir"; then
        echo -e "${GREEN}OK: $name unchanged${NC}"
        continue
    fi

    cur_version="$(version_of WORKING "$plugin_json" || true)"
    base_version="$(version_of "$MERGE_BASE" "$plugin_json" || echo "")"

    if [ -z "$base_version" ]; then
        echo -e "${GREEN}OK: $name is new (version $cur_version)${NC}"
        continue
    fi

    if [ "$cur_version" = "$base_version" ]; then
        echo -e "${RED}FAIL: $name changed but version not bumped (still $cur_version)${NC}"
        echo -e "       Run: scripts/sync-version.sh <new-version> $name"
        FAILURES=$((FAILURES + 1))
    else
        echo -e "${GREEN}OK: $name bumped $base_version -> $cur_version${NC}"
    fi
done

echo ""
if [ "$FAILURES" -gt 0 ]; then
    echo -e "${RED}Version-bump check FAILED ($FAILURES plugin(s) changed without a bump).${NC}"
    echo "Auto-update is version-keyed: unbumped changes never reach users' installs."
    exit 1
fi
echo -e "${GREEN}Version-bump check PASSED.${NC}"
exit 0
