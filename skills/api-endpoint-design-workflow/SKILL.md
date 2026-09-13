---
name: api-endpoint-design-workflow
description: Lock the contract (resource, verb, path, request/response schema, status codes, edge cases) for a new or changed REST endpoint before implementation. Use when asked to "design"/"add"/"change" an endpoint from scratch. NOT for the code-change execution once the contract is locked (use python-implementation-workflow) or a convention check on an already-designed route (use api-rest-conventions).
---

# API Endpoint Design Workflow Skill

Use when adding a new REST endpoint or materially changing an existing contract. It complements `~/.claude/rules/api-rest-conventions.md` (enforceable rules) and `python-implementation-workflow` (general Python execution process).

## Workflow
1. **Lock the contract**
   - Write down the resource, verb, path, request schema, response schema, and status codes before coding.
   - Confirm whether the change is additive (safe) or breaking (needs versioning) for existing clients.
2. **Check for reuse**
   - Look for an existing resource/router/schema pattern in `src/api` instead of inventing a new convention.
3. **Design edge cases**
   - Decide exact status codes and error-envelope shapes for not-found, validation failure, auth/authz failure, pagination bounds, and idempotent retry for POST.
4. **Implement in order**
   - Request schema/validation at the boundary -> service call -> response schema/serialization -> error mapping.
   - Keep validation at the boundary (per `~/.claude/rules/security-boundaries.md`); do not push raw untrusted input into service/domain logic.
5. **Verify**
   - Add or extend tests for happy path, each validation failure, auth failure, and pagination/edge bounds (per `testing-conventions`).
   - Manually exercise the endpoint (`curl`/httpie) to confirm the actual response shape matches the design.
6. **Report**
   - Summarize the endpoint contract, versioning impact, and tests added.

## Guardrails
- Never skip pagination on a collection endpoint.
- Never return raw internal exception details in the response body.
- Never change an existing endpoint's response shape without versioning or explicit approval.

## Completion checklist
- [ ] Contract (path/verb/schemas/status codes) matches what was locked in step 1.
- [ ] Validation happens at the boundary, not deep in service code.
- [ ] Tests cover happy path, validation failure, and auth failure.
- [ ] Versioning handled if the change is breaking.
