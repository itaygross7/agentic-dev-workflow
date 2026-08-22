---
name: design-patterns-selection
description: Answer "should I use a factory/strategy/decorator here" or "how do I avoid this big if/elif chain" for backend Python logic — picks the smallest pattern or plain function/dataclass. NOT for deciding which architectural layer code belongs in (use architecture-layering) or for reviewing already-written code (use code-reviewer).
---

# Design Pattern Selection Skill

Use for real structural choices. Cross-check `code-quality`'s YAGNI rule: justify a pattern with a **current** concrete need, not a future guess.

## Default: prefer the plain option first
Most backend logic needs no named pattern or abstract base class. Start with a plain function or small dataclass. Use a named pattern only when one of the signals below is present.

## Decision guide
| Signal in the actual code | Pattern | Watch-out |
|---|---|---|
| 2+ concrete implementations of the same operation, selected at runtime | **Strategy** (small class/callable per variant + lookup) | Don't build this for one implementation "in case" a second appears later. |
| Object construction needs branching logic or hides which concrete type is built | **Factory function** (plain function returning the right type) | A Factory *class* is rarely needed in Python; a function usually suffices. |
| Multiple unrelated concerns need to run around the same core operation (logging, retry, caching) | **Decorator** (function or class decorator) | More than 2-3 stacked decorators gets hard to trace; consider an explicit pipeline instead. |
| Code depends directly on a third-party SDK/vendor throughout business logic | **Adapter** (typed interface owned by the IO layer — see `architecture-layering` skill) | Don't leak vendor types past the adapter boundary. |
| Something needs to react to an event without the producer knowing its consumers | **Observer / pub-sub** | Adds indirection; justify it with 2+ real subscribers. One listener is just a direct call. |
| A dependency call might fail repeatedly and shouldn't be hammered | **Circuit breaker** (see `resilient-network-client-workflow` skill) | Justified only for a critical, frequent, failure-prone dependency. |
| Data access logic (queries) is scattered through business logic | **Repository** (typed data-access interface — see `architecture-layering` skill's IO layer) | Don't build a generic repository framework for one collection/table; start concrete. |
| A domain object's data is inspected externally to make a decision that belongs to the object | **Tell, Don't Ask** (behavior on the object itself) | Not really a "pattern" so much as the default; see `code-quality`. |
| Business logic mixed with I/O makes tests need a real DB/network | **Functional core, imperative shell** (pure logic + thin IO wrapper) | Often the simplest fix; don't overreach for a bigger pattern first. |

## Process
1. Name the concrete signal from the table that's actually present — never a hypothetical one.
2. Pick the smallest pattern that resolves it, and state the plain/no-pattern option first so the added complexity is a deliberate trade.
3. If no signal applies, say so and use the plain option.

## Guardrails
- Never introduce an abstract base class for a single concrete implementation.
- Never add a pattern whose justifying signal is absent.
- Prefer composition and plain functions over deep inheritance hierarchies.

## Completion checklist
- [ ] The concrete signal that justifies the pattern is stated explicitly.
- [ ] The plain/no-pattern alternative was considered and rejected for a stated reason.
- [ ] No unused abstraction (interface/base class with a single implementation) was introduced.
