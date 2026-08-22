---
name: suggest-agent
description: Suggest (without launching) the best-fit agent for the current situation. Explicit command version of "which agent fits now" — matches context against the agent-routing table, states the pick, launches nothing.
disable-model-invocation: true
---

# /suggest-agent

Match current accumulated context against `agent-routing`'s situation
table (`~/.claude/skills/agent-routing/SKILL.md`) and state the single
best fit, cited — "per agent-routing: `<situation>` -> `<agent>`" — or
"none" if the default (Explore / direct-answer-mode) already covers it.

Launch nothing; this only suggests. To actually run the suggested agent,
use `/consult` (with or without naming it) — that command is the one that
carries go-ahead, this one doesn't.
