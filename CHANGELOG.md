# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.13.0] - 2026-01-30

### Added
- **Multi-Persona Critique Workflow** - Complete system for running structured document critiques:
  - `/playbook:critique`: New command for parallel multi-persona document critiques with versioning, synthesis, and issue tracking
  - **Persona Library** (5 reusable personas):
    - `marketing-strategist`: Messaging clarity, positioning, competitive differentiation
    - `product-manager`: Internal consistency, requirements clarity, prioritization
    - `technical-reviewer`: Feasibility, architecture, technical accuracy
    - `domain-expert`: Domain-specific accuracy and credibility (customizable)
    - `investor`: Business viability, market opportunity, defensibility
  - **Critique Synthesis Template**: P0/P1/P2 prioritization, cross-version comparison, launch readiness checklist, auto-generated tasks
  - **Issue Tracker Template**: Track issues across critique versions (Open → Fixed → Verified → Regressed)

### Changed
- Total commands now: 28 (was 27)
- Total templates now: 9 (was 7)
- New `resources/personas/` directory for reusable persona definitions
- README expanded with Multi-Persona Document Critique section

### Rationale
This workflow was identified by analyzing 5 coding sessions that ran iterative critique workflows on foundation documents (v3 → v4 → v5). Key friction points addressed:
1. **Persona re-specification**: Had to write out persona descriptions each time instead of referencing by name
2. **Version management**: Manual version incrementing and file renaming
3. **No synthesis template**: No standard P0/P1/P2 format with exit criteria
4. **No issue tracking**: Same issue flagged as "new" in each version
5. **No task generation**: Synthesis findings not automatically actionable

The new workflow enables: `/playbook:critique docs/foundations/` → parallel agents → synthesis with P0/P1/P2 → implement fixes → `/playbook:critique docs/foundations/ --rerun` → track resolution.

## [0.12.0] - 2026-01-29

### Added
- **Agent-Ready PRD System** - Complete overhaul of PRD workflow optimized for agentic engineering:
  - **New PRD Template** (`product-requirements-v2.md`): Comprehensive template with agent-ready checklist, structured acceptance criteria (Given/When/Then), technical context section, decision log, and explicit scope boundaries
  - **Two-Mode Command**: `/playbook:product-requirements` now supports `--autonomous` flag for context-based drafting and default interview mode
  - **PRD Drafting Agent** (`prd-drafting-agent`): Autonomous agent that drafts complete PRDs from available context

### Changed
- `/playbook:product-requirements` command completely rewritten with:
  - Autonomous mode for generating PRDs from existing context
  - Interview mode with "Agentic Engineer" persona for technical context gathering
  - Agent-Ready Checklist validation step
  - Technical Context section (integration points, data requirements, constraints, patterns)
- Total agents now: 9 (was 8)
- Total templates now: 7 (was 6)

