---
name: playbook:git-worktree
description: Create a git worktree for isolated parallel development
argument-hint: "<branch-name> [worktree-path]"
---

# Git Create Worktree

You are an AI assistant tasked with creating a new git worktree for a project. Your goal is to set up a worktree, either from an existing branch or by creating a new branch.

## Your Goal

Create a new git worktree, either from an existing branch or by creating a new branch first.

## What is a Worktree?

A git worktree allows you to have multiple working directories attached to the same repository. This is useful for:
- Working on multiple branches simultaneously
- Running tests on one branch while developing on another
- Comparing implementations side by side

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
1. **Branch name**: The branch to check out in the worktree
2. **Worktree path**: Where to create the worktree (default: `../<branch-name>`)

### Step 3: Check Branch Status

Check if the branch exists:

```bash
git show-ref --verify --quiet refs/heads/<branch-name> && echo "exists" || echo "new"
```

**If branch exists**: Proceed directly to creating the worktree
**If branch doesn't exist**: Create it from current branch or specified source

### Step 4: Create Branch (if needed)

If creating a new branch:

```bash
git branch <branch-name> [source-branch]
```

**Important**: Do NOT switch to the new branch. Keep the main repository on the original branch.

### Step 5: Create Worktree

Create the worktree pointing to the branch:

```bash
git worktree add <worktree-path> <branch-name>
```

### Step 6: Verify Creation

Verify the worktree was created successfully:

```bash
git worktree list
```

### Step 7: Copy Important Files (Optional)

If there are important untracked files (like `.env.local`), offer to copy them:

```bash
cp .env.local <worktree-path>/
```

### Step 8: Summary

Provide a summary:
- Branch name (existing or created)
- Worktree path created
- Current branch in main repo (should be unchanged)
- Instructions to navigate to the worktree

## Key Principles

- **Main repo stays on original branch**: Do not switch branches in the main repository
- **Safe operation**: Creating a worktree doesn't affect the main repository
- **Remote sync**: New branches only exist locally until pushed
- **File copying**: Untracked files may need to be manually copied to worktree

## Example Execution

**User Request**: "Create a worktree for feature-auth from production"

**Execution**:
1. Check current status (on `main`, clean)
2. Branch `feature-auth` doesn't exist → create from `production`
3. Create worktree at `../feature-auth`
4. Verify creation
5. Summary: "Worktree created at ../feature-auth on branch feature-auth"

---

*Remember: Worktrees allow parallel development without context switching. Keep the main repository on its original branch.*
