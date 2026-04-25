# Impact Estimation

## What It Is

A quantitative framework for estimating the impact of a product change. Uses a bottom-up formula with three-scenario analysis to produce defensible estimates rather than gut-feel guesses.

## When to Use

- Prioritizing features or initiatives (RICE scoring, roadmap planning)
- Justifying investment in a project to stakeholders
- Comparing the expected value of competing options
- Setting targets for an experiment or launch

## The Framework

### Core Formula

```
Impact = Users Affected x Current Action Rate x Expected Lift x Value per Action
```

| Variable | Definition | Example |
|----------|-----------|---------|
| Users Affected | Number of users who will encounter the change | 50,000 monthly active users on the pricing page |
| Current Action Rate | Baseline rate of the action you're trying to influence | 3.2% conversion rate |
| Expected Lift | Estimated % improvement from the change | +15% relative lift |
| Value per Action | Revenue, time saved, or other value per successful action | $49 average order value |

**Example calculation**: 50,000 x 0.032 x 0.15 x $49 = **$11,760/month**

### Three-Scenario Analysis

Never present a single estimate. Use three scenarios to communicate uncertainty:

| Scenario | Percentile | Description |
|----------|-----------|-------------|
| Pessimistic | 20th | What happens if our weakest assumption is true |
| Realistic | 50th | Most likely outcome given current evidence |
| Optimistic | 80th | What happens if conditions are favorable |

Present the realistic scenario as the headline number. Show pessimistic and optimistic as a range.

### Lift Estimation Source Hierarchy

Use the most reliable source available for your lift estimate:

1. **Historical data** (strongest): Prior A/B tests on similar changes in your product
2. **User research**: Qualitative signals from interviews, usability tests, surveys
3. **Competitor benchmarks**: Published results from comparable products or features
4. **Expert judgment** (weakest): Informed guesses from domain experts

Always note which source level you're using. The weaker the source, the wider your pessimistic-to-optimistic range should be.

### Flagging Weak Variables

For each variable in the formula, rate your confidence:
- **High**: Based on measured data (analytics, prior tests)
- **Medium**: Based on reasonable inference (benchmarks, research)
- **Low**: Based on assumption (gut feel, analogies)

Flag any variable rated "Low" — it's the most likely source of error. Consider whether you can gather data to improve confidence before committing to the decision.

## How to Apply

1. Identify the intervention (what you're changing) and the target metric (what you're measuring).
2. Gather data for each variable in the formula. Note the source and confidence level.
3. Calculate impact for all three scenarios.
4. Present: realistic as headline, range in parentheses, and flag the weakest variable.
5. Use the result to inform prioritization — not as a precise prediction.

**Output format example**:
> Estimated impact: **$11,760/month** ($4,900–$18,200 range)
> Weakest variable: Expected Lift (based on competitor benchmarks, not own data)
