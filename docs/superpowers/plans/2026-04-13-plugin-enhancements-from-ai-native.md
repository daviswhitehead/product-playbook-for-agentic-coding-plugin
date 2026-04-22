# Tech Plan: Plugin Enhancements from ai-native-pm

## Project Overview
**Date**: 2026-04-13
**Size**: Medium
**Source**: Cross-pollination from `shortformhq/ai-native-product-playbook`
**Analysis**: `.context/notes.md`

### Scope

Four workstreams, ordered by dependency:

1. **Conciseness & AI-Filler Principles** — Shared quality rules all commands reference
2. **Methods Library** — Reusable thinking frameworks loaded on demand
3. **Session Close-Out Command** — Orchestrated end-of-session workflow
4. **Architectural Patterns** — Metadata and behavioral upgrades to existing commands/skills

---

## Workstream 1: Conciseness & AI-Filler Principles

### What

Add explicit rules for detecting and removing AI-characteristic verbosity. Two outputs:
1. A new skill (`conciseness-check`) with the specific filler patterns and self-check procedure
2. Updates to AGENTS.md with the two high-level principles

### Why First

This is foundational — everything else we build should follow these rules. Adding it first means the methods library, close-out command, and all future output benefit from day one.

### Files to Create

**`plugins/product-playbook-for-agentic-coding/skills/conciseness-check/SKILL.md`**

```yaml
---
name: conciseness-check
description: Quality check for AI-generated output. Detects and removes hedge stacking, throat-clearing, motivational padding, restating, and unnecessary transitions. Use before presenting any substantive artifact to the user.
---
```

Content should include:

**Section 1: Filler Patterns to Eliminate**
Adapted from ai-native-pm Core Principle 9 — concrete patterns with examples:

| Pattern | Example | Fix |
|---------|---------|-----|
| Hedge stacking | "it's worth noting that perhaps" | State directly or omit |
| Unnecessary transitions | "with that in mind", "building on the above" | Delete — context is implicit |
| Throat-clearing | "in order to effectively address" | Start with the verb |
| Motivational padding | "this powerful approach enables teams to" | State what it does, not how great it is |
| Restating | Same point in different words in consecutive sentences | Keep the stronger version |
| Meta-commentary | "I wanted to reach out to...", "as mentioned above" | Delete |
| Excessive hedging | "it might be possible that this could potentially" | Pick one hedge or commit |

**Section 2: Critique Before Checkpoint**
From ai-native-pm Core Principle 7:
- Multi-phase commands that produce a substantive artifact (PRD, tech plan, research synthesis, critique synthesis) should run a self-review pass before presenting to the user
- The self-review checks for filler patterns above, plus structural issues (redundant sections, buried conclusions, missing specifics)
- Fix issues silently — don't show the user the self-check, show them the clean output

**Section 3: Stakeholder Document Structure**
From ai-native-pm Stakeholder Document Structure:
- Any document going to multiple reviewers should use a two-layer structure
- **At-a-Glance**: Self-sufficient. Reader who stops here has everything needed to decide or give feedback. As short as possible. No teasers to appendix.
- **Appendix**: Detailed analysis, evidence, methodology, options rejected. Exists so readers *can* dig in, not so they *must*.
- Clear boundary (e.g., `---` + `## Appendix`) between the two layers

### Files to Modify

**`AGENTS.md`** — Add two principles to the "Core Principles" section:

```markdown
### 6. Concise by Default
AI output is a draft, not the final artifact. Before presenting any document
or communication:
- Remove AI-characteristic filler (hedge stacking, throat-clearing,
  motivational padding, restating, meta-commentary)
- Deduplicate — if a point is made once, don't restate it
- Prefer fewer pages — multiple readers × inflated text is compounding cost
See the `conciseness-check` skill for specific patterns.

### 7. Critique Before Checkpoint
Multi-phase workflows that produce a substantive artifact should run a
self-review pass before presenting to the user. Catch structural issues,
filler, and missing specifics. Fix silently — the user sees clean output.
```

### Design Decisions

- **Skill (not just AGENTS.md update)**: The filler patterns and self-check procedure are too detailed for AGENTS.md. A skill provides the reference material; AGENTS.md provides the principle that triggers loading the skill.
- **Stakeholder Document Structure lives here**: It's a conciseness/quality pattern, not a standalone concept. Keeps the number of new files lower.
- **No changes to existing commands yet**: The principles propagate naturally through AGENTS.md. Commands that would most benefit (PRD, tech plan, critique synthesis) can add explicit `See conciseness-check skill` references in the Architectural Patterns workstream.

