# Strategy Kernel

## What It Is

Richard Rumelt's Strategy Kernel framework: a strategy is a coherent set of three elements — Diagnosis, Guiding Policy, and Coherent Actions. If any element is missing or disconnected, what you have is not a strategy.

## When to Use

- Validating that a tech plan connects problem analysis to architectural decisions
- Reviewing a product strategy or foundations document
- Checking whether a proposal is a real strategy or a list of goals
- Any time a plan feels like a collection of good ideas without a thread connecting them

## The Framework

### 1. Diagnosis

A clear, honest statement of the challenge being faced. Grounded in evidence, not aspiration.

**Test**: "Could a reasonable person disagree with this diagnosis?"
- If no one could disagree, it's probably too vague ("we need to grow")
- If it's controversial or specific, it's probably a real diagnosis

**Examples**:
- Weak: "We need to improve our user experience"
- Strong: "New users drop off at the onboarding quiz because it asks 12 questions before showing any value"

### 2. Guiding Policy

The overall approach for dealing with the challenge. Must include explicit tradeoffs — what you're choosing and what you're giving up.

**Test**: "Does this rule things out?"
- If the policy is compatible with everything, it's not a policy
- A real policy makes some actions clearly off-limits

**Examples**:
- Weak: "We will focus on quality and speed"
- Strong: "We will optimize for time-to-first-value over feature completeness, accepting that power users will hit limitations in v1"

### 3. Coherent Actions

Specific, coordinated steps that implement the guiding policy. Actions must reinforce each other, not just coexist.

**Test**: "Do these actions reinforce each other?"
- If removing one action doesn't affect the others, they're not coherent — they're a to-do list
- Coherent actions create compounding effects

**Examples**:
- Weak: "Build feature A, improve feature B, launch campaign C"
- Strong: "Reduce onboarding to 3 questions (action 1), show personalized results immediately (action 2), measure drop-off at each step (action 3) — each action depends on the previous"

## Strategy vs. Non-Strategy

These are commonly mistaken for strategies but are not:

| Looks Like Strategy | Why It's Not |
|-------------------|-------------|
| Goals | "Grow 20% this quarter" describes a destination, not a path |
| Feature lists | A backlog is not a strategy — it lacks diagnosis and tradeoffs |
| Vision statements | "Be the best X" is aspiration, not analysis |
| Values | "We value quality" doesn't tell you what to do differently |
| Budgets | Resource allocation without diagnosis is just spending |

## How to Apply

1. Read the document and extract what you believe to be the Diagnosis, Guiding Policy, and Coherent Actions.
2. If any element is missing, flag it.
3. Run each element's test question.
4. Check that the three elements connect logically: Does the diagnosis motivate the policy? Does the policy constrain the actions? Do the actions implement the policy?
5. If the document is a list of goals or features disguised as strategy, name it directly.
