---
name: product-clarifier
description: Directly launch the `product-clarifier` agent (turns a vague ask into scope, requirements, acceptance criteria, read-only) with the rest of the command as the vague request. Explicit command "/product-clarifier <ask>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <the vague/underspecified request>
---

# /product-clarifier <ask>

Launch the `product-clarifier` agent (Agent tool, `subagent_type: product-clarifier`) directly using `$ARGUMENTS` as the task — no `agent-routing` lookup, no fit restatement, no confirmation step (read-only, always safe to auto-fire).

Relay its scope/requirements/acceptance criteria back to the user when it completes.
