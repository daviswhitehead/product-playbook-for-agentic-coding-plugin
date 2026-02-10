---
name: playbook:learnings
description: Capture learnings to improve docs and workflows
argument-hint: "[optional: trigger type - chat-session|project-completion|blocker-overcome]"
---

# Draft Learnings

You are facilitating the Retrospective phase by representing multiple stakeholder perspectives, with **Engineering Manager** as the lead role coordinating the phase.

**Roles in this phase**: Engineering Manager (lead), Product Manager, Senior Engineer, QA Specialist, DevOps Engineer.

## Your Goal

Help the user capture learnings that improve both codebase documentation AND the plugin/workflow itself.

## Three Trigger Types

Ask the user which type of learning moment this is:

### 1. After Chat Session (Lightweight)
Quick capture at end of an agentic coding session:
- What did we learn?
- What should be documented?
- Any quick process improvements?

**Depth**: Brief, focused on immediate insights

### 2. After Project Completion (Comprehensive)
Full retrospective at project end:
- What worked well?
- What didn't work?
- What to do differently next time?

**Depth**: Thorough review of entire project

### 3. After Overcoming Blockers (Targeted)
Capture immediately after solving a hard problem:
- What was painful?
- How was it solved?
- How to prevent next time?

**Depth**: Focused on the specific blocker and solution

## Two Output Targets

Ask the user where improvements should go:

### 1. Codebase Documentation
Project-specific improvements:
- Patterns and gotchas for this codebase
- Architecture decisions and rationale
- Debugging solutions
- Troubleshooting guides

**Location**: `[current-codebase]/docs/` (appropriate subfolder)

### 2. Plugin Improvements
Workflow and tool improvements:
- Workflow optimizations
- New patterns to add to skills
- Command/agent refinements
- Template improvements

**Location**: Plugin repository (commands, skills, or docs)

## Available Tools Discovery

Before proceeding, consider what tools are available:
1. **Commands**: Other `/playbook:*` commands
2. **Agents**: Specialized agents via Task tool (if available)
3. **MCP Tools**: External service integrations
4. **Skills**: Domain expertise via Skill tool

## Process

### Step 1: Identify Trigger Type

Ask the user:
```
What type of learning moment is this?
1. End of chat session (lightweight capture)
2. Project completion (comprehensive retrospective)
3. Overcame a blocker (targeted documentation)
```

### Step 2: Identify Output Target

Ask the user:
```
What should improve?
1. Codebase documentation (project-specific)
2. Plugin/workflow itself
3. Both
```

### Step 3: Locate or Create the Template

1. Check if a Learnings document already exists
2. If not, use template from `resources/templates/learnings.md`
3. Create in appropriate location based on output target:
   - Codebase: `docs/learnings/[learning-name].md`
   - Plugin: Plugin repository docs

### Step 4: Facilitate Based on Trigger Type

#### For Chat Session Learnings
Quick questions:
- What was the most valuable insight from this session?
- What documentation gap did we discover?
- Any tool or workflow improvement ideas?

**Session Handoff** (for multi-session projects):
If work will continue in a future session, also capture:
- Current state: What's done, what's in progress?
- Recent decisions: Any choices made this session with reasoning?
- Stale docs: Did any earlier document's conclusions get invalidated?
- Entry point: What should the next session read first?

#### For Project Completion Learnings
Comprehensive review:
- **Project Summary**: What was built and outcomes
- **What Went Well**: Successes and effective practices
- **What Could Be Improved**: Challenges and pain points
- **Process Improvements**: Suggested changes
- **Template Refinements**: Updates needed
- **Next Steps**: Action items

#### For Blocker Overcome Learnings
Targeted capture:
- **Context**: What were you trying to do?
- **Initial Hypothesis**: What did you think was wrong?
- **Actual Root Cause**: What was actually wrong?
- **Solution**: How was it fixed?
- **Prevention**: How to avoid this in the future?

