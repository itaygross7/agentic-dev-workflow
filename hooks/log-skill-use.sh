#!/usr/bin/env bash
# PreToolUse(Skill) hook: record every skill invocation.
#
# `tune-skills` reports which skills never fire, but until now its only input
# was a hand-maintained trigger-audit.log. This produces the measured dataset:
# one line per actual invocation. Observational — never blocks a skill.
set -uo pipefail
LOG="$HOME/.claude/skill-use.log"
input="$(cat || true)"
[ -n "${input:-}" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
name="$(printf '%s' "$input" | jq -r '.tool_input.skill // empty' 2>/dev/null || true)"
[ -n "${name:-}" ] || exit 0
printf '%s\t%s\n' "$(date -Is)" "$name" >>"$LOG"
exit 0
