#!/usr/bin/env bash
# InstructionsLoaded hook: record which CLAUDE.md / .claude/rules files actually
# loaded, when, and why.
#
# This exists to replace the hand-written trigger-audit.log with measured data:
# `tune-skills` can only tell you which skills never fire if something is
# counting. Purely observational — always exits 0 and never blocks anything.
#
# The payload schema is not pinned here on purpose: the whole JSON object is
# logged compactly, so a field rename upstream degrades the log's readability
# rather than silently emptying it.
set -uo pipefail

LOG="$HOME/.claude/instructions-loaded.log"
MAX_BYTES=$((5 * 1024 * 1024))

input="$(cat || true)"
[ -n "${input:-}" ] || exit 0

# Rotate before appending so the log can never grow without bound.
if [ -f "$LOG" ] && [ "$(wc -c <"$LOG" 2>/dev/null || echo 0)" -gt "$MAX_BYTES" ]; then
  mv -f "$LOG" "$LOG.1" 2>/dev/null || true
fi

ts="$(date -Is)"
if command -v jq >/dev/null 2>&1; then
  printf '%s\t%s\n' "$ts" "$(printf '%s' "$input" | jq -c . 2>/dev/null || printf '%s' "$input" | tr -d '\n')" >>"$LOG"
else
  printf '%s\t%s\n' "$ts" "$(printf '%s' "$input" | tr -d '\n')" >>"$LOG"
fi
exit 0
