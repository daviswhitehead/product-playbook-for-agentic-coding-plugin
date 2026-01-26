# Product Playbook for Agentic Coding

A Claude Code plugin that provides a structured 4-phase workflow for agentic software development.

## Overview

This plugin implements a systematic approach to building software with AI assistance, following four key phases:

1. **Product Discovery** - Define what to build and why
2. **Solution Planning** - Design how to build it
3. **Delivery** - Execute the work systematically
4. **Retrospective** - Capture learnings and improve

## Installation

```bash
claude /install path/to/product-playbook-for-agentic-coding-plugin
```

Or if published to a marketplace:
```bash
claude /install product-playbook-for-agentic-coding
```

## Commands

| Command | Description |
|---------|-------------|
| `/playbook:product-requirements` | Draft product requirements with multi-persona discovery |
| `/playbook:tech-plan` | Create technical plan with architecture and sequencing |
| `/playbook:tasks` | Break down work into specific, actionable tasks |
| `/playbook:work` | Execute the next task from the tasks document |
| `/playbook:debug` | Systematic debugging workflow |
| `/playbook:learnings` | Capture learnings to improve docs and plugin |

## Agents

| Agent | Description |
|-------|-------------|
| `product-discovery-agent` | Multi-persona facilitation for product discovery |
| `solution-planning-agent` | Technical planning with architect perspective |
| `delivery-agent` | Task execution with engineering perspective |
| `debugging-agent` | Systematic debugging with verification-first approach |

## Skills

| Skill | Description |
|-------|-------------|
| `codebase-docs-search` | Patterns for finding and using project documentation |
| `learning-capture` | Multi-trigger, dual-target learning capture |
| `autonomous-execution` | Patterns for autonomous project execution |

## Key Features

### Tool Discovery
Commands intelligently discover available tools (commands, agents, MCP tools, skills) and select the right one for each task.

### Codebase Doc Searching
Automatically searches project documentation (`docs/`, `projects/`, `CLAUDE.md`, etc.) to incorporate project-specific context.

### Learning Capture
Three trigger points for capturing learnings:
- After chat sessions (lightweight)
- After project completion (comprehensive)
- After overcoming blockers (targeted)

Learnings can improve either the codebase documentation or the plugin itself.

### External Plugin Integration
Works with other plugins by providing wrapper context when invoking external tools, ensuring outputs conform to playbook workflows.

## Project Structure

```
product-playbook-for-agentic-coding-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── workflows/           # Core workflow commands
│   └── debug.md             # Debugging command
├── agents/
│   └── workflow/            # Phase-specific agents
├── skills/
│   ├── codebase-docs-search/
│   ├── learning-capture/
│   └── autonomous-execution/
└── resources/
    └── templates/           # Document templates
```

## Usage

### Starting a New Project

```
/playbook:product-requirements
```

This will guide you through defining what to build and why, using multi-persona perspectives (Product Manager, Business Stakeholder, Domain Expert, etc.).

### Planning the Solution

```
/playbook:tech-plan
```

Design the technical architecture and sequencing, drawing from Software Architect and Engineering perspectives.

### Breaking Down Work

```
/playbook:tasks
```

Create a detailed task breakdown with acceptance criteria, dependencies, and effort estimates.

### Executing Tasks

```
/playbook:work
```

Work through tasks systematically, with quality checks and documentation updates.

### Capturing Learnings

```
/playbook:learnings
```

Capture what you learned to improve future work.

## Philosophy

This plugin embodies several key principles:

- **Multi-Persona Approach**: Different phases benefit from different perspectives
- **Systematic Workflows**: Structured processes reduce cognitive load
- **Learning Compounds**: Captured learnings improve future work
- **Tool Orchestration**: Leverage the best tool for each task
- **Documentation Discipline**: Keep docs updated as you work

## Contributing

Contributions welcome! Please see the plugin structure and follow existing patterns.

## License

MIT
