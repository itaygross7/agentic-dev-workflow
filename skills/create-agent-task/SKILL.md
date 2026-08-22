---
name: create-agent-task
description: "Generate a locked, execution-ready task brief for delegated agent work. Use once the approach is already decided (e.g. after plan-change picked an option, or the change is small enough not to need planning) — not for another option-comparison round."
disable-model-invocation: true
---

Build a precise implementation brief for delegated execution. Use this once the approach is already decided (for example after `plan-change` picked an option, or when the change is small enough not to need planning). This creates the final locked brief to hand to `code-creator`/`code-improver`, not another option-comparison round.

## Inputs needed
If missing, ask for them:
- Change request — what should be built/fixed.
- Scope limits — what must not change.
- Validation target — tests/commands/acceptance checks.

## Produce
1. Locked task statement (1-2 sentences) — precise enough that a passing test could be written against it; if not, ask for the missing specificity.
2. Change magnitude classification (surgical/surgical+ improvement/targeted/structural — see the `disciplined-change-workflow` skill, or `python-implementation-workflow` for Python specifics) with a one-line justification.
3. Context: codebase location, entry point, sibling modules/patterns to match, relevant shared models/contracts, external dependencies already in use.
4. File-level scope (touch / do-not-touch), including standing prohibitions: no breaking a cross-component API unless required, no new dependency without saying why existing ones do not solve it, no duplicate logic, no speculative abstractions (YAGNI).
5. Ordered stages with, per stage: what changes, why, how to verify it landed, and what breaks if it is wrong.
6. Plan-completion checklist (one line per stage confirming it landed) and an edge-case checklist (empty/zero/negative/boundary/`None`-where-allowed/retry-safety for the changed path).
7. Definition of done checklist (type hints, tests for changed behavior, no new security regressions, no cross-component break unless required).
8. Verification commands to run (tests, import/lint checks relevant to this repo).
9. Security & logging spot-check: no secret/PII in logs, no path traversal, no raw exception text to external callers, every `except` logs or is justified.
10. Risks and "could break if" notes.

## Constraints
- Keep the task self-contained — the agent should not need a follow-up.
- Avoid ambiguous verbs ("improve", "optimize") without a measurable outcome.
- Include security and regression checks.
- No implementation code in the brief itself — signatures/skeletons only if structure is part of the ask.