---

## Workstream 2: Methods Library

### What

A new `resources/methods/` directory containing reusable thinking frameworks. Each method is a standalone markdown file with: What It Is, When to Use, The Framework, How to Apply.

### Structure

```
plugins/product-playbook-for-agentic-coding/
  resources/
    methods/
      socratic-questioning.md
      strategy-kernel.md
      impact-estimation.md
      devils-advocate.md
```

### Files to Create

**`resources/methods/socratic-questioning.md`**

A 5-category questioning framework for validating PRDs and proposals:
1. Problem Clarity — "What specific pain? Who experiences it? Cost of inaction?"
2. Solution Validation — "Why this solution? Simplest version? User behavior assumptions?"
3. Success Criteria — "How to measure? What's failure? Target within what timeframe?"
4. Constraints — "Top technical risks? Explicitly not doing? Half the time, what to cut?"
5. Strategic Fit — "Why now? Connection to company strategy? Future impact?"

Guidance: Pick 3-5 most relevant questions per use. Quality over quantity.

**`resources/methods/strategy-kernel.md`**

Rumelt's Strategy Kernel:
1. Diagnosis — Clear statement of the challenge, grounded in data. Test: "Could someone disagree?"
2. Guiding Policy — Overall approach, must include explicit tradeoffs. Test: "Does this rule things out?"
3. Coherent Actions — Specific, coordinated initiatives. Test: "Do these reinforce each other?"

Includes a "Strategy vs. Non-Strategy" test (goals, feature lists, visions, and values are not strategies).

**`resources/methods/impact-estimation.md`**

Quantitative impact estimation:
- Core formula: `Impact = Users Affected × Current Action Rate × Expected Lift × Value per Action`
- Three-scenario analysis: Pessimistic (20th %ile), Realistic (50th), Optimistic (80th)
- Lift estimation source hierarchy: Historical data > User research > Competitor benchmarks > Expert judgment
- Guidance: Present realistic as headline, pessimistic/optimistic as range. Flag weakest variables.

**`resources/methods/devils-advocate.md`**

Structured pressure-testing protocol:
1. State decision as falsifiable statement
2. Challenge each assumption (market timing, competitive response, resource sufficiency, user behavior, opportunity cost)
3. Defend or reconsider each challenge
4. Document the result

Guidance: "Better to hear hard questions from AI than from your CEO."

### How Commands Reference Methods

Commands should load methods on-demand via a standard pattern:

```markdown
### Method Loading (Optional)

When [specific condition], load the relevant method from `resources/methods/`:
- [Method name]: [When to use it in this command's context]

Read the method file and apply its framework to the current task.
```

This is a recommendation, not a mandate. Commands reference methods; they don't depend on them. Methods are also useful independently — a user can ask "apply the strategy kernel to this proposal" without going through a specific command.

### Which Commands Should Reference Methods

| Command | Method | When |
|---------|--------|------|
| `product-requirements` | Socratic Questioning | During Interview Mode Step 4 (Multi-Persona Discovery) — use to validate problem clarity and solution direction |
| `tech-plan` | Strategy Kernel | During Step 3 — use to validate that the architecture connects diagnosis, policy, and actions |
| `critique` | Devil's Advocate | As an additional persona option — a persona-independent structural review |
| `foundations` | Strategy Kernel | During Step 3 (Build the Stack) — use to validate the strategy isn't just goals/values |
| Future `estimate-impact` | Impact Estimation | Primary method for the command |

### Design Decisions

- **4 methods, not 6**: Skipping Resource Interleaving and Ownership Handoff from ai-native-pm. These are PM-specific team coordination frameworks — too narrow for the general-purpose playbook. The 4 selected are universal thinking tools.
- **Separate files, not embedded in commands**: Methods should be reusable across commands and useful independently. Embedding them in specific commands creates duplication.
- **Lightweight command references**: Commands get a small "Method Loading" section that points to the method file. This avoids bloating command files and lets methods evolve independently.
- **No command modifications in this workstream**: Method references in commands will be added as part of Workstream 4 (Architectural Patterns) to batch the command edits.

