---
name: devops-engineer
description: Directly launch the `devops-engineer` agent (CI/CD, Dockerfiles, deploy config, observability) with the rest of the command as the task. Explicit command "/devops-engineer <task>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <pipeline/container/deploy/observability task>
---

# /devops-engineer <task>

Launch the `devops-engineer` agent (Agent tool, `subagent_type: devops-engineer`) directly using `$ARGUMENTS` as the task, plus the target environment and existing pipeline file already known — no `agent-routing` lookup, no fit restatement, no confirmation step (action-capable, but naming it here already is the go-ahead).

Relay its result back to the user when it completes.
