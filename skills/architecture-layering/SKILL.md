---
name: architecture-layering
description: Decide which layer new code belongs in when a prompt says "where should this live", "add a new endpoint/service/adapter", or "this function does IO and business logic together". Defines boundary/service/IO layers and error-as-contract. NOT for picking a design pattern once the layer is already known (use design-patterns-selection).
---

# Architecture Layering Skill

Use when deciding where code belongs, adding a service/endpoint/pipeline stage, or wiring an external dependency. It complements `code-quality` by defining layer boundaries.

## Layers (dependencies point inward only)
- **Boundary** — API handler, queue consumer, CLI parser, pipeline entry point. Validate/parse input, call exactly one service, map result or exception outward. No business logic.
- **Service / orchestration** — business logic. Framework-agnostic; depends only on injected adapters/interfaces. Knows nothing about HTTP objects or queue framing.
- **IO / adapter** — DB, external APIs, filesystem, queues. The only layer that performs IO.

A boundary must not run queries. A service must not build an HTTP response. If the design forces code into the wrong layer, stop and redraw the boundary before implementing.

## Errors as a contract
- Services raise **named domain exceptions** from a dedicated `exceptions.py`; never return `None`, `False`, `-1`, or another sentinel to signal failure silently.
- Translate domain exceptions to transport errors (HTTP status / queue nack) **only at the boundary**.
- Callers depend on exception **types**, not message strings.
- When re-raising across a layer, chain: `raise BoundaryError("...") from domain_error`.

## External systems
- Wrap every third-party API/provider behind a typed adapter interface owned by the IO layer.
- Service/orchestration code depends on that interface; never imports the vendor SDK directly.
- Inject adapters via constructor/DI; avoid module-level mutable globals across layers.

## Pipeline boundaries (multi-stage processing flows)
- Each stage has one responsibility; stages exchange typed payloads (schema/model classes), not raw dicts.
- When a stage crosses a trust boundary, treat data as untrusted until that stage validates/transforms it.
- Apply path-traversal protection at every stage that reads, writes, or executes a file.

## State and idempotency
- Make retryable operations idempotent (idempotency key or natural upsert).
- A function either returns a value or changes state — not both (command/query separation).

## When adding a feature
1. Decide each piece's layer **before** writing code.
2. Reuse existing services/adapters; don't duplicate IO inside a boundary handler.
3. Keep public/cross-component APIs backward-compatible unless the task explicitly requires a break.

## Testing implication
- Services must be unit-testable by mocking injected adapters. If a service needs real IO to test, the service/adapter boundary is wrong — fix the layering, not the test.
