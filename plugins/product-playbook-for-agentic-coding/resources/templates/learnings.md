---
title: "[Brief descriptive title]"
date: [YYYY-MM-DD]
trigger: [chat-session | project-completion | blocker-overcome]
category: [performance | database | integration | workflow | debugging | architecture | testing | design | generation | infrastructure]
tags: [relevant, searchable, keywords]
severity: [critical | high | medium | low]
module: "[affected_module_name]"
---

# Learnings: [Title]

## Project Overview
**Project Name**: [Project Name]
**Date**: [Date]

## Related Docs
- **Product Requirements**: [Link or path]
- **Tech Plan**: [Link or path]
- **Tasks Doc**: [Link or path]

## Trigger Context
**Trigger Type**: [chat-session | project-completion | blocker-overcome]

### Chat Session Learnings
*Use when capturing lightweight learnings after a coding session*
- Quick insight or pattern discovered
- Documentation gap found
- Tool improvement idea

### Project Completion Learnings
*Use for comprehensive retrospective after completing a project*
- Full project summary and outcomes
- Process improvements identified
- Template refinements needed

### Blocker Overcome Learnings
*Use immediately after solving a hard problem*
- What was painful
- How it was solved
- How to prevent next time

### Platform Quirks Discovered
*Capture framework/platform-specific behavior that differs from standard expectations*
- Did you discover any platform quirk (e.g., React Native Web, Next.js, Expo)?
- How does it differ from what you'd expect in standard HTML/CSS/JS?
- Should this be documented in a project-level gotchas file (e.g., `docs/guides/[platform]-gotchas.md`)?

## Learning Target
**Where should this improve things?**
- [ ] Codebase documentation (project-specific)
- [ ] Plugin improvements (workflow/tools)
- [ ] Both

---

## Project Summary (for project-completion trigger)
**What We Built**: [Brief description of what was delivered]

**Key Outcomes**: [Major results and achievements]

**Comparison to Goals**: [How results compare to Product Requirements success criteria]

---

## What Went Well

### Process
- [ ] [What worked well in the workflow]
- [ ] [Effective practice or pattern]

### Tools and Workflows
- [ ] [Tools that saved time or improved quality]
- [ ] [Workflow improvements that helped]

### AI Collaboration
- [ ] [Valuable AI interactions or guidance]
- [ ] [Effective collaboration patterns]

## What Could Be Improved

### Bottlenecks
- [ ] [Where we got stuck or slowed down]
- [ ] [Process inefficiencies encountered]

### Process Gaps
- [ ] [Missing process elements]
- [ ] [Confusing or unnecessary steps]

### Tool Gaps
- [ ] [Tools or automations we wish we had]
- [ ] [Tool limitations encountered]

---

## Debugging Insights (for blocker-overcome trigger)

### Root Cause Analysis
- **Initial hypothesis**: [What we initially thought]
- **Actual root cause**: [What it actually was]
- **Why hypothesis was wrong**: [Misleading signals, assumptions]

### Key Insight
[The core learning that should be documented for future reference]

### Prevention Strategy
[How to prevent this issue in the future or catch it earlier]

---

## Deep Retrospective Findings (Optional)
*Populated when using deep retrospective mode with SpecStory session analysis.*

### Sessions Analyzed
- **Count**: [N sessions]
- **Date range**: [From] to [To]

### Repetition Patterns
| Pattern | Occurrences | Est. Time Wasted | Prevention |
|---------|-------------|------------------|------------|
| [Pattern 1] | X times | ~Y min | [Action] |

### Wasted Effort
| Instance | What Happened | Root Cause | Prevention |
|----------|---------------|------------|------------|
| [Instance 1] | [Description] | [Why] | [Action] |

### Frustration Signals
| Signal | Context | Root Cause | Prevention |
|--------|---------|------------|------------|
| [Signal 1] | [What was happening] | [Why] | [Action] |

### Knowledge Gaps Found
| Gap | Info Location | Should Be In | Action |
|-----|---------------|--------------|--------|
| [Gap 1] | [Where it exists] | [Where it should be] | [Move/copy] |

### Comparison: Standard vs Deep Findings
| Finding | In Standard Retro? | Source |
|---------|:---:|--------|
| [Finding 1] | Yes/No | [Standard/Deep analysis] |

---

## Actionable Improvements

### Codebase Documentation Updates
- [ ] [Doc to create or update]
- [ ] [Pattern to document]
- [ ] [Gotcha to capture]

### Plugin Improvements
- [ ] [Workflow enhancement]
- [ ] [Template refinement]
- [ ] [New skill or pattern to add]

## Promote Learnings

Move key learnings to where they'll be seen at the right moment:

### Promotion Hierarchy
1. **Code/automation** (happens automatically — scripts, hooks, linters)
2. **CLAUDE.md / MEMORY.md** (agent sees every session)
3. **Templates/checklists** (available when starting similar work)
4. **Learnings docs** (comprehensive reference)

### Promotion Checklist
- [ ] Key pattern → CLAUDE.md rule?
- [ ] Trigger condition → MEMORY.md entry?
- [ ] Reusable process → `docs/templates/` checklist?
- [ ] Repeated manual step → script/automation?
- [ ] Stale doc → updated with new knowledge?

### Promotions Made
| Learning | Promoted To | Location |
|----------|-------------|----------|
| [Learning 1] | [CLAUDE.md / template / script] | [path] |
| [Learning 2] | [CLAUDE.md / template / script] | [path] |

## Next Steps
- [ ] [Action item 1]
- [ ] [Action item 2]

---

*This document captures learnings to improve future work. Use YAML frontmatter for searchability.*
