---
name: playbook:rubric
description: Run quality rubrics against code to validate implementation quality
argument-hint: "<rubric-name> [--files <pattern>] [--threshold <score>]"
---

# Quality Rubric Validator

You are validating code quality against predefined rubrics. This helps ensure implementations meet established standards before merging.

## Your Goal

Run quality rubrics against code and produce:
1. A numeric score (0-100) for each rubric dimension
2. Specific findings with file:line references
3. Prioritized improvements list
4. Overall pass/fail recommendation

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (work, debug)
2. **Agents**: Specialized agents via Task tool (if available)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools for the task at hand.

## Available Rubrics

### Built-in Rubrics

| Rubric | Description | Dimensions |
|--------|-------------|------------|
| `design-system` | UI component compliance | Token usage, composition, accessibility, responsiveness |
| `testing` | Test coverage and quality | Unit, integration, E2E coverage; test quality |
| `accessibility` | WCAG compliance | ARIA, keyboard nav, contrast, screen reader |
| `security` | Security best practices | Input validation, auth, secrets, OWASP |
| `performance` | Performance patterns | Bundle size, re-renders, queries, caching |
| `api` | API design quality | REST conventions, error handling, documentation |

### Custom Rubrics

Users can define custom rubrics in `docs/rubrics/<name>.md` with format:

```markdown
# <Rubric Name>

## Dimensions

### <Dimension 1> (25 points)
- [ ] Criterion A (10 points)
- [ ] Criterion B (8 points)
- [ ] Criterion C (7 points)

### <Dimension 2> (25 points)
...
```

## Arguments

Parse the command arguments:
- `<rubric-name>`: Which rubric to run (e.g., "design-system", "testing")
- `--files <pattern>`: Glob pattern for files to validate (default: changed files)
- `--threshold <score>`: Minimum passing score (default: 80)

## Process

### Step 1: Identify Files to Validate

**If `--files` specified**: Use the glob pattern

**Otherwise**: Detect changed files
```bash
git diff --name-only HEAD~1  # or compare against main branch
```

Focus on relevant file types for the rubric:
- `design-system`: `*.tsx`, `*.css`, `*.scss`
- `testing`: `*.test.ts`, `*.spec.ts`, `*.test.tsx`
- `accessibility`: `*.tsx`, `*.jsx`
- `security`: `*.ts`, `*.tsx`, `route.ts`, `api/**`
- `performance`: `*.ts`, `*.tsx`

### Step 2: Load the Rubric

**For built-in rubrics**: Use the embedded criteria below.

**For custom rubrics**: Search for and read `docs/rubrics/<name>.md`

### Step 3: Evaluate Each Dimension

For each dimension in the rubric:

1. **Search the codebase** for relevant patterns
2. **Check each criterion** against the code
3. **Record findings** with specific file:line references
4. **Score the dimension** based on criteria met

### Step 4: Generate Report

```markdown
# Quality Rubric: <Rubric Name>

**Files Analyzed**: X files
**Overall Score**: XX/100 [PASS/FAIL]
**Threshold**: XX

---

## Dimension Scores

| Dimension | Score | Status |
|-----------|-------|--------|
| <Dimension 1> | XX/25 | ✅/⚠️/❌ |
| <Dimension 2> | XX/25 | ✅/⚠️/❌ |
| <Dimension 3> | XX/25 | ✅/⚠️/❌ |
| <Dimension 4> | XX/25 | ✅/⚠️/❌ |

---

## Detailed Findings

### <Dimension 1>: XX/25

**✅ Passing Criteria:**
- [Criterion A] (10/10): Evidence at `file.tsx:42`

**⚠️ Partial Criteria:**
- [Criterion B] (4/8): Issue at `file.tsx:78` - [description]

**❌ Failing Criteria:**
- [Criterion C] (0/7): Not found in codebase

[Repeat for each dimension...]

---

## Prioritized Improvements

| Priority | Issue | Location | Points |
|----------|-------|----------|--------|
| P1 | [Most impactful issue] | `file:line` | +X pts |
| P2 | [Second issue] | `file:line` | +X pts |
| P3 | [Third issue] | `file:line` | +X pts |

---

## Recommendation

[PASS] Ready to merge. Score exceeds threshold.
OR
[FAIL] Address P1 issues before merging. Current score: XX, Required: XX
```

