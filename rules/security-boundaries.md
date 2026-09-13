---
paths:
  - "**/endpoints/**/*.py"
  - "**/routes*.py"
  - "**/server.py"
  - "**/*_lambda.py"
  - "**/*auth*.py"
  - "**/token_verification.py"
---

# Security boundary rules (scoped)

Apply at HTTP and worker boundaries.

## Input handling
- Treat all external input as untrusted.
- Validate and normalize at the boundary before calling service/domain code.
- Reject unexpected content-types/oversized payloads before parsing (explicit max body size).
- Validate structure against a schema/model at the boundary — never pass a raw unvalidated
  dict deeper into the call stack.

## Authentication and authorization
- Authenticate before authorizing; never infer identity from client-supplied fields
  (headers, body, query params) without verifying a trusted token/session first.
- Enforce authorization (ownership/role/scope) at the boundary for every handler that
  touches another user's or tenant's data — a valid token proves identity, not permission.
- Fail closed: on missing/ambiguous auth state, deny by default rather than falling back to
  an permissive path.

## Error exposure
- Return safe, generic external error messages.
- Keep detailed internals in logs only.

## File and path safety
- Resolve and validate paths before file access.
- Reject path traversal attempts (`..`, absolute path jumps, unsafe joins).

## Queue and async safety
- Handle malformed payloads explicitly.
- Preserve idempotency for retryable operations when possible.

## Done conditions
- Boundary handlers reject invalid input, wrong content-type/size, and unauthorized access predictably.
- No sensitive data leaks through responses or logs.
