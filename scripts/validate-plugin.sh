#!/bin/bash

# Plugin Validation Script
# Validates the structure and content of the product-playbook-for-agentic-coding plugin

set -e

PLUGIN_DIR="plugins/product-playbook-for-agentic-coding"
ERRORS=0
WARNINGS=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Plugin Validation: product-playbook-for-agentic-coding"
echo "=========================================="
echo ""

# Function to report error
error() {
    echo -e "${RED}ERROR: $1${NC}"
    ERRORS=$((ERRORS + 1))
}

# Function to report warning
warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

# Function to report success
success() {
    echo -e "${GREEN}OK: $1${NC}"
}

# 1. Check plugin structure
echo "Checking plugin structure..."
echo "-------------------------------------------"

# Check required directories
for dir in ".claude-plugin" "commands" "agents" "skills" "resources/templates"; do
    if [ -d "$PLUGIN_DIR/$dir" ]; then
        success "Directory exists: $dir"
    else
        error "Missing directory: $dir"
    fi
done

# Check required files
if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    success "plugin.json exists"
else
    error "Missing plugin.json"
fi

echo ""

# 2. Validate plugin.json
echo "Validating plugin.json..."
echo "-------------------------------------------"

if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    # Check for required fields
    for field in "name" "version" "description" "author"; do
        if grep -q "\"$field\"" "$PLUGIN_DIR/.claude-plugin/plugin.json"; then
            success "plugin.json has field: $field"
        else
            error "plugin.json missing field: $field"
        fi
    done
fi

echo ""

# 3. Validate commands
echo "Validating commands..."
echo "-------------------------------------------"

COMMAND_COUNT=0
for cmd in $(find "$PLUGIN_DIR/commands" -name "*.md" 2>/dev/null); do
    COMMAND_COUNT=$((COMMAND_COUNT + 1))
    filename=$(basename "$cmd")

    # Check for frontmatter
    if head -1 "$cmd" | grep -q "^---"; then
        # Check for required frontmatter fields
        if grep -q "^name:" "$cmd"; then
            success "Command $filename has 'name' field"
        else
            error "Command $filename missing 'name' field"
        fi

        if grep -q "^description:" "$cmd"; then
            success "Command $filename has 'description' field"
        else
            error "Command $filename missing 'description' field"
        fi
    else
        error "Command $filename missing frontmatter"
    fi
done

if [ $COMMAND_COUNT -eq 0 ]; then
    warning "No commands found"
else
    echo "Found $COMMAND_COUNT command(s)"
fi

echo ""

# 4. Validate agents
echo "Validating agents..."
echo "-------------------------------------------"

AGENT_COUNT=0
for agent in $(find "$PLUGIN_DIR/agents" -name "*.md" 2>/dev/null); do
    AGENT_COUNT=$((AGENT_COUNT + 1))
    filename=$(basename "$agent")

    # Check for frontmatter
    if head -1 "$agent" | grep -q "^---"; then
        # Check for required frontmatter fields
        if grep -q "^name:" "$agent"; then
            success "Agent $filename has 'name' field"
        else
            error "Agent $filename missing 'name' field"
        fi

        if grep -q "^description:" "$agent"; then
            success "Agent $filename has 'description' field"
        else
            error "Agent $filename missing 'description' field"
        fi
    else
        error "Agent $filename missing frontmatter"
    fi
done

if [ $AGENT_COUNT -eq 0 ]; then
    warning "No agents found"
else
    echo "Found $AGENT_COUNT agent(s)"
fi

echo ""

# 5. Validate skills
echo "Validating skills..."
echo "-------------------------------------------"

