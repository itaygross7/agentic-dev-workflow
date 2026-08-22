---
name: bug-investigator
description: Directly launch the `bug-investigator` agent (read-only root-cause analysis, ranked evidence-based suspects) with the rest of the command as the symptom. Explicit command "/bug-investigator <symptom>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <observed symptom + expected behavior>
---

# /bug-investigator <symptom>

Launch the `bug-investigator` agent (Agent tool, `subagent_type: bug-investigator`) directly using `$ARGUMENTS` as the task, plus the observed symptom, expected behavior, and any repro steps already known from this conversation — no `agent-routing` lookup, no fit restatement, no confirmation step (read-only, always safe to auto-fire).

Relay its ranked suspects back to the user when it completes; if the cause comes back confirmed, point at `/bug-fixer` next.
