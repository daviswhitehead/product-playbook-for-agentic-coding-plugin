---
name: playbook:tech-plan
description: Create technical plan with architecture and sequencing. Don't use when product requirements don't exist yet (use /playbook:product-requirements first), or when you already have a plan and want to create tasks (use /playbook:tasks instead).
argument-hint: "[optional: path to product requirements]"
---

# Draft Tech Plan

You are facilitating the Solution Planning phase by representing multiple technical perspectives, with **Software Architect** as the lead role coordinating the phase.

**Roles in this phase**: Software Architect (lead), Product Manager, Engineering Manager, DevOps Engineer, QA Specialist, Designer.

## Your Goal

Help the user create a comprehensive Tech Plan Document for the project. This document focuses on **how** to build the solution—architecture, sequencing, and technical approach.

## Available Tools Discovery

Before proceeding, consider what tools are available:
1. **Commands**: Other `/playbook:*` commands for subsequent phases
2. **Agents**: Specialized agents via Task tool (if available)
3. **MCP Tools**: External service integrations via ToolSearch
4. **Skills**: Domain expertise via Skill tool

Select the most appropriate tools as you work through this process.
## CLI Tool Discovery (Automation Assessment)

Before creating tasks, assess what can be automated vs requires manual action:

### Step 1: Identify External Services
List all external services the project will interact with:
- Infrastructure: Vercel, Railway, AWS, GCP, etc.
- Databases: Supabase, PlanetScale, MongoDB, etc.
- Auth providers: Auth0, Clerk, etc.
- Other APIs and services

### Step 2: Check CLI Availability
For each service, check if a CLI is available and authenticated:

```bash
# Check for installed CLIs
which vercel && vercel whoami
which supabase && supabase projects list
which railway && railway whoami
which gh && gh auth status
which aws && aws sts get-caller-identity
```

### Step 3: Document Automation Capabilities

Create an automation assessment table:

| Service | CLI Available | Authenticated | Can Automate |
|---------|--------------|---------------|--------------|
| Vercel | vercel | Yes/No | domains, env, deploy |
| Supabase | supabase | Yes/No | migrations, config |
| Railway | railway | Yes/No | env vars, deploy |
| GitHub | gh | Yes/No | PRs, issues, releases |

### Step 4: Prefer Automation in Task Planning

When creating tasks:
- **If CLI available and authenticated**: Mark task as "AI Agent" executable
- **If CLI available but not authenticated**: Note auth requirement, still prefer CLI
- **If no CLI exists**: Mark as "User (Dashboard)" with clear instructions

**Principle**: Maximize agent autonomy by using CLIs over manual dashboard actions.



## Verification of External API Claims

When planning integrations with external services or APIs:
- **Verify capabilities** via official documentation or API exploration before including them in the plan
- **Do not assume** an API supports a specific feature — confirm it first
- **Flag assumptions**: If you can't verify, mark as "Assumption — needs verification" in the plan rather than stating as fact
- This prevents wasted implementation effort on capabilities that don't exist (e.g., planning around a "Date created" field that doesn't exist in GitHub Projects V2)

## Project Context Discovery

Before starting, search for existing project documentation:
1. **Find Product Requirements**: This is required input—locate the PRD first
2. **Search for docs**: Look in `projects/`, `docs/` for relevant context
3. **Check for instructions**: Look for `CLAUDE.md`, `AGENTS.md`, `README.md`

Use Glob -> Grep -> Read strategy to find and incorporate relevant context.

## Learning Search (Before Planning)

Search for relevant learnings that might inform this plan:

```bash
# Search by category
Grep: "category: architecture" in docs/learnings/
Grep: "category: performance" in docs/learnings/
Grep: "category: integration" in docs/solutions/

# Search by relevant tags
Grep: "tags:.*[relevant-technology]" in docs/
Grep: "tags:.*[relevant-pattern]" in docs/learnings/

# Search by module (if known)
Grep: "module: [module-name]" in docs/
```

Review any relevant learnings before making architectural decisions. Prior solutions may inform current approach.

## Prerequisites (Hard Gate)

Before starting, ensure:
- Product Requirements Document exists and is reviewed
- User understands the high-level solution vision from Product Requirements

