---
name: playbook:debug-ci
description: Debug CI/CD failures systematically using GitHub CLI
argument-hint: "[PR number or workflow run ID]"
---

# Debug CI Failures

You are facilitating iterative CI failure debugging with a focus on **Latest Run Focus**, **Systematic Log Analysis**, and **Iterative Debugging**.

## Your Goal

Help the user systematically debug CI/CD test failures by focusing on the latest run, analyzing logs, and iterating with targeted fixes.

## Available Tools Discovery

Before proceeding, inventory available tools:
1. **Commands**: Other `/playbook:*` commands (debug, learnings)
2. **Agents**: Specialized agents via Task tool (debugging-agent)
3. **MCP Tools**: External service integrations via ToolSearch (GitHub)
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools for the task at hand.

## Prerequisites

Before starting, ensure:
- GitHub CLI (`gh`) is installed and authenticated
- User has access to view workflow runs, logs, and artifacts
- PR number or workflow run ID is provided

## Process

### Step 1: Get Latest Run Information

**ALWAYS start with the most recent CI run - don't assume previous fixes worked**

1. Get the latest workflow run:
```bash
# List recent workflow runs
gh run list --limit 5

# Get specific PR's checks
gh pr checks <PR_NUMBER>
```

2. Get run status and details:
```bash
gh run view <RUN_ID>
```

### Step 2: Download and Analyze Logs

1. Download logs for failed job:
```bash
gh run view <RUN_ID> --log-failed
```

2. Look for patterns:
   - Test failures (which tests, how many)
   - Error messages and stack traces
   - Environment/dependency issues
   - Timeout or resource issues

### Step 3: Classify Failure Type

Categorize the failure:

| Type | Indicators | Approach |
|------|------------|----------|
| **Test Bug** | Assertion error, expected vs actual mismatch | Fix test expectations |
| **Product Bug** | Logic error caught by test | Fix product code |
| **Environment** | Missing env vars, service unavailable | Fix CI config |
| **Flaky** | Intermittent, passes on retry | Add retry or fix race condition |
| **Timeout** | Test took too long | Optimize or increase timeout |

### Step 4: Reproduce Locally (When Possible)

```bash
# Run the same test locally
npm test -- --grep "failing test name"

# With similar environment
CI=true npm test
```

### Step 5: Apply Targeted Fix

**One fix at a time** - don't bundle multiple changes:

1. Identify the most likely root cause
2. Make minimal targeted change
3. Test locally if possible
4. Commit and push
5. Wait for CI to run
6. Reassess if still failing

### Step 6: Iterate

After each CI run:
1. **Check latest run** (not cached results)
2. **Compare to previous** - did the fix help?
3. **Adjust hypothesis** if needed
4. **Apply next fix** if issue persists

## Common Failure Patterns

### Test Timeouts
```bash
# Increase timeout in test config
jest.setTimeout(30000);

# Or in CI workflow
env:
  JEST_TIMEOUT: 30000
```

### Missing Environment Variables
```bash
# Check what's available in CI
gh run view <RUN_ID> --log | grep -i "env\|secret"

# Verify secrets are set
gh secret list
```

### Database/Service Issues
```bash
# Check service health in logs
gh run view <RUN_ID> --log | grep -i "database\|connection\|postgres"
```

### Flaky Tests
- Look for race conditions
- Check for shared state between tests
- Consider retry mechanisms

## Key Principles

1. **Latest Run Focus**: Always check the most recent CI run
2. **Systematic Analysis**: Follow the same process each time
3. **One Fix at a Time**: Isolate changes to identify what works
4. **Local Reproduction**: Try to reproduce failures locally first
5. **Log Everything**: Save logs for comparison between runs

## Next Steps

After fixing CI:
1. Document the root cause
2. Consider if this is a pattern that needs prevention
3. Use `/playbook:learnings` to capture what you learned
