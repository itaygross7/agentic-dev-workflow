---
name: agent-lifecycle
description: Resume, find, or retire agent work across sessions — "is X still running", "continue with the agent from before", "what happened to the investigation I started earlier". Use before respawning an agent from scratch or re-explaining context it already has. NOT for launching a brand-new specialist for a fresh task (use agent-routing).
---

# Agent lifecycle situation map

| Situation | Use |
|---|---|
| Continuing work with an agent still active/recent in this session | `SendMessage` to its `agentId` — never respawn fresh |
| "Where did I already explore/decide this" (this session or a past one) | `search_session_transcripts` first, before re-explaining |
| Know it's an old session but can't recall exact wording | `list_sessions` |
| A thread of work is done and won't be resumed | `archive_session` immediately |
| Need to hand off/resume work sitting in a different past session | `mcp__ccd_session_mgmt__send_message` into that session |

## Why this exists
Fixes "I run agents but can't manage them comfortably or keep using them" —
resume don't respawn, search don't re-explain, archive don't accumulate.

## Track running instances
Whenever you spawn an agent via the Agent tool, append a row to
`agent-registry.md` in this session's scratchpad directory: `nickname |
agentId | persona | status | purpose`. Default nickname is
`<persona>_<n>` (e.g. `architect_1`, then `architect_2` for a second
instance of the same persona). Update that row's status to `completed` or
`failed` when the corresponding task-notification arrives. This is what
`/session-agents`, `/name`, and `/tell` read and update.

## Communications log
In the same `agent-registry.md` file, keep a `## Communications` section:
one terse line per message sent, oldest first — `main -> architect_1:
spawned (design review)`, `main -> senior-dev_1: resumed`, `senior-dev_1 ->
architect_1: relayed`. Log it whenever you spawn, `SendMessage`, or relay via
`/tell`. This is a log, not a transcript — short entries only. It's what
`/session-agents chart` draws as arrows.
