# Devil's Advocate

## What It Is

A structured protocol for pressure-testing decisions. Systematically challenges assumptions across 5 categories to surface risks before they become surprises. Works independently of personas — it tests the decision logic itself, not a stakeholder's perspective.

## When to Use

- Before committing to a major architectural or product decision
- When a proposal feels "obviously right" (highest risk of unchallenged assumptions)
- As a complement to persona-based critique (covers structural logic that personas may miss)
- When evaluating a go/no-go decision

## The Framework

### Step 1: State the Decision as a Falsifiable Statement

Convert the decision into a clear, testable claim.

- Weak: "We should build a notification system"
- Strong: "Building a real-time notification system will increase 7-day retention by 10% within 3 months of launch, at a cost of 4 engineering weeks"

The statement should be specific enough that you could look back in 6 months and say whether it was true or false.

### Step 2: Challenge Each Assumption Category

For each category, ask: "What would have to be true for this decision to fail?"

**Market Timing**
- Why now and not 6 months ago or 6 months from now?
- What market conditions does this assume will hold?
- Could a competitor move make this irrelevant before we ship?

**Competitive Response**
- How will competitors react to this?
- Does this create a sustainable advantage or a temporary one?
- Are we building something competitors can easily replicate?

**Resource Sufficiency**
- Do we actually have the skills, time, and budget to execute this?
- What else won't get done because we're doing this?
- What happens if it takes 2x longer than estimated?

**User Behavior**
- Are we assuming users will change a current habit? (They usually won't.)
- Have we validated that users want this, or are we inferring from indirect signals?
- What's the activation energy required for users to adopt this?

**Opportunity Cost**
- What's the best alternative use of these resources?
- If we do nothing, what happens?
- Is this the highest-leverage thing we could be doing right now?

### Step 3: Defend or Reconsider

For each challenge raised in Step 2:
- **If defensible**: State the defense clearly. Note what evidence supports it.
- **If not defensible**: Note the risk. Decide whether to mitigate, accept, or reconsider the decision.

### Step 4: Document the Result

Record:
- The original decision statement
- Top 3 challenges surfaced
- For each: defense, mitigation, or decision change
- Final disposition: Proceed / Proceed with mitigation / Reconsider

## How to Apply

1. Write the falsifiable statement (Step 1). If you can't make it falsifiable, the decision isn't clear enough yet.
2. Work through each assumption category (Step 2). Spend ~2 minutes per category. Skip categories that genuinely don't apply.
3. For the strongest challenges, defend or reconsider (Step 3).
4. Document the result (Step 4) so the reasoning is preserved.

Better to hear hard questions from AI than from your CEO.
