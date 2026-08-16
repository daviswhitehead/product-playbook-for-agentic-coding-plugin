#!/bin/bash
#
# check-version-bump.sh — Enforce that plugin changes actually propagate to installs.
#
# WHY THIS EXISTS:
#   Claude Code marketplace auto-update is *version-keyed*: a plugin only re-installs on
#   users' machines when its version number changes. A content change shipped at an
#   unchanged version silently never propagates — installs stay stale forever.
#
# TWO MODES, because the question is different before and after a merge:
#
#   PR MODE  (HEAD != base tip). "Does this PR declare a version change?"
#     Satisfied by a changeset under .changes/ (preferred — a new file per PR, so it
#     cannot conflict with any other PR) or by a hand bump of plugin.json (legacy path,
#     still accepted).
#
#   MAIN MODE  (HEAD == base tip, i.e. a push to main). "Did main's version actually go up?"
#     Fails while changesets sit unreleased, and fails if a push changed plugin content
#     without the version increasing versus the previous commit.
#
# WHAT THIS REPLACED, AND WHY:
#   This script used to compare the working tree against the MERGE BASE in both modes.
#   That verified "this branch bumped since it forked", not "main's version will increase" —
#   so a branch forked at 0.26.1 and bumped to 0.26.2 passed even when main had already
#   reached 0.26.4, and merging it would drag main's version BACKWARDS. The only thing
#   preventing that was git conflicting on the version lines, which is also precisely the
#   friction that forced N open PRs to merge serially with one patch version each.
#   Worse, the main-branch invocation compared main against itself, so it reported
#   "unchanged" and could never fail: there was no post-merge backstop at all.
#
# USAGE:
#   scripts/check-version-bump.sh [base-ref]
#     base-ref   git ref to diff against (default: origin/main)
#
# Exit 0 = every changed plugin declares (PR mode) or completed (main mode) a version change.
# Exit 1 = otherwise.

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

# Pending changesets — the shared signal both modes read.
shopt -s nullglob
CHANGESETS=()
for f in .changes/*.md; do
    [ "$(basename "$f")" = "README.md" ] && continue
    CHANGESETS+=("$f")
done

# Mode detection: on a push to main the workflow passes the branch we are already on.
if [ "$(git rev-parse HEAD)" = "$(git rev-parse "$BASE_REF")" ]; then
    MODE="main"
else
    MODE="pr"
fi

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

# version_gt <a> <b> -> exit 0 if a is strictly greater than b, semver-aware.
# Compares numerically per component so 0.10.0 > 0.9.0 (a plain string sort gets this
# wrong). Non-numeric/malformed versions return 1 (not-greater), which fails closed.
version_gt() {
    python3 - "$1" "$2" <<'PY'
import re, sys
def parse(v):
    m = re.match(r'^(\d+)\.(\d+)\.(\d+)', (v or '').strip())
    return tuple(int(x) for x in m.groups()) if m else None
a, b = parse(sys.argv[1]), parse(sys.argv[2])
sys.exit(0 if (a is not None and b is not None and a > b) else 1)
PY
}

# changeset_names_plugin <plugin> -> exit 0 if some changeset targets it.
# A changeset with no explicit "plugin:" line targets the default plugin.
changeset_names_plugin() {
    local plugin="$1" f explicit found=1
    for f in "${CHANGESETS[@]:-}"; do
        [ -f "$f" ] || continue
        explicit="$(sed -n 's/^plugin:[[:space:]]*//p' "$f" | head -1)"
        if [ -z "$explicit" ]; then
            explicit="product-playbook-for-agentic-coding"
        fi
        if [ "$explicit" = "$plugin" ]; then found=0; fi
    done
    return $found
}

