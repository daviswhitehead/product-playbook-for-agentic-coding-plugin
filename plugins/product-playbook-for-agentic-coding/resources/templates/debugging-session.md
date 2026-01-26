# Debugging Session

## Session Overview
**Issue**: [Brief description of the problem]
**Date**: [Date]
**Duration**: [Time spent]
**Environment**: [Development/Staging/Production]

## Problem Statement

### Initial Symptoms
- [Symptom 1]
- [Symptom 2]
- [Symptom 3]

### User Impact
- [Who is affected]
- [What functionality is broken]
- [Workaround (if any)]

## Verification Steps

### Step 1: Verify Basic Functionality
**Status**: [ ] Pending | [ ] In Progress | [ ] Complete

**Actions Taken**:
```bash
# Commands run
```

**Results**:
- [What was found]
- [Response codes, errors, etc.]

**Key Insight**: [Is the issue reproducible? What conditions trigger it?]

---

### Step 2: Check Logs
**Status**: [ ] Pending | [ ] In Progress | [ ] Complete

**Log Sources**:
- [Application logs]
- [Server logs]
- [Browser console]
- [Database logs]

**Key Findings**:
- [Error patterns]
- [Timing information]
- [Request IDs for correlation]

---

### Step 3: Verify Configuration
**Status**: [ ] Pending | [ ] In Progress | [ ] Complete

**Configuration Checked**:
- [Environment variables]
- [Service configuration]
- [Database settings]
- [Network/CORS settings]

**Findings**:
- [What's configured]
- [What's missing/incorrect]

---

### Step 4: Check for Caching Issues
**Status**: [ ] Pending | [ ] In Progress | [ ] Complete

**When to Check**:
- "Changing code makes it work temporarily"
- Data exists in DB but not displayed in UI
- Inconsistent behavior between requests

**Areas to Check**:
- [ ] Browser cache
- [ ] API/server cache
- [ ] Database query cache
- [ ] CDN cache

**Quick Test**:
Force refresh or clear caches to rule out caching issues.

---

## Hypothesis Tracking

### Hypothesis 1: [Description]
**Status**: [ ] Untested | [ ] Testing | [ ] Confirmed | [ ] Disproven

**Evidence**:
- [Supporting evidence]
- [Contradicting evidence]

**Resolution**: [How hypothesis was confirmed/disproven]

---

### Hypothesis 2: [Description]
**Status**: [ ] Untested | [ ] Testing | [ ] Confirmed | [ ] Disproven

**Evidence**:
- [Supporting evidence]
- [Contradicting evidence]

**Resolution**: [How hypothesis was confirmed/disproven]

---

## Root Cause Analysis

### Actual Root Cause
[Detailed explanation of what was actually wrong]

### Why Initial Hypothesis Was Wrong
[Explanation of why we initially thought it was something else]

### Contributing Factors
- [Factor 1]
- [Factor 2]

---

## Solution Tracking

### Solution 1: [Description]
**Status**: [ ] Planned | [ ] In Progress | [ ] Implemented | [ ] Rejected

**Implementation**:
```diff
# Code changes or configuration changes
```

**Verification**:
- [How solution was tested]
- [Test results]

---

### Solution 2: [Description]
**Status**: [ ] Planned | [ ] In Progress | [ ] Implemented | [ ] Rejected

**Implementation**:
```diff
# Code changes or configuration changes
```

**Verification**:
- [How solution was tested]
- [Test results]

---

## Resolution

### Final Solution
[Summary of what fixed the issue]

### Verification
- [ ] Issue no longer reproducible
- [ ] Root cause identified
- [ ] Solution verified working
- [ ] No regressions introduced

### Follow-up Items
- [ ] [Follow-up task 1]
- [ ] [Follow-up task 2]

---

## Key Learnings

### What Worked Well
- [Effective debugging technique]
- [Helpful tool or approach]

### What Could Be Improved
- [Ineffective approach]
- [Tool or process gap]

### Documentation to Create
- [ ] [Pattern to document]
- [ ] [Gotcha to capture]
- [ ] [Troubleshooting guide to add]

---

*This template helps structure debugging sessions with verification-first approach and hypothesis tracking.*
