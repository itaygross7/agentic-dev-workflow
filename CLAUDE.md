# CLAUDE.md — user-level core (loads in every repo on this machine)

## Who you're working with
Itay Gross — Python backend developer. Mid-level: never explain basics.
Background: cyber research, then an experienced dev team.
He knows type hints, Pydantic, logging, async, HTTPStatus, unittest — do
not explain these.

## Response contract
- Reply to Itay in English. Keep code, identifiers, commands, and paths in English.
- Bottom line first. Short explanation only when it changes what he'd do.
- If the request is ambiguous or context is missing, ask before answering.
  Do not proceed on invented assumptions.

## The one rule before any recommendation
Check whether the codebase already solves this. Do not propose a new tool,
library, or dependency before existing options are exhausted.

## DO NOT
- Do not propose improvements that weren't requested.
- Do not add unrequested boilerplate.
- Do not change a public function's name or signature without first checking
  its callers, and say what you found.

## Context modes
- Solo / personal repos: direct, less formal, move fast.
- Work / shared repos: conservative, surgical, backward-compatible; cross-
  component or public-API changes need explicit approval before proceeding.
Infer from the repo; when unsure, ask which mode applies.

## Agent invocation
Explore/Plan: launch freely, no confirmation needed — this covers ad hoc
research only.
junior-dev: same free launch, no confirmation — fire it whenever the work is
plain bulk reading with no judgment in it, even if I didn't ask for it. One
per task, briefed only by main (or the team lead), and its brief gets relayed
to whoever needs it instead of each agent re-reading the same source.
Once an approved plan has already named a specific agent
for a step, deviating from that step (skipping it, substituting your own
approach) needs the same go-ahead as naming a new specialist — don't
silently swap it in, even to consolidate redundant work.
Specialist agent: before naming one, check `agent-routing` for fit and cite
it in the announcement — "per agent-routing: <situation> -> <agent>" — then:
- Confirm-required modes: wait for my explicit go-ahead ("ok"/"go"/"yes")
  next message before calling it. Feedback on a deliverable ("rerun", "fix
  point 3") is not go-ahead.
- Auto mode: decide and call directly, no asking — optimize for speed/tokens.
Skip confirmation if I named the agent myself, or if I ran `/consult <agent>`.
`/consult` with no name still applies consult's own action-capable check.
For resuming, finding, or retiring agent work across sessions, see
`agent-lifecycle`.

## Coding conventions (defaults, not to be restated back to me)
Type hints on every function; Sphinx docstrings; logging (never print), lazy
args; named exceptions (never return None for failure); guard clauses over
nested ifs; Pydantic for JSON payloads; HTTPStatus enums; no getattr; no
module-level mutable globals; path-traversal protection; single responsibility.

## How this setup is organized
- Path-specific conventions (python, api, mongodb, aws, …) are path-scoped
  rules in `~/.claude/rules/`, not skills. Each has a `paths:` glob and loads
  only when Claude reads a matching file — every repo, present and future, no
  per-repo setup. Verified 2026-09-06 on 2.1.263 by probe; open issues #21858
  and #22170 claim user-level `paths:` is ignored, which was not true here. If
  conventions stop loading, re-run that probe before assuming anything else.
  Multi-step workflows stay skills.
- Workflows (planning, bug-fix, review, tests, …) are skills.
- Specialist roles (reviewer, investigator, security-auditor, …) are subagents.
Do not restate a skill's content here — this file stays minimal on purpose.

## Compaction
When compacting, preserve code changes, decisions made, and open questions.
Drop restated file contents.
