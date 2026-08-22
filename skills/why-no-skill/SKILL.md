---
name: why-no-skill
description: Diagnose why a skill or agent suggestion did not fire for a given prompt. Invoke manually with the prompt that should have matched, to tune skill/agent descriptions. Not for normal coding tasks.
disable-model-invocation: true
argument-hint: "<the prompt that should have matched a skill>"
allowed-tools: Read, Grep, Glob, Bash
---

The user gives a prompt they expected to trigger one of their skills or
specialist agents, but it didn't fire (or the wrong one fired). Do this:

1. Enumerate the candidates: read the `name` + `description` frontmatter of
   each `SKILL.md` under `~/.claude/skills/` (and any project `.claude/skills/`),
   and each agent `.md` under `~/.claude/agents/`.
2. Decide which skill(s) or agent(s) SHOULD have matched the given prompt.
3. Explain in one or two sentences why the current description likely failed to
   match — usually: too abstract, missing the user's actual trigger words,
   overlapping with another description, or a missing "Not for" boundary.
4. Propose a revised `description` line: concrete "what + when + NOT for",
   including the real trigger phrasing from this prompt.
5. Append one line to the audit log so the monthly `tune-skills` pass sees it,
   tagging the type so skill and agent entries share one log:

   printf '%s\t%s\t%s\t%s\t%s\n' "$(date -Iseconds)" "<skill|agent>" "<prompt>" "<expected-unit>" "<suggested-fix>" >> "$HOME/.claude/trigger-audit.log"

Report the diagnosis and the proposed description. Do NOT edit the skill or
agent file yourself — the user approves changes.
