---
name: tune-skills
description: Directly launch the `tune-skills` agent (maintenance pass over the skill/agent library — never-fires, weak/overlapping descriptions, proposed rewrites) using the rest of the command as extra focus, if any. Explicit command "/tune-skills [focus]" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: [optional: specific skill/agent or log entry to focus on]
---

# /tune-skills [focus]

Launch the `tune-skills` agent (Agent tool, `subagent_type: tune-skills`) directly. Have it read `~/.claude/trigger-audit.log` and the installed skills/agents; if `$ARGUMENTS` names a specific skill, agent, or log entry, focus there — otherwise run the standard full pass. No `agent-routing` lookup, no fit restatement, no confirmation step (it's tool-tiered action-capable but prompt-restricted to propose-only, so naming it here is enough).

Relay its ranked report back to the user when it completes — it proposes rewrites only, never edits files itself.
