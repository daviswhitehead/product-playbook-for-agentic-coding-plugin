---
name: playbook:debug
description: Systematic debugging workflow with verification-first approach. Don't use for CI/CD-specific failures (use /playbook:debug-ci instead), or for general code review without a specific bug.
argument-hint: "[optional: brief description of the issue]"
recommended-mode: auto-accept
thinking-depth: think-harder
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

### Step 0: Check Observability Before Hypothesizing

**Before forming any hypothesis about the root cause, check available observability sources for direct evidence.** The most common debugging waste is implementing a fix for a guessed root cause when 30 seconds of checking logs would reveal the actual error.

Check whichever of these are available for the project:

1. **Traces/APM**: LangSmith, Datadog, or equivalent — look for the actual error message, stack trace, and timing
2. **Error tracking**: PostHog, Sentry, or equivalent — check for error events, frequency, and affected users
3. **Deployment logs**: Railway, Vercel (`vercel logs`), CloudWatch — read the actual error output
4. **CI/Actions history**: GitHub Actions run logs — check the actual failure output, not just the job name
5. **Environment config**: Verify required env vars exist in the target environment (`vercel env ls`, `doppler secrets`, `railway variables`)

**Rule**: Never change code based on an unverified hypothesis. If you catch yourself thinking "it's probably X," stop and find evidence first. State what you checked and what you found before proposing any fix.

### Step 0.5: Triage — Is This Related to Current Changes?

**For CI/test failures or issues discovered during development:**

1. Check if the error is in code you modified: `git diff --name-only | grep <failing-file>`
2. If the issue exists on the base branch too, it's pre-existing — report it and decide whether to fix or skip
3. If the issue is clearly unrelated to current work (e.g., flaky test in an unmodified module), flag it to the user rather than spending time investigating

This prevents wasting debugging cycles on pre-existing issues that aren't related to the current task.

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
   - **Reproduce in the REAL execution context, not a simulation of it.** If the
     failure occurs under cron, CI, launchd, a container, or any headless/scheduled
     runner, reproduce it *there* (e.g. a temporary `* * * * *` cron entry writing to
     /tmp, a scratch CI job) — not in an interactive shell. Interactive shells and
     `env -i` simulations inherit session properties that env vars don't capture
     (macOS keychain access, GUI session state, credential helpers) and will
     false-pass. A fix "verified" only in a simulation is unverified. (Found 2026-07:
     a Claude CLI keychain failure under cron passed every GUI-shell test for weeks;
     a real-cron test reproduced it in one minute.)

2. **Verify It's Actually a Problem**:
   - Is this expected behavior?
   - Could this be user error or misunderstanding?
   - Check if this is documented as known behavior

3. **Check Common Causes**:
   - Cache issues (browser, framework, build)
   - Environment configuration
   - Recent changes (git log, deployments)

4. **Probe the running system before blaming configuration** (do NOT skip when the suspect is an external service):

   Config files, dashboards, and your mental model all drift from the running system. When a hypothesis implicates external config — an OAuth client, a DNS record, a CDN rule, an IAM policy, a feature flag — **find a request that distinguishes the hypotheses, and make it.** Reading the repo tells you what *should* be true; the live service tells you what *is*.

   ```
   Hypothesis: "<external thing> is misconfigured"
   → What single request would return a different answer if it were configured correctly?
   → Make that request. Then diagnose.
   ```

   Also verify *which instance* you are talking to. A deployment can point at a different backing service than you assume, which makes a correctly-configured service look broken.

   **Never hand a human step-by-step instructions to change external state on the strength of a config-file reading.** If you're wrong you've cost them time, taught them to distrust the diagnosis, and made the real cause harder to find — they now believe the thing you told them to change was broken. State the evidence and how you got it, so they can spot a bad premise before acting.

   *Found 2026-07-25 (chef-chopsky): a Google `redirect_uri_mismatch` was root-caused to a missing redirect URI, reasoned entirely from repo config, and the user was walked through adding it in Google Cloud Console. The console was already correct — the preview pointed at a different Supabase project than assumed. A ~5-second probe of the live authorize endpoint disproved it, and was only run after the user pushed back with a screenshot.*

5. **Treat never-executed paths as unimplemented.** A `catch`, retry, or fallback branch you have never watched run is untested code, whatever it looks like. If your diagnosis depends on one having worked, make it fire once and read the output. *(Same session: a CI fallback posted to a URL that had always returned 404, hidden behind a poll-count guard and a `::warning::` on a green job. It had never once succeeded.)*

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

### Tool Limitation Recognition

When using diagnostic tools (search APIs, log queries, MCP servers):
- **After 2 consecutive failures with the same tool**, stop and switch strategy
- Do not brute-force a tool that's clearly returning empty/error results
- Switch to: a different tool, web search, documentation, or asking the user
- **Express uncertainty**: Say "I'm not sure, let me verify" instead of stating capabilities/limitations as fact

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
