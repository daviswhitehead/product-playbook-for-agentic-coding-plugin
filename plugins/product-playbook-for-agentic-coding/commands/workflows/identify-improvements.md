---
name: playbook:identify-improvements
description: Identify top improvements from an agentic coding session for continuous improvement
argument-hint: "[optional: specific area to focus on]"
---

# Identify Top 10 Improvements

You are facilitating a **Continuous Improvement Ritual** at the end of an agentic coding session. Your role is to identify the top 10 improvements that would make similar work faster and smoother in the future.

## Your Goal

Help the user identify the **top 10 improvements** that would accelerate future agentic coding sessions. Then, optionally implement these improvements to create a continuous improvement flywheel.

## Prerequisites

Before starting, ensure:
- An agentic coding session has just completed (or is near completion)
- You have access to the session context (conversation history, files changed, tasks completed)
- You understand what work was done and how it was accomplished

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (learnings, improve-playbook)
2. **Agents**: Specialized agents via Task tool (playbook-improvement-agent)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools for the task at hand.

## Process

### Step 0: Session Context Review

Quickly review the session to understand:
1. **What was accomplished**: Tasks completed, features delivered, problems solved
2. **How it was accomplished**: Workflows used, tools selected, prompts written
3. **Friction points**: Where did things slow down? What required multiple iterations?
4. **Success patterns**: What worked particularly well?

### Step 1: Identify Top Problems

**Before identifying improvements, start by identifying the problems experienced.**

Analyze the session for:

1. **Problems Encountered**
   - What went wrong or was difficult?
   - What required multiple iterations or workarounds?
   - What was confusing or unclear?
   - What slowed down progress?

2. **Tool & Capability Gaps**
   - What tools or capabilities were missing?
   - What would have made tasks easier?
   - What integrations or automations were needed?

3. **Process & Workflow Problems**
   - What workflows were inefficient?
   - Where did handoffs break down?
   - What documentation was missing or wrong?

4. **Knowledge Gaps**
   - What information was hard to find?
   - What context was missing?
   - What had to be re-discovered?

### Step 2: Generate Improvement Ideas

For each problem identified, brainstorm improvements:

**Improvement Categories**:
- **Documentation**: Missing guides, unclear instructions
- **Templates**: Missing or incomplete templates
- **Workflows**: Inefficient processes
- **Tools**: Missing or misconfigured tools
- **Context**: Missing project context or history
- **Prompts**: Better prompt patterns
- **Automation**: Manual steps that could be automated

### Step 3: Prioritize Top 10

Score each improvement on:
- **Impact**: How much time/effort would this save? (1-5)
- **Frequency**: How often would this help? (1-5)
- **Effort**: How hard to implement? (1-5, lower is better)

**Priority Score** = (Impact × Frequency) / Effort

Select the top 10 improvements by priority score.

### Step 4: Create Improvement Document

Create a document in the project folder:

```markdown
# Top 10 Improvements: [Session/Project Name]

## Session Summary
- **Date**: YYYY-MM-DD
- **Work Completed**: [Brief summary]
- **Total Duration**: [Approximate time]

## Top 10 Improvements

### 1. [Improvement Title]
- **Problem**: [What went wrong]
- **Solution**: [What to do about it]
- **Category**: [Documentation/Template/Workflow/Tool/etc.]
- **Priority Score**: X.X
- **Effort**: [Small/Medium/Large]
- **Status**: [ ] Not Started / [ ] In Progress / [x] Complete

### 2. [Improvement Title]
...

## Session Wins (What Worked Well)
1. [Pattern that worked well]
2. [Tool that was particularly helpful]
3. [Workflow that was efficient]

## Patterns to Replicate
- [Pattern 1]: [When to use it]
- [Pattern 2]: [When to use it]

## Next Steps
- [ ] Implement improvement #1
- [ ] Implement improvement #2
- [ ] Share learnings with team
```

### Step 5: Implement Quick Wins (Optional)

If time permits, implement improvements that are:
- Small effort (< 15 minutes)
- High impact
- No dependencies

Mark implemented improvements as complete in the document.

## Improvement Categories & Examples

### Documentation Improvements
- Add missing setup instructions
- Clarify confusing sections
- Add examples to guides
- Update outdated information

### Template Improvements
- Add missing fields to templates
- Improve template structure
- Add better examples
- Create new templates for common needs

### Workflow Improvements
- Streamline multi-step processes
- Add automation to manual steps
- Improve handoff points
- Better sequencing

### Tool Improvements
- Configure tools better
- Add missing tool integrations
- Create helper scripts
- Improve tool documentation

### Context Improvements
- Add project-specific context
- Document decisions and rationale
- Capture institutional knowledge
- Improve searchability

## Key Principles

1. **Problems First**: Start with problems, not solutions
2. **Prioritize Ruthlessly**: Not all improvements are equal
3. **Quick Wins Matter**: Small improvements compound
4. **Document Everything**: Future sessions benefit from learning
5. **Share Learnings**: Others face similar challenges

## Next Steps

After identifying improvements:
1. Implement quick wins immediately
2. Add larger improvements to project backlog
3. Use `/playbook:learnings` to capture key insights
4. Share patterns that worked well
