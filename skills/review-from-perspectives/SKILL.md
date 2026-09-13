---
name: review-from-perspectives
description: "Review a change from 1-3 selected engineering role lenses and surface trade-offs. "
disable-model-invocation: true
---

Review this change through explicit role lenses — concrete lenses, not generic praise. This is a **quick multi-angle pass**; for a deep dive on one concern, delegate to the matching specialist (`security-auditor`, `architect`, `tech-lead`, `code-reviewer`, `devops-engineer`, `product-clarifier`).

## Inputs needed
- Change summary — what changed.
- Roles (1-3, or "auto" to pick from the table below) — e.g. backend, security, architecture, QA, network, cloud, reliability, data, PM.

## Role selection
Pick 1-3 roles by the change's dominant concern. Default to **Senior Backend Developer** if nothing more specific dominates.

| Dominant concern | Role |
|---|---|
| General correctness, readability, maintainability | Senior Backend Developer |
| Untrusted input, files, auth, secrets, trust-boundary crossing | Security Reviewer |
| Where code belongs, coupling, new service/stage, scaling shape | Architect |
| Behavior change, regressions, "is this tested?" | QA |
| Endpoints, timeouts, retries, TLS, connectivity | Network Reviewer |
| Deploy, containers, env config, resource limits, cost | Cloud/Infra Reviewer |
| Behavior under load/failure, observability, resource leaks | Reliability (SRE) |
| Schemas, queries, PII, data flow, metrics | Data Reviewer |
| Scope, delivery risk, user value, perceived performance | Project Manager |

## The roles
- **Senior Backend Developer** — correctness, conventions, error handling, typing, tests. Flags silent failure returns, god functions, hidden side effects.
- **Security Reviewer** — input validation, injection, secret/PII leakage, trust-boundary violations, path traversal, supply-chain risk. Lens: *"How would an attacker abuse this, and what's the blast radius?"*
- **Architect** — layer boundaries (see the `architecture-layering` skill), dependency direction, coupling, idempotency. Flags business logic in boundaries, IO in services, cross-component breakage.
- **QA** — success/failure/boundary coverage, regression risk, deterministic tests. Flags untested error paths and behavior changes with no locking test.
- **Network Reviewer** — timeouts, retry/backoff, idempotency under retry, TLS, DNS. Flags unbounded calls, missing timeouts, no transient-failure retry.
- **Cloud/Infra Reviewer** — containerization, env config, resource limits, scaling, secrets, cost. Flags in-process state, hardcoded config/secrets, missing resource bounds.
- **Reliability (SRE)** — dependency-failure behavior, observability, backpressure, resource lifecycle. Flags unbounded memory, leaked resources, retry storms.
- **Data Reviewer** — data integrity/model, schema evolution, query performance (N+1, full scans), PII handling/retention. Flags raw dicts across boundaries, N+1 queries, unnecessary PII logging.
- **Project Manager** — user value, scope/delivery risk, perceived performance, backward compatibility. Flags scope creep, speculative work (YAGNI), UX harm.

## Required output
1. Role selection and why (1-3 roles).
2. Findings per role — only material issues, with file/function/line.
3. Tensions/trade-offs when roles disagree.
4. **Opinion block** (end every response with this):
```
## Opinion — <Role(s)>
**Verdict:** approve / approve with changes / needs rework
**From the <role> view:** 2-4 bullets, the points that matter most through this lens.
**Top risk:** the single biggest concern (or "none material").
**Recommendation:** what to do next.
```

## Rules
- No generic praise. Name the file/function/line for every finding.
- Prioritize correctness, safety, and regression risk over style.
- Keep findings concrete and testable — say exactly what and why, never "could be better."
