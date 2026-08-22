---
name: senior-dev
description: Directly launch the `senior-dev` agent (independent, fresh read of the code — second opinion, sanity check, rubber-duck, read-only) with the rest of the command as the question. Explicit command "/senior-dev <question>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <question + file/function it's about>
---

# /senior-dev <question>

Launch the `senior-dev` agent (Agent tool, `subagent_type: senior-dev`) directly using `$ARGUMENTS` as the question, plus the specific file(s)/function(s) and any assumption to double-check — no `agent-routing` lookup, no fit restatement, no confirmation step (read-only, always safe to auto-fire).

Relay its verdict back to the user when it completes.
