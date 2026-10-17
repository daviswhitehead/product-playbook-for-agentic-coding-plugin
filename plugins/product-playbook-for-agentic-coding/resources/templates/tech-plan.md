# Tech Plan

## Project Overview
**Project Name**: [Project Name]
**Product Requirements**: [Link to Product Requirements]
**Date**: [Date]
**Version**: [Version]
**Size**: [Small | Medium | Large] *(From Product Requirements)*

### Size-Based Planning Guidance
The complexity and depth of this Tech Plan should match the project size:

**Small Projects**: Keep it simple and focused
- Minimal architecture documentation
- Direct, straightforward sequencing
- Use existing patterns and technologies
- Simple risk assessment

**Medium Projects**: Balanced approach
- Clear architecture with key components
- Phased sequencing with dependencies
- Some technology evaluation and rationale
- Comprehensive risk assessment

**Large Projects**: Comprehensive planning
- Detailed architecture with all components
- Multi-phase sequencing with critical paths
- Extensive technology evaluation and research
- Detailed risk assessment with mitigation strategies

## Technical Architecture

### System Overview
[High-level description of the system architecture]

### Architecture Diagram (Optional)
Use a concise diagram if helpful to visualize the system:
- Component diagram showing major parts and relationships
- Sequence or data flow for a critical path
- External integrations overview

### Core Components
**Component 1: [Name]**
- **Purpose**: [What this component does]
- **Key Responsibilities**: [Main functions]
- **Interfaces**: [How it interacts with other components]

**Component 2: [Name]**
- **Purpose**: [What this component does]
- **Key Responsibilities**: [Main functions]
- **Interfaces**: [How it interacts with other components]

### Data Models
[Key data models and relationships]

### API Design
[API structure and key endpoints]

## Sequencing

### Implementation Sequence
**Phase 1: [Phase Name]**
- **Objective**: [What this phase accomplishes]
- **Components**: [Components to be built]
- **Dependencies**: [What needs to be done first]
- **Deliverables**: [What gets delivered]

**Phase 2: [Phase Name]**
- **Objective**: [What this phase accomplishes]
- **Components**: [Components to be built]
- **Dependencies**: [Prerequisites]
- **Deliverables**: [What gets delivered]

**Phase 3: [Phase Name]**
- **Objective**: [What this phase accomplishes]
- **Components**: [Components to be built]
- **Dependencies**: [Prerequisites]
- **Deliverables**: [What gets delivered]

### Critical Path
[Sequence of work that must be done in order]

### Parallel Work Opportunities
- [Task A] and [Task B] can be done simultaneously
- [Task C] and [Task D] can be done simultaneously

## PR Strategy

**Estimated Scope**: [X files estimated]

