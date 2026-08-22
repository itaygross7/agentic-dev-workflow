---
name: tech-lead
description: Directly launch the `tech-lead` agent (ship/hold/defer judgment call, speed-vs-quality trade-offs, read-only) with the rest of the command as the decision to weigh in on. Explicit command "/tech-lead <decision>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <decision to weigh in on>
---

# /tech-lead <decision>

Launch the `tech-lead` agent (Agent tool, `subagent_type: tech-lead`) directly using `$ARGUMENTS` as the task, plus deadline/blast-radius/tech-debt context already known from this conversation — no `agent-routing` lookup, no fit restatement, no confirmation step (read-only, always safe to auto-fire).

Relay its judgment call back to the user when it completes.
