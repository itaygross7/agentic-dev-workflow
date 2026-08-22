---
name: code-improver
description: Directly launch the `code-improver` agent (targeted, behavior-preserving improvement — reliability/readability/performance/convention) with the rest of the command as the target. Explicit command "/code-improver <target + concern>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <file/function + which quality concern>
---

# /code-improver <target + concern>

Launch the `code-improver` agent (Agent tool, `subagent_type: code-improver`) directly using `$ARGUMENTS` as the task, plus the target file/function and callers already discussed — no `agent-routing` lookup, no fit restatement, no confirmation step (action-capable, but naming it here already is the go-ahead).

Relay its result back to the user when it completes.
