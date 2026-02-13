---
name: playbook:review-autonomy
description: Review a project's readiness for autonomous agentic execution
argument-hint: "[optional: path to project folder]"
---

# Review Project for Autonomous Execution

You are facilitating project review for autonomous execution readiness, evaluating whether a project is ready for an AI agent to work on it with minimal human intervention.

## Your Goal

Help the user evaluate a project's readiness for autonomous agentic engineering execution by:

1. Reviewing project documents and current state
2. Scoring the project using readiness criteria
3. Identifying gaps and blockers
4. Generating prioritized improvement recommendations
5. Creating a review report with actionable next steps

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (work, work-multiple)
2. **Agents**: Specialized agents via Task tool (delivery-agent)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool (autonomous-execution)

Select the most appropriate tools for the task at hand.

## Prerequisites

Before starting, ensure:
- Project has at least a tech plan or tasks document (or both)
- You can access project documentation and codebase
- You understand the project's scope and objectives

## Process

### Step 1: Locate and Review Project Documents

1. **Locate project documents**:
   - Tech Plan Document (typically `projects/[project-name]/tech-plan.md`)
   - Tasks Document (typically `projects/[project-name]/tasks.md`)
   - Product Requirements (if applicable)
   - Related documentation

2. **Read and understand**:
   - Project scope and objectives
   - Architecture and technical approach
   - Execution strategy and sequencing
   - Current state of documentation

3. **Identify what exists vs. what's missing**

### Step 2: Score Using Readiness Rubric

Evaluate each dimension on a 1-5 scale:

#### Documentation Quality (Weight: 25%)
| Score | Criteria |
|-------|----------|
| 5 | Complete PRD, tech plan, tasks with clear acceptance criteria |
| 4 | Good documentation with minor gaps |
| 3 | Basic documentation, some ambiguity |
| 2 | Incomplete documentation, significant gaps |
| 1 | Missing or unusable documentation |

#### Task Specificity (Weight: 25%)
| Score | Criteria |
|-------|----------|
| 5 | Tasks have clear acceptance criteria, dependencies, and validation steps |
| 4 | Most tasks are clear, few need clarification |
| 3 | Tasks defined but some ambiguity |
| 2 | Tasks too vague or too large |
| 1 | No clear task breakdown |

#### Technical Clarity (Weight: 20%)
| Score | Criteria |
|-------|----------|
| 5 | Architecture clear, patterns documented, no ambiguity |
| 4 | Good technical clarity with minor questions |
| 3 | Basic technical direction, some decisions needed |
| 2 | Significant technical uncertainty |
| 1 | No technical direction |

#### Validation Infrastructure (Weight: 15%)
| Score | Criteria |
|-------|----------|
| 5 | Tests exist, CI passes, clear validation path |
| 4 | Good test coverage, minor gaps |
| 3 | Some tests, validation possible |
| 2 | Limited testing infrastructure |
| 1 | No testing or validation |

#### Risk Mitigation (Weight: 15%)
| Score | Criteria |
|-------|----------|
| 5 | Low risk, reversible changes, good rollback |
| 4 | Manageable risk with clear mitigation |
| 3 | Some risk, mitigation possible |
| 2 | High risk, limited mitigation |
| 1 | Very high risk, no mitigation |

### Step 3: Calculate Overall Score

```
Overall Score = (Doc × 0.25) + (Tasks × 0.25) + (Tech × 0.20) + (Valid × 0.15) + (Risk × 0.15)
```

**Readiness Levels**:
- **4.5-5.0**: Ready for full autonomous execution
- **3.5-4.4**: Ready with minor supervision
- **2.5-3.4**: Needs improvement before autonomous work
- **1.5-2.4**: Significant gaps, requires manual work
- **1.0-1.4**: Not ready, needs complete preparation

### Step 4: Generate Recommendations

For each low-scoring dimension, provide:

1. **Gap Description**: What's missing or insufficient
2. **Impact**: How this affects autonomous execution
3. **Recommendation**: Specific action to improve
4. **Priority**: High/Medium/Low based on impact

### Step 5: Create Review Report

Create a report in the project folder:

```markdown
# Autonomous Execution Readiness Review

## Project: [Name]
## Date: YYYY-MM-DD
## Reviewer: Claude (AI Assistant)

## Overall Score: X.X / 5.0
**Readiness Level**: [Level]

## Dimension Scores
| Dimension | Score | Notes |
|-----------|-------|-------|
| Documentation Quality | X/5 | [Brief note] |
| Task Specificity | X/5 | [Brief note] |
| Technical Clarity | X/5 | [Brief note] |
| Validation Infrastructure | X/5 | [Brief note] |
| Risk Mitigation | X/5 | [Brief note] |

## Gaps Identified
1. [Gap 1 - Priority: High/Medium/Low]
2. [Gap 2]

## Recommendations
1. [Recommendation 1]
2. [Recommendation 2]

## Next Steps
- [ ] [Action item 1]
- [ ] [Action item 2]

## Conclusion
[Summary of readiness and recommended path forward]
```

## Key Principles

1. **Be Honest**: Don't inflate scores - accurate assessment helps
2. **Be Specific**: Vague feedback isn't actionable
3. **Prioritize**: Focus on highest-impact improvements first
4. **Consider Context**: What's acceptable varies by project type
5. **Think Like an Agent**: What would confuse or block autonomous execution?

## Next Steps

After the review:
1. Address high-priority gaps
2. Re-review if significant changes made
3. Use `/playbook:work` or `/playbook:work-multiple` for autonomous execution
