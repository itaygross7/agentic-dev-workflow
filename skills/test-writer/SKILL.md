---
name: test-writer
description: Directly launch the `test-writer` agent (writes/updates pytest coverage for changed or new behavior, then runs it) with the rest of the command as the target behavior. Explicit command "/test-writer <target>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <behavior/file to cover>
---

# /test-writer <target>

Launch the `test-writer` agent (Agent tool, `subagent_type: test-writer`) directly using `$ARGUMENTS` as the task — no `agent-routing` lookup, no fit restatement, no confirmation step (action-capable, but naming it here already is the go-ahead).

If it finds a production bug rather than a test gap, it will report that instead of silently patching around it — relay that back to the user, don't apply it yourself.

Relay its result back to the user when it completes.
