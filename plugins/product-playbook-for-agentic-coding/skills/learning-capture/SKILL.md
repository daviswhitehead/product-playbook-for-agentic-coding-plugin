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

**Session Handoff** (if work continues later):
Also capture state for the next session:
- What's done and what's next
- Decisions made with reasoning
- Docs that need updating (stale conclusions)
- Where to start next session

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

## Deep Session Analysis Patterns

When performing a deep retrospective (analyzing SpecStory session files in `.specstory/history/`), use these patterns to extract insights the agent missed during the session.

### Pattern: Repetition Detection
**Signal**: Same action performed multiple times without progress.
**How to detect**: Scan for repeated file reads (same path 3+ times), repeated errors, repeated user corrections, and solution/revert cycles.
**What it means**: The agent lacked context, had a faulty mental model, or didn't learn from previous attempts.
**Improvement**: Add the missing context to CLAUDE.md or MEMORY.md so future sessions start with it.

### Pattern: Frustration Signal Detection
**Signal**: User communication shifts from collaborative to directive.
**Severity scale**:
1. Mild — User provides more specific instructions than before
2. Moderate — Short corrective phrases ("no", "not that", "just X")
3. Strong — User takes over the task themselves
4. Severe — User explicitly states frustration
**Improvement**: Identify the specific mismatch and encode it as a behavioral rule.

### Pattern: Wasted Effort Detection
**Signal**: Work that didn't contribute to the final outcome.
**How to detect**: Compare final git diff to all changes during session, look for "let me try a different approach" patterns, count debugging cycles per issue (>2 = wasted).
**Improvement**: Document the correct approach so future sessions don't repeat wrong paths.

### Pattern: Scope Drift Detection
**Signal**: Work expanded significantly beyond original request.
**How to detect**: Compare first user message to final summary. Count files touched vs expected.
**Improvement**: If unintentional, add scope-check trigger to MEMORY.md.

---

## YAML Frontmatter Schema

All learnings should include searchable frontmatter:

```yaml
---
title: "Brief descriptive title"
date: YYYY-MM-DD
trigger: chat-session | project-completion | blocker-overcome
target: codebase | plugin | both
category: performance | database | integration | workflow | debugging | testing | security | design | generation | infrastructure
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
- `design`: Visual design, UX, branding learnings
- `generation`: AI content/image generation learnings
- `infrastructure`: DevOps, CI/CD, deployment learnings

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

### Step 5.5: Deep Analysis (Optional, Project Completion Only)
If session history files are available (`.specstory/history/*.md`):
- Spawn a research agent to scan for repetition patterns, frustration signals, wasted effort, scope drift
- Quantify findings with examples and estimated time impact
- Compare deep findings against the standard retrospective to identify blind spots
- Feed improvement actions into Step 6 alongside standard learnings

### Step 6: Promote Key Learnings
Move the most important learnings to higher-actionability locations:
- **Code/scripts** (automatic) > **CLAUDE.md** (always visible) > **Templates** (on-demand) > **Docs** (reference)
- Ask: "Which 2-3 learnings should be promoted? Where should they live?"
- Implement the promotions (edit CLAUDE.md, create template, update script)

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
