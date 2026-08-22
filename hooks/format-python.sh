#!/usr/bin/env bash
# PostToolUse hook: format + lint Python files after Claude edits them.
# Reads Claude Code's hook JSON from stdin. Safe: no-ops if anything is missing,
# so it can never break an edit. Verify it fires with `claude --debug` once;
# if your version names the field differently, adjust the jq path below.
set -euo pipefail
input="$(cat || true)"
command -v jq >/dev/null 2>&1 || exit 0
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
[ -n "${file:-}" ] || exit 0
case "$file" in
  *.py) : ;;
  *) exit 0 ;;
esac
[ -f "$file" ] || exit 0
if command -v ruff >/dev/null 2>&1; then
  ruff check --fix "$file" >/dev/null 2>&1 || true
  ruff format "$file" >/dev/null 2>&1 || true
fi
exit 0
