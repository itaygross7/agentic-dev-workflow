---
name: tell
description: Send a message to a named agent instance, or relay one instance's last output into another. Only invoked explicitly via /tell.
disable-model-invocation: true
argument-hint: <nickname> <message> | <nickname> from <other-nickname>
---

# Message or relay between agent instances

Parse `$ARGUMENTS`:
- `<nickname> from <other-nickname>` — look up both in `agent-registry.md`,
  take `<other-nickname>`'s last reported result from this conversation, and
  send it to `<nickname>` via `SendMessage({to: <nickname's agentId>,
  message: <that result>, summary: "relayed from <other-nickname>"})`.
- Otherwise, treat it as `<nickname> <message text>` — look up `<nickname>`'s
  agentId in the registry and call `SendMessage({to: agentId, message:
  <message text>, summary: "..."})`.

If the nickname isn't tracked, say so and point at `/session-agents` (to see
what's tracked) or `/name` (to assign one first).
