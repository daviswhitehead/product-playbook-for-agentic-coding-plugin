# Learnings Workflow Improvements — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make the learnings workflow proactively surface and implement plugin improvements as a first-class output alongside codebase improvements.

**Architecture:** Single file rewrite of `commands/workflows/learnings.md` in the playbook plugin repo. Four changes: combined opening questions, structured tagged findings in deep analysis, new 5th analysis category (skill_gap), and parallel promotion tracks.

**Tech Stack:** Markdown (skill definition file)

**Target file:** `/Users/daviswhitehead/GitHub/product-playbook-for-agentic-coding-plugin/plugins/product-playbook-for-agentic-coding/commands/workflows/learnings.md`

**Design doc:** `docs/plans/2026-03-10-learnings-workflow-improvements-design.md`

---

### Task 1: Combine Steps 1+2 into a Single Opening Question

**Files:**
- Modify: `commands/workflows/learnings.md:17-65` (Three Trigger Types + Two Output Targets sections)
- Modify: `commands/workflows/learnings.md:99-138` (Step 1 + Step 2)

**Step 1: Replace the "Three Trigger Types" and "Two Output Targets" sections (lines 17-65)**

Replace with a single combined section that asks one question. Output defaults to "both" (codebase + plugin). The trigger type descriptions stay as reference material, but the user only gets one question, not two sequential ones.

```markdown
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
```

**Step 2: Replace Steps 1 and 2 (lines 99-138)**

Replace with a single "Step 1: Identify Trigger Type and Output" that combines both questions into one interaction. Keep the deep retrospective defaulting logic from the earlier edit.

```markdown
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

Set `deep_retrospective = true` if the user selects A (or accepts the default) and proceed to Step 4.5 after Step 4.
```

**Step 3: Verify the edit**

Read the modified file and confirm:
- Only one user-facing question in Step 1
- Output defaults to "both"
- Deep retrospective logic preserved

**Step 4: Commit**

```bash
cd /Users/daviswhitehead/GitHub/product-playbook-for-agentic-coding-plugin
git add plugins/product-playbook-for-agentic-coding/commands/workflows/learnings.md
git commit -m "refactor(learnings): combine trigger type + output target into single question"
```

---

### Task 2: Add 5th Analysis Category — Skill/Workflow Gaps

**Files:**
- Modify: `commands/workflows/learnings.md` (Step 4.5.2, around lines 193-219)

**Step 1: Add "Skill/Workflow Gaps" as 5th category**

After the existing "Knowledge Gaps" section in Step 4.5.2, add:

```markdown
**Skill/Workflow Gaps** (patterns that map to plugin improvements):
- Agent didn't invoke a skill that was available and relevant
- Agent used a skill but the skill's instructions were insufficient (missing step, wrong default)
- User had to redirect the agent's approach — the skill should have guided it correctly
- Agent repeated a cross-session pattern that a skill should encode
- User overrode an agent default — the skill's default should change
- Agent confabulated facts that a "verify before asserting" instruction would have prevented
```

**Step 2: Verify the edit**

Read the file and confirm the 5th category appears after Knowledge Gaps.

**Step 3: Commit**

```bash
cd /Users/daviswhitehead/GitHub/product-playbook-for-agentic-coding-plugin
git add plugins/product-playbook-for-agentic-coding/commands/workflows/learnings.md
git commit -m "feat(learnings): add skill/workflow gaps as 5th deep analysis category"
```

---

### Task 3: Restructure Deep Analysis Output to Structured Tagged Findings

**Files:**
- Modify: `commands/workflows/learnings.md` (Step 4.5.2 agent instructions + Step 4.5.3 output format, around lines 193-241)

**Step 1: Add tagging instructions to the agent prompt**

Before the existing analysis categories in Step 4.5.2, add instructions for agents to tag each finding:

```markdown
Use the Task tool to spawn research agents that read through the session files (they can be very large — read in chunks). Agents should return **structured, tagged findings**.

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

The agent should analyze for these 5 categories:
```

**Step 2: Replace the prose output format (Step 4.5.3, lines 221-241)**

