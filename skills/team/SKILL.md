---
name: team
description: Talk to a persistent team lead (senior-dev in Team Lead Mode) that decomposes the task, spawns the specialists it needs, and owns one shared junior-dev whose briefs it fans out. Continuing the conversation reuses the same lead instead of respawning. Triggers on "set up the team", "use the team", "get the team on this". If the team is not yet set up, prompt the user to run /team with a brief — never silently substitute solo routing. NOT for a single specialist on a scoped question (name the agent or use /consult).
disable-model-invocation: false
argument-hint: [--lead <agent>] <message>
---

# /team <message>

Parse an optional leading `--lead <agent>` off `$ARGUMENTS`; the rest is the message.
Default lead is `senior-dev`, nickname `team`. With `--lead <agent>`, validate it against the
7 Team-Lead-Mode-capable agents — `senior-dev`, `architect`, `tech-lead`, `code-reviewer`,
`bug-investigator`, `security-auditor`, `product-clarifier` — and if it is not one of these,
say so, list the valid choices, and launch nothing. The nickname is then `team-<lead-agent>`
(e.g. `team-architect`), so several teams can run side by side under different leads.

Everything below uses `<lead-agent>` and `<nickname>` accordingly.

The whole team is **standing**: the lead, the shared `junior-dev`, and every specialist the lead spawns are created once and resumed by message on later turns. A follow-up `/team` continues the same conversation with the same people, so a reviewer still knows what it found last round and what it deliberately let pass. When a follow-up is genuinely unrelated work rather than a continuation, say so in your message — the lead then tells its members not to carry forward stale framing, or keeps the new work under a separate nickname.

## Procedure
1. Look up nickname `<nickname>` in this session's `agent-registry.md` (scratchpad directory; per `agent-lifecycle`).
   - **Found, status running/completed** → `SendMessage({to: <its agentId>, message: "[TEAM LEAD MODE] " + $ARGUMENTS, summary: "<short recap>"})`. Log `main -> <nickname>: resumed` in `## Communications`.
   - **Not found** (first call, or file doesn't exist yet):
     a. Spawn a `junior-dev` instance via the Agent tool. Register it in `agent-registry.md` as nickname `<nickname>_junior` (row: `<nickname>_junior | <agentId> | junior-dev | running | shared read service for team`).
     b. Spawn `<lead-agent>` via the Agent tool with prompt: `"[TEAM LEAD MODE] shared junior-dev: <nickname>_junior (agentId <its agentId>) — you are its only caller. Brief it for all bulk reads, then forward its consolidated brief to the specialists that need it, in parallel. Specialists must not message it or spawn their own. " + $ARGUMENTS`, **overriding `model: opus`** for this call. Register it as nickname `<nickname>` (row: `<nickname> | <agentId> | <lead-agent> | running | <one-line task summary>`).
     c. Register every specialist the lead spawns as `<nickname>_<agent-type>` (e.g. `team_code-reviewer`) so `agent-lifecycle` can resume them and `/session-agents` shows the whole team, not just the lead. On a follow-up `/team`, the lead reuses those members rather than spawning fresh ones.
     d. Log all spawns in `## Communications`: `main -> <nickname>_junior: spawned (shared junior)`, `main -> <nickname>: spawned (lead, <lead-agent>)`.
2. Relay whatever the lead returns back to Itay as the response — this is a synthesized answer from whatever specialists the lead used, not a single specialist's raw output.

If the lead's response is a checkpoint request ("I want to run `bug-fixer` for X — confirm?"), surface it as-is and wait for Itay's reply; a follow-up `/team <reply>` continues the same instance via step 1's "found" branch.
