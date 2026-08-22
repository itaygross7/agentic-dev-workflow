---
name: list-agents
description: List all available agents and what each is for. Explicit command version of "which agents do I have" — read-only, no side effects.
disable-model-invocation: true
---

# /list-agents

Read the "Agents available" section of the `agent-routing` skill
(`~/.claude/skills/agent-routing/SKILL.md`) and print that list verbatim —
don't re-derive or restate it here, `agent-routing` is the single source of
truth for the roster. Launch nothing; this only informs.
