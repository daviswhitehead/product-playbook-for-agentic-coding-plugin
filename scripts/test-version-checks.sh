#!/bin/bash
#
# test-version-checks.sh — Exercise check-version-bump.sh and release.sh in a sandbox repo.
#
# WHY THIS EXISTS:
#   These two scripts are the only thing standing between a merged change and an install
#   that silently never updates. The previous guard passed a scenario that would drag main's
#   version BACKWARDS (case 7 below) and its main-branch invocation could never fail at all
#   (case 5) — both invisible without a test that constructs the situation on purpose.
#
# USAGE: scripts/test-version-checks.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
PASS=0; FAIL=0
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

PLUGIN="product-playbook-for-agentic-coding"

# Build a minimal repo with the same shape the real scripts expect.
new_sandbox() {  # new_sandbox <version>
    local version="$1" dir="$SANDBOX/repo"
    rm -rf "$dir"; mkdir -p "$dir/scripts" "$dir/.claude-plugin" "$dir/.changes"
    mkdir -p "$dir/plugins/$PLUGIN/.claude-plugin" "$dir/plugins/$PLUGIN/commands"
    cp "$REPO_ROOT/scripts/check-version-bump.sh" "$REPO_ROOT/scripts/release.sh" "$dir/scripts/"
    chmod +x "$dir/scripts/"*.sh
    cat > "$dir/plugins/$PLUGIN/.claude-plugin/plugin.json" <<EOF
{
  "name": "$PLUGIN",
  "version": "$version"
}
EOF
    cat > "$dir/.claude-plugin/marketplace.json" <<EOF
{
  "name": "test-marketplace",
  "plugins": [
    { "name": "$PLUGIN", "source": "./plugins/$PLUGIN", "version": "$version" }
  ]
}
EOF
    printf '# Changelog\n\n## [Unreleased]\n\n## [%s] - 2026-01-01\n\n### Added\n- seed\n' "$version" > "$dir/CHANGELOG.md"
    echo "seed" > "$dir/plugins/$PLUGIN/commands/thing.md"
    git -C "$dir" init -q -b main
    git -C "$dir" config user.email t@t.t; git -C "$dir" config user.name t
    git -C "$dir" add -A; git -C "$dir" commit -q -m "seed at $version"
    echo "$dir"
}

set_version() {  # set_version <dir> <version>
    python3 - "$1" "$2" "$PLUGIN" <<'PY'
import json, sys, os
d, v, plugin = sys.argv[1], sys.argv[2], sys.argv[3]
p = os.path.join(d, "plugins", plugin, ".claude-plugin", "plugin.json")
data = json.load(open(p)); data["version"] = v
json.dump(data, open(p, "w"), indent=2)
m = os.path.join(d, ".claude-plugin", "marketplace.json")
mk = json.load(open(m))
for e in mk["plugins"]:
    if e["name"] == plugin: e["version"] = v
json.dump(mk, open(m, "w"), indent=2)
PY
}

changeset() {  # changeset <dir> <slug> <bump> [heading]
    local heading="${4:-### Fixed}"
    printf -- '---\nplugin: %s\nbump: %s\n---\n\n%s\n- **%s** — body prose.\n' \
        "$PLUGIN" "$3" "$heading" "$2" > "$1/.changes/$2.md"
}

check() {  # check <description> <expected: pass|fail> <dir> [base-ref]
    local desc="$1" expected="$2" dir="$3" base="${4:-main}" out rc
    out="$(cd "$dir" && bash scripts/check-version-bump.sh "$base" 2>&1)"; rc=$?
    local actual="pass"; [ $rc -ne 0 ] && actual="fail"
    if [ "$actual" = "$expected" ]; then
        echo -e "${GREEN}PASS${NC} $desc"; PASS=$((PASS+1))
    else
        echo -e "${RED}FAIL${NC} $desc (expected $expected, got $actual)"
        echo "$out" | sed 's/^/       /'
        FAIL=$((FAIL+1))
    fi
}

expect() {  # expect <description> <condition-result-rc>
    if [ "$1" -eq 0 ]; then
        echo -e "${GREEN}PASS${NC} $2"; PASS=$((PASS+1))
    else
        echo -e "${RED}FAIL${NC} $2"; FAIL=$((FAIL+1))
    fi
}

echo "=========================================="
echo "Version check tests"
echo "=========================================="
echo ""
echo "--- PR mode ---"

# 1. plugin changed, changeset present -> pass
D="$(new_sandbox 0.26.0)"
git -C "$D" checkout -q -b feature
echo "edit" >> "$D/plugins/$PLUGIN/commands/thing.md"
changeset "$D" "my-fix" patch
git -C "$D" add -A; git -C "$D" commit -q -m change
check "plugin changed + changeset -> pass" pass "$D"

# 2. plugin changed, nothing declared -> fail
D="$(new_sandbox 0.26.0)"
git -C "$D" checkout -q -b feature
echo "edit" >> "$D/plugins/$PLUGIN/commands/thing.md"
git -C "$D" add -A; git -C "$D" commit -q -m change
check "plugin changed + no declaration -> fail" fail "$D"

# 3. legacy hand bump still accepted
D="$(new_sandbox 0.26.0)"
git -C "$D" checkout -q -b feature
echo "edit" >> "$D/plugins/$PLUGIN/commands/thing.md"
set_version "$D" 0.26.1
git -C "$D" add -A; git -C "$D" commit -q -m change
check "plugin changed + hand bump -> pass (legacy path)" pass "$D"

# 4. no plugin change at all
D="$(new_sandbox 0.26.0)"
git -C "$D" checkout -q -b feature
echo "docs" > "$D/README.md"
git -C "$D" add -A; git -C "$D" commit -q -m docs
check "no plugin change -> pass" pass "$D"

