---
name: playbook:git-commit
description: Analyze git changes and create well-structured conventional commits
argument-hint: "[optional: specific files or commit message hint]"
recommended-mode: auto-accept
thinking-depth: normal
---

# Git Commit

You are an AI assistant tasked with analyzing git changes and creating appropriate commits. Your goal is to identify logical groupings of changes and create conventional commits one at a time.

## Your Goal

Create well-structured, conventional commits that logically group related changes.

## Process

### Step 1: Review Changes

First, analyze the current state:

```bash
git status
git diff --stat
```

Identify:
- Modified files
- Deleted files
- New/untracked files
- Staged vs unstaged changes

### Step 1.5: Run Pre-Commit Validation

Before creating any commits, verify the code is in a good state:

1. **Discover project validation** — check CLAUDE.md and package.json for:
   - `ci:local` (local CI simulation — preferred)
   - `test:verify` (comprehensive)
   - Individual: `lint`, `typecheck`, `test`

2. **Run at minimum**:
   ```bash
   npm run lint && npm run typecheck
   npm test
   ```

3. **If validation fails**: Fix issues before committing. Do not commit broken code.

4. **Skip if explicitly requested**: If the user says "just commit" or "commit without tests", respect that — but note the risk.

**Why**: The pre-commit hook catches some issues on staged files, but a full-project lint and typecheck catches cross-file breakage that staged-file-only checks miss.

### Step 2: Analyze and Plan

Review all changes and create a plan of commits. For each potential commit, identify:

- The specific files or changes that belong together
- A conventional commit type and scope
- A clear description of what changed and why

Explain your plan to the user before proceeding.

### Step 3: Execute Commits One by One

For EACH commit, follow these steps in order:

1. **Stage Changes**
   - Stage ONLY the files for this specific commit:
     ```bash
     git add <specific-files>
     ```
   - Verify staging:
     ```bash
     git status
     ```

2. **Create Commit**
   - Create a conventional commit with a clear message:
     ```bash
     git commit -m "<type>[scope]: <description>"
     ```
   - Verify the commit:
     ```bash
     git log -1 --oneline
     ```

3. **Proceed to Next Commit**
   - Only move to the next commit after the current one is complete
   - Repeat steps 1-2 for each planned commit

## Conventional Commit Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (formatting, whitespace)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools
- `ci`: Changes to CI configuration files and scripts
- `build`: Changes that affect the build system or external dependencies

## Commit Message Format

```
<type>[scope]: <description>

<body>

<footer>
```

**Examples**:
- `feat(auth): add password reset functionality`
- `fix(api): resolve timeout issue in chat endpoint`
- `docs: update README with setup instructions`
- `refactor(playbook): migrate commands to thin wrappers`

## Key Principles

- **Logical Grouping**: Group related changes together
- **One Change Per Commit**: Each commit should represent a single logical change
- **Conventional Format**: Use conventional commit format for consistency
- **Clear Descriptions**: Write clear, descriptive commit messages
- **Verify Before Proceeding**: Always verify staging and commits before moving to the next

---

*Remember: Good commits are atomic, logical, and well-described. Each commit should represent a single, complete change.*