# ---------------------------------------------------------------------------
# MAIN MODE — did main's version actually go up?
# ---------------------------------------------------------------------------
if [ "$MODE" = "main" ]; then
    echo "Post-merge check on $(git rev-parse --abbrev-ref HEAD) ($(git rev-parse --short HEAD))..."
    echo "-------------------------------------------"

    if [ "${#CHANGESETS[@]}" -gt 0 ]; then
        echo -e "${RED}FAIL: ${#CHANGESETS[@]} unreleased changeset(s) in .changes/${NC}"
        for f in "${CHANGESETS[@]}"; do echo "       - $f"; done
        echo ""
        echo "       Merged content is sitting on main at an unchanged version, which means"
        echo "       it has reached zero installs (propagation is version-keyed)."
        echo "       Run: scripts/release.sh && git add -A && git commit -m 'chore: release' && git push"
        exit 1
    fi

    PREV="$(git rev-parse --verify --quiet HEAD~1 || true)"
    if [ -z "$PREV" ]; then
        echo -e "${GREEN}OK: no previous commit to compare against.${NC}"
        exit 0
    fi

    for plugin_json in plugins/*/.claude-plugin/plugin.json; do
        plugin_dir="$(dirname "$(dirname "$plugin_json")")"
        name="$(basename "$plugin_dir")"

        if git diff --quiet "$PREV" HEAD -- "$plugin_dir"; then
            echo -e "${GREEN}OK: $name unchanged in this commit${NC}"
            continue
        fi

        cur_version="$(version_of WORKING "$plugin_json" || true)"
        prev_version="$(version_of "$PREV" "$plugin_json" || echo "")"

        if [ -z "$prev_version" ]; then
            echo -e "${GREEN}OK: $name is new (version $cur_version)${NC}"
        elif version_gt "$cur_version" "$prev_version"; then
            echo -e "${GREEN}OK: $name $prev_version -> $cur_version${NC}"
        else
            echo -e "${RED}FAIL: $name changed on main but version did not increase ($prev_version -> $cur_version)${NC}"
            echo -e "       This content will not reach a single install until the version climbs."
            FAILURES=$((FAILURES + 1))
        fi
    done

    echo ""
    if [ "$FAILURES" -gt 0 ]; then
        echo -e "${RED}Post-merge version check FAILED.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Post-merge version check PASSED.${NC}"
    exit 0
fi

# ---------------------------------------------------------------------------
# PR MODE — does this PR declare a version change?
# ---------------------------------------------------------------------------
MERGE_BASE="$(git merge-base "$BASE_REF" HEAD 2>/dev/null || echo "$BASE_REF")"

echo "Checking version declarations against $BASE_REF (merge-base ${MERGE_BASE:0:8})..."
echo "-------------------------------------------"

for plugin_json in plugins/*/.claude-plugin/plugin.json; do
    plugin_dir="$(dirname "$(dirname "$plugin_json")")"
    name="$(basename "$plugin_dir")"

    if git diff --quiet "$MERGE_BASE" -- "$plugin_dir"; then
        echo -e "${GREEN}OK: $name unchanged${NC}"
        continue
    fi

    if changeset_names_plugin "$name"; then
        echo -e "${GREEN}OK: $name changed and declares a changeset${NC}"
        continue
    fi

    # Legacy path: a hand bump still satisfies the requirement.
    cur_version="$(version_of WORKING "$plugin_json" || true)"
    base_version="$(version_of "$MERGE_BASE" "$plugin_json" || echo "")"

    if [ -z "$base_version" ]; then
        echo -e "${GREEN}OK: $name is new (version $cur_version)${NC}"
    elif version_gt "$cur_version" "$base_version"; then
        echo -e "${GREEN}OK: $name hand-bumped $base_version -> $cur_version${NC}"
        echo -e "${YELLOW}     (a changeset is preferred — it cannot conflict with other PRs)${NC}"
    else
        echo -e "${RED}FAIL: $name changed but declares no version change${NC}"
        echo -e "       Add a changeset (preferred — never conflicts with other open PRs):"
        echo -e "         .changes/<slug>.md  with  'plugin: $name' and 'bump: patch|minor|major'"
        echo -e "       See .changes/README.md."
        FAILURES=$((FAILURES + 1))
    fi
done

echo ""
if [ "$FAILURES" -gt 0 ]; then
    echo -e "${RED}Version-declaration check FAILED ($FAILURES plugin(s)).${NC}"
    echo "Auto-update is version-keyed: undeclared changes never reach users' installs."
    exit 1
fi
echo -e "${GREEN}Version-declaration check PASSED.${NC}"
exit 0
