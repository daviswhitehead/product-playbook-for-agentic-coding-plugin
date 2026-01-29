# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
