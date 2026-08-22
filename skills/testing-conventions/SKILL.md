---
name: testing-conventions
description: "Pytest authoring conventions: coverage of success/failure/boundary cases, test isolation, assertion discipline, regression-test requirements. Apply when creating or modifying tests."
---

# Test authoring rules (scoped)

Apply when creating or modifying tests.

## Framework and style
- Use `pytest` conventions already present in this repository.
- Keep tests independent and deterministic.
- Name tests by behavior (`test_<unit>_<condition>_<expected>`).

## Coverage expectations
- Cover at least:
  - Success path
  - Expected failure/exception path
  - Boundary/edge input relevant to the change
- For bug fixes, add a regression test that fails before the fix and passes after it.

## Isolation
- Mock or stub network, external APIs, queues, filesystem, and time-dependent behavior when not under explicit integration test scope.
- Avoid real external calls in unit tests.
- Never share mutable state between tests; every test must be runnable independently and
  in any order. Keep shared fixtures minimal — only what every test in the group needs.

## Assertions
- Assert externally observable behavior (output, side effects, contract), not fragile implementation details.
- If a function has side effects (DB write, external call), assert the side effect
  happened (or was called with the right arguments), not just the return value.
- Never write a test with no assertion — an empty/`pass`-only test body is silent noise,
  not coverage.

## Done conditions
- Tests are readable and focused on one behavior per test.
- New/changed logic is covered by targeted tests.
- Relevant local test command passes.
- No test-only code paths were added to production modules to make something patchable —
  patch the real implementation instead.
