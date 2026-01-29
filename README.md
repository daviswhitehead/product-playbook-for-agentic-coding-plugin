# Product Playbook for Agentic Coding

A Claude Code plugin that provides a structured 4-phase workflow for agentic software development.

## Overview

This plugin implements a systematic approach to building software with AI assistance, following four key phases:

1. **Product Discovery** - Define what to build and why
2. **Solution Planning** - Design how to build it
3. **Delivery** - Execute the work systematically
4. **Retrospective** - Capture learnings and improve

## Installation

### From GitHub (Recommended)
```bash
# Add the GitHub repository as a marketplace
/plugin marketplace add daviswhitehead/product-playbook-for-agentic-coding-plugin

# Install the plugin
/plugin install product-playbook-for-agentic-coding@product-playbook-marketplace
```

### From Local Path (Development)
```bash
# Add the local plugin directory as a marketplace
/plugin marketplace add /path/to/product-playbook-for-agentic-coding-plugin

# Install the plugin
/plugin install product-playbook-for-agentic-coding@product-playbook-marketplace
```

## Commands

### Core Workflow Commands
| Command | Description |
|---------|-------------|
| `/playbook:product-requirements` | Draft product requirements with multi-persona discovery |
| `/playbook:tech-plan` | Create technical plan with architecture and sequencing |
| `/playbook:tasks` | Break down work into specific, actionable tasks |
| `/playbook:work` | Execute the next task from the tasks document |
| `/playbook:work-multiple` | Work autonomously on multiple tasks without interruption |
| `/playbook:learnings` | Capture learnings to improve docs and plugin |

### Debugging & CI Commands
| Command | Description |
|---------|-------------|
| `/playbook:debug` | Systematic debugging workflow |
| `/playbook:debug-ci` | Debug CI/CD failures using GitHub CLI |

### Design Commands
| Command | Description |
|---------|-------------|
| `/playbook:design-critique` | Facilitate a design critique to analyze visual designs |
| `/playbook:design-spec` | Create a high-fidelity design specification for complex UI features |

### Review & Improvement Commands
| Command | Description |
|---------|-------------|
| `/playbook:review-autonomy` | Review project readiness for autonomous execution |
| `/playbook:identify-improvements` | Identify top 10 improvements from a coding session |
| `/playbook:prompt-coaching` | Get real-time coaching on your prompts |

### Git Commands
| Command | Description |
|---------|-------------|
| `/playbook:git-commit` | Analyze changes and create well-structured conventional commits |
| `/playbook:git-pr` | Create a pull request with clear title and description |
| `/playbook:git-worktree` | Create a git worktree for isolated parallel development |
| `/playbook:git-branch-worktree` | Create a new branch and worktree together |
| `/playbook:git-delete-branch` | Safely delete a branch from local and remote |
| `/playbook:git-move-changes` | Move uncommitted changes to a new branch |

### Organization Commands
| Command | Description |
|---------|-------------|
| `/playbook:organize-files` | Organize project files into logical subdirectories |
| `/playbook:review-playbook` | Systematically review and optimize the playbook/plugin |

### Document Workflow Commands
| Command | Description |
|---------|-------------|
| `/playbook:rubric-doc` | Generate documents based on a spec file with rubric/excellence criteria |
| `/playbook:refine-doc` | Incorporate new information into existing documents while maintaining consistency |
| `/playbook:distill` | Create focused summaries or quick references from longer documents |

### Help
| Command | Description |
|---------|-------------|
| `/playbook:help` | List all commands and find the right one for your task |

## Agents

| Agent | Description |
|-------|-------------|
| `product-discovery-agent` | Multi-persona facilitation for product discovery |
| `solution-planning-agent` | Technical planning with architect perspective |
| `delivery-agent` | Task execution with engineering perspective |
| `debugging-agent` | Systematic debugging with verification-first approach |
| `insight-extractor-agent` | Extract and organize insights from source materials with citations |
| `cross-reference-validator-agent` | Validate consistency across interconnected documents |

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
│   └── marketplace.json     # Marketplace definition
├── plugins/
│   └── product-playbook-for-agentic-coding/
│       ├── .claude-plugin/
│       │   └── plugin.json  # Plugin definition
│       ├── commands/
│       │   ├── workflows/   # Core workflow commands
│       │   └── debug.md     # Debugging command
│       ├── agents/
│       │   └── workflow/    # Phase-specific agents
│       ├── skills/
│       │   ├── codebase-docs-search/
│       │   ├── learning-capture/
│       │   └── autonomous-execution/
│       └── resources/
│           └── templates/   # Document templates
└── README.md
```

## Usage

> **Important**: These are slash commands, not skills. Invoke them directly by typing `/playbook:*` in the chat, not via the Skill tool.

### Complete Workflow Example

```bash
# 1. Start with product discovery
/playbook:product-requirements
# Answer questions, define the problem, users, and success criteria
# Output: docs/projects/my-feature/product-requirements.md

# 2. Plan the technical approach
/playbook:tech-plan
# Design architecture, sequencing, and technical approach
# Output: docs/projects/my-feature/tech-plan.md

# 3. Break down into tasks
/playbook:tasks
# Create specific, actionable tasks with acceptance criteria
# Output: docs/projects/my-feature/tasks.md