### Rationale
PRDs must enable autonomous technical planning and implementation. The previous PRD structure left too much implicit—agents couldn't create tech plans without asking clarifying questions, and acceptance criteria weren't testable. The new structure ensures:
1. Every requirement has verifiable acceptance criteria (Given/When/Then)
2. Technical context is explicit (integration points, data, constraints, patterns)
3. Scope is unambiguous (explicit In/Out tables)
4. Decisions are logged with rationale (agents don't re-litigate)
5. Open questions are flagged as blockers

This closes the gap between "what to build" and "how to build it"—enabling true end-to-end autonomous engineering from PRD to shipped code.

## [0.11.0] - 2026-01-29

### Added
- **Meta-Improvement Command** (1 new):
  - `/playbook:improve-playbook`: Analyze coding sessions to identify patterns, compare against existing playbook capabilities, and implement improvements as a PR. This is a self-improving workflow that learns from how you use AI coding tools.
- **Meta-Improvement Agent** (1 new):
  - `playbook-improvement-agent`: Analyzes session history, identifies repeatable patterns, performs gap analysis against existing tools, and proposes well-designed solutions.

### Changed
- Total commands now: 27 (was 26)
- Total agents now: 8 (was 7)
- README expanded with Self-Improvement section explaining the meta-workflow
- Added command details for `/playbook:improve-playbook`

### Rationale
This meta-capability enables the playbook to continuously improve based on actual usage. The workflow:
1. Reads SpecStory session history from the current project
2. Identifies repeatable patterns in how you work
3. Compares patterns against existing playbook capabilities
4. Finds gaps where new tools would add value
5. Proposes solutions with evidence from sessions
6. Implements approved improvements
7. Creates a PR to the playbook repository

This closes the loop: use the playbook → identify patterns → improve the playbook → use the improved playbook.

## [0.10.0] - 2026-01-29

### Added
- **Document Workflow Commands** (3 new):
  - `/playbook:rubric-doc`: Generate documents based on a spec file with rubric/excellence criteria. Searches context directories and produces cited drafts.
  - `/playbook:refine-doc`: Incorporate new information or feedback into existing documents while maintaining consistency across related docs.
  - `/playbook:distill`: Create focused summaries or quick references from longer documents, optimized for specific purposes (interviews, presentations, etc).
- **Document Workflow Agents** (2 new):
  - `insight-extractor-agent`: Systematically extract and organize insights from source materials (interview notes, research, meeting notes) with proper citations.
  - `cross-reference-validator-agent`: Validate consistency across interconnected documents, checking links, definitions, and summaries.

### Changed
- Total commands now: 26 (was 23)
- Total agents now: 7 (was 4)
- README expanded with Document Workflow Commands section

### Rationale
These tools were identified by analyzing patterns across 30+ coding sessions in a job search preparation codebase. Common patterns included:
- Generating structured documents from specs/rubrics with citations
- Extracting insights from interview notes with source links
- Refining documents with stakeholder feedback while maintaining consistency
- Creating quick references for interviews and presentations
- Validating cross-references across interconnected documentation

## [0.9.0] - 2026-01-27

### Added
- **Help Command** (1 new):
  - `/playbook:help`: List all commands with decision tree for choosing the right one
- **Local Development Documentation**:
  - Worktree setup guide for fast plugin iteration
  - Local path installation instructions
  - Quick ideas capture workflow

### Changed
- Total commands now: 23 (was 22)
- README expanded with comprehensive development section

## [0.8.0] - 2026-01-26

### Added
- **Design Commands** (1 new):
  - `/playbook:design-spec`: Create high-fidelity design specifications for complex UI features
- **Templates** (1 new):
  - `design-spec.md`: Comprehensive design specification template

### Changed
- Total commands now: 22 (was 21)
- Total templates now: 6 (was 5)
- Playbook migration complete: all 103 files processed, playbook can be deprecated

## [0.7.0] - 2026-01-26

### Added
- **Review Commands** (1 new):
  - `/playbook:review-playbook`: Systematically review and optimize playbook/plugin with scoring rubric

### Changed
- Total commands now: 21 (was 20)
- Plugin now fully self-sufficient (playbook review capabilities included)

## [0.6.0] - 2026-01-26

### Added
- **Git Commands** (6 new):
  - `/playbook:git-commit`: Analyze changes and create conventional commits
  - `/playbook:git-pr`: Create pull requests with GitHub CLI
  - `/playbook:git-worktree`: Create git worktrees for parallel development
  - `/playbook:git-branch-worktree`: Create branch and worktree together
  - `/playbook:git-delete-branch`: Safely delete branches (local + remote)
  - `/playbook:git-move-changes`: Move uncommitted changes to new branch
- **Organization Commands** (1 new):
  - `/playbook:organize-files`: Organize project files by content analysis

### Changed
- Total commands now: 20 (was 12)
- Added Git Commands and Organization Commands sections to README

## [0.5.0] - 2026-01-26

### Added
- **Commands** (6 new):
  - `/playbook:debug-ci`: Debug CI/CD failures using GitHub CLI
  - `/playbook:prompt-coaching`: Real-time coaching on prompts
  - `/playbook:design-critique`: Facilitate design critiques for visual analysis
  - `/playbook:review-autonomy`: Review project readiness for autonomous execution
  - `/playbook:work-multiple`: Work autonomously on multiple tasks
  - `/playbook:identify-improvements`: Identify top 10 improvements from sessions

### Changed
- Expanded command documentation in README with categorized sections
- Total commands now: 12 (was 6)

## [0.4.0] - 2026-01-26

### Added
- Learning search integration in `/playbook:tech-plan`, `/playbook:work`, and `/playbook:debug`
- YAML frontmatter-based filtering for finding relevant learnings
- Validation script (`scripts/validate-plugin.sh`) for plugin quality checks
- CHANGELOG.md for tracking version history

### Changed
- Enhanced project context discovery with explicit learning search patterns
- Improved documentation with usage examples

## [0.3.0] - 2026-01-26

### Added
- **Skills** (3 new):
  - `codebase-docs-search`: Patterns for finding and using project documentation
  - `learning-capture`: Multi-trigger, dual-target learning capture patterns
  - `autonomous-execution`: Patterns for autonomous project execution
- **Agents** (4 new):
  - `product-discovery-agent`: Multi-persona product discovery facilitation
  - `solution-planning-agent`: Technical planning with architect perspective
  - `delivery-agent`: Systematic task execution with quality gates
  - `debugging-agent`: Verification-first debugging approach

### Changed
- Updated README with agents and skills documentation
- Updated project structure to include agents and skills directories

## [0.2.0] - 2026-01-25

### Added
- **Commands** (6 new):
  - `/playbook:product-requirements`: Draft product requirements with multi-persona discovery
  - `/playbook:tech-plan`: Create technical plan with architecture and sequencing
  - `/playbook:tasks`: Break down work into specific, actionable tasks
  - `/playbook:work`: Execute tasks from the tasks document
  - `/playbook:debug`: Systematic debugging workflow
  - `/playbook:learnings`: Capture learnings to improve docs and plugin
- **Templates** (5 new):
  - `product-requirements.md`: Product Requirements Document template
  - `tech-plan.md`: Technical Plan Document template
  - `tasks.md`: Tasks Document template
  - `learnings.md`: Learnings Document template
  - `debugging-session.md`: Debugging Session template

### Changed
- Restructured plugin for marketplace distribution
- Updated marketplace.json with correct schema

## [0.1.0] - 2026-01-25

### Added
- Initial plugin structure
- Core plugin files (plugin.json, README.md, CLAUDE.md, AGENTS.md)
- `/playbook:hello` test command
- Basic marketplace configuration

---

## Version History Summary

| Version | Date | Highlights |
|---------|------|------------|
| 0.13.0 | 2026-01-30 | Multi-persona critique: `/playbook:critique` command, 5 personas, synthesis + issue tracker templates |
| 0.12.0 | 2026-01-29 | Agent-ready PRD system: new template, two-mode command, `prd-drafting-agent` |
| 0.11.0 | 2026-01-29 | Meta-improvement: `/playbook:improve-playbook` command and `playbook-improvement-agent` |
| 0.10.0 | 2026-01-29 | 3 new document workflow commands (rubric-doc, refine-doc, distill), 3 new agents |
| 0.9.0 | 2026-01-27 | 1 new command (help), local development documentation |
| 0.8.0 | 2026-01-26 | 1 new command (design-spec), 1 new template, playbook migration complete |
| 0.7.0 | 2026-01-26 | 1 new command (review-playbook), plugin fully self-sufficient |
| 0.6.0 | 2026-01-26 | 7 new commands (6 git commands, 1 organization command) |
| 0.5.0 | 2026-01-26 | 6 new commands (debug-ci, prompt-coaching, design-critique, review-autonomy, work-multiple, identify-improvements) |
| 0.4.0 | 2026-01-26 | Learning search integration, validation script |
| 0.3.0 | 2026-01-26 | 3 skills, 4 agents |
| 0.2.0 | 2026-01-25 | 6 commands, 5 templates |
| 0.1.0 | 2026-01-25 | Initial release |