### Step 5: Offer Next Steps

Based on results:
- **If PASS**: "Ready to merge. Any specific areas you'd like me to improve further?"
- **If FAIL**: "I can fix the P1 issues now. Would you like me to address them?"

---

## Built-in Rubric Definitions

### Design System Rubric (100 points)

#### Component Composition (25 points)
- [ ] Uses existing atoms/molecules instead of raw elements (10)
- [ ] Follows composition patterns from design system (8)
- [ ] No inline styles where tokens exist (7)

#### Token Usage (25 points)
- [ ] Uses `classes.*` or design tokens for text styles (10)
- [ ] Uses `nativeColors.*` for native color values (8)
- [ ] Uses spacing tokens (`space-*`, `p-*`, `m-*`) (7)

#### Accessibility (25 points)
- [ ] ARIA attributes on interactive elements (10)
- [ ] accessibilityLabel/accessibilityRole on buttons (8)
- [ ] Focus management for modals/dialogs (7)

#### Responsiveness (25 points)
- [ ] Uses responsive breakpoints (`sm:`, `md:`, `lg:`) (10)
- [ ] Touch targets ≥44×44px on interactive elements (8)
- [ ] Layouts adapt to mobile/tablet/desktop (7)

---

### Testing Rubric (100 points)

#### Unit Test Coverage (25 points)
- [ ] Core logic has unit tests (10)
- [ ] Edge cases tested (error paths, boundaries) (8)
- [ ] Mocking used appropriately (7)

#### Integration Test Coverage (25 points)
- [ ] API routes have integration tests (10)
- [ ] Database operations tested with real services (8)
- [ ] Auth flows tested (7)

#### E2E Test Coverage (25 points)
- [ ] Critical user paths have E2E tests (10)
- [ ] Error scenarios tested (8)
- [ ] External APIs mocked appropriately (7)

#### Test Quality (25 points)
- [ ] Tests are deterministic (no flakiness) (10)
- [ ] Clear test names describe behavior (8)
- [ ] No skipped or commented-out tests (7)

---

### Accessibility Rubric (100 points)

#### Semantic HTML (25 points)
- [ ] Proper heading hierarchy (h1→h2→h3) (10)
- [ ] Semantic elements (nav, main, article) (8)
- [ ] Lists use ul/ol appropriately (7)

#### ARIA (25 points)
- [ ] role attributes on custom widgets (10)
- [ ] aria-label on icon-only buttons (8)
- [ ] aria-modal and aria-labelledby on dialogs (7)

#### Keyboard Navigation (25 points)
- [ ] All interactive elements focusable (10)
- [ ] Focus trap in modals (8)
- [ ] Escape key closes modals (7)

#### Visual (25 points)
- [ ] Color contrast ≥4.5:1 for text (10)
- [ ] Focus indicators visible (8)
- [ ] Text resizable to 200% (7)

---

### Security Rubric (100 points)

#### Input Validation (25 points)
- [ ] User input validated on server (10)
- [ ] Type checking on API inputs (8)
- [ ] SQL/NoSQL injection prevention (7)

#### Authentication (25 points)
- [ ] Auth checks on protected routes (10)
- [ ] JWT/session validation (8)
- [ ] Proper error messages (no info leak) (7)

#### Secrets Management (25 points)
- [ ] No hardcoded secrets in code (10)
- [ ] Environment variables for sensitive data (8)
- [ ] .env files in .gitignore (7)

#### OWASP Top 10 (25 points)
- [ ] XSS prevention (escape user content) (10)
- [ ] CSRF protection (8)
- [ ] Secure headers configured (7)

---

## Key Principles

### Be Specific
- Every finding should have a file:line reference
- Vague feedback is not actionable

### Score Fairly
- Partial credit for partial compliance
- Don't penalize for things outside scope

### Prioritize Impact
- P1 = Security/correctness issues
- P2 = Maintainability/quality issues
- P3 = Style/polish issues

### Enable Action
- Link findings to specific improvements
- Offer to fix issues directly

---

*Quality rubrics make code review objective and actionable.*
