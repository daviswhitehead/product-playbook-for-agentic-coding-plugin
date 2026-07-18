# Product Playbook Plugin Development

## Versioning & Propagation (read this first)

**The propagation model — why the version bump is not optional:**
Claude Code's marketplace auto-update is **version-keyed**. A user's install only
re-pulls a plugin when its **version number changes**. This means:

> **A content change shipped at an unchanged version silently NEVER reaches users —
> even with `autoUpdate: true`.** The install stays stale until the version bumps.

This bit us once already: a content-only commit shipped at the same version, and
every local install silently stayed on the old copy. The guardrails below make that
mistake impossible to merge.

**IMPORTANT**: Every change to a plugin MUST bump its version in **both** files, which
must always match:

1. **`plugins/<plugin-name>/.claude-plugin/plugin.json`** — the plugin's own version
2. **`.claude-plugin/marketplace.json`** — the marketplace entry's `version`

Do the bump with the helper (it edits both together so they can't drift):

```bash
scripts/sync-version.sh <new-version>          # e.g. 0.22.0
# then add a "## [<new-version>] - YYYY-MM-DD" section to CHANGELOG.md
```

Also update **`README.md`** if component counts/tables changed.

### Version Bumping Rules

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes, major reorganization
- **MINOR** (1.0.0 → 1.1.0): New commands, agents, or skills
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, doc updates, minor improvements

### Enforcement

Two guards run on every PR to `main` (`.github/workflows/plugin-guard.yml`), and you
can run them locally:

- `scripts/validate-plugin.sh` — asserts each `marketplace.json` entry's version
  matches the corresponding `plugin.json` version.
- `scripts/check-version-bump.sh [base-ref]` — fails if any plugin's files changed
  versus the base branch without a `plugin.json` version bump.

### Merging multiple open PRs (stacked bumps)

When several content PRs are open at once, none will pass the guard until each
bumps the version — and they can't all claim the same number. Merge them
**sequentially, oldest first, one patch version per PR**: check out the PR
branch (if another worktree holds it, use a temp branch + `git push origin
HEAD:<branch>`), merge `origin/main` in, run `scripts/sync-version.sh
<next-patch>`, add the CHANGELOG section, push, wait for the guard, merge, then
repeat for the next PR against the new main. This keeps CHANGELOG↔PR mapping
1:1 and lets every merge pass the guard independently. (Proven on the 2026-07
four-PR backlog: 0.22.1 → 0.22.4.)

### Delivering an update to installed machines

Because this is a marketplace-embedded plugin (plugin source is a relative path
inside the marketplace repo), a pushed-to-`main` version bump is the trigger, but a
machine may need a marketplace refresh to pull it. See README → "Updating the Plugin".

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
│   └── workflows/           # Core workflow commands (playbook:*)
│       ├── product-requirements.md
│       ├── tech-plan.md
│       ├── tasks.md
│       ├── work.md
│       ├── learnings.md
│       └── debug.md         # Debugging workflow
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
│   ├── autonomous-execution/
│   │   └── SKILL.md
│   └── mobile-debugging/
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
- `docs/`, `projects/`
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

- [ ] Version bumped in **both** `plugin.json` and `marketplace.json` (use `scripts/sync-version.sh`)
- [ ] `CHANGELOG.md` has a section for the new version
- [ ] `scripts/validate-plugin.sh` passes (incl. version consistency)
- [ ] `scripts/check-version-bump.sh` passes (plugin changed ⇒ version bumped)
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
