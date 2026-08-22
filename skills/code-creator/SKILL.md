---
name: code-creator
description: Directly launch the `code-creator` agent (implements a new, well-specified feature/function/module from a clear spec) with the rest of the command as the spec. Explicit command "/code-creator <spec>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <spec: what to build, where, affected callers>
---

# /code-creator <spec>

Launch the `code-creator` agent (Agent tool, `subagent_type: code-creator`) directly using `$ARGUMENTS` as the task, plus the target location and any affected callers already discussed in this conversation — no `agent-routing` lookup, no fit restatement, no confirmation step (this is action-capable, but naming it here already is the go-ahead).

If the spec or target location is missing, say so instead of guessing.

Relay its result back to the user when it completes.
