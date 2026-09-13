---
paths:
  - "**/*.py"
---

# Python implementation rules (scoped)

Apply these when editing Python files.

## Keep changes surgical
- Edit only files/functions required by the task.
- Avoid unrelated refactors.

## Contracts and typing
- Add type hints to new or changed function signatures.
- Keep function signatures and return contracts backward compatible unless the task requires a breaking change.
- Prefer explicit domain models for structured payloads over ad-hoc dictionaries across boundaries.
- Prefer raising a named exception on failure over returning `None`/a sentinel value — it
  forces every caller to remember a None-check instead of handling failure explicitly.
- More than ~3 positional parameters is a signal to group related data into a model
  instead of adding more parameters.
- Never use a mutable default argument (`def f(items=[])`); default to `None` and assign
  inside the function body.

## Error handling
- Catch specific exceptions where recovery is meaningful.
- When translating exceptions, chain them (`raise ... from e`).
- Do not silently swallow failures.
- Keep `try` blocks scoped to only the line(s) that can actually raise — wrapping an
  entire function body in one `try` masks which call failed.

## Logging
- Use module loggers (`logging.getLogger(__name__)`).
- Log contextual identifiers; do not log secrets or sensitive user content.
- Include enough context to reproduce the issue without a debugger (e.g. relevant IDs),
  not just a bare message string.

## Web/API conventions
- Use `HTTPStatus` constants in route responses instead of bare status integers in new/changed code.
- Validate request payloads before they reach service logic.

## Maintainability
- Reuse existing repository patterns and helpers first.
- Keep function responsibilities focused.
- Introduce new dependencies only when existing libraries cannot solve the task.
- Do not mutate a function's input arguments; operate on a copy if a change is needed.
- Standard library first, then third-party, then internal imports, separated by blank
  lines; avoid imports inside function bodies except for documented circular-import/
  optional-dependency workarounds.
- Do not leave `TODO`/`FIXME` comments without a ticket reference or a one-line
  explanation of the blocker.

## Done conditions
- Behavior is correct for happy path and failure path.
- Relevant tests are added/updated for changed behavior.
- No new security regressions are introduced.
