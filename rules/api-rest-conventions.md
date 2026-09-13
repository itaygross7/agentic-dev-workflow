---
paths:
  - "**/endpoints/**/*.py"
  - "**/routes*.py"
  - "**/*_router.py"
  - "**/*_lambda.py"
  - "**/server.py"
---

# REST API design rules (scoped)

Apply when adding or changing HTTP API endpoints. Complements `python-conventions`
(HTTPStatus/validation) and `security-boundaries` (input trust boundary).

## Resource design
- Model endpoints around resources (plural nouns), not actions: `/users/{id}`, not `/getUser`.
- Use HTTP verbs for intent: `GET` (read, safe/idempotent), `POST` (create/non-idempotent action),
  `PUT` (full replace, idempotent), `PATCH` (partial update), `DELETE` (idempotent remove).

## Pagination and filtering
- Paginate any collection endpoint (`limit`/`offset` or cursor-based); never return unbounded result sets.
- Use query parameters for filtering/sorting; keep filter semantics documented and consistent across endpoints.

## Versioning
- Version breaking changes explicitly (URI prefix `/v1/` or a version header/param); never silently break an existing response contract.

## Idempotency and retries
- For non-idempotent `POST` operations that create resources, support an idempotency key so clients can safely retry.

## Errors
- Return a consistent error envelope across all endpoints, e.g.
  `{"error": {"code": "invalid_request", "message": "...", "details": {}}}`.
- Use precise HTTP status codes; do not overload `200` for error cases or `500` for client errors.

## Done conditions
- New/changed endpoints follow existing resource naming and verb semantics in this codebase.
- Collection endpoints are paginated; error responses use the shared error envelope.

Source: Microsoft REST API Guidelines (github.com/microsoft/api-guidelines), RFC 9457 (Problem Details for HTTP APIs — obsoletes RFC 7807).
