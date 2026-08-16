---
name: playbook:help
description: List all commands and help you choose the right one for your task
argument-hint: "[optional: what you're trying to do]"
recommended-mode: edit
thinking-depth: normal
---

# Playbook Help

Display all available commands and help the user find the right one for their task.

## Quick Reference

### Which Command Should I Use?

**Starting a whole product, or don't know what to build yet?**
→ `/playbook:foundations` - Mission, Vision, Personas, Engagement frameworks
→ `/playbook:research-synthesis` - Turn research into ranked strategic opportunities

**Starting a new feature or project?**
→ `/playbook:product-requirements` - Define WHAT to build and WHY

**Know what to build, need to plan HOW?**
→ `/playbook:tech-plan` - Design architecture and approach

**Have a plan, need actionable tasks?**
→ `/playbook:tasks` - Break down into specific tasks

**Ready to implement?**
→ `/playbook:work` - Execute the next task
→ `/playbook:work-multiple` - Execute multiple tasks autonomously

**Scope changed mid-project?**
→ `/playbook:emergent` - Capture a mid-flight bug or new requirement as a micro-PRD

**Something broken?**
→ `/playbook:debug` - Systematic debugging workflow
→ `/playbook:debug-ci` - CI/CD specific failures

**PR open, or a backlog of them?**
→ `/playbook:monitor-pr` - Shepherd one PR's CI to green, then merge
→ `/playbook:merge-prs` - Triage every open PR, approve one plan, merge the queue

**Wrapping up?**
→ `/playbook:close` - Session close-out: uncommitted work, handoff context, learnings
→ `/playbook:close-project` - Project close-out: planned-vs-implemented diff, move to done/

**Designing UI for a feature?**
→ `/playbook:design-system` - Extract your design system into DESIGN.md
→ `/playbook:design-spec` - Create spec + generate Stitch mockup prompts
→ `/playbook:mockups` - Batch-generate Stitch screens
→ `/playbook:design-critique` - Multi-persona visual feedback on mockups
→ `/playbook:design-to-code` - Transform mockups into component scaffolds
→ `/playbook:design-verify` - Compare implementation against mockups

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

### Strategy Foundations
| Command | When to Use |
|---------|-------------|
| `/playbook:foundations` | New product or strategy work - Mission, Vision, Personas, Engagement |
| `/playbook:research-synthesis` | After research - synthesize quant + qual + taste into opportunities |

### Core Workflow (4-Phase)
| Command | When to Use |
|---------|-------------|
| `/playbook:product-requirements` | Starting a new feature - define problem, users, success criteria |
| `/playbook:tech-plan` | After requirements - design architecture, sequencing, approach |
| `/playbook:tasks` | After tech plan - create specific, actionable tasks |
| `/playbook:work` | Execute one task from the tasks document |
| `/playbook:work-multiple` | Execute multiple tasks autonomously |
| `/playbook:emergent` | Mid-project bug or new requirement - capture as a micro-PRD first |
| `/playbook:learnings` | After completing work - capture insights for future |

### Close-Out
| Command | When to Use |
|---------|-------------|
| `/playbook:close` | End of a session - uncommitted work check, handoff context, learnings |
| `/playbook:close-project` | Project finished - planned-vs-implemented diff, move to done/, retrospective |

### Debugging & CI
| Command | When to Use |
|---------|-------------|
| `/playbook:debug` | Something isn't working - systematic debugging |
| `/playbook:debug-ci` | CI/CD pipeline failures - GitHub Actions, tests |

### Pull Requests
| Command | When to Use |
|---------|-------------|
| `/playbook:monitor-pr` | One PR open - drive CI to green with local-first fixes, then merge |
| `/playbook:merge-prs` | Backlog of open PRs - triage all, approve one plan, merge the queue |

### Design Pipeline
| Command | When to Use |
|---------|-------------|
| `/playbook:design-system` | Extract or create DESIGN.md (foundation for consistency) |
| `/playbook:design-spec` | Create detailed UI spec + generate Stitch mockup prompts |
| `/playbook:mockups` | Batch-generate Stitch screens with consistency enforcement |
| `/playbook:design-critique` | Multi-persona visual critique on mockups |
| `/playbook:design-to-code` | Transform Stitch HTML into project component scaffolds |
| `/playbook:design-verify` | Compare implementation against Stitch mockups |

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

### Meta
| Command | When to Use |
|---------|-------------|
| `/playbook:help` | This command - find the right command for your task |
| `/playbook:hello` | Verify the plugin installed correctly |

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
7. /playbook:monitor-pr            → Drive CI to green, then merge
8. /playbook:learnings             → Capture what you learned
9. /playbook:close                 → Close out the session
```

### Clearing a PR Backlog
```
1. /playbook:merge-prs             → Triage every open PR, present one merge plan
2. (approve the plan once)         → Queue merges autonomously from here
3. /playbook:learnings             → Capture anything new about the merge mechanics
```

### UI Feature Development (with Design Pipeline)
```
1. /playbook:product-requirements  → Define the feature
2. /playbook:design-system         → Extract/create DESIGN.md
3. /playbook:design-spec           → Engineer spec + Stitch prompts
4. /playbook:mockups               → Batch-generate Stitch screens
5. /playbook:design-critique       → Visual critique (iterate until converged)
6. /playbook:tech-plan             → Plan implementation
7. /playbook:tasks                 → Break into tasks
8. /playbook:design-to-code        → Scaffold components from mockups
9. /playbook:work                  → Implement (repeat)
10. /playbook:design-verify        → Compare against mockups
11. /playbook:git-commit           → Commit changes
12. /playbook:git-pr               → Create PR
13. /playbook:learnings            → Capture what you learned
```

### Debugging Session
```
1. /playbook:debug                 → Systematic debugging
2. /playbook:learnings             → Capture the solution (blocker-overcome)
```

### UI Polish / Iteration Work
```
1. /playbook:product-requirements  → Detects lightweight work, creates scope note
2. /playbook:work                  → Execute directly (no tasks doc needed)
3. /playbook:git-commit            → Commit when done
4. /playbook:learnings             → Capture what you learned
```

### Bug Fix
```
1. /playbook:debug                 → Systematic debugging
2. /playbook:learnings             → Capture the solution
3. /playbook:git-commit            → Commit the fix
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