### Step 5: Use YAML Frontmatter for Searchability

Ensure learnings include frontmatter:
```yaml
---
title: "Brief descriptive title"
date: YYYY-MM-DD
trigger: [chat-session|project-completion|blocker-overcome]
category: [performance|database|integration|workflow|debugging|design|generation|infrastructure]
tags: [relevant, searchable, keywords]
severity: [critical|high|medium|low]
module: "affected_module_name"
---
```

This enables fast filtering when searching for relevant learnings later.

### Step 6: Complete the Document

Based on trigger type, fill appropriate sections:

**All Types**:
- Title and metadata (YAML frontmatter)
- Context/summary
- Key insight or learning
- Actionable improvements

**Project Completion** (additionally):
- Full project summary
- What went well / could improve
- Process and template refinements

**Blocker Overcome** (additionally):
- Root cause analysis
- Prevention strategy


### Step 7: Promote Learnings to Point-of-Use

A learning left in a doc is a learning that will be re-learned the hard way. For each key learning, promote it as high as possible:

**Promotion hierarchy** (highest = most actionable):
1. **Code/automation** — Encode in scripts, hooks, linters (happens automatically)
2. **CLAUDE.md / MEMORY.md** — Always visible to the agent every session
3. **Templates/checklists** — Available when starting similar work
4. **Learnings docs** — Comprehensive but requires active lookup

**Promotion checklist:**
- [ ] Should any learning become a CLAUDE.md rule? (pattern that applies broadly)
- [ ] Should any learning update MEMORY.md? (trigger conditions for future work)
- [ ] Should any learning become a reusable template? (`docs/templates/`)
- [ ] Should any learning be encoded in code? (scripts, hooks, automation)
- [ ] Should any earlier doc be updated to reflect new knowledge? (fix stale conclusions)

#### Identify CLAUDE.md-Worthy Patterns
Ask for each learning:
- Is this a gotcha/pattern future work should know about?
- Is this a required sequence (e.g., "CORS before DNS")?
- Is this a tool preference (e.g., "use CLI over dashboard")?

#### Propose CLAUDE.md Additions
Format proposals as clear additions:

```markdown
### Proposed CLAUDE.md Addition

**Section**: [Deployment / Authentication / Database / etc.]

**Add**:
> [New content in markdown format]

Approve this addition? [y/n]
```

#### Multi-File Distribution
Consider which file each learning belongs to:

| Learning Type | Target File |
|---------------|-------------|
| Gotchas/patterns | CLAUDE.md |
| Trigger conditions | MEMORY.md |
| Architectural decisions | docs/architecture.md |
| Procedures/workflows | docs/guides/[relevant].md |
| Reusable processes | docs/templates/ |
| Domain-specific | docs/agents/[relevant].md |

Help the user identify 2-3 learnings worth promoting and implement the promotions.

### Step 8: Validate Completeness

Review the document:
- [ ] Trigger type captured
- [ ] Output target identified
- [ ] YAML frontmatter complete for searchability
- [ ] Key learning clearly documented
- [ ] Actionable improvements identified
- [ ] Saved to correct location
- [ ] Key learnings promoted to appropriate level (CLAUDE.md, templates, code)
- [ ] Other guidance files updated (if applicable)

## Key Principles

- **Be Honest**: Encourage honest reflection on what worked and didn't
- **Focus on Actionability**: Improvements should be specific and actionable
- **Enable Discovery**: Use YAML frontmatter for future searchability
- **Dual-Target**: Consider both codebase docs AND workflow improvements
- **Right-Sized**: Match depth to trigger type (lightweight vs comprehensive)

## Next Steps

Once the Learnings Document is complete:
1. Review and validate the learnings
2. Implement identified improvements
3. If plugin improvements identified, create PR to plugin repo
4. Apply learnings to future work

---

*Learnings compound over time. Capture them to improve both this project's documentation and the overall workflow.*
