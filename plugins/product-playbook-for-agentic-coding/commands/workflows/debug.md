---
name: playbook:debug
description: Systematic debugging workflow with verification-first approach
argument-hint: "[optional: brief description of the issue]"
---

# Debug Issue

You are facilitating a debugging session using structured problem-solving, with a focus on **Verification First** and **Documentation Discipline**.

## Your Goal

Help the user systematically debug application issues (bugs, errors, unexpected behavior) using a verification-first approach.

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (learnings for capturing solutions)
2. **Agents**: Specialized debugging agents via Task tool (if available)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

## Project Context Discovery

Before diving into the issue, search for existing solutions:
1. **Check project docs**: Look for troubleshooting guides
2. **Find existing debugging sessions**: Look for prior debugging docs
3. **Review CLAUDE.md**: For architectural context that might help

Use Glob -> Grep -> Read strategy to find relevant context.

## Learning Search (Before Investigating)

**Critical**: Search for prior solutions before debugging from scratch:

```bash
# Search by error message or symptom
Grep: "[error-message]" in docs/solutions/
Grep: "[symptom-keyword]" in docs/learnings/

# Search by category
Grep: "category: debugging" in docs/learnings/
Grep: "category: [area]" in docs/solutions/

# Search by severity (for similar critical issues)
Grep: "severity: critical" in docs/learnings/
Grep: "severity: high" in docs/solutions/

# Search by module affected
Grep: "module: [affected-module]" in docs/
```

If a prior solution exists, apply it. If not, continue with investigation and **capture the learning afterward**.

## Prerequisites

Before starting, ensure:
- Issue/error is identified and described
- Relevant logs are accessible (if available)
- Issue can be reproduced (or at least symptoms are clear)

## Process

### Step 1: Initial Problem Assessment

1. Gather problem description from user
2. Identify the type of issue (bug, error, unexpected behavior, performance)
3. Note initial symptoms and user impact
4. Check if logs are available

### Step 2: Check for Existing Solutions

**Before investigating, search for prior solutions:**
1. Search learnings docs for similar issues (by category, tags, symptoms)
2. Check troubleshooting guides
3. Review prior debugging sessions

If a solution exists, apply it. If not, continue with investigation.

### Step 3: Follow Verification-First Approach

**Before diving deep, verify basic assumptions:**

1. **Reproduce the Issue**:
   - Can you consistently reproduce it?
   - What are the exact steps to reproduce?
   - Does it happen in all environments or just specific ones?

2. **Verify It's Actually a Problem**:
   - Is this expected behavior?
   - Could this be user error or misunderstanding?
   - Check if this is documented as known behavior

3. **Check Common Causes**:
   - Cache issues (browser, framework, build)
   - Environment configuration
   - Recent changes (git log, deployments)

### Step 4: Systematic Investigation

Use these investigation techniques:

1. **Logs Analysis**:
   - Review application logs
   - Review platform logs (if applicable)
   - Cross-reference multiple log sources

2. **Network Requests**:
   - Check API calls, timeouts, error responses
   - Verify request/response payloads
   - Check for CORS or authentication issues

3. **Database Queries**:
   - Verify data integrity
   - Check query performance
   - Review database logs

4. **State Inspection**:
   - Component state
   - Application state
   - Local storage/session storage

5. **Environment Differences**:
   - Compare dev/staging/production
   - Check environment variables
   - Verify service configurations

### Step 5: Hypothesis Tracking

For each hypothesis:
1. **State the hypothesis clearly**
2. **Identify evidence needed to confirm/disprove**
3. **Test the hypothesis**
4. **Document results**

Track hypotheses systematically:
- Hypothesis 1: [Description] - Status: [Untested/Testing/Confirmed/Disproven]
- Hypothesis 2: [Description] - Status: [Untested/Testing/Confirmed/Disproven]

### Step 6: Root Cause Analysis

Ask these questions:

1. **What is the actual vs expected behavior?**
   - Document the gap clearly

2. **When did this start happening?**
   - Check recent commits, deployments, dependency updates
   - Use git bisect if needed

3. **What changed recently?**
   - Code changes, configuration changes, dependency updates

4. **Is it isolated or systemic?**
   - Does it affect one feature or many?
   - Is it user-specific or global?

### Step 7: Document Findings

Create or update a debugging session document:
- Problem description
- Reproduction steps
- Investigation findings
- Root cause (actual vs initial hypothesis)
- Evidence collected

### Step 8: Implement and Verify Fix

1. Based on root cause, implement a fix
2. Test the fix thoroughly:
   - Unit tests for the specific fix
   - Integration tests for related functionality
   - Manual verification
3. Ensure no regressions

### Step 9: Capture Learning

After fixing, use `/playbook:learnings` with trigger type "blocker-overcome" to:
- Document the root cause
- Document the solution
- Add to troubleshooting guides if broadly applicable

## Common Debugging Commands

```bash
# Run specific test
npm test -- [test-name]

# TypeScript errors
npm run typecheck

# Build to catch compile-time issues
npm run build

# Check recent changes
git log --oneline -10
git diff HEAD~5

# Git bisect to find when issue started
git bisect start
git bisect bad HEAD
git bisect good [known-good-commit]
```

## Framework Debugging Checklist

Before diving deep, check common issues:

- [ ] **Build cache**: Delete build artifacts and rebuild
- [ ] **Node modules**: Delete `node_modules/` and reinstall
- [ ] **Environment variables**: Verify config is correct
- [ ] **Browser cache**: Hard reload (Cmd+Shift+R)
- [ ] **TypeScript**: Run type checking for hidden errors

## Verification Plan

After fixing, verify:
- [ ] Issue no longer reproduces
- [ ] All related tests pass
- [ ] No regressions introduced
- [ ] Fix documented if complex
- [ ] Test added to prevent regression (if applicable)
- [ ] Learning captured via `/playbook:learnings`

## Prevention Measures

Consider:
- What tests would have caught this?
- What documentation was missing?
- What tooling could prevent recurrence?
- Should this be added to CI/CD checks?

---

**Remember**: Good debugging is systematic, documented, and leads to prevention, not just fixes.