---

## Workstream 3: Session Close-Out Command

### What

A new command `/playbook:close` that orchestrates end-of-session cleanup: uncommitted work → task cleanup → handoff context → learn flow. Builds on the existing `session-checkpoint` skill and `learnings` command.

### Files to Create

**`plugins/product-playbook-for-agentic-coding/commands/workflows/close.md`**

```yaml
---
name: playbook:close
description: Run a session close-out — checks for uncommitted work, cleans up tasks, writes handoff context, then captures learnings. Use when wrapping up a session or at natural stopping points.
argument-hint: "[--quick] [--skip-learnings]"
recommended-mode: auto-accept
---
```

**Phases:**

**Phase 1: Uncommitted Work Check** (fast, mechanical)
1. Run `git status` — are there uncommitted changes?
2. If yes: show brief summary, offer to commit. Draft commit message if user approves.
3. If clean: skip silently.

**Phase 2: Task Cleanup** (fast, mechanical)
1. Check for active tasks (if a tasks.md exists for the current project).
2. For `in_progress` tasks: Is the work done? Mark completed, or note what's left.
3. For stale tasks: Propose deletion.
4. For pending tasks not started: Note as carryover.
5. Brief summary only — don't belabor it.

**Phase 3: Handoff Context** (medium, judgment required)
1. Draft a handoff note capturing:
   - **What was accomplished** this session (2-3 bullets)
   - **What's in progress** but not finished
   - **What's next** — most logical next action
   - **Key decisions made** that affect future work
   - **Open questions** still needing answers
2. **Multi-phase project awareness**: If the session worked on a project with a defined plan (phases, milestones), add:
   - Phase completed this session
   - Blocker for next phase (e.g., "user must review before Phase 2")
   - Parallelizable work that can proceed without waiting
3. Write to `docs/checkpoints/latest.md` (reuses session-checkpoint format).
4. Commit the checkpoint.

**Phase 4: Learn Flow** (slower, substantive)
1. Unless `--quick` or `--skip-learnings` is passed, prompt the user:
   > "Any learnings from this session worth capturing? (Or type 'skip' to close out.)"
2. If user has input: route to `/playbook:learnings` with `chat-session` trigger.
3. If user skips: close silently.

**Phase 5: Summary**
```
Session closed.

Git: [Committed 3 files / Clean / 2 uncommitted (noted)]
Tasks: [2 completed, 1 carried forward]
Handoff: Saved to docs/checkpoints/latest.md
Learnings: [Captured / Skipped]
```

### Proactive Invocation

The command should define when Claude should proactively suggest closing:

```markdown
## Proactive Invocation

Claude should suggest running close when it detects:
- User signaling session end ("thanks", "I'm done", "let's stop here")
- A natural stopping point after completing the last requested task
- User saying "anything else before I go?"

Proactive trigger format:
> Before you go — want me to run a quick close-out? I'll check for
> uncommitted work, update tasks, and write a handoff note.
```

### Relationship to Existing Components

| Existing Component | Relationship |
|-------------------|-------------|
| `session-checkpoint` skill | Close-out writes to the same `docs/checkpoints/latest.md` format. The skill provides the format spec; the command orchestrates when/how it's written. |
| `learnings` command | Close-out invokes learnings as its final phase. Learnings remains standalone for when users want to capture learnings mid-session. |
| `autonomous-execution` skill | Already recommends checkpoints every 3 tasks. Close-out handles the end-of-session case. |

### Design Decisions

