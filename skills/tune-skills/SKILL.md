---
name: tune-skills
description: Audit the installed skill and agent library — which units never fire, which descriptions are too weak or overlapping to win a match, and what to rewrite them to. Triggers on "why didn't a skill fire", "are any of my skills dead", "audit/clean up my skills", "which agents do I actually use", or a periodic maintenance pass. Proposes only — never edits skill or agent files. NOT for routing one task to the right specialist (use agent-routing).
disable-model-invocation: false
argument-hint: [optional: specific skill/agent or log entry to focus on]
---

# /tune-skills [focus]

Launch the `tune-skills` agent (Agent tool, `subagent_type: tune-skills`) directly. Have it read `~/.claude/trigger-audit.log`, the installed skills/agents, and `~/.claude/rules/*.md` (path-scoped rules — judge their `paths:` globs against the real repos, not just their prose); if `$ARGUMENTS` names a specific skill, agent, or log entry, focus there — otherwise run the standard full pass. No `agent-routing` lookup, no fit restatement, no confirmation step (it's tool-tiered action-capable but prompt-restricted to propose-only, so naming it here is enough).

Relay its ranked report back to the user when it completes — it proposes rewrites only, never edits files itself.
