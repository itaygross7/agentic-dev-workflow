---
name: consult
description: Explicitly consult a specialist agent — "consult <agent>" runs it directly, "consult" with no name picks the best fit via the agent-routing map and runs it (one extra check if the pick is action-capable). Running this IS the go-ahead; no separate Agent-invocation confirmation needed.
disable-model-invocation: true
---

# /consult

1. **Agent named** (`/consult <agent>`): validate it exists against
   `agent-routing`'s list, then launch it directly — naming it is
   unambiguous go-ahead, skip the Agent invocation confirmation gate
   regardless of tier.
2. **No name given** (`/consult`): match current context against
   `agent-routing`'s situation table, state the single best pick in one
   line, cited — "per agent-routing: `<situation>` -> `<agent>`".
   - Pick is **read-only** tier -> launch it directly.
   - Pick is **action-capable** tier -> ask one explicit confirmation
     before launching. Auto-picking is fine; auto-mutating files without
     the user having named the agent isn't.
3. **Nothing fits**: if nothing in the table clearly beats the default
   (Explore / direct-answer-mode), say so and launch nothing — "none" is a
   valid, expected outcome, not a failure to find something.