echo ""
echo "--- main mode (the backstop that did not exist before) ---"

# 5. unreleased changesets sitting on main -> fail
D="$(new_sandbox 0.26.0)"
echo "edit" >> "$D/plugins/$PLUGIN/commands/thing.md"
changeset "$D" "pending" patch
git -C "$D" add -A; git -C "$D" commit -q -m "merged PR"
check "unreleased changesets on main -> fail" fail "$D"

# 6. plugin changed and version increased -> pass
D="$(new_sandbox 0.26.0)"
echo "edit" >> "$D/plugins/$PLUGIN/commands/thing.md"
set_version "$D" 0.26.1
git -C "$D" add -A; git -C "$D" commit -q -m release
check "main: content changed + version up -> pass" pass "$D"

# 7. THE HOLE: plugin changed, version identical -> must fail
D="$(new_sandbox 0.26.0)"
echo "edit" >> "$D/plugins/$PLUGIN/commands/thing.md"
git -C "$D" add -A; git -C "$D" commit -q -m "content at unchanged version"
check "main: content changed + version SAME -> fail" fail "$D"

# 8. plugin changed, version went backwards -> must fail
D="$(new_sandbox 0.26.4)"
echo "edit" >> "$D/plugins/$PLUGIN/commands/thing.md"
set_version "$D" 0.26.2
git -C "$D" add -A; git -C "$D" commit -q -m "backwards"
check "main: content changed + version BACKWARDS -> fail" fail "$D"

echo ""
echo "--- release.sh ---"

# 9. highest bump type wins across changesets; CHANGELOG written; changesets consumed
D="$(new_sandbox 0.26.0)"
changeset "$D" "a-fix" patch "### Fixed"
changeset "$D" "b-feature" minor "### Added"
(cd "$D" && bash scripts/release.sh >/dev/null 2>&1)
V="$(python3 -c "import json;print(json.load(open('$D/plugins/$PLUGIN/.claude-plugin/plugin.json'))['version'])")"
[ "$V" = "0.27.0" ]; expect $? "release: patch+minor -> minor bump (0.26.0 -> 0.27.0, got $V)"
MV="$(python3 -c "import json;print([p for p in json.load(open('$D/.claude-plugin/marketplace.json'))['plugins'] if p['name']=='$PLUGIN'][0]['version'])")"
[ "$MV" = "$V" ]; expect $? "release: marketplace.json kept in sync ($MV)"
grep -q "## \[0.27.0\]" "$D/CHANGELOG.md"; expect $? "release: CHANGELOG section added"
grep -q "a-fix" "$D/CHANGELOG.md" && grep -q "b-feature" "$D/CHANGELOG.md"
expect $? "release: both changeset bodies folded into CHANGELOG"
[ "$(grep -c '^### Added' "$D/CHANGELOG.md")" -ge 1 ] && [ "$(grep -c '^### Fixed' "$D/CHANGELOG.md")" -ge 1 ]
expect $? "release: entries grouped under their own headings"
[ -z "$(find "$D/.changes" -name '*.md' ! -name 'README.md')" ]
expect $? "release: changesets consumed"
grep -q "## \[Unreleased\]" "$D/CHANGELOG.md"; expect $? "release: Unreleased header preserved"

# 10. major beats minor
D="$(new_sandbox 1.2.3)"
changeset "$D" "c-break" major "### Changed"
changeset "$D" "d-fix" patch "### Fixed"
(cd "$D" && bash scripts/release.sh >/dev/null 2>&1)
V="$(python3 -c "import json;print(json.load(open('$D/plugins/$PLUGIN/.claude-plugin/plugin.json'))['version'])")"
[ "$V" = "2.0.0" ]; expect $? "release: major wins (1.2.3 -> 2.0.0, got $V)"

# 11. dry run changes nothing
D="$(new_sandbox 0.26.0)"
changeset "$D" "e-fix" patch
BEFORE="$(git -C "$D" status --porcelain; cat "$D/plugins/$PLUGIN/.claude-plugin/plugin.json")"
(cd "$D" && bash scripts/release.sh --dry-run >/dev/null 2>&1)
AFTER="$(git -C "$D" status --porcelain; cat "$D/plugins/$PLUGIN/.claude-plugin/plugin.json")"
[ "$BEFORE" = "$AFTER" ]; expect $? "release --dry-run: nothing written"

# 12. release then main-mode check passes end to end
D="$(new_sandbox 0.26.0)"
echo "edit" >> "$D/plugins/$PLUGIN/commands/thing.md"
changeset "$D" "f-fix" patch
git -C "$D" add -A; git -C "$D" commit -q -m "merged PR"
(cd "$D" && bash scripts/release.sh >/dev/null 2>&1)
git -C "$D" add -A; git -C "$D" commit -q -m "chore: release"
check "release -> main check green end to end" pass "$D"

# 13. no changesets at all is a no-op, not an error
D="$(new_sandbox 0.26.0)"
(cd "$D" && bash scripts/release.sh >/dev/null 2>&1); expect $? "release: no changesets -> exit 0"

# 14. invalid bump type is rejected
D="$(new_sandbox 0.26.0)"
changeset "$D" "bad" enormous
(cd "$D" && bash scripts/release.sh >/dev/null 2>&1); [ $? -ne 0 ]
expect $? "release: invalid bump type rejected"

echo ""
echo "=========================================="
echo -e "Passed: ${GREEN}$PASS${NC}   Failed: ${RED}$FAIL${NC}"
echo "=========================================="
[ "$FAIL" -eq 0 ] || exit 1
