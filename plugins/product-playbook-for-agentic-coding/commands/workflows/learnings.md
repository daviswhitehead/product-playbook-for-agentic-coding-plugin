---
name: playbook:learnings
description: Capture learnings to improve docs and workflows. Don't use for saving session state for later resumption (use session-checkpoint skill), or for analyzing chat sessions at scale (use /playbook:improve-playbook instead).
argument-hint: "[optional: trigger type - chat-session|project-completion|blocker-overcome]"
recommended-mode: edit
thinking-depth: think-harder
---

# Draft Learnings

You are facilitating the Retrospective phase by representing multiple stakeholder perspectives, with **Engineering Manager** as the lead role coordinating the phase.

**Roles in this phase**: Engineering Manager (lead), Product Manager, Senior Engineer, QA Specialist, DevOps Engineer.

## Your Goal

Help the user capture learnings that improve both codebase documentation AND the plugin/workflow itself.

## Trigger Types & Output

Ask the user a single combined question:

```
What type of learning moment is this?
1. End of chat session (lightweight capture)
2. Project completion (comprehensive retrospective)
3. Overcame a blocker (targeted documentation)

Output defaults to **both** codebase docs and plugin improvements.
Say so if you only want one target.
```

### Trigger Type Reference

| Type | Depth | Key Questions |
|------|-------|---------------|
| Chat session | Brief | What did we learn? What should be documented? Process improvements? |
| Project completion | Thorough | What worked? What didn't? What to do differently? |
| Blocker overcome | Targeted | What was painful? Root cause? Prevention? |

### Output Targets

Both targets are active by default:

1. **Codebase Documentation** — Patterns, gotchas, architecture decisions, debugging solutions. Location: `[current-codebase]/docs/`
2. **Plugin Improvements** — Skill/workflow optimizations, missing steps, wrong defaults, new commands. Location: Plugin repository (`commands/`, `skills/`)

## Available Tools Discovery

Before proceeding, consider what tools are available:
1. **Commands**: Other `/playbook:*` commands
2. **Agents**: Specialized agents via Task tool (if available)
3. **MCP Tools**: External service integrations
4. **Skills**: Domain expertise via Skill tool

## Process

### Pre-Check: Prior Learnings Search (ALL Trigger Types)

**Before starting any retrospective**, search for prior learnings to enable cross-session pattern detection:

1. **Search for existing learnings docs**: `docs/learnings/*.md`, `docs/solutions/*.md`
2. **Read YAML frontmatter** of each to understand categories, tags, and severity
3. **Search for prior improvement ideas**: Look for `## Action Items` or `## Future Work` sections in prior learnings docs — these contain ideas that were documented but may never have been implemented
4. **Build a "recurring patterns" list**: If the current project's themes (e.g., "CI churn", "testing gaps", "context loss") match tags or content from prior learnings, flag them:

```
Prior learnings search found N existing docs.

Recurring patterns detected:
- "[pattern]" — appeared in [N] prior learnings ([dates/titles])
  → Prior proposed fix: [what was proposed before]
  → Was it implemented? [yes/no/partially]

These recurring patterns should be prioritized HIGHEST in this
retrospective — they represent problems that documentation alone
hasn't solved and likely need systemic fixes (automation, tooling,
workflow changes), not more documentation.
```

5. **If prior improvement ideas were never implemented**, surface them:

```
Unimplemented improvement ideas from prior retrospectives:
- [Idea] (from [date] learnings) — still relevant? [y/n]
```

**Why this matters**: Without this search, the same problems get documented repeatedly across retrospectives without escalation. A pattern that appears in 3 retrospectives needs a systemic fix, not a 4th documentation entry.

---

### Pre-Check: Validation Status (Project Completion Only)

**Before capturing learnings for a completed project**, run two pre-checks:

#### Pre-Check A: Gap Analysis

**Run a planned-vs-implemented gap analysis before the retrospective.** This gives the retrospective concrete data instead of relying on memory.

1. **Locate planning docs**: Find the PRD, tech plan, tasks doc, and any v2/revised plans
2. **Compare planned vs actual**: For each planned component, check if it was implemented, modified, deferred, or dropped
3. **Write the analysis to a file**: Save as `projects/[project-name]/planned-vs-implemented.md` — this becomes input to the retrospective questions