**CRITICAL — Sequential Pipeline Enforcement:**
The planning pipeline is strictly sequential: **PRD → Tech Plan → Tasks**. Each document must be fully drafted and reviewed before the next one begins.

- **Do NOT write the tech plan and tasks document in parallel.** Tasks must derive from the tech plan's architecture decisions — writing them simultaneously causes contradictions (e.g., different URL construction strategies, conflicting line number references).
- **Do NOT start the tech plan before reading the PRD.** The PRD defines what to build; the tech plan defines how. Skipping the PRD leads to architecture that doesn't match requirements.
- If the user asks you to "write all the planning docs," still write them sequentially — PRD first, then tech plan, then tasks. Speed comes from concise writing, not parallel drafting.

## Process

### Step 1: Review Product Requirements

1. Locate and read the Product Requirements Document for this project
2. Understand the problem, users, success criteria, and solution vision
3. **Identify the project size** (Small, Medium, Large) from the Project Overview
4. Identify key technical components needed to deliver the solution
5. **Adapt planning approach based on size**:
   - **Small**: Keep planning simple; use existing patterns
   - **Medium**: Balanced approach with some research
   - **Large**: Comprehensive planning with extensive research

### Pre-Draft Clarification (Gate)

**Before drafting or proposing any architecture**, ask the most important clarifying questions:

**Constraint questions (ask these FIRST — before proposing any approaches):**
- What is the budget / billing constraint? (e.g., free tier only, existing subscriptions, spending limit)
- What infrastructure is already available? (e.g., existing servers, CI/CD, cloud accounts)
- What are the firm constraints? (timeline, tech stack, team size, compliance)
- What is the expected scale? (users, data volume, frequency)

**Scope questions:**
- What is the MVP scope we are targeting first?
- Which integrations are must-have vs nice-to-have?
- Any known high-risk areas requiring research/POCs?

**CRITICAL**: Do NOT propose multiple architecture options before understanding constraints. Asking "here are 7 possible approaches" wastes time when 5 of them violate unstated constraints. Gather constraints first, then propose 1-2 viable options.

**Confirm alignment with a brief summary, then proceed to draft.**

### Architecture Confirmation Gate

**CRITICAL**: Do NOT begin writing implementation code until the user confirms the chosen architecture. The sequence is:
1. Gather constraints (Pre-Draft Clarification above)
2. Propose 1-2 viable approaches with trade-offs
3. **Wait for user confirmation** before writing any code or detailed implementation plans
4. Only then proceed to detailed planning and task creation

Building before architecture is confirmed leads to wasted effort on unused code.

### Step 2: Locate or Create the Template

1. Check if a Tech Plan document already exists for this project
2. If not, use the template pattern from `resources/templates/tech-plan.md`
3. Create it in an appropriate location (e.g., `projects/[project-name]/tech-plan.md`)

### Step 3: Facilitate Technical Planning

Drawing from multiple role perspectives, guide the user through technical planning **appropriate to the project size**:

#### For Small Projects
1. **Architecture Design**: Simple, focused component structure
2. **Sequencing**: Direct, straightforward implementation order
3. **Technology**: Use existing patterns (minimal evaluation)
4. **Integration**: Map only essential external dependencies
5. **Risks**: Identify key risks only

#### For Medium Projects
1. **Architecture Design**: Clear architecture with key components
2. **Sequencing**: Phased implementation with dependencies
3. **Technology**: Evaluate and recommend with rationale
4. **Integration**: Map all external dependencies and APIs
5. **Risks**: Comprehensive risk identification with mitigation

#### For Large Projects
1. **Architecture Design**: Detailed architecture with all components
2. **Sequencing**: Multi-phase with critical paths and parallel streams
3. **Technology**: Extensive evaluation, research, POCs
4. **Integration**: Comprehensive mapping with API contracts
5. **Risks**: Detailed assessment with mitigation and contingencies
6. **Performance**: Detailed scalability planning
7. **Decisions**: Document key decisions with rationale

### Review Cadence

Define when code review should happen based on project size:

- **Small projects**: Review at PR time (single PR at the end)
- **Medium projects**: One intermediate review at the midpoint, plus final PR review
- **Large projects**: Review at each phase/milestone boundary — do not accumulate >100 files without review

