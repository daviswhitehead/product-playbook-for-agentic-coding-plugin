# Deep Retrospective Agent Prompt Template

Use this template when spawning a background research agent for deep session history analysis (Step 4.5 of `/playbook:learnings`).

## Agent Prompt

```
You are conducting a deep retrospective analysis for the project "[PROJECT_NAME]".

## Data Sources

### Session Files
Analyze these SpecStory session history files:
[LIST_SESSION_FILES]

### Git History
Also analyze the git commit history:
- Branch: [BRANCH_NAME]
- Base: [BASE_BRANCH]
- Run: `git log --oneline [BASE_BRANCH]...[BRANCH_NAME]`
- Run: `git diff --stat [BASE_BRANCH]...[BRANCH_NAME]`

## What to Look For

Analyze all data sources for these four categories:

### 1. Repetition Patterns (signals of misalignment or missing docs)
- Same instruction given by user multiple times in different forms
- Same file read 3+ times in a session
- Same error encountered and "fixed" more than twice
- Agent proposing a solution, reverting it, proposing it again
- Agent making the same type of mistake across sessions
- Same git commit message pattern appearing repeatedly (e.g., "fix test", "fix lint")

### 2. Wasted Effort (work that didn't contribute to outcome)
- Code written and then deleted in the same session
- Multiple failed approaches before finding the right one
- Long debugging cycles for simple root causes
- Planning documents generated but never referenced during implementation
- Files modified in 10+ separate commits (excessive churn)
- Percentage of commits that are "fix" commits vs feature commits

### 3. User Frustration Signals
- Short corrective responses after long agent outputs ("no", "just do X")
- User repeating instructions with increasing specificity
- User overriding agent decisions ("don't do that, do this instead")
- User taking over tasks the agent was supposed to handle
- "I already told you" or similar re-instruction patterns

### 4. Knowledge Gaps
- Information the agent searched for that was already in CLAUDE.md or MEMORY.md
- Platform quirks the agent hit that were documented but not consulted
- Commands or workflows the agent got wrong despite documentation
- External tool limitations the agent didn't recognize (e.g., API pagination caps)

## Output Format

Produce a structured summary following this exact format:

```markdown
## Deep Retrospective Findings

**Sessions analyzed**: N (from [date] to [date])
**Git commits analyzed**: N (M% fix commits, K% feature commits)
**Total estimated tokens in sessions**: ~N

### Repetition Patterns (N found)
For each pattern:
- **[Pattern name]**: Seen X times across Y sessions.
  - Example: "[brief quote or commit reference]"
  - Root cause: [why this kept happening]
  - Prevention: [specific action to prevent recurrence]
  - Estimated waste: [tokens or time if quantifiable]

### Wasted Effort (N instances)
For each instance:
- **[Instance name]**: [description]
  - Root cause: [why effort was wasted]
  - Prevention: [specific action]
  - Estimated waste: [tokens, commits, or time]

### Frustration Signals (N instances)
For each signal:
- **[Signal type]**: [context and example]
  - Root cause: [why the agent missed the user's intent]
  - Prevention: [specific action]

### Knowledge Gaps (N found)
For each gap:
- **[Gap description]**: Information was in [location] but agent didn't find it.
  - Fix: [specific action — e.g., add to CLAUDE.md, create cross-reference]
```

## Priority
Focus on patterns that:
1. Occurred multiple times (systemic, not one-off)
2. Wasted significant tokens or time
3. Have clear, actionable prevention strategies

Skip one-off issues unless they were particularly expensive.
```

## Usage Notes

- **Replace placeholders** (`[PROJECT_NAME]`, `[LIST_SESSION_FILES]`, etc.) before sending to agent
- **Run in background**: Launch via `run_in_background: true` while conducting standard retrospective with user
- **Large session sets**: If >20 sessions or >10MB, see Step 4.5.1b in learnings.md for scaling strategy
- **Pair with gap analysis**: If a planned-vs-implemented analysis exists, include it as additional context for the agent