# 4. Execute tasks one by one
/playbook:work
# Implement, test, and document each task
# Updates: tasks.md status, code changes

# 5. Debug any issues
/playbook:debug
# Systematic debugging with verification-first approach

# 6. Capture learnings
/playbook:learnings
# Document what you learned for future work
# Output: docs/learnings/YYYY-MM-DD-topic.md
```

### Command Details

#### `/playbook:product-requirements`
Guides you through defining **what** to build and **why**:
- Multi-persona perspectives (PM, Business, Domain Expert, etc.)
- Pre-draft clarification gate
- Probing questions to deepen understanding
- Output: Product Requirements Document

#### `/playbook:tech-plan`
Designs **how** to build it:
- Architecture decisions with rationale
- Sequencing plan (phases, dependencies)
- Technology stack evaluation
- Risk assessment
- Searches for relevant learnings first

#### `/playbook:tasks`
Breaks work into actionable tasks:
- Acceptance criteria for each task
- Dependencies between tasks
- AI tool recommendations per task
- Effort estimates

#### `/playbook:work`
Executes tasks systematically:
- Identifies next task based on dependencies
- Searches for relevant learnings before starting
- Quality validation against acceptance criteria
- Updates task status and documentation

#### `/playbook:debug`
Systematic debugging workflow:
- **Searches for prior solutions first**
- Verification-first approach
- Hypothesis tracking
- Root cause analysis
- Captures learning after resolution

#### `/playbook:learnings`
Captures learnings with three triggers:
- **Chat session** (lightweight): Quick insights
- **Project completion** (comprehensive): Full retrospective
- **Blocker overcome** (targeted): Problem/solution documentation

Two output targets:
- **Codebase docs**: Project-specific knowledge
- **Plugin improvements**: Workflow enhancements

## Philosophy

This plugin embodies several key principles:

- **Multi-Persona Approach**: Different phases benefit from different perspectives
- **Systematic Workflows**: Structured processes reduce cognitive load
- **Learning Compounds**: Captured learnings improve future work
- **Tool Orchestration**: Leverage the best tool for each task
- **Documentation Discipline**: Keep docs updated as you work

## Development

### Local Development Setup (Recommended)

For fast iteration when developing the plugin, set up a local development environment:

#### Option 1: Worktree Alongside Target Project

Keep the plugin repo next to your working project for easy access:

```bash
# Clone plugin repo alongside your project
cd /path/to/your-projects
git clone git@github.com:daviswhitehead/product-playbook-for-agentic-coding-plugin.git

# Your structure:
# your-projects/
# ├── my-app/                    # Your working project
# └── product-playbook-for-agentic-coding-plugin/  # Plugin (edit here)
```

#### Option 2: Install from Local Path

Install the plugin from your local clone instead of GitHub:

```bash
# In Claude Code, in your target project:
/plugin marketplace add /path/to/product-playbook-for-agentic-coding-plugin
/plugin install product-playbook-for-agentic-coding@product-playbook-marketplace
```

Now edits to your local plugin are reflected after restarting Claude Code.

#### Development Workflow

1. **Edit** plugin files in your local clone
2. **Validate** with `./scripts/validate-plugin.sh`
3. **Test** by restarting Claude Code or reinstalling
4. **Commit** when changes work
5. **Push** to GitHub when ready to share

#### Quick Ideas Capture

When working in a target project and you have plugin improvement ideas:

1. Create a `docs/plugin-improvements.md` file in your target project
2. Append ideas as they come up
3. Periodically batch-process ideas into the plugin repo

### Validation

Run the validation script to check plugin structure and content:

```bash
./scripts/validate-plugin.sh
```

This checks:
- Plugin structure (directories, required files)
- Command frontmatter (name, description fields)
- Agent frontmatter
- Skill SKILL.md files
- Template files
- marketplace.json configuration

### Local Testing

```bash
# Add as local marketplace
/plugin marketplace add /path/to/product-playbook-for-agentic-coding-plugin

# Install
/plugin install product-playbook-for-agentic-coding@product-playbook-marketplace

# Test a command
/playbook:hello
```

## Contributing

Contributions welcome! Please follow these guidelines:

1. **Fork the repository** and create a feature branch
2. **Follow existing patterns** for commands, agents, and skills
3. **Run validation** before submitting: `./scripts/validate-plugin.sh`
4. **Update CHANGELOG.md** with your changes
5. **Submit a pull request** with clear description

### Adding a New Command

1. Create `plugins/product-playbook-for-agentic-coding/commands/your-command.md`
2. Include required frontmatter:
   ```yaml
   ---
   name: playbook:your-command
   description: Brief description of what it does
   argument-hint: "[optional: usage hint]"
   ---
   ```
3. Follow the multi-persona pattern if applicable
4. Include tool discovery and context gathering sections

### Adding a New Skill

1. Create directory: `plugins/product-playbook-for-agentic-coding/skills/your-skill/`
2. Create `SKILL.md` with frontmatter:
   ```yaml
   ---
   name: your-skill
   description: When to use this skill and what it provides
   ---
   ```
3. Include clear guidance and examples

## License

MIT
