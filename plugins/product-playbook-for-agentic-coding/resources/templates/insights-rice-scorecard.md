# RICE Scoring Rubric

## Purpose

Score product improvement ideas using a modified RICE framework that separates **Value** (what you gain) from **Risk** (what could go wrong). This produces a single score for ranking ideas.

## Scoring Dimensions (1-5 Scale)

### Reach

How many active users does this affect? (Chef Chopsky: 7-15 weekly active users)

| Score | Definition | Chef Chopsky Example |
|-------|-----------|---------------------|
| 5 | Affects >80% of active users | Agent's greeting behavior (every user sees it) |
| 4 | Affects 50-80% of active users | Recipe generation quality (most users request recipes) |
| 3 | Affects 20-50% of active users | Memory-related issues (affects returning users specifically) |
| 2 | Affects 5-20% of active users | Mobile-specific UI bugs (subset of users on mobile) |
| 1 | Affects 1-2 specific users | Edge case in a specific cuisine preference |

### Impact

How strongly does this affect the product goal it's linked to?

| Score | Definition | Chef Chopsky Example |
|-------|-----------|---------------------|
| 5 | Directly drives D7 retention (P0) | Fixing a bug that causes users to abandon mid-conversation |
| 4 | Strongly influences satisfaction (P1) | Improving recipe quality for the most common request type |
| 3 | Improves engagement frequency (P2) | Adding a "cook again" shortcut for past recipes |
| 2 | Minor quality improvement | Better formatting of ingredient lists |
| 1 | Cosmetic/polish | Updating a cooking phrase to be more fun |

### Confidence

How sure are we that this idea is correct and will have the expected impact?

| Score | Definition | Chef Chopsky Example |
|-------|-----------|---------------------|
| 5 | Direct user complaint + clear root cause | User said "I already told you this" + memory lookup confirms agent didn't check |
| 4 | Pattern across 3+ sessions | Same friction point observed in 3 different users' sessions |
| 3 | Pattern in 2 sessions | 2 users hit the same issue but different contexts |
| 2 | Single session inference | One user seemed frustrated (no explicit feedback) |
| 1 | Speculation from transcript tone | "The user might have wanted..." with no supporting evidence |

### Effort

How much work is required to implement this?

| Score | Definition | Chef Chopsky Example |
|-------|-----------|---------------------|
| 1 | Single-line prompt/config change | Add "check user_memory for dietary preferences" to agent prompt |
| 2 | Multi-line change in 1 file | Update agent prompt with new memory lookup logic |
| 3 | Changes across 2-3 files | New agent behavior + update memory schema |
| 4 | New component/endpoint needed | Build a recipe rating UI component + API endpoint |
| 5 | Architecture change or multi-week project | Redesign the agent's memory system |

## Formulas

```
Value  = (Reach + Impact) / 2
Risk   = ((6 - Confidence) + Effort) / 2
Score  = Value > Risk ? Value / Risk : -(Risk / Value)
```

- **Positive scores**: Value exceeds Risk. Higher is better.
- **Negative scores**: Risk exceeds Value. More negative is worse.
- Score of exactly 0 is not possible (requires Value = Risk = 0, which is impossible with 1-5 inputs).

## Designation Thresholds

| Designation | Condition | Meaning |
|------------|-----------|---------|
| **no_brainer** | Score > 2.0 | High value, low risk. Do this immediately. |
| **quick_win** | 1.0 < Score ≤ 2.0 | Positive ROI, worth doing soon. |
| **big_bet** | 0 < Score ≤ 1.0 | Positive but risky. Needs validation or phasing. |
| **dont_do** | Score ≤ 0 | Risk exceeds value. Skip unless context changes. |

## Simple vs Complex Classification

After scoring, classify each idea for implementation routing:

| Classification | Criteria |
|---------------|----------|
| **simple** | Touches ≤3 files AND estimated ≤50 lines of change AND no new dependencies |
| **complex** | Exceeds any simple threshold |

Simple ideas with `no_brainer` or `quick_win` designation are candidates for automated PRs (Stage 5).
Complex ideas with high scores are candidates for PRD drafting (Stage 6).

## Calibration Examples

### No Brainer Example

| Field | Value |
|-------|-------|
| Description | Add dietary preference check before recipe generation |
| Reach | 4 |
| Impact | 5 |
| Confidence | 5 |
| Effort | 1 |
| Value | 4.5 |
| Risk | 1.0 |
| Score | 4.50 |
| Designation | no_brainer |

### Quick Win Example

| Field | Value |
|-------|-------|
| Description | Friendlier error recovery messages |
| Reach | 3 |
| Impact | 3 |
| Confidence | 4 |
| Effort | 1 |
| Value | 3.0 |
| Risk | 1.5 |
| Score | 2.00 |
| Designation | quick_win |

### Big Bet Example

| Field | Value |
|-------|-------|
| Description | Weekly meal plan mode |
| Reach | 4 |
| Impact | 5 |
| Confidence | 2 |
| Effort | 5 |
| Value | 4.5 |
| Risk | 4.5 |
| Score | 1.00 |
| Designation | big_bet |

### Don't Do Example

| Field | Value |
|-------|-------|
| Description | Social recipe sharing to Twitter/Instagram |
| Reach | 1 |
| Impact | 1 |
| Confidence | 1 |
| Effort | 4 |
| Value | 1.0 |
| Risk | 4.5 |
| Score | -4.50 |
| Designation | dont_do |

## Scoring Instructions

1. Score each RICE dimension independently using the calibration anchors above.
2. Use integer values only (1-5) for each dimension.
3. Calculate Value, Risk, and Score using the formulas.
4. Assign designation based on Score thresholds.
5. Classify as simple or complex based on implementation scope.
6. Provide a brief rationale for your scoring (1-2 sentences explaining the key factors).