- **Command, not skill**: This is a user-invocable workflow (`/playbook:close`), not passive guidance. Users need to type `/playbook:close` or have it suggested proactively.
- **Lighter than ai-native-pm's version**: ai-native-pm's `pm:close` has 6 phases including a memory capture phase and a mandatory learn flow. We simplify: 4 phases, optional learnings, no memory capture (Claude Code's auto-memory handles that). This matches the playbook's general-purpose audience — users won't always want a 15-minute close-out ceremony.
- **Reuse session-checkpoint format**: No new checkpoint format. The `docs/checkpoints/latest.md` structure is already established and integrated with `autonomous-execution`.
- **`--quick` skips learnings only**: The mechanical checks (git, tasks, handoff) are fast and always valuable. Only the learnings flow is optional.

---

## Workstream 4: Architectural Patterns

### What

Metadata and behavioral upgrades to existing commands and skills, adopted from patterns in ai-native-pm that improve quality across the board.

### Pattern 1: Recommended Mode & Thinking Depth

Add frontmatter hints to all commands and skills so users know the optimal permission/thinking settings.

**Format** (added to YAML frontmatter):

```yaml
recommended-mode: auto-accept | edit | plan
thinking-depth: normal | think-harder
```

**How to assign:**

| Command Type | Recommended Mode | Thinking Depth |
|-------------|-----------------|----------------|
| Mechanical workflows (close, commit, work) | auto-accept | normal |
| Judgment-heavy creation (PRD, tech-plan, foundations) | edit (default) | think-harder |
| Analysis/synthesis (critique, research-synthesis, learnings) | edit | think-harder |
| Read-only (help, review-autonomy) | edit | normal |

**Files to modify**: All command files in `commands/workflows/` and `commands/git/` — add `recommended-mode` and `thinking-depth` to frontmatter. This is a batch edit — two lines added per file, no content changes.

**Note**: Claude Code does not currently parse `recommended-mode` or `thinking-depth` from frontmatter as executable directives. These serve as documentation for the user and as hints for the AI (which sees the frontmatter in the loaded skill content). If Claude Code adds native frontmatter support later, these fields are ready.

### Pattern 2: Proactive Invocation Triggers

Add a `## Proactive Invocation` section to skills that should be suggested without being explicitly requested.

**Which skills get proactive triggers:**

| Skill | Trigger Condition |
|-------|------------------|
| `conciseness-check` (new) | Before presenting any multi-paragraph artifact |
| `session-checkpoint` | Session exceeding ~1 hour or 5+ tasks completed |
| `learning-capture` | After overcoming a significant blocker |
| `codebase-docs-search` | When a command needs project context and hasn't searched yet |

**Format** (added as a section in each SKILL.md):

```markdown
## Proactive Invocation

This skill should be suggested (not auto-invoked) when:
- [Condition 1]
- [Condition 2]

Suggested format:
> [Specific prompt text]
```

**Files to modify**: The 4 SKILL.md files listed above.

### Pattern 3: Completeness Gates

Add a checklist-style gate before key phase transitions in multi-phase commands. Prevents shallow execution.

**Which commands get gates:**

| Command | Gate Location | What It Checks |
|---------|-------------|----------------|
| `learnings` | Before Step 6 (Promote) | "Have you scanned for: code patterns, workflow improvements, template fixes, recurring issues?" |
| `critique` | Before Step 3 (Synthesize) | "All persona agents returned? Any failures to retry?" |
| `product-requirements` | Before Step 5/6 (Draft) in Interview Mode | Already has Pre-Draft Clarification Gate — no change needed |

**Format** (added inline in the command):

```markdown
### Completeness Gate

Before proceeding, verify:
- [ ] [Check 1]
- [ ] [Check 2]
- [ ] [Check 3]

If any items are unchecked, go back and address them before continuing.
```

**Files to modify**: `learnings.md`, `critique.md` — add gate sections at the specified locations.

### Pattern 4: Graceful Degradation

Ensure new components (methods, close-out) work without all prerequisites. Add explicit degradation notes.

**Already designed in:**
- Methods Library: Commands *reference* methods but don't *depend* on them. If method files are missing, the command works — it just doesn't load the framework.
- Close-out: Each phase skips silently if there's nothing to do (no uncommitted work, no tasks doc, no project context).
- Conciseness skill: Works standalone or as a reference from other commands.

**Explicit degradation note to add to the close-out command:**

```markdown
## Graceful Degradation

Each phase is independent and fails gracefully:
- No git repo? Skip Phase 1.
- No tasks document? Skip Phase 2.
- No active project? Write handoff inline instead of to file.
- User declines learnings? Skip Phase 4.

The command should always produce a useful summary, even if every phase is skipped (meaning: the session was clean with nothing to close out).
```

### Pattern 5: Method References in Commands

Add lightweight method-loading sections to the commands identified in Workstream 2. This is batched here to combine with the frontmatter edits from Pattern 1.

**Edits:**

**`product-requirements.md`** — Add after the "Multi-Persona Discovery" section header in Interview Mode:

```markdown
#### Optional: Load Socratic Questioning Framework

For deeper problem validation, load `resources/methods/socratic-questioning.md`
and apply its 5-category framework. Particularly useful for Problem Clarity
(category 1) and Success Criteria (category 3).
```

**`tech-plan.md`** — Add to Step 3 (Facilitate Technical Planning):

```markdown
#### Optional: Apply Strategy Kernel

When validating the architecture connects diagnosis to actions, load
`resources/methods/strategy-kernel.md`. Verify the plan has a clear diagnosis
(the technical challenge), guiding policy (the architectural approach), and
coherent actions (the implementation phases).
```

**`critique.md`** — Add to Available Personas section:

```markdown
In addition to persona-based critique, you can run a **Devil's Advocate review**
using `resources/methods/devils-advocate.md`. This is persona-independent —
it pressure-tests the decision logic rather than reviewing from a stakeholder
perspective.
```

**`foundations.md`** — Add to Step 3 (Build the Stack):

```markdown
#### Validate with Strategy Kernel

After completing the stack, load `resources/methods/strategy-kernel.md` and
verify the foundations form a real strategy (diagnosis + guiding policy +
coherent actions), not just goals, values, or feature lists.
```

---

## Sequencing

```
Workstream 1: Conciseness Principles
  ├── Create conciseness-check skill
  └── Update AGENTS.md
         ↓
Workstream 2: Methods Library
  ├── Create 4 method files
  └── (Command references deferred to WS4)
         ↓
Workstream 3: Session Close-Out
  ├── Create close.md command
  └── (References session-checkpoint + learnings)
         ↓
Workstream 4: Architectural Patterns
  ├── Add frontmatter to all commands (batch)
  ├── Add proactive triggers to 4 skills
  ├── Add completeness gates to 2 commands
  ├── Add method references to 4 commands
  └── Add graceful degradation notes
         ↓
Final: Version bump + README update
```

**Why this order:**
- WS1 first: Establishes quality bar for everything that follows
- WS2 second: Creates the method files that WS4 will reference from commands
- WS3 third: New command that benefits from WS1's conciseness principles
- WS4 last: Batch edits to existing files — combines frontmatter, method refs, gates, and triggers into one pass per file

### Parallel Opportunities

- WS1 and WS2 are independent and can run in parallel
- WS3 depends on WS1 (should follow conciseness principles) but not WS2
- WS4 depends on WS1 + WS2 (needs method files to exist before referencing them)

### Estimated Scope

| Workstream | New Files | Modified Files | Est. Total |
|-----------|-----------|---------------|------------|
| WS1 | 1 (skill) | 1 (AGENTS.md) | 2 |
| WS2 | 4 (methods) | 0 | 4 |
| WS3 | 1 (command) | 0 | 1 |
| WS4 | 0 | ~35 commands/skills + 2 templates | ~37 |
| Final | 0 | 2 (plugin.json, README.md) | 2 |
| **Total** | **6** | **~40** | **~46** |

Most WS4 modifications are mechanical (2 lines of frontmatter per file). The substantive content edits are the 4 method-reference additions and 2 completeness gates.

---

## Technical Risks

**Risk 1: Frontmatter fields not parsed by Claude Code**
- **Impact**: `recommended-mode` and `thinking-depth` serve only as documentation, not executable config
- **Probability**: Known — Claude Code currently ignores unknown frontmatter fields
- **Mitigation**: These fields are still useful as in-context hints (the AI reads the full skill content). If Claude Code adds native support later, we're ready. No harm in adding them now.

**Risk 2: Method files increase context loading**
- **Impact**: Commands that reference methods load additional content, using more context window
- **Probability**: Low — methods are 30-50 lines each
- **Mitigation**: Methods are loaded on-demand, not always. Commands say "load when [condition]", not "always load". Users with small context windows can skip method loading.

**Risk 3: Close-out proactive triggers annoy users**
- **Impact**: Suggesting `/playbook:close` at wrong times feels pushy
- **Probability**: Medium — detecting "session end" from conversational signals is imprecise
- **Mitigation**: Proactive trigger is a suggestion, not an auto-invocation. The prompt asks "want me to run close-out?" rather than running it. Users learn to invoke it themselves.

---

## Version Bump

Current version: `0.19.0`

This is a **minor** bump (new command, new skill, new resources): → `0.20.0`

Update in `plugin.json` and verify/update README component counts.
