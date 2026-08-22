---
name: bug-fixer
description: Directly launch the `bug-fixer` agent (applies the smallest safe fix for a bug whose root cause is already confirmed, adds a regression test) with the rest of the command as the diagnosed bug. Explicit command "/bug-fixer <cause + evidence>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <file/function + confirmed root cause + evidence>
---

# /bug-fixer <cause + evidence>

Launch the `bug-fixer` agent (Agent tool, `subagent_type: bug-fixer`) directly using `$ARGUMENTS` as the task, plus the exact file/function, confirmed root cause, and evidence (traceback/log/failing assertion) from this conversation — no `agent-routing` lookup, no fit restatement, no confirmation step (this is action-capable, but naming it here already is the go-ahead).

If the root cause isn't actually confirmed yet (still just a symptom), say so and suggest `/bug-investigator` first instead of guessing a cause.

Relay its result back to the user when it completes.
