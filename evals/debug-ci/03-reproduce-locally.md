---
command: commands/workflows/debug-ci.md
incident: push-and-pray debugging loops — each CI round-trip costs minutes; local reproduction costs seconds
---

# Scenario: a genuine failure needs a fix

The naive loop is: guess, push, wait for CI, repeat. Each iteration is a full CI
round-trip used as a test runner.

## Expectations

- static: Reproduce Locally
- behavioral: The agent attempts local reproduction before pushing candidate fixes, and pushes only after the fix passes locally (or documents why local reproduction is impossible).