SKILL_COUNT=0
for skill_dir in $(find "$PLUGIN_DIR/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null); do
    SKILL_COUNT=$((SKILL_COUNT + 1))
    skill_name=$(basename "$skill_dir")

    # Check for SKILL.md
    if [ -f "$skill_dir/SKILL.md" ]; then
        success "Skill $skill_name has SKILL.md"

        # Check for frontmatter
        if head -1 "$skill_dir/SKILL.md" | grep -q "^---"; then
            if grep -q "^name:" "$skill_dir/SKILL.md"; then
                success "Skill $skill_name has 'name' field"
            else
                error "Skill $skill_name SKILL.md missing 'name' field"
            fi

            if grep -q "^description:" "$skill_dir/SKILL.md"; then
                success "Skill $skill_name has 'description' field"
            else
                error "Skill $skill_name SKILL.md missing 'description' field"
            fi
        else
            error "Skill $skill_name SKILL.md missing frontmatter"
        fi
    else
        error "Skill $skill_name missing SKILL.md"
    fi
done

if [ $SKILL_COUNT -eq 0 ]; then
    warning "No skills found"
else
    echo "Found $SKILL_COUNT skill(s)"
fi

echo ""

# 5b. Validate hooks
# A hook is the one component that runs every session without being invoked, so
# a malformed one degrades every session silently for every user. Validate it.
echo "Validating hooks..."
echo "-------------------------------------------"

HOOKS_FILE="$PLUGIN_DIR/hooks/hooks.json"
if [ -f "$HOOKS_FILE" ]; then
    if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$HOOKS_FILE" 2>/dev/null; then
        success "hooks.json is valid JSON"

        # Every referenced script must exist and be executable, or the hook
        # fails silently at session start.
        while IFS=$'\t' read -r event relpath; do
            [ -z "$event" ] && continue
            if [ -z "$relpath" ]; then
                warning "$event hook does not use \${CLAUDE_PLUGIN_ROOT} — may not resolve once installed"
            elif [ ! -f "$PLUGIN_DIR$relpath" ]; then
                error "$event hook references a missing script: $relpath"
            elif [ ! -x "$PLUGIN_DIR$relpath" ]; then
                error "$event hook script is not executable: $relpath"
            else
                success "$event hook -> $relpath (exists, executable)"
            fi
        done < <(python3 - "$HOOKS_FILE" <<'PYEOF'
import json, re, sys
d = json.load(open(sys.argv[1]))
for event, entries in d.get("hooks", {}).items():
    for entry in entries:
        for h in entry.get("hooks", []):
            m = re.search(r'\$\{CLAUDE_PLUGIN_ROOT\}"?(/[^\s"]+)', h.get("command", ""))
            print(f"{event}\t{m.group(1) if m else ''}")
PYEOF
        )
    else
        error "hooks.json is not valid JSON"
    fi
else
    warning "No hooks/hooks.json (optional)"
fi

echo ""

# 6. Validate templates
echo "Validating templates..."
echo "-------------------------------------------"

TEMPLATE_COUNT=0
for template in $(find "$PLUGIN_DIR/resources/templates" -name "*.md" 2>/dev/null); do
    TEMPLATE_COUNT=$((TEMPLATE_COUNT + 1))
    filename=$(basename "$template")
    success "Template exists: $filename"
done

if [ $TEMPLATE_COUNT -eq 0 ]; then
    warning "No templates found"
else
    echo "Found $TEMPLATE_COUNT template(s)"
fi

echo ""

# 7. Check marketplace.json
echo "Validating marketplace.json..."
echo "-------------------------------------------"

if [ -f ".claude-plugin/marketplace.json" ]; then
    success "marketplace.json exists"

    for field in "name" "owner" "plugins"; do
        if grep -q "\"$field\"" ".claude-plugin/marketplace.json"; then
            success "marketplace.json has field: $field"
        else
            error "marketplace.json missing field: $field"
        fi
    done
else
    error "Missing marketplace.json"
fi

echo ""

# 8. Check version consistency between marketplace.json entries and plugin.json files
# WHY: auto-update is version-keyed; if these two disagree, the marketplace listing
# and what actually installs can diverge. They must match for every plugin.
echo "Checking version consistency (marketplace.json <-> plugin.json)..."
echo "-------------------------------------------"

if [ -f ".claude-plugin/marketplace.json" ]; then
    CONSISTENCY_REPORT="$(python3 - <<'PY'
import json, os
with open(".claude-plugin/marketplace.json") as f:
    market = json.load(f)
for entry in market.get("plugins", []):
    name = entry.get("name", "?")
    mver = entry.get("version")
    src = (entry.get("source") or "").lstrip("./")
    pj = os.path.join(src, ".claude-plugin", "plugin.json")
    if not src or not os.path.isfile(pj):
        print(f"WARN|{name}|marketplace entry has no resolvable plugin.json at '{pj}'")
        continue
    with open(pj) as f:
        pver = json.load(f).get("version")
    if mver == pver:
        print(f"OK|{name}|{pver}")
    else:
        print(f"ERR|{name}|marketplace={mver} plugin.json={pver}")
PY
)"
    while IFS='|' read -r status name detail; do
        case "$status" in
            OK)   success "$name versions match ($detail)" ;;
            WARN) warning "$name: $detail" ;;
            ERR)  error "$name version mismatch: $detail (run scripts/sync-version.sh)" ;;
        esac
    done <<< "$CONSISTENCY_REPORT"
