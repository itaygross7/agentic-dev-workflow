---
name: code-review-standards
description: "Review-time priority order and severity flagging for Python changes: correctness -> security -> error handling -> tests -> maintainability, flagged as must-fix/should-fix/nice-to-have. Apply when reviewing, auditing, or critiquing a diff or PR — this is what the code-reviewer agent follows."
---

# Code review emphasis (Copilot code review)

Governs review-time flagging only: GitHub's automated PR code-review bot, and the `code-reviewer`
agent (which references this file instead of restating it). During normal authoring, follow
`python-conventions`/`code-quality` — this file's role is judging already-written
diffs, not producing new code.

## Review priority
1. Correctness and regressions
2. Security and input boundary safety
3. Error handling and observability
4. Test coverage for changed behavior
5. Maintainability and clarity

## Flag as must-fix when present
- Broad exception swallowing (`except:`/`except Exception:` with no comment justifying it,
  or caught-and-logged-then-ignored as if the operation still succeeded)
- `try` block wrapping more than the line(s) that can actually raise (masks which call failed)
- Unvalidated external input at boundaries
- Secret/token/PII leakage in code, logs, or error responses
- Path traversal risk in file operations
- Resource opened without a context manager (file, DB connection, HTTP session, lock)
- Missing timeout on a network/IO call
- Contract-breaking API changes without coordinated updates to callers
- Behavior changes without matching tests
- Stack trace, internal file path, or raw exception text returned to an external caller

## Flag as should-fix when present
- N+1 query pattern inside a loop that could be batched
- Entire dataset loaded into memory when pagination/filtering is available
- Dead code path that exists only to support a test patch
- Logic duplicated across modules that should be a shared helper
- File exceeds ~1000 lines — ask whether it has more than one responsibility

## Review tone
- Be specific and actionable — name the file/function/line for every finding.
- Focus on real defects over style preferences; acknowledge what's done well.
- Label findings by severity (must-fix / should-fix / nice-to-have) rather than treating
  everything as equally urgent.
