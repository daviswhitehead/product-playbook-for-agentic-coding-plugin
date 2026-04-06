---
name: user-journey-testing
description: Patterns for defining and executing end-to-end user journeys via browser automation at major milestones. Catches integration bugs that component tests miss. Don't use for unit testing, API testing, or debugging a single component. Don't use mid-task — use at milestone boundaries only.
---

# User Journey Testing

## Problem

Component-level and unit tests pass while real user flows are broken. Test stubs (e.g., `x-test-chat-stub`) create false confidence by exercising rendering but not the real system pipeline. The most effective bug-finding technique in practice is testing as a real user would — end-to-end, through the actual system.

## When to Use Journey Tests

- **Major milestones**: After completing a milestone's tasks, before declaring it done
- **Before PR creation**: As part of the pre-PR validation process
- **After pipeline changes**: Any change to the agent, streaming, tool calling, or data flow
- **Before handoff to user**: Always self-test via journeys before asking the user to manually test

## Core Principle: Real Pipeline, Not Stubs

Journey tests exercise the **real system**:
- Real agent (not stubbed)
- Real database (not mocked)
- Real streaming (not simulated)
- Real browser interaction (not programmatic DOM manipulation)

This is fundamentally different from E2E tests that use stubs for speed/reliability. Both are valuable, but only journey tests answer: **"Does this actually work for a real person?"**

## How to Define a Journey

Structure each journey as a sequence of actions and verifications from the user's perspective:

```
Journey: [Name — describes the user goal]
Preconditions: [What must be true before starting]
Steps:
  1. [Action]: Navigate to /path
     Verify: Page loads, expected elements visible
  2. [Action]: Type "message" in chat input, press Send
     Verify: Message appears in chat, agent responds
  3. [Action]: Click on [element]
     Verify: Expected result occurs
  ...
Success Criteria: [What "working" looks like at the end]
```

### Example Journeys

**Create and Edit a Recipe:**
```
Journey: Create recipe in chat, then edit it
Preconditions: Logged-in user with an active conversation
Steps:
  1. Navigate to chat
  2. Send "Make me a pad thai recipe with shrimp"
  3. Verify: Tool call indicator appears, then recipe card renders in chat
  4. Click recipe card link
  5. Verify: Recipe detail page loads with title, ingredients, instructions
  6. Navigate back to chat
  7. Send "Actually, make it with tofu instead of shrimp"
  8. Verify: Agent updates the recipe (not creates a new one)
  9. Click updated recipe card
  10. Verify: Detail page shows tofu, not shrimp
Success Criteria: Single recipe exists with tofu, edit history preserved
```

**Guest User Gating:**
```
Journey: Guest user hits message limit
Preconditions: Fresh browser session (no auth)
Steps:
  1. Navigate to home page
  2. Start a conversation as guest
  3. Send 5 messages (with agent responses between each)
  4. Verify: Messages 1-5 all visible with agent replies
  5. Attempt to send message 6
  6. Verify: Gate modal appears (not on message 5, on attempt 6)
Success Criteria: User sees all 5 messages before being gated
```

## How to Execute Journeys

### Using Browser Automation

Use Agent Browser CLI or Playwright MCP to walk through each step:

```
1. Start dev services: npm run deploy:development:all
2. Navigate to the starting page
3. For each step:
   a. Perform the action (click, type, navigate)
   b. Wait for the expected result (use testId selectors, not timeouts)
   c. Take a screenshot as evidence
   d. If verification fails: stop, document the failure, fix it
4. After all steps pass: compile evidence report
```

### The Autonomous Testing Prompt

At major milestones, use this pattern:

> "Commit the current work, then do the manual test yourself autonomously. Use the Agent Browser CLI or Playwright to simulate a real user walking through these journeys. Fix any issues you find. Only hand off to me after all journeys pass."

### Evidence Capture

Each journey execution should produce:

```
## Journey Report: [Name]
**Date**: YYYY-MM-DD
**Result**: PASS / FAIL

| Step | Action | Expected | Actual | Status |
|------|--------|----------|--------|--------|
| 1 | Navigate to /chat | Page loads | Page loaded | PASS |
| 2 | Send message | Agent responds | Agent responded | PASS |
| 3 | Click recipe | Detail page | 404 error | FAIL |

**Screenshots**: [attached or linked]
**Failures fixed**: [description of what was wrong and how it was fixed]
```

## Defining Journeys for a Milestone

When a milestone is complete, define 3-5 journeys that cover its scope:

1. **Happy path**: The primary user flow the milestone enables
2. **Edge case**: An unusual but valid scenario (e.g., multiple recipes in one chat)
3. **Error recovery**: What happens when something goes wrong (e.g., network drop)
4. **Cross-feature**: A journey that spans this milestone + a previous one
5. **Permission boundary**: Test behavior for different user types (guest, free, paid)

Not every milestone needs all 5. Use judgment — cover the riskiest flows.

## Distinction from Other Test Types

| Type | Speed | Pipeline | Purpose | When |
|------|-------|----------|---------|------|
| Unit tests | Fast (~10s) | None | Logic correctness | Every commit |
| Integration tests | Medium (~2-3m) | Real DB | Service layer | Before push |
| E2E tests (stubbed) | Medium (~3-4m) | Stub | UI rendering | Before push |
| **Journey tests** | **Slow (~5-10m)** | **Real** | **User experience** | **Milestones** |

Journey tests are the most expensive but the most truthful. They are the final quality gate before declaring work complete.
