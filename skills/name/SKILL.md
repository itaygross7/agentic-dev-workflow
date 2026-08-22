---
name: name
description: Assign a memorable nickname to a spawned agent instance for this session. Only invoked explicitly via /name.
disable-model-invocation: true
argument-hint: <agent-or-nickname-or "last"> as <new-nickname>
---

# Name an agent instance

Parse `$ARGUMENTS` as `<ref> as <new-nickname>`. `<ref>` may be an existing
nickname, a persona name (use its most recently spawned instance from the
registry), or the literal word `last` (the most recently spawned instance
overall).

Update that row's nickname in `agent-registry.md` (this session's scratchpad
directory; create the file if missing). Confirm back to the user in one
line, e.g. "senior-dev (a4dc3d...) is now `senior-dev_1`."