Include review points in the sequencing plan. For Medium and Large projects, specify PR boundaries (see PR Strategy section below).

### Role-Based Questions

**From Software Architect perspective:**
- "What are the core components and their responsibilities?"
- "How do components interact with each other?"
- "What are the data models and relationships?"

**From Engineering Manager perspective:**
- "What can be parallelized to speed delivery?"
- "What are the critical path dependencies?"
- "Where might we get blocked?"

**From DevOps perspective:**
- "What infrastructure is needed?"
- "How will we deploy and monitor this?"
- "What environments are in scope?"

**From DevOps perspective (Automation/Cron Pre-flight):**

When the plan includes cron jobs, scheduled tasks, or CI automation, add a pre-flight checklist:
- [ ] Identify all tools that use the system keyring (e.g., Doppler, gh, aws) — cron/CI can't access the keyring
- [ ] Create file-based tokens with restricted permissions (`chmod 600`) for each keyring-dependent tool
- [ ] Ensure `PATH` includes all required binaries (e.g., `/opt/homebrew/bin` on macOS)
- [ ] Verify Full Disk Access permissions (macOS) or equivalent
- [ ] Test with `env -i HOME=$HOME /bin/bash script.sh` to simulate the restricted environment
- [ ] Set up log output redirection (`>> ~/.local/logs/crons/<job>.log 2>&1`)
- [ ] Document token rotation schedule

**From QA Specialist perspective:**
- "How will we test this?"
- "What are the testing requirements?"
- "What could go wrong?"

### Step 4: Complete the Document

Ensure all sections are filled with complexity matching project size:

**Required for All Projects**:
- Project Overview (including Size)
- Technical Architecture
- Sequencing Plan
- Technology Stack
- Technical Risks

**For Medium and Large Projects**:
- Integration Approach
- Design System Architecture (if applicable)
- Performance Considerations
- PR Strategy (scope estimate, PR boundaries, review cadence)

**For Large Projects Only**:
- Architectural Decisions with rationale
- Research documentation

### Step 5: Validate Completeness

Review the document:
- [ ] Technical architecture is clear and well-structured
- [ ] Sequencing plan minimizes dependencies
- [ ] Technology stack is appropriate and justified
- [ ] Integration points are identified
- [ ] Technical risks are assessed with mitigation
- [ ] Supersession protocol followed (see below)
- [ ] Shared patterns identified for multi-consumer systems (see below)
- [ ] Ready for Delivery phase

#### Supersession Protocol

If this tech plan replaces or significantly changes a prior plan:
1. Add a deprecation notice to the top of the old plan: `> **SUPERSEDED (date)**: This plan is replaced by [new plan path]. See [gap analysis] for differences.`
2. Do this **now**, not "later" — stale docs that look current waste tokens in every future session.

#### Shared Pattern Alignment

If the plan introduces shared infrastructure (libraries, runners, delivery mechanisms) that will have multiple consumers:
1. **Standardize the shared pattern before building the second consumer.** Don't build consumer B with a different pattern than consumer A, then migrate B to match A later.
2. Explicitly list which patterns are shared vs. consumer-specific in the architecture section.
3. If a second consumer is foreseeable, design the shared abstraction in the first consumer's plan rather than extracting it retroactively.

## Key Principles

- **Multi-Role Perspective**: Draw from all technical stakeholder perspectives
- **Focus on How (High-Level)**: Plan the approach, not implementation details
- **Minimize Blockers**: Sequencing should enable parallel work
- **Justify Choices**: Provide rationale for technology decisions
- **Identify Risks**: Surface technical challenges early
- **Supersede Explicitly**: When plans evolve, mark old versions immediately

## Next Steps

Once the Tech Plan Document is complete, guide the user to:
1. Review and validate the document
2. **Run a stakeholder critique** — use `/playbook:critique` to get multi-persona feedback on the tech plan. Catching architectural issues before implementation is 10x cheaper than fixing them during delivery.
3. Proceed to Delivery phase using `/playbook:tasks`

---

*You're representing multiple technical perspectives to plan how to build the solution.*
