---
name: consult
description: Explicitly consult a specialist agent — "consult <agent>" runs it directly, "consult" with no name picks the best fit via the agent-routing map and runs it (one extra check if the pick is action-capable). Add --keep to leave the agent running so you can follow up with /tell instead of re-explaining. Running this IS the go-ahead; no separate Agent-invocation confirmation needed.
disable-model-invocation: true
argument-hint: [--keep] [agent] <task>
---

# /consult [--keep] [agent] <task>

Parse an optional leading `--keep` off `$ARGUMENTS` before anything else; the rest is the agent name (if given) and the task.

## Before spawning: is one already running?
Check this session's `agent-registry.md` for a running agent of the type you are about to launch (per `agent-lifecycle`). If there is one, do not silently spawn a second — say so in one line, and either resume it with `SendMessage` when the new task continues the old one, or spawn a fresh instance under a distinct nickname when it does not. Two live agents of the same type with no way to tell them apart is the failure this check exists to prevent.

## --keep
Without it, the agent answers and ends. That is the right default: most consults are one question.

With `--keep`, register the agent in `agent-registry.md` under a short nickname derived from its type (`security-auditor` -> `sec`, `code-reviewer` -> `rev`, first three letters otherwise, disambiguated with a digit if taken). Report the nickname on the way back, so the follow-up is `/tell <nick> <message>` rather than a fresh consult that re-reads everything.

Use it when the next message is likely a follow-up on the same target — iterating on one module, working through a findings list, narrowing an investigation.

**Do not use it when you want a cold read.** `senior-dev` exists to answer from the code rather than from your framing, and a kept instance has already absorbed the framing of its first question — its second answer is no longer independent. The same applies to any adversarial pass on a genuinely new target. When in doubt on those two, spawn fresh; the re-read is cheaper than a contaminated verdict.

Ask a kept agent to shut down once its work is done rather than leaving it idle for the session.


1. **Agent named** (`/consult <agent>`): validate it exists against
   `agent-routing`'s list, then launch it directly — naming it is
   unambiguous go-ahead, skip the Agent invocation confirmation gate
   regardless of tier.
2. **No name given** (`/consult`): match current context against
   `agent-routing`'s situation table, state the single best pick in one
   line, cited — "per agent-routing: `<situation>` -> `<agent>`".
   - Pick is **read-only** tier -> launch it directly.
   - Pick is **action-capable** tier -> ask one explicit confirmation
     before launching. Auto-picking is fine; auto-mutating files without
     the user having named the agent isn't.
3. **Nothing fits**: if nothing in the table clearly beats the default
   (Explore / direct-answer-mode), say so and launch nothing — "none" is a
   valid, expected outcome, not a failure to find something.

## What each agent needs from you

`/consult <agent>` replaces the twelve per-agent launcher commands that used to
wrap these. The value those carried was the prompt for *what to supply* — kept
here. If the argument is thin, ask for the missing piece before launching.

| Agent | Give it |
|---|---|
| `architect` | design question or task |
| `bug-fixer` | file/function + confirmed root cause + evidence |
| `bug-investigator` | observed symptom + expected behavior |
| `code-creator` | spec: what to build, where, affected callers |
| `code-improver` | file/function + which quality concern |
| `code-reviewer` | diff/PR/files to review |
| `devops-engineer` | pipeline/container/deploy/observability task |
| `product-clarifier` | the vague/underspecified request |
| `security-auditor` | route/file/module to audit |
| `senior-dev` | question + file/function it's about |
| `tech-lead` | decision to weigh in on |
| `test-writer` | behavior/file to cover |
| `junior-dev` | the source to read + what to name/measure in it |
| `tune-skills` | optional: a specific skill/agent or log entry to focus on |
