---
name: codebase-docs-search
description: Patterns for finding and using project documentation at runtime. Use this skill when you need to search for existing documentation, solutions, patterns, or learnings in a codebase before starting work.
---

# Codebase Documentation Search

This skill provides patterns for discovering and leveraging project-specific documentation at runtime. Use it to find existing solutions, understand patterns, and avoid reinventing the wheel.

## When to Use This Skill

Search codebase docs when:
- Starting a new feature (check for existing patterns)
- Debugging an issue (check for documented solutions)
- Planning technical work (understand architecture decisions)
- Before making architectural changes (review existing decisions)
- When encountering unfamiliar code (find explanations)

## Standard Documentation Locations

Search these locations in order of priority:

### High Priority (Project-Specific)
| Location | Purpose |
|----------|---------|
| `CLAUDE.md` | AI-specific project instructions |
| `AGENTS.md` | AI agent guidelines |
| `docs/` | General project documentation |
| `docs/projects/` | Project-specific docs |
| `docs/solutions/` | Documented problem solutions |
| `docs/learnings/` | Captured learnings |

### Medium Priority (Context)
| Location | Purpose |
|----------|---------|
| `README.md` | Project overview |
| `docs/guides/` | How-to guides |
| `docs/architecture/` | Architecture decisions |
| `playbook/` | Workflow documentation |

### Lower Priority (Reference)
| Location | Purpose |
|----------|---------|
| `*.md` files in root | Various documentation |
| Code comments | Inline documentation |
| Test files | Expected behaviors |

## Search Strategy

### Step 1: Glob for Documentation Files

```bash
# Find all markdown files in standard locations
Glob: docs/**/*.md
Glob: **/README.md
Glob: **/CLAUDE.md
Glob: **/AGENTS.md
```

### Step 2: Grep for Relevant Content

```bash
# Search for keywords in documentation
Grep: "keyword" in docs/
Grep: "error message" in docs/solutions/
Grep: "pattern name" in docs/
```

### Step 3: Read Relevant Files

After finding matches, read the most relevant files to understand:
- Existing solutions to similar problems
- Architectural decisions and rationale
- Patterns used in the codebase
- Known gotchas or constraints

## YAML Frontmatter Search

For learnings and solutions with YAML frontmatter, use targeted searches:

```yaml
# Frontmatter schema for learnings
---
title: "Brief descriptive title"
date: YYYY-MM-DD
trigger: [chat-session|project-completion|blocker-overcome]
category: [performance|database|integration|workflow|debugging]
tags: [relevant, searchable, keywords]
severity: [critical|high|medium|low]
module: "affected_module_name"
---
```

### Search by Category
```bash
Grep: "category: performance" in docs/learnings/
Grep: "category: database" in docs/solutions/
```

### Search by Tags
```bash
Grep: "tags:.*authentication" in docs/
Grep: "tags:.*caching" in docs/learnings/
```

### Search by Module
```bash
Grep: "module: user_service" in docs/
```

## Search Patterns by Context

### Before Starting a Feature
1. Search for similar features: `Grep: "feature-name" in docs/`
2. Check for architectural patterns: `Grep: "pattern" in docs/architecture/`
3. Look for related learnings: `Grep: "category:.*relevant-category" in docs/learnings/`

### When Debugging
1. Search for the error: `Grep: "error message" in docs/solutions/`
2. Check for known issues: `Grep: "symptom" in docs/learnings/`
3. Look for troubleshooting guides: `Glob: docs/**/troubleshoot*.md`

### Before Making Changes
1. Check for architecture decisions: `Grep: "component-name" in docs/architecture/`
2. Look for related decisions: `Grep: "decision" in docs/`
3. Review existing patterns: `Glob: docs/patterns/**/*.md`

## Handling Missing Documentation

If documentation doesn't exist for your area:

1. **Note the gap** - This is valuable feedback
2. **Proceed with caution** - Make educated decisions
3. **Document as you go** - Create the docs you wish existed
4. **Capture learnings** - Use `/playbook:learnings` after completing work

## Integration with Playbook Commands

This skill is automatically used by:
- `/playbook:tech-plan` - Searches for architecture docs and existing patterns
- `/playbook:work` - Searches for relevant learnings before starting tasks
- `/playbook:debug` - Searches for existing solutions to similar problems

## Best Practices

1. **Search before creating** - Always check if documentation exists
2. **Use specific keywords** - More specific searches yield better results
3. **Check multiple locations** - Docs may be in unexpected places
4. **Read frontmatter** - YAML metadata helps filter relevant docs
5. **Note gaps** - Missing docs are opportunities to improve
6. **Keep docs updated** - Update docs when you find them outdated

## Example Workflow

```markdown
# Before implementing user authentication:

1. Search for existing auth docs:
   Glob: docs/**/*auth*.md
   Grep: "authentication" in docs/

2. Check for security patterns:
   Grep: "security" in docs/architecture/

3. Look for related learnings:
   Grep: "category: security" in docs/learnings/
   Grep: "tags:.*auth" in docs/solutions/

4. Review findings and incorporate into planning
```

---

*Good documentation search prevents duplicate work and leverages institutional knowledge.*