Replace the current unstructured format with:

```markdown
#### 4.5.3: Present Findings

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
```

**Step 3: Verify the edit**

Read the modified section and confirm:
- Tagging instructions appear before categories
- Structured finding format replaces prose format
- Findings are grouped by target in the summary

**Step 4: Commit**

```bash
cd /Users/daviswhitehead/GitHub/product-playbook-for-agentic-coding-plugin
git add plugins/product-playbook-for-agentic-coding/commands/workflows/learnings.md
git commit -m "feat(learnings): structured tagged findings in deep analysis output"
```

---

### Task 4: Redesign Step 7 — Parallel Promotion Tracks

**Files:**
- Modify: `commands/workflows/learnings.md` (Step 7, lines 292-358)

**Step 1: Replace the entire Step 7 section**

Replace everything from "### Step 7: Promote Learnings to Point-of-Use" through the "Multi-File Distribution" table (lines 292-358) with the two-track design.

The new Step 7 should contain:

```markdown
### Step 7: Promote Learnings to Point-of-Use

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
```

**Step 2: Update the validation checklist (Step 8, lines 360-370)**

Add plugin-specific validation items:

```markdown
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
- [ ] Other guidance files updated (if applicable)
```

**Step 3: Verify the edit**

Read the full Step 7 and Step 8 and confirm:
- Two tracks exist (Codebase + Plugin)
- Codebase track uses decision tree routing
- Plugin track has Steps A-D (discover, map, classify, present)
- Both tracks use batch approval
- Step 8 checklist covers both tracks

**Step 4: Commit**

```bash
cd /Users/daviswhitehead/GitHub/product-playbook-for-agentic-coding-plugin
git add plugins/product-playbook-for-agentic-coding/commands/workflows/learnings.md
git commit -m "feat(learnings): parallel codebase + plugin promotion tracks with batch approval"
```

---

### Task 5: Update Next Steps and Key Principles

**Files:**
- Modify: `commands/workflows/learnings.md` (Key Principles + Next Steps, lines 372-390)

**Step 1: Update Key Principles**

Replace:
```markdown
- **Dual-Target**: Consider both codebase docs AND workflow improvements
```

With:
```markdown
- **Plugin Improvements Are First-Class**: Plugin/workflow improvements are proactively surfaced, not an afterthought. The deep analysis explicitly looks for skill gaps, and promotion runs a dedicated plugin track.
```

**Step 2: Update Next Steps**

Replace:
```markdown
## Next Steps

Once the Learnings Document is complete:
1. Review and validate the learnings
2. Implement identified improvements
3. If plugin improvements identified, create PR to plugin repo
4. Apply learnings to future work
```

With:
```markdown
## Next Steps

Once the Learnings Document is complete:
1. Review and validate the learnings
2. Both promotion tracks should already be implemented (codebase + plugin edits done in Step 7)
3. If plugin changes were made, commit them in the plugin repo
4. Apply learnings to future work
```

**Step 3: Commit**

```bash
cd /Users/daviswhitehead/GitHub/product-playbook-for-agentic-coding-plugin
git add plugins/product-playbook-for-agentic-coding/commands/workflows/learnings.md
git commit -m "docs(learnings): update principles and next steps for plugin-first approach"
```

---

### Task 6: Final Verification

**Step 1: Read the complete file**

Read the entire modified `learnings.md` and verify:
- [ ] Single opening question (trigger type, output defaults to both)
- [ ] Deep retrospective defaults for project completions
- [ ] 5 analysis categories (including skill_gap)
- [ ] Structured tagged findings format
- [ ] Parallel promotion tracks (codebase + plugin)
- [ ] Batch approval (not per-item)
- [ ] Plugin repo discovery instructions
- [ ] Updated validation checklist
- [ ] Updated key principles and next steps

**Step 2: Check for consistency**

Verify no orphaned references to the old "Step 2: Identify Output Target" or old promotion format.

**Step 3: Run a syntax check**

Verify the markdown renders correctly (no broken code fences, tables, etc.).
