---
name: playbook:git-pr
description: Create a pull request with clear title and description using GitHub CLI
argument-hint: "[optional: target branch, default: main/production]"
---

# Git Create Pull Request

You are an AI assistant tasked with creating a pull request for the current branch. Your goal is to push the branch to remote (if needed) and create a PR targeting the specified base branch.

## Your Goal

Create a pull request with a clear title and description, ensuring the branch is pushed to remote first.

## Prerequisites

Before starting, ensure:
- You're in a git repository
- GitHub CLI (`gh`) is installed and authenticated
- You know the target base branch (default: `main` or `production`)

## Process

### Step 1: Check Current Status

First, analyze the current state:

```bash
git status
git branch --show-current
git log --oneline -5
```

Check:
- Current branch name
- Whether branch is clean or has uncommitted changes
- Recent commits to summarize

### Step 2: Get Target Branch

Default to targeting `main` or `production` branch. Check which exists:

```bash
git branch -r | grep -E 'origin/(main|production|master)' | head -1
```

Only ask the user if there's clear context indicating a different target branch is needed.

### Step 2.5: Run Pre-Push Validation

Before pushing, run the project's full validation suite:

1. **Discover validation command** — check CLAUDE.md / package.json for `ci:local`, `test:verify`
2. **Run it** with explicit timeout (validation may take 2-5 minutes):
   ```bash
   npm run ci:local  # or test:verify — whatever exists
   ```
   Use Bash timeout of 300000ms (5 minutes) to avoid Claude Code's default 2-minute timeout.
3. **If validation fails**: Fix issues before pushing. Do not push broken code to trigger CI.
4. **Skip if the user explicitly requests it**: Note the risk of CI failure.

**Why**: Every push triggers CI. Validating locally first means CI should pass on the first try, saving minutes and money. The pre-push git hook provides a safety net, but running validation explicitly avoids timeout issues.

### Step 3: Push Branch to Remote (if needed)

Check if the branch exists on remote and push if needed:

```bash
git push -u origin HEAD
```

### Step 4: Create Pull Request

Create PR using GitHub CLI. **Default to draft** unless the user explicitly requests a ready PR:

```bash
# Default: draft PR (fast CI only, mark ready when full CI needed)
gh pr create --draft --base <target-branch> --title "<descriptive title>" --body "<description>"

# Only if user explicitly requests non-draft:
gh pr create --base <target-branch> --title "<descriptive title>" --body "<description>"
```

**Why draft by default**: Draft PRs typically skip expensive CI (E2E, integration). Mark as "Ready for review" when the full suite should run. This is the primary mechanism for CI cost control in projects with tiered CI.

**PR Title**: Use conventional commit format when possible:
- `feat: add new feature`
- `fix: resolve issue with X`
- `refactor: restructure module`
- `docs: update documentation`

**PR Description**: Include:
- Summary of changes
- What was changed and why
- Testing checklist (if applicable)

### Step 5: Share PR URL

Always share the PR URL as a clickable hyperlink in your response:

```bash
gh pr view --web
```

## PR Description Template

```markdown
## Summary

Brief overview of what this PR does.

## Changes

- What changed
- Why it changed
- Key modifications

## Testing

- [ ] Checklist items for reviewer
```

## Key Principles

- **Always push first**: Push the branch before creating the PR
- **Clear title**: Use conventional commit format when possible
- **Descriptive body**: Include summary, changes, and testing checklist
- **Share URL**: Always provide the PR URL as a clickable hyperlink

---

*Remember: Always push the branch first, then create the PR. Provide clear title and description for reviewers.*
