---
name: improve-code
description: "Propose a targeted, justified improvement to existing code without changing behavior or interfaces. "
disable-model-invocation: true
---

Improve this code in a targeted, conservative way — no behavior change and no broken interfaces.

## Inputs needed
If missing, ask for them:
- File/function to improve.
- Callers of this function, if it's public/cross-component (or "n/a").

## Qualifying categories (only improve if one clearly applies)
- **Reliability**: real failure risk (broad except, missing resource cleanup, swallowed exception).
- **Conventions compliance**: violates an established repo convention.
- **Readability**: genuinely hard to follow — not just different from your preference.
- **Performance**: measurable complexity-class improvement on a known hot path.
- **Maintainability**: current shape will cause concrete problems as the code grows.

## Required output (one improvement per response)
1. `WHY` — one sentence: the concrete benefit and category.
2. `EXISTING` — the complete current function/class, with the problem annotated inline (`# <-- PROBLEM: reason`).
3. `REPLACE WITH` — the complete improved function/class, with changed lines marked `# CHANGED` and added lines marked `# ADDED`.

## Constraints
- Do not change observable behavior or any interface/signature/return type.
- Do not bundle unrelated improvements into one output.
- Do not introduce new dependencies or speculative abstractions.
- Do not rename for preference alone; only rename when the current name is genuinely misleading.
- If the same pattern appears in multiple places, say so — it probably needs a shared helper rather than a one-off fix.
