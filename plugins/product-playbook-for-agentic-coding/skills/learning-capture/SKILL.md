---
name: learning-capture
description: Multi-trigger, dual-target learning capture patterns. Use this skill to understand how to capture learnings at different points in the development workflow and route them to appropriate targets (codebase docs or plugin improvements).
---

# Learning Capture

This skill provides patterns for capturing learnings at the right moments and routing them to the right places. Learnings compound over time - the more you capture, the more future work benefits.

## Three Trigger Points

Learnings should be captured at three key moments, each with different depth and focus:

### 1. After Chat Session (Lightweight)

**When**: At the end of any significant agentic coding session

**Focus**: Quick capture of immediate insights
- What did we learn?
- What should be documented?
- Any quick process improvements?

**Depth**: Brief, 2-5 bullet points
**Time**: 2-5 minutes

**Example Output**:
```markdown
## Session Learning: 2026-01-25

- Discovered that the auth middleware requires explicit error handling
- Found undocumented API endpoint at `/internal/health`
- Process improvement: Always check existing tests before writing new ones
```

### 2. After Project Completion (Comprehensive)

**When**: At project milestones or completion

**Focus**: Thorough retrospective
- What worked well?
- What didn't work?
- What to do differently next time?

**Depth**: Full retrospective with multiple sections
**Time**: 15-30 minutes

**Sections to Cover**:
- Project summary and outcomes
- What went well (successes, effective practices)
- What could be improved (challenges, pain points)
- Process improvements (suggested changes)
- Template refinements (updates needed)
- Action items (next steps)

### 3. After Overcoming Blockers (Targeted)

**When**: Immediately after solving a difficult problem

**Focus**: Capture while fresh
- What was painful?
- How was it solved?
- How to prevent next time?

**Depth**: Focused on the specific blocker
**Time**: 5-10 minutes

**Sections to Cover**:
- Context: What were you trying to do?
- Initial hypothesis: What did you think was wrong?
- Actual root cause: What was actually wrong?
- Solution: How was it fixed?
- Prevention: How to avoid this in the future?

## Two Output Targets

Learnings can improve two distinct areas:

### Target 1: Codebase Documentation

**What goes here**: Project-specific knowledge
- Patterns and gotchas for this codebase
- Architecture decisions and rationale
- Debugging solutions for this project
- Troubleshooting guides
- API quirks and workarounds

**Location**: `[current-codebase]/docs/` (appropriate subfolder)

**Subfolder Guidelines**:
| Content Type | Location |
|--------------|----------|
| Problem solutions | `docs/solutions/` |
| General learnings | `docs/learnings/` |
| Architecture decisions | `docs/architecture/` |
| Troubleshooting | `docs/troubleshooting/` |

### Target 2: Plugin/Workflow Improvements

**What goes here**: Process and tool improvements
- Workflow optimizations
- New patterns to add to skills
- Command/agent refinements
- Template improvements
- Cross-project patterns

**Location**: Plugin repository (commands, skills, or docs)

**Improvement Types**:
| Type | Action |
|------|--------|
| Command enhancement | Update command markdown |
| New skill pattern | Add to skill SKILL.md |
| Template fix | Update resources/templates/ |
| New workflow | Create new command or skill |

## YAML Frontmatter Schema

All learnings should include searchable frontmatter:

```yaml
---
title: "Brief descriptive title"
date: YYYY-MM-DD
trigger: chat-session | project-completion | blocker-overcome
target: codebase | plugin | both
category: performance | database | integration | workflow | debugging | testing | security
tags: [relevant, searchable, keywords]
severity: critical | high | medium | low
module: "affected_module_name"
---
```

### Field Guidelines

**trigger**: Which trigger point captured this learning
- `chat-session`: Quick session insight
- `project-completion`: Full retrospective
- `blocker-overcome`: Problem solution

**target**: Where the improvement applies
- `codebase`: This specific project
- `plugin`: The playbook plugin itself
- `both`: Applies to both

**category**: Primary classification
- `performance`: Speed, efficiency issues
- `database`: Data layer issues
- `integration`: External service issues
- `workflow`: Process issues
- `debugging`: Investigation patterns
- `testing`: Test-related learnings
- `security`: Security-related learnings

**severity**: Impact level
- `critical`: Must know, high impact
- `high`: Important, significant impact
- `medium`: Good to know
- `low`: Nice to have

**tags**: Searchable keywords (3-7 tags)

**module**: Specific code module affected (if applicable)

## Decision Matrix: Which Target?

Use this matrix to decide where learnings should go:

| Learning Type | Codebase? | Plugin? |
|---------------|-----------|---------|
| Bug fix for specific code | Yes | No |
| General debugging pattern | Maybe | Yes |
| Architecture decision | Yes | No |
| Workflow improvement | No | Yes |
| Template enhancement | No | Yes |
| Cross-project pattern | Maybe | Yes |
| Project-specific gotcha | Yes | No |
| Tool usage tip | No | Yes |

## Capture Workflow

### Step 1: Identify Trigger
Ask: "What kind of learning moment is this?"
- End of session → Lightweight capture
- Project done → Comprehensive retrospective
- Solved hard problem → Targeted capture

### Step 2: Identify Target
Ask: "Who benefits from this learning?"
- Just this project → Codebase docs
- Future projects/workflows → Plugin improvements
- Both → Document in both places

### Step 3: Use Appropriate Template
Use template from `resources/templates/learnings.md` and fill sections based on trigger type.

### Step 4: Add Frontmatter
Add YAML frontmatter for searchability.

### Step 5: Save to Correct Location
- Codebase: `docs/learnings/YYYY-MM-DD-topic.md`
- Plugin: Create PR to plugin repo

## Integration Points

This skill supports:
- `/playbook:learnings` command (primary interface)
- `/playbook:debug` (captures blocker-overcome learnings)
- `/playbook:work` (suggests session learnings)

## Best Practices

1. **Capture while fresh** - Don't wait, details fade quickly
2. **Be specific** - Vague learnings don't help
3. **Include context** - Future you needs to understand why
4. **Add tags generously** - Makes finding easier
5. **Link to code** - Reference specific files/lines when relevant
6. **Update existing docs** - Sometimes better than creating new ones
7. **Review periodically** - Old learnings may need updates

---

*Every learning captured makes future work easier. Compound your knowledge.*
