# Morning Insights Report

**Date**: {{run_date}}
**Sessions Analyzed**: {{sessions_analyzed}} of {{total_available}} available
**Ideas Generated**: {{ideas_generated}}
**Pipeline Cost**: ${{total_cost}}

---

## Goal Tracking

Track progress against the three north-star metrics. Trend direction matters more than absolute values at this stage.

| Goal | Metric | Current | Previous | Trend |
|------|--------|---------|----------|-------|
| D7 Return Rate | % of users who return within 7 days | {{d7_return_current}} | {{d7_return_previous}} | {{d7_return_trend}} |
| Satisfaction Score | Thumbs up ratio | {{satisfaction_current}} | {{satisfaction_previous}} | {{satisfaction_trend}} |
| Sessions per User | Avg weekly sessions per user | {{sessions_per_user_current}} | {{sessions_per_user_previous}} | {{sessions_per_user_trend}} |

**Goal commentary**: Brief narrative on goal movement and what's driving it. 2-3 sentences.

---

## Executive Summary

{{executive_summary}}

*Tone: Direct, actionable, no filler. 3-5 sentences maximum. Lead with the most important insight.*

---

## RICE Ranked Ideas (Top 15)

Non-duplicate ideas sorted by Score descending. Maximum 15 entries.

| Rank | Idea | Category | Score | Designation | Classification |
|------|------|----------|-------|-------------|----------------|
| 1 | ... | ... | ... | ... | ... |

*Include source persona for each idea. Flag cross-session patterns.*

---

## Highlights Summary

{{highlights_summary}}

*Aggregate the best moments across all analyzed sessions. What's working well? 3-5 bullet points.*

---

## Lowlights Summary

{{lowlights_summary}}

*Aggregate the friction points across all analyzed sessions. What needs improvement? 3-5 bullet points with improvement questions.*

---

## Self-Observations

{{self_observations}}

*Pipeline's assessment of its own analysis quality this run. Evidence validation rate, common patterns, confidence in findings. 2-3 sentences.*

---

## Run Metadata

| Metric | Value |
|--------|-------|
| Run ID | {{run_id}} |
| Trigger | {{trigger}} |
| Duration | {{duration}} |
| LLM Calls | {{total_llm_calls}} |
| Input Tokens | {{total_input_tokens}} |
| Output Tokens | {{total_output_tokens}} |
| Cost Estimate | ${{total_cost}} |
| Evidence Validation Rate | {{evidence_validation_rate}} |
| Duplicate Ideas Filtered | {{duplicates_filtered}} |

---

## Data Quality Notes

{{data_quality_notes}}

*Note any data gaps, unavailable services, or quality concerns. If PostHog was unreachable, note it here. If LangSmith traces were missing, note it here.*
