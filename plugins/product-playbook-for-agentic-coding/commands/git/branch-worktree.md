---
name: playbook:git-branch-worktree
description: Create a new branch and worktree together for isolated development
argument-hint: "<project-name> [source-branch]"
---

# Git Create Branch and Worktree

You are an AI assistant tasked with creating a new git branch and worktree for a project. Your goal is to create a branch from the specified source and set up a worktree.

## Your Goal

Create a new git branch and worktree, ensuring the main repository stays on the original branch.

## Process

### Step 1: Check Current Status

First, analyze the current state:

```bash
git status
git branch --show-current
git worktree list
```

### Step 2: Get Parameters

Determine:
1. **Project name**: Used for both branch name and worktree directory
2. **Source branch**: Branch to create from (default: current branch)

### Step 3: Check for Existing Branch/Worktree

Before creating, check if the branch or worktree already exists:

```bash
git show-ref --verify --quiet refs/heads/<project-name> && echo "branch exists"
```

```bash
git worktree list | grep <project-name>
```

If either exists, inform the user and ask how to proceed.

### Step 4: Create Branch

If the branch doesn't exist, create it from the source branch:

```bash
git branch <project-name> <source-branch>
```

**Important**: Do NOT switch to the new branch. Keep the main repository on the original branch.

### Step 5: Create Worktree

Create the worktree pointing to the new branch:

```bash
git worktree add ../<project-name> <project-name>
```

### Step 6: Verify Creation

Verify the branch and worktree were created successfully:

```bash
git worktree list
```

### Step 7: Summary

Provide a summary:
- Branch name created
- Worktree path created
- Current branch in main repo (should be unchanged)
- Instructions to navigate to the worktree

## Key Principles

- **Main repo stays on original branch**: Never switch branches in the main repository
- **Parallel development**: Worktrees allow working on multiple branches simultaneously
- **Safe operation**: Creating a worktree doesn't affect the main repository
- **Remote sync**: The new branch only exists locally until pushed

## Example Execution

**User Request**: "Create a branch and worktree for v9-authentication from production"

**Execution**:
1. Check current status (on `main` branch, clean)
2. Verify branch/worktree don't exist
3. Create branch `v9-authentication` from `production`
4. Create worktree at `../v9-authentication`
5. Verify creation
6. Summary with navigation instructions

---

*Remember: Always stay on the original branch. The worktree allows working on the new branch in a separate directory.*
