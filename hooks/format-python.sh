#!/usr/bin/env bash
# PostToolUse hook: format, lint, and type-check Python files after Claude edits them.
#
# Formatting is silent and auto-applied. What ruff and mypy CANNOT fix is
# reported back to Claude on stderr with exit 2, which is how PostToolUse
# surfaces a problem to the model — the edit already happened and cannot be
# undone, but Claude sees the diagnostics and fixes them in the same turn.
#
# Never fails the edit: every probe is guarded, and a missing tool is a no-op.
set -uo pipefail

# Hooks do not inherit an interactive shell's PATH. Without this, a tool
# installed under ~/.local/bin is invisible and every check silently no-ops —
# which is exactly how this hook sat dead from 2026-07-07 to 2026-09-06.
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"

input="$(cat || true)"
command -v jq >/dev/null 2>&1 || exit 0

file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
[ -n "${file:-}" ] || exit 0
case "$file" in *.py) : ;; *) exit 0 ;; esac
[ -f "$file" ] || exit 0

report=""

if command -v ruff >/dev/null 2>&1; then
  ruff check --fix "$file" >/dev/null 2>&1 || true
  ruff format "$file" >/dev/null 2>&1 || true
  # Second pass, no --fix: whatever is left needs a human-shaped decision.
  if ! remaining="$(ruff check --output-format=concise "$file" 2>&1)"; then
    [ -n "$remaining" ] && report+="ruff (not auto-fixable):"$'\n'"$remaining"$'\n'
  fi
fi

if command -v mypy >/dev/null 2>&1; then
  # mypy reads mypy.ini/pyproject.toml from the repo and IMPORTS anything named
  # in `plugins =`. Editing one .py file in a hostile repo would be enough to
  # execute that module, so pin an empty config the repo cannot influence.
  _MYPY_CFG="$HOME/.claude/hooks/mypy-hook.ini"
  if ! types="$(timeout 45 mypy --config-file "$_MYPY_CFG" --no-error-summary --no-color-output "$file" 2>&1)"; then
    [ -n "$types" ] && report+="mypy:"$'\n'"$types"$'\n'
  fi
fi

if [ -n "$report" ]; then
  printf '%s\n' "$file still has issues after auto-fix — resolve them now:" >&2
  printf '%s' "$report" >&2
  exit 2
fi
exit 0
