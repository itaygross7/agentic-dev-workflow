---
name: team
description: Talk to a persistent team lead (senior-dev, in Team Lead Mode) that decomposes the task, spawns whichever specialists it needs, and owns one shared junior-dev whose consolidated briefs the lead fans out to the team. Continuing the conversation reuses the same lead instead of respawning. Only invoked explicitly via /team.
disable-model-invocation: true
argument-hint: <message>
---

# /team <message>

Default team: nickname `team`, lead = `senior-dev`. Runs the shared procedure below with `<lead-agent> = senior-dev`. (For a different lead, use `/team-custom <lead-agent> <message>` instead — same mechanics.)

## Procedure
1. Look up nickname `team` in this session's `agent-registry.md` (scratchpad directory; per `agent-lifecycle`).
   - **Found, status running/completed** → `SendMessage({to: <its agentId>, message: "[TEAM LEAD MODE] " + $ARGUMENTS, summary: "<short recap>"})`. Log `main -> team: resumed` in `## Communications`.
   - **Not found** (first call, or file doesn't exist yet):
     a. Spawn a `junior-dev` instance via the Agent tool. Register it in `agent-registry.md` as nickname `team_junior` (row: `team_junior | <agentId> | junior-dev | running | shared read service for team`).
     b. Spawn `senior-dev` via the Agent tool with prompt: `"[TEAM LEAD MODE] shared junior-dev: team_junior (agentId <its agentId>) — you are its only caller. Brief it for all bulk reads, then forward its consolidated brief to the specialists that need it, in parallel. Specialists must not message it or spawn their own. " + $ARGUMENTS`, **overriding `model: opus`** for this call. Register it as nickname `team` (row: `team | <agentId> | senior-dev | running | <one-line task summary>`).
     c. Log both spawns in `## Communications`: `main -> team_junior: spawned (shared junior)`, `main -> team: spawned (lead, senior-dev)`.
2. Relay whatever `team` returns back to Itay as the response — this is a synthesized answer from whatever specialists the lead used, not a single specialist's raw output.

If the lead's response is a checkpoint request ("I want to run `bug-fixer` for X — confirm?"), surface it as-is and wait for Itay's reply; a follow-up `/team <reply>` continues the same instance via step 1's "found" branch.