**Why this matters**: Without a gap analysis, retrospective questions like "what didn't work?" get vague answers. With a gap analysis, you can ask specific questions like "the tech plan called for GitHub Actions but you used local cron — what drove that decision?"

#### Pre-Check B: Validation Tasks

1. **Locate the tasks document** for the project (typically `projects/[project-name]/tasks.md`)
2. **Search for validation/QA tasks** — look for tasks related to the project's actual validation needs. Common examples include: test coverage, integration testing, CI pipeline verification, performance profiling, security review, manual smoke testing. Don't assume UI-specific checks (Lighthouse, accessibility audit, visual review) apply to every project — match validation to what the project actually built.
3. **Check their status**:
   - If validation tasks exist and are **incomplete**, warn the user:
     ```
     "I found incomplete validation tasks in the tasks document:
     - [List incomplete validation tasks]

     Validation is often skipped because it's less exciting than building.
     Would you like to:
     1. Complete validation tasks first, then capture learnings
     2. Proceed with learnings and document deferred validation as an action item"
     ```
   - If validation tasks exist and are **complete**, proceed normally
   - If **no validation tasks exist**, note this as a gap in the learnings
   - If validation tasks exist but **tests were planned in the tasks doc and not created**, flag them:
     ```
     "Planned but unimplemented tests found:
     - [List tests from tasks doc that do not exist as files]

     Would you like to:
     1. Create the missing tests now, then continue learnings
     2. Document as a gap and continue"
     ```

These pre-checks prevent two common patterns: (1) projects skip validation and move directly to learnings/closure, and (2) retrospectives produce vague insights because no one checked what actually shipped vs what was planned.

### Step 1: Identify Trigger Type and Output

Ask the user:
```
What type of learning moment is this?
1. End of chat session (lightweight capture)
2. Project completion (comprehensive retrospective)
3. Overcame a blocker (targeted documentation)

Output defaults to **both** codebase docs and plugin improvements.
Say so if you only want one target.
```

**If the user selects option 2 (project completion)**, check for session history files:

1. Search for SpecStory session files: `.specstory/history/*.md`
2. If session files exist within the project's date range, **default to deep retrospective**:

```
Session history files found (N files from [date range]).

For project completions, I recommend a **deep retrospective** — it analyzes
session files for patterns the standard retro misses: repetition, wasted
effort, and user frustration signals. (In past projects, deep analysis found
8+ patterns that standard retrospectives missed.)

A. **Deep retrospective** (recommended) — ~30-45 minutes
B. **Standard retrospective** — ~15 minutes
```

3. If no session files are found, fall back to standard retrospective automatically.

Set `deep_retrospective = true` if the user selects A (or accepts the default) and proceed to Step 3.5 after Step 3.

### Step 2: Locate or Create the Template

1. Check if a Learnings document already exists
2. If not, use template from `resources/templates/learnings.md`
3. Create in `docs/learnings/[learning-name].md`

### Step 3: Facilitate Based on Trigger Type

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

**If a gap analysis was produced in Pre-Check A**, use it to generate specific, targeted questions instead of generic ones. The gap analysis transforms vague retrospective prompts into concrete questions grounded in what actually happened.

**Gap-analysis-informed questions** (preferred):
```
Based on the planned-vs-implemented analysis:

1. **Architecture drift**: [Specific drift from gap analysis] — what drove this change?
   Was it a good decision in hindsight, or should the plan have been updated earlier?

2. **Deferred items**: [Specific deferred items] — should these be implemented,
   formally dropped, or carried to the next project?

3. **Unplanned additions**: [Items built but not in plan] — were these necessary?
   Should future plans account for this type of emergent work?

4. **Process friction**: Which phase caused the most rework?
   (Discovery → Planning → Implementation → Testing → Deployment)

5. **Multi-session coordination**: What information was hardest to maintain
   across sessions? What would have helped?
```

**Generic fallback** (use only if no gap analysis exists):
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

### Step 3.5: Deep Session History Analysis (If Selected)

