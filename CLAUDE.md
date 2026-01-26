# Product Playbook Plugin Development

## Versioning Requirements

**IMPORTANT**: Every change to this plugin MUST include updates to:

1. **`.claude-plugin/plugin.json`** - Bump version using semver
2. **`README.md`** - Verify/update component counts and tables

### Version Bumping Rules

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes, major reorganization
- **MINOR** (1.0.0 → 1.1.0): New commands, agents, or skills
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, doc updates, minor improvements

## Directory Structure

```
product-playbook-for-agentic-coding-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (required)
├── CLAUDE.md                # This file - plugin development guidelines
├── AGENTS.md                # Universal AI instructions (portable)
├── README.md                # User-facing documentation
│
├── commands/
│   ├── workflows/           # Core workflow commands (playbook:*)
│   │   ├── product-requirements.md
│   │   ├── tech-plan.md
│   │   ├── tasks.md
│   │   ├── work.md
│   │   └── learnings.md
│   └── debug.md             # Utility commands
│
├── agents/
│   └── workflow/            # Phase-specific agents
│       ├── product-discovery-agent.md
│       ├── solution-planning-agent.md
│       ├── delivery-agent.md
│       └── debugging-agent.md
│
├── skills/
│   ├── codebase-docs-search/
│   │   └── SKILL.md
│   ├── learning-capture/
│   │   └── SKILL.md
│   └── autonomous-execution/
│       └── SKILL.md
│
└── resources/
    └── templates/           # Document templates
        ├── product-requirements.md
        ├── tech-plan.md
        ├── tasks.md
        └── learnings.md
```

## Command Naming Convention

All commands use `playbook:` prefix to avoid collisions:
- `/playbook:product-requirements` - Product Discovery phase
- `/playbook:tech-plan` - Solution Planning phase
- `/playbook:tasks` - Task breakdown
- `/playbook:work` - Task execution
- `/playbook:debug` - Debugging workflow
- `/playbook:learnings` - Learning capture

## Component Formats

### Commands

```markdown
---
name: playbook:command-name
description: Brief description of what the command does
argument-hint: "[optional argument description]"
---

# Command Title

Command instructions and workflow...
```

### Agents

```markdown
---
name: agent-identifier
description: "Use this agent when [triggering conditions]. Examples:

<example>
Context: [Situation]
user: \"[User request]\"
assistant: \"[Response using this agent]\"
<commentary>
[Why this agent should be triggered]
</commentary>
</example>"

model: inherit
---

You are [agent role description]...

## Your Responsibilities
1. [Responsibility 1]
2. [Responsibility 2]

## Process
[Step-by-step workflow]
```

### Skills

```markdown
---
name: skill-name
description: This skill should be used when [conditions]. It provides [what it provides].
---

# Skill Title

[Detailed skill content and guidance]
```

## Key Patterns

### Tool Discovery Pattern

All workflow commands should include:

```markdown
## Available Tools Discovery

Before proceeding, inventory available tools:
1. **List available commands**: Check what slash commands are available
2. **List available agents**: Check Task tool agent types
3. **List available MCP tools**: Check ToolSearch for MCP capabilities
4. **List available skills**: Check Skill tool options

Select the most appropriate tool for the task at hand.
```

### Codebase Doc Searching Pattern

Commands should search for project context:

```markdown
## Project Context

Search for relevant documentation:
- `docs/`, `docs/projects/`, `projects/`
- `CLAUDE.md`, `AGENTS.md`, `README.md`

Use Glob → Grep → Read strategy to find and incorporate relevant context.
```

### Learning Capture Pattern

Three trigger points:
1. **After chat sessions** - Lightweight capture
2. **After project completion** - Comprehensive retrospective
3. **After overcoming blockers** - Targeted documentation

Two output targets:
1. **Codebase documentation** - Project-specific learnings
2. **Plugin improvements** - Workflow and tool enhancements

## Quality Checklist

Before committing changes:

- [ ] Version bumped in plugin.json
- [ ] README.md updated if components changed
- [ ] All commands have proper frontmatter (name, description)
- [ ] All agents have proper frontmatter (name, description, model)
- [ ] All skills have SKILL.md with proper frontmatter
- [ ] No hardcoded paths (plugin should work in any project)

## Testing

After making changes:

1. Install plugin locally: `claude /install [path]`
2. Verify commands appear in command list
3. Test each modified command
4. Verify agents spawn correctly via Task tool
5. Verify skills provide useful guidance
