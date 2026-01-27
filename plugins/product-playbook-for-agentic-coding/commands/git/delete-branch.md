---
name: playbook:git-delete-branch
description: Safely delete a git branch from local and remote after verification
argument-hint: "<branch-name>"
---

# Git Delete Branch

You are an AI assistant tasked with safely deleting a git branch (both local and remote).

## Your Goal

Safely delete a git branch from both local and remote repositories after verifying it's safe to delete.

## Process

### Step 1: Get Branch Name

Confirm the branch name to delete with the user.

### Step 2: Verify Branch Safety

Before deleting, verify the branch is safe to delete:

1. **Check if branch exists locally**:
   ```bash
   git show-ref --verify --quiet refs/heads/<branch-name> && echo "local exists"
   ```

2. **Check if branch exists on remote**:
   ```bash
   git ls-remote --heads origin <branch-name>
   ```

3. **Check if merged into base branch**:
   ```bash
   git log main..<branch-name> --oneline
   ```
   (Empty output means all commits are merged)

4. **Check for unsynced commits** (if both local and remote exist):
   ```bash
   git fetch origin
   git log <branch-name>..origin/<branch-name> --oneline
   git log origin/<branch-name>..<branch-name> --oneline
   ```

### Step 3: Safety Checks

**Before deleting, verify:**
- ✅ Local and remote branches are in sync (if both exist)
- ✅ The latest commits have been merged into the base branch
- ✅ User has confirmed it's safe to delete

**If any safety check fails:**
- Inform the user of the issue
- Ask for confirmation before proceeding
- Suggest alternatives (e.g., keep branch, merge first)

### Step 4: Delete Local Branch

If the branch exists locally and is safe to delete:

```bash
git branch -d <branch-name>
```

If unmerged changes exist and you're certain it's safe:
```bash
git branch -D <branch-name>  # Force delete
```

### Step 5: Delete Remote Branch

If the branch exists on remote:

```bash
git push origin --delete <branch-name>
```

### Step 6: Verify Deletion

Verify both branches were deleted:

```bash
git branch -a | grep <branch-name>
```

Should return no results if deletion was successful.

### Step 7: Summary

Provide a summary:
- Branch name deleted
- Local deletion status
- Remote deletion status
- Any warnings or notes

## Key Principles

- **Safety first**: Always verify branches are merged before deleting
- **Sync check**: Ensure local and remote are in sync before deleting
- **Current branch**: Cannot delete the branch you're currently on
- **Force delete**: Only use `-D` when absolutely certain

---

*Remember: Always verify branches are safe to delete before proceeding. Check that commits are merged and branches are in sync.*
