---
name: playbook:debug-ci
description: Debug CI/CD failures systematically using GitHub CLI
argument-hint: "[PR number or workflow run ID]"
---

# Debug CI Failures

You are facilitating iterative CI failure debugging with a focus on **Latest Run Focus**, **Systematic Log Analysis**, **Policy Compliance**, and **Iterative Debugging**.

## Your Goal

Help the user systematically debug CI/CD test failures by focusing on the latest run, analyzing logs, checking policy compliance, and iterating with targeted fixes.

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

### Step 2: Analyze Job Timing and Shard Distribution

**For sharded test suites, timing analysis is the fastest way to find the problem.**

1. Compare job durations to identify outliers:
```bash
# View all jobs with their durations
gh run view <RUN_ID> --json jobs --jq '.jobs[] | "\(.name): \(.conclusion) (\(.startedAt) → \(.completedAt))"'
```

2. If one shard is significantly slower than others (2x+), it likely contains the problematic test:
```bash
# List tests in a specific shard
npx playwright test --list --shard=<N>/<TOTAL>
```

3. Look for tests that:
   - Have no AI/API stubbing (hitting real external services)
   - Use `waitForTimeout` instead of deterministic waits
   - Have high retry counts with long timeouts (multiplier effect: retries x timeout)

**Key insight**: A single unstubbed test with 2 retries and 120s timeout can add 6+ minutes per test to a shard. Identify these first.

### Step 3: Check Policy Compliance

**Before investigating infrastructure or flakiness, check if the failing test follows project policies.**

1. Read the project's `CLAUDE.md` for test policies (look for "Zero Tolerance", "Testing", "E2E"):
```bash
grep -A 5 "Zero Tolerance\|E2E.*stub\|test.*policy" CLAUDE.md
```

2. Check the failing test file against documented policies:
   - **AI Stubbing**: Does the E2E test stub external API calls?
   - **Deterministic Waits**: Does it use `waitForTimeout` instead of condition-based waits?
   - **Test Isolation**: Does it clean up state properly?
   - **Timeouts**: Are suite/test timeouts configured appropriately?

3. Common policy violations that cause CI failures:

| Violation | Symptom | Fix |
|-----------|---------|-----|
| Missing AI stub | Test takes 60s+ instead of 3-5s | Add `page.route()` stub |
| `waitForTimeout` | Flaky — sometimes too short, always wasteful | Wait for DOM condition/testId |
| `addInitScript` for localStorage | Races with inline `<script>` in headless Chrome | Two-navigation pattern |
| No suite timeout | Falls through to global 120s timeout | `test.describe.configure({ timeout: N })` |

**Policy violations are the most common root cause of CI test failures. Check these before investigating timing, flakiness, or infrastructure.**

### Step 4: Download and Analyze Logs

1. Download logs for failed job:
```bash
gh run view <RUN_ID> --log-failed
```

2. Look for patterns:
   - Test failures (which tests, how many)
   - Error messages and stack traces
   - Environment/dependency issues
   - Timeout or resource issues

### Step 5: Classify Failure Type

Categorize the failure:

| Type | Indicators | Approach |
|------|------------|----------|
| **Policy Violation** | Missing stub, waitForTimeout, no timeout config | Fix test to follow policies |
| **Test Bug** | Assertion error, expected vs actual mismatch | Fix test expectations |
| **Product Bug** | Logic error caught by test | Fix product code |
| **Environment** | Missing env vars, service unavailable | Fix CI config |
| **Flaky** | Intermittent, passes on retry | Add retry or fix race condition |
| **Timeout** | Test took too long | Optimize or increase timeout |
| **Migration Drift** | DB push fails, missing migrations | Update repair step in CI workflow |

### Step 6: Reproduce Locally (When Possible)

```bash
# Run the same test locally
npm test -- --grep "failing test name"

# Run a specific shard
npm run test:e2e -- --shard=2/3

# With similar environment
CI=true npm test
```

### Step 7: Apply Targeted Fix

**One fix at a time** - don't bundle multiple changes:

1. Identify the most likely root cause
2. Make minimal targeted change
3. Test locally if possible
4. Commit and push
5. Wait for CI to run
6. Reassess if still failing

### Step 8: Iterate

After each CI run:
1. **Check latest run** (not cached results)
2. **Compare to previous** - did the fix help?
3. **Adjust hypothesis** if needed
4. **Apply next fix** if issue persists

## Context Budget Awareness

**For investigation-heavy CI debugging, be mindful of context window limits.**

If the investigation involves reading 15+ files before writing any code, consider suggesting a split:
- **Session 1**: Investigate + plan (research-heavy, lots of file reads and log analysis)
- **Session 2**: Implement + validate (code changes, test runs)

The plan document (from `/playbook:tech-plan`) serves as the handoff artifact between sessions. This prevents context exhaustion mid-implementation.

## Common Failure Patterns

### Sharded Test Timeouts
```bash
# Compare shard durations
gh run view <RUN_ID> --json jobs --jq '.jobs[] | select(.name | contains("Shard")) | "\(.name): \(.conclusion)"'

# List tests in slow shard
npx playwright test --list --shard=2/3
```

### Missing AI/API Stubs
```bash
# Find E2E files that send messages but don't stub
for f in tests/e2e/*.spec.ts; do
  if grep -qE "sendMessage|Ask Chef Chop" "$f"; then
    if ! grep -q "api/ai/chat/stream" "$f"; then
      echo "UNSTUBBED: $(basename $f)"
    fi
  fi
done
```

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

### Database/Migration Issues
```bash
# Check service health in logs
gh run view <RUN_ID> --log | grep -i "database\|connection\|migration"

# Check for staging migration drift
supabase migration list
```

### Flaky Tests
- Look for race conditions (`waitForTimeout` instead of deterministic waits)
- Check for shared state between tests
- Check for `addInitScript` timing issues in headless Chrome
- Consider retry mechanisms as last resort

## Key Principles

1. **Policy First**: Check test policy compliance before investigating infrastructure
2. **Timing Analysis**: For sharded suites, compare shard durations to find outliers
3. **Latest Run Focus**: Always check the most recent CI run
4. **Systematic Analysis**: Follow the same process each time
5. **One Fix at a Time**: Isolate changes to identify what works
6. **Local Reproduction**: Try to reproduce failures locally first
7. **Context Budget**: Split investigation and implementation if reading 15+ files

## Next Steps

After fixing CI:
1. Document the root cause
2. Consider if this is a pattern that needs prevention (pre-commit hook, CI lint)
3. Use `/playbook:learnings` to capture what you learned
4. If a policy gap enabled the failure, propose enforcement automation