**Only run this step if the user opted for deep retrospective in Step 1.**

**Parallelism**: Launch the deep analysis agent **in the background** while conducting the standard retrospective (Step 3) with the user. This runs both in parallel and cuts total time significantly.

#### 3.5.1: Locate Data Sources

**Session files** — Search for SpecStory session history files:
```
.specstory/history/*.md
```

Filter to files within the project's date range. If no session files are found, fall back to standard retrospective.

**Git history** — Analyze commit patterns alongside session files:
```bash
# Commit volume and categories
git log --oneline [base-branch]...HEAD

# File churn (which files changed most)
git diff --stat [base-branch]...HEAD

# Commit message patterns (look for fix/test churn)
git log --oneline [base-branch]...HEAD | grep -iE "^[a-f0-9]+ (fix|test|revert)" | wc -l
```

Git history often reveals patterns invisible in session files — e.g., "46% of commits were test fixes" or "same file modified in 10+ separate commits."

#### 3.5.1b: Scale Strategy for Large Session Sets

When session data is large (>20 sessions or >10MB total):
- **Prioritize by file size**: Larger sessions = more interaction = more signal
- **Chunk by date range**: Split into weekly ranges and assign parallel agents
- **Sample if necessary**: For 50+ sessions, analyze the 20 largest plus a random sample of 10 smaller ones
- **Always include**: First session (setup patterns), last 5 sessions (final-mile patterns), and any sessions >1MB

#### 3.5.2: Analyze Sessions

Use the Task tool to spawn a research agent (run in background) that reads through the session files and git history. **Use the prompt template at `resources/templates/deep-retrospective-agent-prompt.md`** — fill in the placeholders rather than improvising the prompt each time. If a gap analysis exists from Pre-Check A, include it as additional context for the agent.

Agents should return **structured, tagged findings**.

**For each finding, assign a target tag:**

| Tag | Meaning | Routes To |
|-----|---------|-----------|
| `codebase` | Fix via project documentation or code | CLAUDE.md, README, docs/, code |
| `plugin` | Fix via skill/workflow/command change | Plugin repo files |
| `both` | Needs changes in both places | Both promotion tracks |

**Tagging guidance:**
- "Agent didn't invoke a skill" → `plugin`
- "Agent jumped to implementation during planning" → `plugin`
- "Agent used wrong branch name despite docs" → `codebase`
- "Agent didn't commit before git operations" → `both`

**Agents analyze for these 5 categories:**

**Repetition Patterns** (signals of misalignment or missing docs):
- Same instruction given by user multiple times in different forms
- Same file read 3+ times in a session
- Same error encountered and "fixed" more than twice
- Agent proposing a solution, reverting it, proposing it again
- Agent making the same type of mistake across sessions