**Budget** (stated here, before the first PR; `/playbook:close` reports actual against it):
- PRs: [N] · CI minutes: [≈ PRs × pushes per PR × lane cost — lane costs come from the project's CLAUDE.md or its CI-cost report] · LLM / eval spend: [$N or "none"] · Founder-gated merges: [N]

**Integration branch**: `[project]/integration`. Small slices land here locally (commits, not PRs); the project is reviewed **once** on it (REVIEW.md + a QA round), then ships as one PR per risk class cut from it.

**PR Boundaries** (required for Medium/Large projects). One PR per **risk class**, where the risk class is the pair (CI lane, merge gate). Not one per task:

| PR | Risk class: lane (what CI runs) | Gate (who merges, per Decision Rights) | What ships | Cost (CI cycles × min, eval runs) | Est. Files |
|----|---------------------------------|----------------------------------------|------------|-----------------------------------|------------|
| 1  | [frontend / agent behaviour / migration / workflows-only / docs-only] | [agent / founder] | [What ships] | [e.g. 1 full CI ≈ 45 min, 0 evals] | ~N files |
| 2  | [lane] | [gate] | [What ships] | [e.g. 1 full CI + 1 full eval ≈ $2] | ~N files |

Rules:
- **One PR per risk class.** Typical classes: agent/model behaviour (pays the eval gate), data migration (founder gate), frontend, workflows/scripts, docs. Two tasks in the same class ship in one PR.
- **No stacked PRs.** A stack multiplies CI cycles and freshness re-runs and breaks on squash merges. Sequence through the integration branch instead: if PR 2 needs PR 1's code, merge PR 1 first, then cut PR 2 from the updated integration branch.
- **Bundle prose with the code it describes** (docs, policy, README) unless it would drag the code PR to a slower gate.
- **A mixed PR pays for every lane.** Split it only when the split saves more CI than the second PR costs (a second PR is at least one full fast-CI run plus any preview builds).
- **Split hot files first.** If every feature appends to the same registry or CI config, plan the split in this phase so parallel projects stop colliding on it.
- **Fewer, fuller PRs beat many small ones** when review is by a solo founder: each PR is a review packet, a CI run and a preview environment. Evidence: one 11-day project planned 11 PRs and shipped 32, with stacks that collapsed on squash merges; its one PR built on a local integration branch and reviewed once was the cheapest per change. Projected for that project with this shape: 6–10 PRs (chef-chopsky shipping-velocity retro, 2026-10-12).

**Review Cadence**: [per-PR | per-phase | at merge]

**Note**: Each PR should be independently reviewable and shippable. For projects >100 estimated files, splitting into milestone PRs is mandatory.

## Testing Strategy

### Lanes (each test lives in exactly one)
If the project has a test-portfolio policy, follow it and cite it here; these are the defaults.

| Lane | Contents | Runs when | Blocks merge? | Budget |
|------|----------|-----------|---------------|--------|
| **Deterministic gate** | lint, typecheck, unit, deterministic integration, stubbed E2E | every head: touched tests first, full suite once at ready (CI) | yes | [≤ N min wall, e.g. 15] |
| **Live-model** | evals, live-model integration/E2E | once per agent-behaviour change set, plus nightly | only agent-behaviour PRs | [$N / month] |
| **Health** | quota/billing probes, tracing caps, prod smoke | preflight (seconds) before live jobs; cron | no — opens an issue | – |

A health failure (dead key, exhausted quota) must never cost a full deterministic run: live jobs probe dependencies first and fail in seconds with "billing, not code".

### Test Types and Coverage
- **Unit Tests**: [Coverage approach]
- **Integration Tests**: [Coverage approach]
- **End-to-End Tests**: [Coverage approach]

### New tests (each names the risk it protects)
| Test | Lane | Layer (lowest that can fail for this bug) | Risk / journey it protects | Why not a lower layer |
|------|------|-------------------------------------------|----------------------------|-----------------------|
| [name] | [lane] | [unit / integration / E2E / eval] | [risk] | [only for E2E and live-model tests] |

A test that can't name its risk is cost without coverage: each E2E test adds wall time to every future run. A new eval scenario or guard is seen failing once before it is trusted.

### Test Environment Requirements
- [Test environment setup requirements]
- [Mock vs real service usage strategy]
- [Test data management approach]
- **Runtime parity**: [Which tests run the *built* artifact with the production start command,
  preloads/instrumentation and flags? Dev servers (`tsx`, `next dev`) and test runners are
  different programs. If this plan touches boot, instrumentation/APM, streaming or callbacks,
  name the check that runs under the production start command.]
- **Truth-surface acceptance**: [For anything measured/emitted: the consuming query or record
  that must read a correct non-null value, in production, after deploy.]

## Technology Stack

### Core Technologies
- **Frontend**: [Technology choice with rationale]
- **Backend**: [Technology choice with rationale]
- **Database**: [Technology choice with rationale]

### Tools and Services
- **Development Tools**: [Tool choices]
- **Third-Party Services**: [External services]
- **Infrastructure**: [Hosting, deployment choices]

### Rationale
[Why these technology choices were made]

## Integration Approach

### External Dependencies
**Service 1: [Name]**
- **Purpose**: [What it provides]
- **Integration Type**: [API, SDK, etc.]
- **Data Flow**: [How data flows]

**Service 2: [Name]**
- **Purpose**: [What it provides]
- **Integration Type**: [API, SDK, etc.]
- **Data Flow**: [How data flows]

### API Contracts
[Key API contracts and interfaces]

## Untrusted Inputs & Executing Paths
*(REQUIRED whenever the feature reads email, web pages, feeds, or user text. Otherwise write "None: no untrusted text is read.")*

| Untrusted input | Steps that can execute code or file work for an executing agent | Gate between them |
|-----------------|------------------------------------------------------------------|-------------------|
| [e.g. inbound email body] | [e.g. agent that edits the repo and runs tests] | [e.g. LLM picks one of N enum actions; code validates and applies] |

**Default design: the LLM decides, deterministic code acts.** The LLM chooses from a closed set of structured options; deterministic code applies the change and opens a draft PR; no LLM with a shell ever sees untrusted text. Sanitizers and allowlists are a second layer, not the gate. *(chef-chopsky, 2026-10-11 → 10-17: 7 security-review rounds across two features each patched sanitizers and allowlists, until the executor was restructured so no LLM had Bash.)*

## Technical Risks

**Risk 1: [Description]**
- **Impact**: [What this affects]
- **Probability**: [Likelihood]
- **Mitigation**: [How to address]

**Risk 2: [Description]**
- **Impact**: [What this affects]
- **Probability**: [Likelihood]
- **Mitigation**: [How to address]

## Performance Considerations

**Scalability Plan**: [How the system scales]

**Performance Targets**: [Key performance metrics]

**Optimization Strategy**: [How to optimize]

## Architectural Decisions

**Decision 1: [Topic]**
- **Context**: [Why this decision was needed]
- **Options Considered**: [Alternatives]
- **Decision**: [What was chosen]
- **Rationale**: [Why this was chosen]

---

*This document focuses on How - planning the technical approach and implementation order.*