else
    error "Cannot check version consistency: marketplace.json missing"
fi

echo ""

# 9. Command surface coverage (commands/help.md + README.md)
# WHY: help.md and README.md hand-duplicate data that already lives in every command's
# frontmatter, and adding a command has no step that touches either file. They drift by
# omission — six real commands (close, close-project, emergent, foundations, monitor-pr,
# research-synthesis) went missing from help.md before this check existed, which makes a
# command effectively undiscoverable no matter how good it is. Generating these files was
# rejected: their value is the human judgment about WHICH command fits WHICH situation,
# which no frontmatter field encodes. So enforce coverage and leave the curation alone.
# Bidirectional, because both directions fail: a new command going unlisted (observed),
# and a renamed/deleted command leaving a dangling reference (not yet, but inevitable).
echo "Checking command surface coverage (help.md + README.md)..."
echo "-------------------------------------------"

# NOTE: the report goes to a temp file rather than through $(...). bash 3.2 (still the
# default /bin/bash on macOS) mis-parses a heredoc containing apostrophes when it sits
# inside command substitution, failing with "unexpected EOF while looking for matching `'".
COVERAGE_TMP="$(mktemp)"
trap 'rm -f "$COVERAGE_TMP"' EXIT

python3 - "$PLUGIN_DIR" > "$COVERAGE_TMP" <<'PY'
import os, re, sys

plugin_dir = sys.argv[1]
cmd_dir = os.path.join(plugin_dir, "commands")
help_rel = "commands/help.md"
help_path = os.path.join(plugin_dir, help_rel)
readme_path = "README.md"

# Every command's declared name, from frontmatter (the filename may differ: e.g.
# commands/git/create-pr.md declares playbook:git-pr).
real = {}
for root, _, files in os.walk(cmd_dir):
    for fn in sorted(files):
        if not fn.endswith(".md"):
            continue
        path = os.path.join(root, fn)
        with open(path) as f:
            for line in f:
                m = re.match(r'^name:\s*(\S+)', line)
                if m:
                    real[m.group(1)] = os.path.relpath(path, plugin_dir)
                    break

if not real:
    print("ERR||no commands with a 'name:' field found")

if os.path.isfile(help_path):
    with open(help_path) as f:
        help_txt = f.read()
    problems = 0
    for name, src in sorted(real.items()):
        # Trailing (?![\w-]) so /playbook:work is not satisfied by /playbook:work-multiple.
        if not re.search(r'/' + re.escape(name) + r'(?![\w-])', help_txt):
            print(f"ERR|{name}|not listed in {help_rel} (defined in {src})")
            problems += 1
    for ref in sorted(set(re.findall(r'/(playbook:[a-z0-9][a-z0-9-]*)', help_txt))):
        if ref not in real:
            print(f"ERR|{ref}|referenced in {help_rel} but no command defines it")
            problems += 1
    if not problems:
        print(f"OK||{help_rel} covers all {len(real)} commands, no dangling references")
else:
    print(f"ERR||{help_rel} not found")

if os.path.isfile(readme_path):
    with open(readme_path) as f:
        readme_txt = f.read()
    # Require a real table row, not a prose mention: /playbook:close-project was named in
    # README prose while absent from every command table.
    problems = 0
    for name, src in sorted(real.items()):
        if not re.search(r'^\|\s*`/' + re.escape(name) + r'`\s*\|', readme_txt, re.M):
            print(f"ERR|{name}|no README.md command-table row (defined in {src})")
            problems += 1
    if not problems:
        print(f"OK||README.md has a table row for all {len(real)} commands")
else:
    print("WARN||README.md not found - skipping README coverage")
PY

while IFS='|' read -r status name detail; do
    [ -z "$status" ] && continue
    case "$status" in
        OK)   success "$detail" ;;
        WARN) warning "$detail" ;;
        ERR)  if [ -n "$name" ]; then error "$name: $detail"; else error "$detail"; fi ;;
    esac
done < "$COVERAGE_TMP"

echo ""

# Summary
echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo "Commands: $COMMAND_COUNT"
echo "Agents: $AGENT_COUNT"
echo "Skills: $SKILL_COUNT"
echo "Templates: $TEMPLATE_COUNT"
echo ""
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Validation FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Validation PASSED${NC}"
    exit 0
fi
