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

**IMPORTANT**: Every change to a plugin MUST declare a version change. **Do not edit the
version in a PR** — add a **changeset** instead:

```bash
cat > .changes/my-change.md <<'EOF'
---
plugin: product-playbook-for-agentic-coding
bump: patch
---

### Fixed
- **What changed** — why it mattered, and what it prevents now.
EOF
```

A changeset is a new file, so it can never conflict with another PR. The version itself is
computed once, on `main`:

```bash
scripts/release.sh          # consumes .changes/*, bumps both manifests, writes CHANGELOG
git add -A && git commit -m "chore: release" && git push
```

Also update **`README.md`** if component counts/tables changed.

### Why not bump in the PR?

The version is a single monotonic counter on `main`, but PRs are parallel. Requiring each
PR to bump it made N open PRs mutually exclusive — they all wanted the same next number —
so merges had to serialize, one patch version per PR, with every PR's version-file edits
conflicting with every other PR's.

And that conflict was doing load-bearing safety work nobody designed. The guard compared
against the **merge base**, so it verified "this branch bumped since it forked", not
"main's version will increase": a branch forked at 0.26.1 and bumped to 0.26.2 passed even
when `main` had already reached 0.26.4. The only thing preventing that merge from dragging
main's version *backwards* was git conflicting on the version lines. Meanwhile the
main-branch guard run compared main against itself, so it always reported "unchanged" and
could never fail — there was no post-merge backstop at all.

Changesets remove the shared-counter contention; the rewritten guard supplies the backstop
that was missing. See `.changes/README.md`.

### Version Bumping Rules

Set `bump:` in the changeset accordingly:

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes, major reorganization
- **MINOR** (1.0.0 → 1.1.0): New commands, agents, or skills
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, doc updates, minor improvements

When several changesets are released together, the **highest** bump type wins.

### Enforcement

Guards run on every PR to `main` and on every push to `main`
(`.github/workflows/plugin-guard.yml`), and you can run them locally:

- `scripts/validate-plugin.sh` — asserts each `marketplace.json` entry's version matches
  the corresponding `plugin.json` version, and that every command appears in `help.md` and
  README's tables.
- `scripts/check-version-bump.sh [base-ref]` — two modes. On a **PR**: the changed plugin
  must declare a changeset (a hand bump is still accepted). On **main**: fails while
  changesets sit unreleased, and fails if plugin content changed without the version
  increasing versus the previous commit.
- `scripts/test-version-checks.sh` — 20 cases over both scripts. Run it after touching
  either.

### Merging multiple open PRs

Merge them in any order — changesets don't conflict, so nothing needs to be stacked. Then
run `scripts/release.sh` **once** and push; that single release covers every PR merged
since the last one. `main` is red between the first merge and the release, which is the
forcing function: content on `main` at an unchanged version has reached zero installs.

If another worktree holds a PR branch, don't disturb it — use a temp branch plus
`git push origin HEAD:<branch>`. `/playbook:merge-prs` automates this whole flow.

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

- [ ] Changeset added under `.changes/` (do **not** hand-edit the version in a PR)
- [ ] Changeset body is the CHANGELOG prose you actually want (`release.sh` uses it verbatim)
- [ ] `scripts/validate-plugin.sh` passes (incl. version + command-surface coverage)
- [ ] `scripts/check-version-bump.sh` passes (plugin changed ⇒ change declared)
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
