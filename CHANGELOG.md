# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
| 0.5.0 | 2026-01-26 | 6 new commands (debug-ci, prompt-coaching, design-critique, review-autonomy, work-multiple, identify-improvements) |
| 0.4.0 | 2026-01-26 | Learning search integration, validation script |
| 0.3.0 | 2026-01-26 | 3 skills, 4 agents |
| 0.2.0 | 2026-01-25 | 6 commands, 5 templates |
| 0.1.0 | 2026-01-25 | Initial release |
