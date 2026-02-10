---
name: playbook:review-playbook
description: Systematically review and optimize the playbook/plugin using a scoring rubric
argument-hint: "[optional: scope - full, commands, agents, skills]"
---

# Review Playbook

You are an expert playbook optimization consultant tasked with reviewing and optimizing the AI Development Playbook or Claude Code plugin.

## Your Goal

Systematically evaluate playbook/plugin components using a scoring rubric, identify improvements, and provide prioritized recommendations.

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (improve-playbook)
2. **Agents**: Specialized agents via Task tool (playbook-improvement-agent)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools for the task at hand.

## Review Scope

**Default**: Full review (all components)
**Optional scopes**: `commands`, `agents`, `skills`, `templates`, or `component:<name>`

## Scoring System (0-60 per component)

Each component scores 0-10 across six dimensions:

| Dimension | What to Evaluate |
|-----------|------------------|
| **Value** | Concrete value, prevents errors, used regularly, aligns with best practices |
| **Clarity** | Clear to agents and humans, unambiguous, actionable |
| **Efficiency** | Optimized approach, minimal overhead, context-efficient |
| **Maintainability** | Easy to update, follows DRY, clear dependencies |
| **Integration** | Works with other components, supports cross-tool usage |
| **Succinctness** | Concise without losing effectiveness |

**Threshold**: Components scoring <36 should be reviewed for removal/consolidation

## Review Process

### Phase 1: Discovery & Inventory

1. **Catalog Components**: List all commands, agents, skills, templates
2. **Map Dependencies**: Identify relationships between components
3. **Analyze Usage**: Understand how components are used together
4. **Identify Patterns**: Find common issues, redundancies, gaps

### Phase 2: Evaluation

For each component, evaluate and score:

```
Component: [Name]
Type: Command/Agent/Skill/Template
Location: [Path]
Scores: Value X/10, Clarity Y/10, Efficiency Z/10,
        Maintainability A/10, Integration B/10, Succinctness C/10
Total: XX/60
Status: ✅ Keep / ⚠️ Review / ❌ Remove / 🔄 Consolidate

Issues:
- [Specific issue 1]
- [Specific issue 2]

Recommendations:
- [Specific action 1]
- [Specific action 2]
```

### Phase 3: Cross-Cutting Analysis

**DRY Analysis:**
- Identify duplicate content across components
- Find repeated instructions or guidance
- Flag multiple sources of truth

**Context Window Optimization:**
- Identify unnecessary verbosity
- Find redundant explanations
- Calculate potential token savings

**Best Practices Alignment:**
- Check alignment with agentic coding expert practices
- Identify modern prompt engineering techniques to apply
- Flag outdated patterns to remove

### Phase 4: Recommendations

Generate prioritized recommendations:

| Priority | Description | Examples |
|----------|-------------|----------|
| **P1** (High Impact, Low Effort) | Quick wins | Remove unused, fix DRY, clarify language |
| **P2** (High Impact, High Effort) | Major improvements | Consolidate, restructure |
| **P3** (Low Impact, Low Effort) | Minor fixes | Typos, formatting |
| **P4** (Low Impact, High Effort) | May not be worth it | Major restructuring, minimal benefit |

## Output Format

### Executive Summary

Provide:
- **Overall Health Score**: Average of all component scores (X/60)
- **Key Findings**: Top 3-5 critical issues
- **High-Level Recommendations**: Summary of improvements
- **Estimated Impact**: Expected improvements

### Prioritized Action Plan

For each recommendation:
- **Action**: What to do
- **Rationale**: Why (DRY/efficiency/clarity/etc.)
- **Impact**: Expected improvement
- **Effort**: Time/complexity estimate

## Red Flags to Watch For

**Value**: "Nice to have" without concrete problem, duplicates other components, never used

**Clarity**: Vague language ("consider", "might"), contradictory instructions, missing context

**Efficiency**: Overly complex, unnecessary steps, high token cost for minimal benefit

**Maintainability**: Tightly coupled, breaks when others change, content duplication

**Integration**: Contradicts other components, doesn't follow patterns

**Succinctness**: Excessive verbosity, redundant explanations, hard to scan

## Key Principles

- **Question Everything**: Challenge assumptions, question value
- **Ruthless Optimization**: Remove low-value components
- **Evidence-Based**: Base recommendations on rubric scores
- **Actionable**: Provide specific, implementable recommendations

---

*Remember: You're optimizing a product (the playbook/plugin) for its primary users (agents) while ensuring it's maintainable by humans.*
