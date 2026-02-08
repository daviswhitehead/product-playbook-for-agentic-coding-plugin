---
name: playbook:help
description: List all commands and help you choose the right one for your task
argument-hint: "[optional: what you're trying to do]"
---

# Playbook Help

Display all available commands and help the user find the right one for their task.

## Quick Reference

### Which Command Should I Use?

**Starting a new feature or project?**
→ `/playbook:product-requirements` - Define WHAT to build and WHY

**Know what to build, need to plan HOW?**
→ `/playbook:tech-plan` - Design architecture and approach

**Have a plan, need actionable tasks?**
→ `/playbook:tasks` - Break down into specific tasks

**Ready to implement?**
→ `/playbook:work` - Execute the next task
→ `/playbook:work-multiple` - Execute multiple tasks autonomously

**Something broken?**
→ `/playbook:debug` - Systematic debugging workflow
→ `/playbook:debug-ci` - CI/CD specific failures

**Want feedback on designs?**
→ `/playbook:design-critique` - Analyze visual designs
→ `/playbook:design-spec` - Create detailed UI specifications

**Want to improve your process?**
→ `/playbook:learnings` - Capture what you learned
→ `/playbook:critique` - Run multi-persona document critiques
→ `/playbook:identify-improvements` - Find top 10 improvements
→ `/playbook:prompt-coaching` - Get coaching on your prompts
→ `/playbook:review-autonomy` - Check project readiness for autonomous work
→ `/playbook:review-playbook` - Review and optimize the plugin itself
→ `/playbook:improve-playbook` - Analyze sessions and implement improvements

**Working with documents?**
→ `/playbook:distill` - Create focused summaries from longer docs
→ `/playbook:refine-doc` - Incorporate new info into existing docs
→ `/playbook:rubric` - Validate code against quality rubrics
→ `/playbook:rubric-doc` - Generate documents from spec files

**Git operations?**
→ `/playbook:git-commit` - Create well-structured commits
→ `/playbook:git-pr` - Create pull requests
→ `/playbook:git-worktree` - Create worktree for parallel development
→ `/playbook:git-branch-worktree` - Create branch + worktree together
→ `/playbook:git-delete-branch` - Safely delete branches
→ `/playbook:git-move-changes` - Move uncommitted changes to new branch

**Organizing files?**
→ `/playbook:organize-files` - Organize project files into subdirectories

---

## All Commands by Category

### Core Workflow (4-Phase)
| Command | When to Use |
|---------|-------------|
| `/playbook:product-requirements` | Starting a new feature - define problem, users, success criteria |
| `/playbook:tech-plan` | After requirements - design architecture, sequencing, approach |
| `/playbook:tasks` | After tech plan - create specific, actionable tasks |
| `/playbook:work` | Execute one task from the tasks document |
| `/playbook:work-multiple` | Execute multiple tasks autonomously |
| `/playbook:learnings` | After completing work - capture insights for future |

### Debugging & CI
| Command | When to Use |
|---------|-------------|
| `/playbook:debug` | Something isn't working - systematic debugging |
| `/playbook:debug-ci` | CI/CD pipeline failures - GitHub Actions, tests |

### Design
| Command | When to Use |
|---------|-------------|
| `/playbook:design-critique` | Review visual designs with structured feedback |
| `/playbook:design-spec` | Create detailed UI specification for complex features |

### Review & Improvement
| Command | When to Use |
|---------|-------------|
| `/playbook:critique` | Run parallel multi-persona critiques on documents |
| `/playbook:review-autonomy` | Check if project is ready for autonomous execution |
| `/playbook:identify-improvements` | Find top 10 improvements from a coding session |
| `/playbook:prompt-coaching` | Get feedback on how to write better prompts |
| `/playbook:review-playbook` | Review and optimize this plugin |
| `/playbook:improve-playbook` | Analyze sessions to find patterns and implement improvements |

### Git Operations
| Command | When to Use |
|---------|-------------|
| `/playbook:git-commit` | Ready to commit - creates conventional commit message |
| `/playbook:git-pr` | Ready to create PR - with clear title and description |
| `/playbook:git-worktree` | Need isolated parallel development environment |
| `/playbook:git-branch-worktree` | Create new branch AND worktree together |
| `/playbook:git-delete-branch` | Clean up old branches (local + remote) |
| `/playbook:git-move-changes` | Move uncommitted work to a new branch |

### Organization
| Command | When to Use |
|---------|-------------|
| `/playbook:organize-files` | Project files need reorganization |

### Document Workflows
| Command | When to Use |
|---------|-------------|
| `/playbook:distill` | Create focused summaries from longer documents |
| `/playbook:refine-doc` | Incorporate new info into existing docs consistently |
| `/playbook:rubric` | Validate code quality against predefined rubrics |
| `/playbook:rubric-doc` | Generate documents based on spec files with citations |

---

## Typical Workflows

### New Feature Development
```
1. /playbook:product-requirements  → Define the feature
2. /playbook:tech-plan             → Plan the implementation
3. /playbook:tasks                 → Break into tasks
4. /playbook:work                  → Execute tasks (repeat)
5. /playbook:git-commit            → Commit changes
6. /playbook:git-pr                → Create PR
7. /playbook:learnings             → Capture what you learned
```

### Debugging Session
```
1. /playbook:debug                 → Systematic debugging
2. /playbook:learnings             → Capture the solution (blocker-overcome)
```

### Quick Task Execution
```
1. /playbook:work                  → Execute next task
2. /playbook:git-commit            → Commit when done
```

### Autonomous Execution
```
1. /playbook:review-autonomy       → Check readiness
2. /playbook:work-multiple         → Execute multiple tasks
```

---

## Getting More Help

- **Plugin README**: Full documentation at the plugin repository
- **Command Details**: Each command has built-in guidance
- **Philosophy**: Multi-persona approach, systematic workflows, learning capture

---

*Type any command to get started, or describe what you're trying to do and I'll recommend the right command.*
