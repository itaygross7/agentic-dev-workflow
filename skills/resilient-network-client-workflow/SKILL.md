---
name: resilient-network-client-workflow
description: Build or harden an outbound HTTP/network client with timeouts, retries, backoff, and connection reuse. Use when writing a new API client, webhook caller, or any code that makes outbound network calls.
---

# Resilient Network Client Workflow Skill

Use when building a new outbound client (REST API caller, webhook sender, internal service client). It complements `networking-fundamentals`, which is for diagnosing existing connectivity issues.

## Workflow
1. **Start with failure modes**
   - Enumerate DNS failure, connect timeout, slow response, 4xx, 5xx, connection reset mid-stream, and decide behavior for each before writing the call.
2. **Set explicit timeouts and reuse connections**
   - Put both connect and read timeouts on every call; reuse a session/connection pool for the same host (see `networking-security`).
3. **Classify errors before retrying**
   - Retry only idempotent operations on transient failures (timeout, connection error, 5xx); never blindly retry a non-idempotent `POST` or a 4xx.
   - Use bounded retries with exponential backoff and jitter; respect `Retry-After` when present.
4. **Validate any user-influenced destination**
   - If host/URL comes from user input, allowlist expected hosts/schemes and reject internal/private IP ranges and metadata endpoints (SSRF — see `networking-security`).
5. **Decide on a circuit breaker only when justified**
   - For a frequent critical-path dependency, consider tripping a circuit after consecutive failures. Don't add this complexity without a concrete need.
6. **Verify**
   - Test a simulated timeout, a 5xx-then-success retry, and a 4xx no-retry case with mocked transport — not live calls in unit tests.
7. **Report**
   - Summarize chosen timeout/retry values and tested failure modes.

## Guardrails
- Never use an infinite/default timeout on an outbound call.
- Never retry a non-idempotent operation without an idempotency key.
- Never disable TLS verification outside isolated local development.

## Completion checklist
- [ ] Every outbound call has explicit connect and read timeouts.
- [ ] Retries are bounded, backed off, and limited to idempotent/transient-failure cases.
- [ ] User-influenced destinations are validated against an allow/deny list.
