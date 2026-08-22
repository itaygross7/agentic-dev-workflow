---
name: team-custom
description: Talk to a persistent team lead with a lead agent OTHER than the default senior-dev — same mechanics as /team (shared junior-dev, checkpoint-then-resume), but you pick which agent coordinates. Only invoked explicitly via /team-custom.
disable-model-invocation: true
argument-hint: <lead-agent> <message>
---

# /team-custom <lead-agent> <message>

Same procedure as `/team`, except the lead and its registry nickname are parameterized.

## Resolve the lead
Parse `$ARGUMENTS` as `<lead-agent> <message>` (first word is the agent name, rest is the message). Validate `<lead-agent>` against the 7 Team-Lead-Mode-capable agents: `senior-dev`, `architect`, `tech-lead`, `code-reviewer`, `bug-investigator`, `security-auditor`, `product-clarifier`. If it's not one of these, say so and list the valid choices — launch nothing.

Nickname for this team: `team-<lead-agent>` (e.g. `team-architect`), distinct from the default `/team`'s `team` nickname — multiple custom teams can run side by side, each under its own lead's nickname.

## Procedure
1. Look up nickname `team-<lead-agent>` in this session's `agent-registry.md`.
   - **Found, status running/completed** → `SendMessage({to: <its agentId>, message: "[TEAM LEAD MODE] " + <message>, summary: "<short recap>"})`. Log `main -> team-<lead-agent>: resumed` in `## Communications`.
   - **Not found**:
     a. Spawn a `junior-dev` instance via the Agent tool. Register it as nickname `team-<lead-agent>_junior`.
     b. Spawn `<lead-agent>` via the Agent tool with prompt: `"[TEAM LEAD MODE] shared junior-dev: team-<lead-agent>_junior (agentId <its agentId>) — you are its only caller. Brief it for all bulk reads, then forward its consolidated brief to the specialists that need it, in parallel. Specialists must not message it or spawn their own. " + <message>`, **overriding `model: opus`**. Register it as nickname `team-<lead-agent>`.
     c. Log both spawns in `## Communications`.
2. Relay whatever the lead returns back to Itay as the response.

Checkpoint / resume behavior is identical to `/team` — a checkpoint request from the lead is surfaced as-is, and a follow-up `/team-custom <lead-agent> <reply>` continues the same instance.
