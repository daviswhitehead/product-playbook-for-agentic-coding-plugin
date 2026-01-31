# Critique Issue Tracker: [Document Set Name]

## Overview

This document tracks issues across critique versions to ensure persistent problems are identified and resolved.

**Document Set**: [Path to documents being critiqued]
**Started**: YYYY-MM-DD
**Current Version**: v[N]

---

## Issue Status Legend

| Status | Meaning |
|--------|---------|
| 🆕 Open | New issue, not yet addressed |
| 🔧 In Progress | Being worked on |
| ✅ Fixed | Fix implemented, awaiting verification |
| ✅✅ Verified | Fix confirmed in next critique |
| 🔄 Regressed | Was fixed, but issue returned |
| ⏸️ Deferred | Intentionally postponed |
| ❌ Won't Fix | Decided not to address |

---

## Active Issues

### P0 Issues (Must Fix)

| ID | Issue | First Seen | Status | Owner | Notes |
|----|-------|------------|--------|-------|-------|
| P0-001 | [Issue title] | v1 | 🆕 Open | — | [Context] |
| P0-002 | [Issue title] | v2 | 🔧 In Progress | @name | [What's being done] |

### P1 Issues (Should Fix)

| ID | Issue | First Seen | Status | Owner | Notes |
|----|-------|------------|--------|-------|-------|
| P1-001 | [Issue title] | v1 | ✅ Fixed | @name | Fixed in v2 |

### P2 Issues (Nice to Fix)

| ID | Issue | First Seen | Status | Owner | Notes |
|----|-------|------------|--------|-------|-------|
| P2-001 | [Issue title] | v1 | ⏸️ Deferred | — | Post-launch |

---

## Issue History by Version

### v1 (YYYY-MM-DD)

**New Issues**: 12 (5 P0, 4 P1, 3 P2)

| ID | Issue | Priority | Status |
|----|-------|----------|--------|
| P0-001 | [Issue] | P0 | 🆕 Open |
| P0-002 | [Issue] | P0 | 🆕 Open |

### v2 (YYYY-MM-DD)

**New Issues**: 3
**Resolved**: 4
**Regressed**: 0

| ID | Issue | Priority | Status | Change |
|----|-------|----------|--------|--------|
| P0-001 | [Issue] | P0 | ✅✅ Verified | Was Open → Fixed → Verified |
| P0-002 | [Issue] | P0 | 🆕 Open | Still open |
| P0-003 | [New issue] | P0 | 🆕 Open | New in v2 |

### v3 (YYYY-MM-DD)

[Continue pattern]

---

## Persistent Issues Report

Issues that have appeared in 2+ consecutive versions:

| ID | Issue | Versions | Current Status | Root Cause Analysis |
|----|-------|----------|----------------|---------------------|
| P0-002 | [Issue] | v1, v2, v3 | 🆕 Open | [Why hasn't this been fixed?] |

**Action Required**: Issues appearing in 3+ versions need dedicated resolution sessions.

---

## Resolution Log

### P0-001: [Issue Title]

**First Reported**: v1 (YYYY-MM-DD)
**Reported By**: Marketing Strategist, Product Manager
**Description**: [Full description of the issue]

**Resolution Timeline**:
- v1: Identified as P0
- v2: Attempted fix in `file.md` - partial resolution
- v3: Complete fix implemented
- v4: Verified resolved

**Final Resolution**: [What was done to fix it]

**Lessons Learned**: [What to do differently next time]

---

### P0-002: [Issue Title]

[Repeat structure for each significant issue]

---

## Metrics

### Resolution Rate by Version

| Version | P0 Open | P0 Fixed | P1 Open | P1 Fixed | P2 Open | P2 Fixed |
|---------|---------|----------|---------|----------|---------|----------|
| v1 | 5 | 0 | 4 | 0 | 3 | 0 |
| v2 | 3 | 2 | 2 | 2 | 3 | 0 |
| v3 | 1 | 2 | 1 | 1 | 2 | 1 |

### Average Time to Resolution

- P0 Issues: X.X versions
- P1 Issues: X.X versions
- P2 Issues: X.X versions

---

## Next Steps

1. [ ] Address remaining P0 issues before next critique
2. [ ] Schedule dedicated session for persistent issue P0-002
3. [ ] Run v[N+1] critique after fixes implemented

---

*Last Updated: YYYY-MM-DD*
