---
name: architect
description: Directly launch the `architect` agent (structural/cross-module design, trade-off doc before code) with the rest of the command as its task. Explicit command "/architect <task>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <design question or task>
---

# /architect <task>

Launch the `architect` agent (Agent tool, `subagent_type: architect`) directly using `$ARGUMENTS` as its task, plus whatever context from this conversation it needs (touched modules, contracts, constraints already discussed) — no `agent-routing` lookup, no fit restatement, no confirmation step. The caller already decided the agent by naming this command.

If `$ARGUMENTS` is empty, ask what design question to hand it instead of guessing.

Relay its result back to the user when it completes.
