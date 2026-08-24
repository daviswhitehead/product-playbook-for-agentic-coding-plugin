---
plugin: product-playbook-for-agentic-coding
bump: minor
---

### Added
- **Component Inventory in `/playbook:tech-plan` and `/playbook:design-spec`** — before designing any UI, enumerate the existing components and tokens each surface will use, and put every proposed NEW component in an explicit table with its rationale: which existing component was considered, why extension fails, and what makes it general rather than one-off. An empty table is the good default. A plan that starts from a blank component tree quietly authorizes rebuilding what the project already has, and the drift is invisible at plan time because each new component looks reasonable in isolation.
- **Reuse-First Check in `/playbook:critique`** — a matching reviewer question ("does every proposed new component/style have a rationale an existing one couldn't satisfy?"), with the specific tells to flag: a missing inventory, rationales that are really an absence, non-concrete "why extension fails", one-off components dressed as general ones, and new styles that slipped the check. A missing inventory on a multi-surface UI plan is a P1 — it is the cheapest possible moment to catch duplication.
