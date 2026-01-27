---
name: playbook:git-move-changes
description: Move uncommitted changes to a new branch without committing
argument-hint: "<new-branch-name>"
---

# Git Move Changes to New Branch

You are an AI assistant tasked with moving local changes to a new branch. Your goal is to create a new branch and move all uncommitted changes to it without making any commits yet.

## Your Goal

Create a new branch and move all uncommitted changes to it, keeping the original branch clean.

## Process

### Step 1: Check Current Status

First, analyze the current state:

```bash
git status
git branch --show-current
```

Check:
- Current branch name
- Uncommitted changes (modified, deleted, untracked files)

### Step 2: Get Branch Name

Ask the user for the new branch name, or suggest one based on the changes:
- Use descriptive names (e.g., `feature/new-auth`, `refactor/cleanup`)
- Use kebab-case
- Include context about the changes

### Step 3: Create and Switch to New Branch

Create a new branch and switch to it. All uncommitted changes will move with you:

```bash
git checkout -b <branch-name>
```

**Important**: Uncommitted changes stay in the working directory and move with you to the new branch.

### Step 4: Verify Changes Moved

Verify that all changes are now on the new branch:

```bash
git status
git branch --show-current
```

Confirm:
- You're on the new branch
- All uncommitted changes are present
- No changes were lost

### Step 5: Summary

Provide a summary:
- New branch name
- What changes were moved (list the types: deletions, modifications, untracked files)
- Remind user that nothing has been committed yet

## Key Principles

- **No commits are made**: This command only creates the branch and moves changes
- **Changes move automatically**: Git moves uncommitted changes with the branch switch
- **Safe operation**: If you need to go back, you can switch back to the original branch
- **Remote sync**: The new branch only exists locally until pushed

## Example Execution

**User Request**: "Move my changes to a new branch called 'playbook-restructure'"

**Execution**:
1. Check status (shows uncommitted changes on `main` branch)
2. Create and switch to new branch: `git checkout -b playbook-restructure`
3. Verify changes moved (all changes present on new branch)
4. Summary:
   ```
   Created new branch 'playbook-restructure' and moved all local changes:
   - 5 deleted files
   - 4 modified files
   - 9 untracked files

   All changes are now on the new branch. Nothing has been committed yet.
   ```

---

*Remember: This only creates the branch and moves changes. No commits are made unless explicitly requested.*
