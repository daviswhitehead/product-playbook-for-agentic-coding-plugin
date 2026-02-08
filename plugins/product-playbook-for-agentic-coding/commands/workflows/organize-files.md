---
name: playbook:organize-files
description: Organize project files into logical subdirectories based on content analysis
argument-hint: "[directory path to organize]"
---

# Organize Project Files

You are helping organize project documentation files into logical subdirectories based on their actual content and subject matter.

## Your Goal

Help the user organize a directory of project files into logical subdirectories by reading and understanding file content, then grouping related files together.

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (if relevant)
2. **Agents**: Specialized agents via Task tool (if available)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools for the task at hand.

## Process

### Step 1: Understand the Directory Structure

1. List all files in the target directory (including subdirectories)
2. Identify file types (markdown, images, code files, etc.)
3. Note any existing subdirectory structure
4. Confirm the target directory with the user

### Step 2: Read and Analyze File Content

For each file, read enough content to understand its subject matter:

1. **Read file headers** (first 50-100 lines) to understand:
   - Project name or topic
   - Document type (tasks, tech plan, learnings, research, etc.)
   - Related sub-projects or features

2. **Identify patterns**:
   - Files about the same sub-project
   - Files of the same type
   - Files related to the same milestone or phase

3. **Group related files** mentally before proposing structure

### Step 3: Propose Organization Structure

Based on your analysis, propose a directory structure that:

1. **Groups by subject matter** (not just file type)
2. **Uses logical subdirectories**:
   - `tasks/` - Task documents
   - `tech-plan/` - Technical planning documents
   - `learnings/` - Retrospectives and summaries
   - `research/` - Research documents
   - `debugging/` - Debugging sessions
   - `testing/` - Testing guides and scenarios
   - `assets/` - Images and other assets

3. **Maintains hierarchy**:
   - Main project files at the root or in `general/`
   - Sub-projects in their own directories

### Step 4: Present Proposed Structure

Before making changes, present:
1. **Directory structure** (tree view)
2. **File mapping** (where each file will go)
3. **Rationale** for each grouping decision
4. **Questions** about any ambiguous files

**Wait for user confirmation before proceeding.**

### Step 5: Execute Organization

1. Create all necessary subdirectories
2. Move files one category at a time
3. Verify each move was successful
4. Report progress as you go

### Step 6: Verify Final Structure

1. List the final directory structure
2. Confirm all files are in their expected locations
3. Note any files that couldn't be moved

## Organization Patterns

### Pattern 1: Sub-Project Based
```
project-name/
  sub-project-1/
    tasks.md
    tech-plan.md
    learnings.md
  sub-project-2/
    tasks.md
    research.md
  general/
    requirements.md
```

### Pattern 2: Document Type Based
```
project-name/
  tasks/
  tech-plans/
  learnings/
  research/
  assets/
```

### Pattern 3: Milestone Based
```
project-name/
  milestone-1/
  milestone-2/
  milestone-3/
  general/
```

## Key Principles

- **Content-Based Organization**: Group files by what they're about, not just their file type
- **Logical Hierarchy**: Create a structure that makes sense for the project
- **User Confirmation**: Always get approval before making changes
- **Preserve Relationships**: Keep related files together

---

*Remember: The goal is to create a logical, maintainable structure that makes it easy to find related files.*
