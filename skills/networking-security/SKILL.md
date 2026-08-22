---
name: networking-security
description: "Outbound network-call rules: explicit connect+read timeouts, TLS verification on, SSRF validation of user-influenced URLs, bounded retries with backoff. Apply when writing or reviewing outbound HTTP client/socket code, or a prompt mentions calling an external API or URL — triggers on topic, not file path. Complements security-boundaries (inbound). For building a resilient client from scratch see resilient-network-client-workflow."
---

# Networking & outbound security rules (scoped)

Apply when writing code that makes outbound network calls (HTTP clients, sockets, webhooks).
Complements `security-boundaries`, which covers inbound HTTP/worker boundaries.

## Outbound HTTP safety
- Always set both connect and read timeouts on outbound requests (e.g. `requests.get(url, timeout=(3, 10))`); never use an infinite/default timeout.
- Never disable TLS verification (`verify=False`) outside a fully isolated local dev environment; keep certificate and hostname verification on.
- Reuse a `requests.Session` (or equivalent connection-pooled client) for repeated calls to the same host instead of opening a new connection per request.
- Cap redirect following and treat unexpected redirect targets as suspicious.

## SSRF prevention
- If a URL/host is derived from user input, validate it against an allowlist of expected hosts/schemes before making the request.
- Reject requests to internal/private IP ranges (loopback, link-local, RFC1918) and cloud metadata endpoints (e.g. `169.254.169.254`) unless the destination is explicitly intended to be internal.
- Resolve DNS once and re-validate the resolved IP where feasible to avoid DNS-rebinding bypasses of an allowlist.

## Error handling
- Distinguish connection/timeout errors from HTTP error responses; do not treat all failures identically when deciding whether to retry.
- Use bounded retries with exponential backoff and jitter for idempotent calls; never retry non-idempotent calls blindly.

## Done conditions
- Every outbound call has an explicit timeout and TLS verification enabled.
- User-influenced destinations are validated against an allowlist/deny-list for private/metadata ranges.

Source: OWASP SSRF Prevention Cheat Sheet, OWASP Transport Layer Protection Cheat Sheet (cheatsheetseries.owasp.org).
