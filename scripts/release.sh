#!/bin/bash
#
# release.sh — Consume .changes/*.md, compute each plugin's new version, update
#              plugin.json + marketplace.json + CHANGELOG.md, delete the changesets.
#
# WHY THIS EXISTS:
#   The version is a single monotonic counter on main, but PRs are parallel. Requiring
#   each PR to bump the version made N open PRs mutually exclusive — they all wanted the
#   same next number — which forced serialized merges (one patch version per PR) and made
#   every PR's version-file edits conflict with every other PR's.
#
#   Changesets move the bump off the PR branch: a PR adds a NEW FILE (cannot conflict),
#   and the number is computed here, once, on main. Any number of PRs merge in any order.
#
# USAGE:
#   scripts/release.sh [--dry-run]
#
# AFTER RUNNING:
#   git add -A && git commit -m "chore: release <version>" && git push
#   The version bump is what propagates the update to installs — see CLAUDE.md.

set -euo pipefail

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

if [ ! -d ".changes" ] || [ -z "$(find .changes -name '*.md' ! -name 'README.md' -print -quit)" ]; then
    echo -e "${YELLOW}No changesets in .changes/ — nothing to release.${NC}"
    exit 0
fi

# All parsing/merging happens in python: version arithmetic and CHANGELOG assembly are
# both places where a bash-and-sed version would be quietly wrong.
PLAN="$(python3 - "$DRY_RUN" <<'PY'
import json, os, re, sys, datetime, glob

dry = sys.argv[1] == "1"
RANK = {"patch": 0, "minor": 1, "major": 2}
DEFAULT_PLUGIN = "product-playbook-for-agentic-coding"

def parse(path):
    text = open(path).read()
    meta, body = {}, text
    m = re.match(r'^---\n(.*?)\n---\n?(.*)$', text, re.S)
    if m:
        for line in m.group(1).splitlines():
            if ':' in line:
                k, v = line.split(':', 1)
                meta[k.strip()] = v.strip()
        body = m.group(2)
    return meta, body.strip()

changesets = sorted(p for p in glob.glob(".changes/*.md") if os.path.basename(p) != "README.md")

by_plugin = {}
for path in changesets:
    meta, body = parse(path)
    plugin = meta.get("plugin", DEFAULT_PLUGIN)
    bump = (meta.get("bump") or "patch").lower()
    if bump not in RANK:
        print(f"ERROR|invalid bump '{bump}' in {path} (expected patch|minor|major)")
        sys.exit(1)
    if not body:
        print(f"ERROR|{path} has no body — the CHANGELOG prose is the point")
        sys.exit(1)
    by_plugin.setdefault(plugin, {"bump": "patch", "entries": [], "files": []})
    slot = by_plugin[plugin]
    if RANK[bump] > RANK[slot["bump"]]:
        slot["bump"] = bump
    slot["entries"].append(body)
    slot["files"].append(path)

def bumped(version, kind):
    major, minor, patch = (int(x) for x in re.match(r'^(\d+)\.(\d+)\.(\d+)', version).groups())
    if kind == "major":
        return f"{major + 1}.0.0"
    if kind == "minor":
        return f"{major}.{minor + 1}.0"
    return f"{major}.{minor}.{patch + 1}"

# Group entries under their "### Heading" so the CHANGELOG keeps one section per kind
# rather than repeating "### Fixed" once per merged PR.
def assemble(entries):
    sections, order = {}, []
    for entry in entries:
        current = "### Changed"
        for line in entry.splitlines():
            if line.startswith("###"):
                current = line.strip()
                if current not in order:
                    order.append(current)
                sections.setdefault(current, [])
            else:
                if current not in sections:
                    sections[current] = []
                    if current not in order:
                        order.append(current)
                sections[current].append(line)
    out = []
    for heading in order:
        lines = sections.get(heading, [])
        while lines and not lines[0].strip():
            lines.pop(0)
        while lines and not lines[-1].strip():
            lines.pop()
        if lines:
            out.append(heading + "\n" + "\n".join(lines))
    return "\n\n".join(out)

today = datetime.date.today().isoformat()
released = []

for plugin, slot in sorted(by_plugin.items()):
    pj = os.path.join("plugins", plugin, ".claude-plugin", "plugin.json")
    if not os.path.isfile(pj):
        print(f"ERROR|changeset names unknown plugin '{plugin}' (no {pj})")
        sys.exit(1)
    with open(pj) as f:
        data = json.load(f)
    old = data["version"]
    new = bumped(old, slot["bump"])
    released.append((plugin, old, new, slot["bump"], len(slot["files"])))

    if dry:
        continue

    data["version"] = new
    with open(pj, "w") as f:
        json.dump(data, f, indent=2); f.write("\n")

    market_path = ".claude-plugin/marketplace.json"
    with open(market_path) as f:
        market = json.load(f)
    for entry in market.get("plugins", []):
        if entry.get("name") == plugin:
            entry["version"] = new
    with open(market_path, "w") as f:
        json.dump(market, f, indent=2); f.write("\n")

    if plugin == DEFAULT_PLUGIN:
        body = assemble(slot["entries"])
        with open("CHANGELOG.md") as f:
            log = f.read()
        section = f"## [Unreleased]\n\n## [{new}] - {today}\n\n{body}\n"
        log = log.replace("## [Unreleased]\n", section, 1)
        with open("CHANGELOG.md", "w") as f:
            f.write(log)

    for path in slot["files"]:
        os.remove(path)

for plugin, old, new, kind, count in released:
    print(f"OK|{plugin}|{old}|{new}|{kind}|{count}")
PY
)"

while IFS='|' read -r status a b c d e; do
    [ -z "$status" ] && continue
    if [ "$status" = "ERROR" ]; then
        echo -e "${RED}ERROR: $a${NC}"; exit 1
    fi
    if [ "$DRY_RUN" = "1" ]; then
        echo -e "${YELLOW}(dry run)${NC} $a: $b -> $c  ($d, from $e changeset(s))"
    else
        echo -e "${GREEN}Released $a: $b -> $c${NC}  ($d, from $e changeset(s))"
    fi
done <<< "$PLAN"

if [ "$DRY_RUN" = "1" ]; then
    echo ""
    echo "Dry run — nothing written. Re-run without --dry-run to apply."
    exit 0
fi

echo ""
echo "Next steps:"
echo "  1. Review the CHANGELOG section and the version files."
echo "  2. git add -A && git commit -m 'chore: release' && git push"
echo "     (the version bump is what propagates the update to installs)"
