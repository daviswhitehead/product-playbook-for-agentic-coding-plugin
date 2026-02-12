# Session Analysis Template

## Purpose

This template defines the expected output format for per-session analysis (Stage 3). Each session produces highlights, lowlights, and improvement ideas grounded in direct evidence.

## Output Schema

The analysis must produce a JSON object matching this structure:

```json
{
  "highlights": [
    {
      "description": "Brief description of what went well (1-2 sentences)",
      "evidence": "Direct quote or [bracketed paraphrase] from transcript",
      "goalLinkage": "d7_retention | satisfaction | engagement | none"
    }
  ],
  "lowlights": [
    {
      "description": "Brief description of what went wrong or was missed (1-2 sentences)",
      "evidence": "Direct quote or [bracketed paraphrase] from transcript",
      "improvementQuestion": "A specific 'How might we...' or 'What if...' question",
      "goalLinkage": "d7_retention | satisfaction | engagement | none"
    }
  ]
}
```

## Evidence Quoting Standards

- **Verbatim quotes**: Use the exact text from the transcript when possible. Enclose in quotation marks.
  - Example: `"I already told you I'm gluten free"`
- **Bracketed paraphrases**: When the evidence spans multiple messages or requires summarization, use brackets.
  - Example: `[User asked about chicken recipes three times, each time receiving the same generic response]`
- **Message references**: Include the approximate message position when helpful.
  - Example: `"What about allergies?" (message 4)`

## Goal Linkage Options

Each highlight and lowlight must be tagged with one of these goals:

| Tag | Meaning | When to use |
|-----|---------|-------------|
| `d7_retention` | Drives or harms 7-day return rate | Experiences that determine whether the user comes back |
| `satisfaction` | Affects user satisfaction | Quality of the agent's response, helpfulness, accuracy |
| `engagement` | Influences session depth/frequency | Features that encourage exploration or repeat usage |
| `none` | No clear goal linkage | Observations that are informative but not goal-linked |

## Example Output

```json
{
  "highlights": [
    {
      "description": "Agent correctly remembered the user's preference for spicy food and incorporated it into recipe suggestions",
      "evidence": "Agent: 'Since you like spicy food, here's a Szechuan chicken recipe...' (message 6)",
      "goalLinkage": "satisfaction"
    }
  ],
  "lowlights": [
    {
      "description": "Agent did not check dietary restrictions before suggesting a recipe containing dairy",
      "evidence": "[User mentioned being lactose intolerant in a previous session, but agent suggested a cream-based sauce]",
      "improvementQuestion": "How might we ensure the agent checks user_memory for dietary restrictions before every recipe suggestion?",
      "goalLinkage": "d7_retention"
    }
  ]
}
```

## Analysis Guidelines

1. Aim for 2-5 highlights and 2-5 lowlights per session. Quality over quantity.
2. Every finding must have evidence — no unsupported claims.
3. Lowlights should always include an improvement question that is specific and actionable.
4. Prefer findings that suggest a product change over observations about individual user behavior.
5. Do not include PII (real names, emails, user IDs) in the analysis output.
