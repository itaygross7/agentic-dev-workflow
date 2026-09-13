---
name: code-quality
description: "Function/class-level Python design rules: one abstraction level per function, naming clarity, single responsibility, YAGNI, guard clauses, command/query separation. Apply when writing or reviewing Python code; complements python-conventions (contracts/errors/logging) with structural design rules."
---

# Code quality rules (scoped)

Apply when writing or reviewing Python code. Complements `~/.claude/rules/python-conventions.md`
(contracts/error-handling/logging) with function/class-level design rules.

## One level of abstraction per function
- Every line in a function should operate at the same level of detail. Don't mix
  high-level orchestration (call service, notify, persist) with low-level implementation
  (building HTTP headers, parsing raw responses) in the same function — extract the
  low-level part into its own function.

## Names are the primary documentation
- A name that needs a comment to explain it is a failed name.
- Booleans start with `is_`, `has_`, `can_`, `should_`.
- Functions: `verb_noun` (`get_user`, `process_payment`) — never `handle`, `process`, or
  `do_stuff` alone. Classes: a noun naming the thing, not the action it performs.

## Functions do one thing
- If you can extract a block and give it a meaningful name, it belongs in its own
  function. Rule of three: a block repeated 3+ times should be extracted; twice and
  non-trivial, extract it; once, leave it unless naming it clarifies intent.

## Class design (SRP, composition, tell-don't-ask)
- Split a class on *reason to change* — a class that does DB + auth + email + formatting
  is a namespace, not a single-responsibility object.
- Prefer composition over inheritance unless the subclass genuinely IS-A the parent
  (Liskov substitution).
- Give domain/business objects behavior, not just data — avoid pulling an object's data
  out to decide something externally when the object itself should expose that decision
  (`user.has_active_premium_subscription()` instead of inspecting `user.subscription.plan`
  and `.is_active` externally). This does not apply to intentional data-transport models
  (request/response schemas) — those are expected to be data-only.

## YAGNI
- Every abstraction, base class, factory, or config option must be justified by a
  *current* requirement. Don't add an abstract base class for one concrete implementation
  "because it'll probably need siblings" — add the abstraction when a second concrete
  implementation actually exists.

## Guard clauses over nested conditionals
- Nesting hides the happy path. Handle preconditions/exceptional cases as early returns so
  the main logic stays flat and visible at the top level.

## Command/query separation
- A function either returns a value or changes state — never both. A "getter" that also
  mutates state (e.g. dequeues/marks-in-progress as a side effect of peeking) causes bugs
  that are hard to trace to their source.

## Common anti-patterns to avoid
Error-handling anti-patterns (exception swallowing, returning `None`/a sentinel to signal
failure) are covered in `~/.claude/rules/python-conventions.md` and not repeated here — this list is
function/class-design specific:
- **Fake encapsulation**: a private method called exactly once that adds no abstraction
  over what the caller already implies — inline it instead.
- **Comments that restate the code** (`# increment the counter` above `count += 1`) — only
  comment the *why*, not the *what*.
- **Over-parameterized functions**: many positional params usually signal multiple
  responsibilities or a missing model — group related params into a request/config model.

## Done conditions
- Each function reads at one level of abstraction; names need no explanatory comment.
- No class combines unrelated responsibilities; no unjustified abstraction was added.
- No function both returns a meaningful value and causes a side effect.
