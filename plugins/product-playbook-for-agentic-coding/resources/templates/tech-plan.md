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

**PR Boundaries** (required for Medium/Large projects). Shape PRs by **CI lane** and **review gate**, not by task:

| PR | Lane (what CI runs) | Gate (who merges) | Phase/Milestone | What ships | Est. Files |
|----|---------------------|-------------------|-----------------|------------|------------|
| 1  | [frontend / agent / workflows-only / docs-only / mixed] | [autonomous / founder] | [Phase name] | [What ships] | ~N files |
| 2  | [lane] | [gate] | [Phase name] | [What ships] | ~N files |

Rules:
- **One PR per (lane, gate) cell per phase.** Two tasks that hit the same lane and the same gate ship in one PR unless one would block the other's review.
- **Bundle prose with the code it describes** (docs, policy, README) unless it would drag the code PR to a slower gate.
- **Stack only when a founder gate would otherwise block autonomous work.** Never delete the base branch of a stack when merging it.
- **A mixed PR pays for every lane.** Split it only when the split saves more CI than the second PR costs (a second PR is at least one full fast-CI run plus any preview builds).
- **Fewer, fuller PRs beat many small ones** when review is by a solo founder: each PR is a review packet, a CI run and a preview environment. Evidence: one session shipped 31 PRs where ~4 would have done; that repo's trailing-28-day read was 89.5 CI minutes per merged PR (chef-chopsky, 2026-10-06 retro).

**Review Cadence**: [per-PR | per-phase | at merge]

**Note**: Each PR should be independently reviewable and shippable. For projects >100 estimated files, splitting into milestone PRs is mandatory.

## Testing Strategy

### Test Types and Coverage
- **Unit Tests**: [Coverage approach]
- **Integration Tests**: [Coverage approach]
- **End-to-End Tests**: [Coverage approach]

### Test Environment Requirements
- [Test environment setup requirements]
- [Mock vs real service usage strategy]
- [Test data management approach]

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
