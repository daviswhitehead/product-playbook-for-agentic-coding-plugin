---
name: playbook:improve-playbook
description: Analyze coding sessions to identify patterns, compare against existing playbook capabilities, and implement improvements as a PR.
argument-hint: "[--sessions <count|range>] [--plugin-path <path>]"
---

# Improve Playbook from Session Patterns

You are orchestrating a meta-improvement workflow: analyzing how the user works with AI coding tools, identifying patterns, finding gaps in the playbook, and implementing improvements.

## Your Goal

Guide the user through a systematic process to improve the playbook based on their actual usage patterns:

1. **Gather** sessions to analyze
2. **Analyze** patterns in those sessions
3. **Compare** patterns against existing playbook capabilities
4. **Propose** solutions for gaps
5. **Implement** approved improvements
6. **Deliver** as a pull request

Each phase has a checkpoint where you present findings and get user approval before proceeding.

## Arguments

Parse optional arguments:
- `--sessions <count|range>`: Number of recent sessions or date range (default: 20 most recent)
- `--plugin-path <path>`: Path to playbook plugin repo (default: auto-detect)

## Process

### Step 1: Setup & Session Discovery

**1.1 Locate Sessions**

Check for SpecStory session history:
```
.specstory/history/*.md
```

If found, list available sessions with dates:
```bash
ls -la .specstory/history/*.md | head -30
```

Report: "Found X sessions from [date range]"

**1.2 Locate Playbook Plugin**

Search in this order:
1. Sibling directory: `../product-playbook-for-agentic-coding-plugin/`
2. User-specified path via `--plugin-path`
3. Clone from GitHub: `https://github.com/daviswhitehead/product-playbook-for-agentic-coding-plugin`

Report which source will be used.

**1.3 Confirm Scope**

Present to user:
```
📊 Session Analysis Setup

Sessions found: X (from [date] to [date])
Sessions to analyze: [count or range]
Playbook location: [path or "will clone from GitHub"]

Proceed with analysis?
```

**CHECKPOINT**: Get user confirmation before proceeding.

---

### Step 2: Analyze Sessions & Identify Patterns

**2.1 Launch Pattern Analysis**

Use the `playbook-improvement-agent` via the Task tool to:
- Read the specified sessions
- Extract intents and workflow shapes
- Cluster into patterns
- Document evidence for each pattern

Provide the agent with:
- List of session files to analyze
- Instructions to focus on repeatable patterns
- Request for structured output

**2.2 Review Pattern Analysis**

Present the patterns found:
```
🔍 Patterns Identified

Found X patterns across Y sessions:

1. **[Pattern Name]** (seen in Z sessions)
   - [Brief description]
   - Example: "[User request from session]"

2. **[Pattern Name]** (seen in Z sessions)
   - [Brief description]
   - Example: "[User request from session]"

...

Do these patterns look accurate? Any to add/remove/modify?
```

**CHECKPOINT**: Get user feedback on patterns before gap analysis.

---

### Step 3: Gap Analysis

**3.1 Read Existing Playbook**

Read the playbook's current capabilities:
- `README.md` - command/agent/skill listings
- `CHANGELOG.md` - recent additions
- Individual command/agent/skill files for details

Build a capabilities inventory:
```
Current Playbook Capabilities:
- Commands: X (list them)
- Agents: Y (list them)
- Skills: Z (list them)
```

**3.2 Compare Patterns to Capabilities**

For each pattern, assess:
- ✅ **Covered**: Existing tool handles this
- ⚠️ **Partial**: Existing tool partially addresses
- ❌ **Gap**: No existing tool addresses this

**3.3 Present Gap Analysis**

```
📋 Gap Analysis Results

| Pattern | Status | Existing Tool | Gap |
|---------|--------|---------------|-----|
| [Pattern 1] | ✅ Covered | /playbook:X | — |
| [Pattern 2] | ❌ Gap | — | [description] |
| [Pattern 3] | ⚠️ Partial | /playbook:Y | [what's missing] |

Gaps to address: X patterns
Enhancements possible: Y patterns

Proceed to solution proposals?
```

**CHECKPOINT**: Get user confirmation before proposing solutions.

---

### Step 4: Propose Solutions

**4.1 Design Solutions for Each Gap**

