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
   each `SKILL.md` under `~/.claude/skills/ (and `~/.claude/rules/*.md` plus any per-repo `.claude/rules/`, which are path-triggered rather than description-matched — a rule that did not fire usually means its `paths:` glob missed, not that its wording lost)` (and any project `.claude/skills/`),
   and each agent `.md` under `~/.claude/agents/`.
2. Decide which skill(s) or agent(s) SHOULD have matched the given prompt.
3. Explain in one or two sentences why the current description likely failed to
   match — usually: too abstract, missing the user's actual trigger words,
   overlapping with another description, or a missing "Not for" boundary.
4. Propose a revised `description` line: concrete "what + when + NOT for",
   including the real trigger phrasing from this prompt.
5. Append one line to the audit log so the monthly `tune-skills` pass sees it,
   tagging the type so skill and agent entries share one log:

   Pass the four fields as positional arguments — never paste the prompt text
   into the command string. It is user input, it can contain `$(...)`, a quote,
   or a newline, and this log is evidence that `tune-skills` acts on:

   ```bash
   log_trigger() {
       printf '%s\t%s\t%s\t%s\t%s\n' "$(date -Iseconds)" \
           "$(printf '%s' "$1" | tr -d '\n\t')" \
           "$(printf '%s' "$2" | tr -d '\n\t')" \
           "$(printf '%s' "$3" | tr -d '\n\t')" \
           "$(printf '%s' "$4" | tr -d '\n\t')" \
           >> "$HOME/.claude/trigger-audit.log"
   }
   log_trigger "<skill|agent>" "<prompt>" "<expected-unit>" "<suggested-fix>"
   ```

   Tabs and newlines are stripped so one entry can never forge a second.

Report the diagnosis and the proposed description. Do NOT edit the skill or
agent file yourself — the user approves changes.
