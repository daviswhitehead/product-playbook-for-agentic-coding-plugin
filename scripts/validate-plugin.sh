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
    ((ERRORS++))
}

# Function to report warning
warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
    ((WARNINGS++))
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
    ((COMMAND_COUNT++))
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
    ((AGENT_COUNT++))
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
    ((SKILL_COUNT++))
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

# 6. Validate templates
echo "Validating templates..."
echo "-------------------------------------------"

TEMPLATE_COUNT=0
for template in $(find "$PLUGIN_DIR/resources/templates" -name "*.md" 2>/dev/null); do
    ((TEMPLATE_COUNT++))
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