For each gap (❌) or partial coverage (⚠️), propose:
- **Tool type**: Command, Agent, Skill, or Enhancement
- **Name**: Following playbook naming conventions
- **Purpose**: What it solves
- **Key capabilities**: What it does
- **Priority**: Based on frequency and value

**4.2 Present Proposals**

```
💡 Proposed Improvements

### High Priority

1. **`/playbook:new-command`** (Command)
   - Addresses: [Pattern name]
   - Gap: [What's missing today]
   - Would enable: [What user could do]

2. **`new-agent`** (Agent)
   - Addresses: [Pattern name]
   - Gap: [What's missing today]
   - Would enable: [What user could do]

### Medium Priority

3. **Enhancement to `/playbook:existing`**
   - Addresses: [Pattern name]
   - Current limitation: [What's partial]
   - Enhancement: [What to add]

---

Which proposals should I implement? (Enter numbers, "all", or "none")
```

**CHECKPOINT**: Get user selection of which proposals to implement.

---

### Step 5: Implement Approved Proposals

**5.1 Prepare Playbook Repo**

If using sibling directory:
```bash
cd [plugin-path]
git checkout main
git pull origin main
git checkout -b feature/session-pattern-improvements
```

If cloning from GitHub:
```bash
git clone https://github.com/daviswhitehead/product-playbook-for-agentic-coding-plugin.git /tmp/playbook-plugin
cd /tmp/playbook-plugin
git checkout -b feature/session-pattern-improvements
```

**5.2 Implement Each Approved Proposal**

For each approved proposal:

1. **Create the tool file**:
   - Commands: `commands/workflows/[name].md`
   - Agents: `agents/workflow/[name].md`
   - Skills: `skills/[name]/SKILL.md`

2. **Follow playbook conventions**:
   - Proper frontmatter (name, description)
   - Structured sections
   - Examples and anti-patterns

3. **Update documentation**:
   - Add to README.md in appropriate section
   - Add to CHANGELOG.md with version bump
   - Update plugin.json version

**5.3 Validate**

Run the validation script:
```bash
./scripts/validate-plugin.sh
```

**5.4 Present Implementation**

```
🛠️ Implementation Complete

Created/Modified Files:
- [file1] (new command)
- [file2] (new agent)
- README.md (updated)
- CHANGELOG.md (updated)
- plugin.json (version bump)

Validation: ✅ PASSED (X commands, Y agents, Z skills)

Review the changes and proceed to PR creation?
```

**CHECKPOINT**: Get user approval before creating PR.

---

### Step 6: Create Pull Request

**6.1 Commit Changes**

```bash
git add .
git commit -m "feat: add tools from session pattern analysis

[List of tools added]

Patterns addressed:
- [Pattern 1]: [Tool created]
- [Pattern 2]: [Tool created]

Based on analysis of X sessions from [project name].

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**6.2 Push and Create PR**

```bash
git push -u origin feature/session-pattern-improvements
gh pr create --title "..." --body "..."
```

**6.3 Report Success**

```
✅ Pull Request Created

URL: [PR URL]

Summary:
- Sessions analyzed: X
- Patterns identified: Y
- Gaps found: Z
- Tools implemented: N

Next steps:
1. Review the PR
2. Test the new tools
3. Merge when ready
```

---

## Key Principles

### Checkpoints Are Mandatory
Never skip a checkpoint. Each phase needs user confirmation before proceeding.

### Evidence-Based Proposals
Every proposal must cite specific sessions and patterns. No speculative improvements.

### Respect Existing Tools
Always do gap analysis. Don't duplicate what exists. Prefer enhancements over new tools.

### Incremental Value
Start with highest-value gaps. It's okay to implement just 1-2 improvements per run.

### Preserve User Agency
The user decides what to implement. Present options, don't dictate.

## Error Handling

### No Sessions Found
```
No SpecStory session history found at .specstory/history/

Options:
1. Check if SpecStory is installed (https://specstory.com)
2. Specify a different session location
3. Manually describe patterns you'd like to address
```

### Playbook Not Found
```
Could not locate playbook plugin.

Options:
1. Specify path with --plugin-path
2. Clone from GitHub (requires network)
3. Create improvements as local files to manually add later
```

### No Gaps Found
```
Great news! The existing playbook already covers the patterns found in your sessions.

Patterns analyzed: X
All covered by existing tools.

Consider:
- Running again after more sessions accumulate
- Manually describing specific workflows you'd like streamlined
```

---

*Improve the playbook by learning from how you actually use it.*
