---
name: plan-change
description: "Create a design-first implementation plan with options, risks, and explicit done criteria. "
disable-model-invocation: true
---

You are in planning mode. Do not write implementation code — skeletons only (signatures, not bodies), so scope is locked before execution. If it is unclear who or what should own this, resolve that with `agent-routing` first.

## Task
State the change request being planned. If it isn't clear yet, ask for it.

## Context required before planning
Stop and ask for anything missing:
- The module(s) the change lives in or touches.
- Any interface/contract/API boundary the change must respect.
- Config/env vars relevant to the change.
- If adding a new component, the existing component most similar to it so the design matches current patterns.

## Required output
1. **Goal** — one testable sentence.
2. **Current system context** — components, data flow, dependencies, patterns being extended. Flag module-level mutable globals or shared state as design risks.
3. **Constraints and risks** — what must not change (public interfaces, cross-component contracts, existing behavior). State explicitly: *"This design could break if ..."*. Include security-boundary implications and async/concurrency risk when relevant.
4. **Options** (minimum 2; any option with new/changed structure must include skeletons: file plus class/function signatures with type hints, bodies as `...`):
   - **Option A (Minimal)** — smallest footprint, reuses existing abstractions.
   - **Option B (Balanced)** — slightly broader, still conservative.
   - **Option C (Structural)** — only if A/B are insufficient; requires explicit approval before implementation.
5. **Trade-off matrix** — rows: risk, scope of impact, regression likelihood, complexity added, security-boundary impact; columns: each option.
6. **Recommendation** with rationale.
7. **Ordered implementation stages** with a verification step per stage (test/command/observable). No stage should leave the tree broken.
8. **Definition of done** — explicit, testable checklist.
9. **Open questions** — anything blocking a clean implementation; do not hide gaps with assumptions.

## Planning rules
- Read the actual code; never assume structure or behavior.
- Prefer the smallest change footprint that satisfies requirements.
- No implementation code in this phase — skeletons only, to prevent "planned X, built Y" drift.
- Put unknowns under "Open questions" instead of guessing.
- Include security, testing, and backward-compatibility checks.