**Wasted Effort** (work that didn't contribute to outcome):
- Code written and then deleted in the same session
- Multiple failed approaches before finding the right one
- Long debugging cycles for simple root causes
- Planning documents generated but never referenced during implementation

**User Frustration Signals**:
- Short corrective responses after long agent outputs ("no", "just do X")
- User repeating instructions with increasing specificity
- User overriding agent decisions ("don't do that, do this instead")
- User taking over tasks the agent was supposed to handle (e.g., manually testing CSS values)

**Knowledge Gaps**:
- Information the agent searched for that was already in CLAUDE.md or MEMORY.md
- Platform quirks the agent hit that were documented but not consulted
- Commands or workflows the agent got wrong despite documentation

**Skill/Workflow Gaps** (patterns that map to plugin improvements):
- Agent didn't invoke a skill that was available and relevant
- Agent used a skill but the skill's instructions were insufficient (missing step, wrong default)
- User had to redirect the agent's approach — the skill should have guided it correctly
- Agent repeated a cross-session pattern that a skill should encode
- User overrode an agent default — the skill's default should change
- Agent confabulated facts that a "verify before asserting" instruction would have prevented

#### 3.5.3: Present Findings

Agents return findings in this structured format:

```
## Finding: [title]
- **Category**: repetition | wasted_effort | frustration | knowledge_gap | skill_gap
- **Target**: codebase | plugin | both
- **Evidence**: [specific quote or example from session]
- **Impact**: [estimated waste — tokens, time, user redirections]
- **Proposed fix**: [concrete action]
- **Target file** (if plugin): [skill/command path, e.g., commands/workflows/debug-ci.md]
```

Produce a summary grouped by target:

```
## Deep Retrospective Findings

**Sessions analyzed**: N (from [date] to [date])

### Codebase Findings (N)
[Findings tagged `codebase` or `both`, grouped by category]

### Plugin Findings (N)
[Findings tagged `plugin` or `both`, grouped by category]

### Cross-Cutting Findings (N)
[Findings tagged `both`, showing proposed changes for each target]
```

#### 3.5.4: Merge Standard + Deep Findings

After both the standard retrospective (Step 3) and deep analysis complete, **merge the findings into a single unified document** rather than presenting them as two separate sections.

1. **Create a comparison table** showing what each method found:

```markdown
| Finding | Standard Retro | Deep Analysis | Notes |
|---------|:---:|:---:|-------|
| [Finding A] | ✓ | ✓ | Both methods caught this |
| [Finding B] | ✓ | - | Only surfaced in discussion |
| [Finding C] | - | ✓ | Hidden pattern in session data |
| [Finding D] | - | ✓ | Agent blind spot |
```

2. **Highlight the delta**: Findings that ONLY appeared in the deep analysis represent the agent's blind spots — patterns invisible during normal conversation. These are the highest-value learnings because they reveal what the retrospective would have missed without session analysis.

3. **Deduplicate**: Where both methods found the same pattern, combine into the stronger version (usually the deep analysis has more evidence).

4. **The comparison table itself is a learning**: It shows whether deep retrospectives are worth the extra time for this type of project. Include it in the final document.

---

### Step 4: Use YAML Frontmatter for Searchability

Ensure learnings include frontmatter:
```yaml
---
title: "Brief descriptive title"
date: YYYY-MM-DD
trigger: [chat-session|project-completion|blocker-overcome]
analysis-depth: [standard|deep]
category: [performance|database|integration|workflow|debugging|design|generation|infrastructure]
tags: [relevant, searchable, keywords]
severity: [critical|high|medium|low]
module: "affected_module_name"
sessions-analyzed: [N]  # only for deep retrospectives
---
```

This enables fast filtering when searching for relevant learnings later.

### Step 5: Complete the Document

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


### Completeness Gate

Before proceeding to promotion, verify:
- [ ] Scanned for code patterns worth documenting
- [ ] Scanned for workflow improvements
- [ ] Scanned for template fixes or enhancements
- [ ] Scanned for recurring issues that need prevention

If any items are unchecked, go back and address them before continuing.

### Step 6: Promote Learnings to Point-of-Use

A learning left in a doc is a learning that will be re-learned the hard way. Promote findings via two parallel tracks.

#### Pre-Promotion: CLAUDE.md Health Check

**Before adding content to CLAUDE.md**, check its current size:
1. Run `wc -c CLAUDE.md`
2. If over **32,000 chars** (80% of 40k limit), trim before adding:
   - Archive RESOLVED known issues → `docs/learnings/resolved-issues.md`
   - Move niche/domain-specific guides → `docs/guides/[topic].md` (keep 1-line reference)
   - Remove content that duplicates the Quick Reference section
   - Condense verbose sections to a reference + link
3. If over **40,000 chars**, trimming is **mandatory** — the file will degrade agent performance

**Demotion checklist** (run before promotion):
- [ ] Are there RESOLVED known issues still in CLAUDE.md? → Archive
- [ ] Are there niche guides in CLAUDE.md used <1x/month? → Move to `docs/guides/`
- [ ] Is any CLAUDE.md content duplicated across sections? → Consolidate
- [ ] Are there stale milestone-specific references? → Delete

---

#### Track 1: Codebase Promotion

For each finding tagged `codebase` or `both`, route using this decision tree:

1. **Broadly applicable gotcha or rule?** → CLAUDE.md (Known Issues or Architecture section)
2. **Specific to one subsystem** (workflows, agent, frontend)? → Subsystem README or `docs/guides/`
3. **Should be enforced in code?** → Lint rule, pre-commit hook, or script check
4. **One-time fix?** → Just do it (no documentation needed)

**Present a single batch summary:**

```
Codebase promotion plan:
- CLAUDE.md: [N findings] — [brief list]
- workflows/README.md: [N findings] — [brief list]
- Code fixes: [N findings] — [brief list]
- No action needed: [N findings]

Approve all? [y/n, or specify changes]
```

Implement all approved edits after a single approval. Do not ask per-item.

---

#### Track 2: Plugin Promotion

For each finding tagged `plugin` or `both`:

**Step A — Discover the plugin repo:**
1. Check CLAUDE.md or MEMORY.md for the plugin repo path
2. If not found, search: `find ~ -maxdepth 4 -name "product-playbook-for-agentic-coding" -type d 2>/dev/null`
3. Cache the discovered path in MEMORY.md for future sessions

**Step B — Map findings to skills/commands:**

Read the plugin directory structure (`commands/workflows/`, `skills/`). For each finding, identify which file should change:

| Finding Pattern | Target File |
|----------------|-------------|
| Agent didn't triage before investigating | `commands/workflows/debug-ci.md` or `debug.md` |
| Agent jumped to implementation during research | `commands/workflows/research-synthesis.md` |
| Agent didn't commit before git operations | `commands/workflows/work.md` |
| Skill default didn't match user preference | The specific skill file |
| Missing workflow entirely | Propose new command file |

**Step C — Classify change type:**

| Type | Description | Example |
|------|-------------|---------|
| New step | Add a step to an existing workflow | "Step 0: Triage" in debug-ci |
| Default change | Change a workflow's default behavior | Deep retro as default |
| New principle | Add a rule/principle to a workflow | "Commit checkpoint" in work.md |
| New workflow | Entirely new command needed | New `/playbook:run-review` |

**Step D — Present a single batch summary:**

```
Plugin promotion plan:
- [file]: [change type] — [brief description]
- [file]: [change type] — [brief description]
- New command: [name] — [brief description]

Approve all? [y/n, or specify changes]
```

Implement all approved edits after a single approval. Do not ask per-item.

### Step 7: Check Planning Doc Accuracy

**Planning documents that drift from reality waste tokens in every future session.** Before finalizing, check:

- [ ] **Are planning docs still accurate?** If the project evolved beyond the original tech plan or tasks doc, mark stale docs as superseded with a deprecation notice pointing to the current source of truth.
- [ ] **Are there standalone critique/review docs that were never referenced?** Synthesize key warnings into the tasks doc as inline notes, then consider archiving the standalone files to reduce directory noise.
- [ ] **Does an architecture README exist?** If agents spent significant time re-discovering the codebase structure, create or update a README in the relevant directory. This is the single highest-ROI action for multi-session projects.

### Step 8: Validate Completeness

Review the document:
- [ ] Trigger type captured
- [ ] YAML frontmatter complete for searchability
- [ ] Key learning clearly documented
- [ ] Actionable improvements identified
- [ ] Saved to correct location
- [ ] **Codebase track**: Key learnings promoted (CLAUDE.md, README, docs/, code)
- [ ] **Plugin track**: Skill/workflow improvements identified, mapped, and implemented
- [ ] Plugin repo path cached in MEMORY.md (if discovered this session)
- [ ] Planning docs checked for accuracy (Step 7)
- [ ] Other guidance files updated (if applicable)

### Step 9: Execute Improvements (The Climax — Don't Just Document, Do)

> **Why this step exists**: The biggest gap in retrospectives is stopping at documentation. Learnings that aren't acted on will be re-learned. **This step is the most important part of the entire workflow** — everything before it is analysis; this is where value is created.

#### 9.1: Present the Full Action Plan

Gather ALL actionable improvements from Steps 3 through 8 (standard findings, deep findings, gap analysis, promotions, planning doc fixes) and present them as a **single prioritized action plan**, split by target:

```
"Here's everything we identified, organized by where it goes:

## Codebase Improvements (N items)
1. [Priority: High] [Action] — [brief description]
2. [Priority: Medium] [Action] — [brief description]
...

## Plugin/Workflow Improvements (N items)
1. [Action] — [brief description]
2. [Action] — [brief description]
...

## Deferred (N items)
1. [Action] — [reason for deferral]
...

Which should we proceed with? (I recommend executing all High priority items.)"
```

**Key**: Present codebase and plugin items separately — but **default to executing both**. Do not defer plugin improvements to "next time" or "when you next improve the playbook." The whole point of the learnings phase is to close the loop in this session.

**Default execution strategy**: Execute codebase improvements immediately, then locate the plugin repo and make plugin edits in the same session. Only defer if the user explicitly asks to skip plugin work. If you find yourself writing "these are documented in the learnings doc for when you next improve the playbook" — stop. That means you're deferring instead of executing.

#### 9.1b: Systemic Analysis — Think Bigger (Project Completion Only)

> **Why this step exists**: The natural tendency is to propose incremental fixes (add a CLAUDE.md rule, update a doc). But if the same class of problem keeps appearing, the fix isn't another rule — it's a systemic change (automation, tooling, workflow redesign). This step forces that elevation.

**After presenting the initial action plan, before the user approves:**

1. **Group findings into root problems**: Look across all findings — do multiple symptoms point to the same underlying cause? Name the root problems explicitly (e.g., "The Trust Gap", "CI Feedback Loop Tax").

2. **Check against prior learnings**: If recurring patterns were found in the Pre-Check, escalate them:
   ```
   "[Pattern] has appeared in [N] prior retrospectives. Previous fixes were
   [documentation/rules]. Since it recurred, a systemic solution is needed —
   not another documentation entry."
   ```

3. **Propose systemic solutions**: For each root problem, brainstorm solutions at multiple levels:
   - **Code/automation**: Can this be enforced by a hook, script, or lint rule?
   - **Tooling**: Can a new skill, command, or framework prevent this?
   - **Process**: Does the workflow need a new step or gate?
   - **Architecture**: Does the system design need to change?

4. **Present a prioritized list** with rationale (impact × feasibility × leverage) alongside the incremental fixes. Let the user decide which level to invest in.

```
"Before you approve the action items — I've also identified [N] root
problems that these symptoms point to:

[Root problem analysis + systemic solutions]

Would you like to:
1. Execute the incremental fixes only
2. Execute incremental fixes + implement systemic solutions
3. Review the systemic proposals first"
```

#### 9.2: Execute Codebase Improvements

For each approved codebase action:
1. Make the change (archive files, fix docs, update configs)
2. Verify the change (run relevant checks)
3. Report what was done

#### 9.3: Create Plugin PR (If Applicable)

If the user selected "Both" or "Plugin/workflow" as the output target and improvements to the playbook/plugin were identified:

1. **Locate the plugin repo**: Check `.claude/plugins/` for the plugin directory
2. **Create a feature branch**: `git checkout -b improve/[project-name]-retrospective-learnings`
3. **Make changes**: Modify the relevant plugin files (commands, templates, skills)
4. **Create the PR**: Use `gh pr create` with a clear description of what was learned and why each change improves the workflow
5. **Report the PR URL** to the user

**Common plugin files to improve:**
- `commands/workflows/*.md` — Workflow steps and guidance
- `resources/templates/*.md` — Task and document templates
- `skills/*.md` — Skill definitions and patterns

#### 9.4: Document Solutions with /compound (If Applicable)

For any high-severity finding that has a clear problem → investigation → solution pattern, suggest running `/compound` (or the compound engineering compound skill) to create a reusable solution document in `docs/solutions/`.

**When to suggest /compound:**
- A significant bug or drift was discovered AND fixed during the retrospective
- The root cause is non-obvious and likely to recur in other projects
- The investigation steps would save future developers time

```
"The [problem] we identified and fixed has a clear solution pattern.
Would you like to run /compound to document it as a reusable solution
in docs/solutions/? This makes it searchable for future projects."
```

#### 9.5: Feed-Forward to Next Project Templates

**Learnings are most valuable when they prevent the same patterns in the next project, not just document them after the current one.**

For each systemic finding (especially from deep analysis), check if it should inform the starting templates for future projects:

| Finding Type | Template to Update |
|-------------|-------------------|
| Missing planning for emergent work | `resources/templates/tech-plan.md` — add "Emergent Work Budget" section |
| Architecture drift not caught early | `resources/templates/tasks.md` — add mid-project architecture check task |
| Multi-session context loss | `resources/templates/tasks.md` — add session handoff checkpoint tasks |
| Validation skipped at end | `resources/templates/tasks.md` — add validation tasks as default |
| Planning docs went stale | `resources/templates/tech-plan.md` — add "Accuracy Review" milestone |

**How to apply**: Don't just note "we should do X next time" — actually edit the template so the next project starts with the improved structure. Add template changes to the plugin PR (Step 9.3).

### Step 10: Improve This Workflow (Meta-Retrospective) — MANDATORY

> **This step is MANDATORY and must ALWAYS be the final step. Never skip it. Never forget it.** The learnings workflow itself is a product. Every time you run it, you discover gaps between what the skill prescribes and what actually works. This step closes the loop — the retrospective retrospectes on itself.

> **Why mandatory**: In the recipes project retrospective (2026-03-16), the agent skipped this step entirely. The user had to prompt twice — first to "think bigger" about solutions, then to reflect on the learnings phase itself. Both prompts produced the most impactful improvements of the session. Skipping this step means leaving the highest-value learnings on the table.

**Part A: Agent self-reflection (do this BEFORE asking the user)**

Compare what the skill prescribed vs what actually happened:
1. Which steps did you skip, rush, or do out of order?
2. Where did the user have to redirect you? (These are the most important signals.)
3. What did you do that the skill didn't tell you to do? (These might be improvements to add.)
4. Did you search prior learnings? Did you propose systemic solutions or just incremental fixes?
5. Did you batch approvals or fragment them?

Present your self-assessment honestly:
```
"Here's my honest assessment of how this learnings session went:

**Steps I followed well**: [list]
**Steps I skipped or rushed**: [list]
**Places you had to redirect me**: [list with what I should have done]
**Proposed improvements to the learnings workflow**: [list]

Do you have additional observations about the process?"
```

**Part B: User input**

Ask the user:
```
"Did anything about the learnings process itself feel like it could
be improved? For example:

- Steps that were missing or out of order
- Questions that weren't asked but should have been
- Parts that felt redundant or too slow
- Things we did that the skill didn't guide us to do"
```

**Part C: Implement improvements**

For ALL identified improvements (from both agent self-reflection and user input):
1. Propose specific edits to `learnings.md`
2. Add the changes to the plugin PR created in Step 9.3 (or create one if none exists)
3. Do not ask "should we do this?" — improvements to the learnings workflow are always worth implementing

**Examples of improvements discovered this way:**
- Git history analysis was missing as a data source (found during subscriptions-v1 retro)
- Step 9 (Execute Improvements) didn't exist — the skill stopped at documentation
- /compound integration wasn't suggested for significant solved problems
- No guidance for large session sets (>20 sessions)
- Prior learnings search was missing — recurring patterns never got escalated (found during recipes retro)
- Systemic analysis ("think bigger") step was missing — agent defaulted to incremental fixes (found during recipes retro)
- Meta-retrospective was skippable — agent skipped it, losing the highest-value improvements (found during recipes retro)

---

## Key Principles

- **Be Honest**: Encourage honest reflection on what worked and didn't
- **Focus on Actionability**: Improvements should be specific and actionable
- **Enable Discovery**: Use YAML frontmatter for future searchability
- **Plugin Improvements Are First-Class**: Plugin/workflow improvements are proactively surfaced, not an afterthought. The deep analysis explicitly looks for skill gaps, and promotion runs a dedicated plugin track.
- **Right-Sized**: Match depth to trigger type (lightweight vs comprehensive)
- **Execute, Don't Just Document**: Learnings without follow-through will be re-learned

## Next Steps

Once the Learnings Document is complete and improvements are executed:
1. Review and validate the learnings
2. Verify all executed improvements (Step 9)
3. If plugin PR was created, share the PR URL with the user
4. If `/compound` was run, verify the solution doc was created
5. Apply learnings to future work

---

*Learnings compound over time. Capture them AND act on them to improve both this project's documentation and the overall workflow.*
