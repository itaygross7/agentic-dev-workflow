---
paths:
  - "**/*.sh"
  - "**/*.bash"
---

# Bash / shell scripting rules (scoped)

Apply when writing or editing shell scripts.

## Script preamble
- Start scripts with `#!/usr/bin/env bash` and `set -euo pipefail` so failures, unset vars, and
  failed pipe stages stop execution instead of silently continuing.
- Use `trap '...' EXIT` for cleanup of temp files/resources instead of relying on the script reaching its end.

## Safety
- Always quote variable expansions (`"$var"`, `"${arr[@]}"`); unquoted expansions cause word-splitting/glob bugs.
- Use `[[ ... ]]` for conditionals instead of `[ ... ]`.
- Use `mktemp` for temp files/dirs; never write to a hardcoded predictable path.
- Never `eval` or interpolate untrusted input directly into a command string.
- Validate argument count/contents at the top of the script (`$#`, usage message) before proceeding.

## Structure
- Prefer POSIX-style function declarations: `my_func() { ...; }`, not `function my_func { ...; }`.
- Keep scripts organized as small functions with a `main "$@"` entry point for anything beyond a few lines.
- Run `shellcheck` on scripts before committing and fix reported issues.

## Done conditions
- `set -euo pipefail` present; no unquoted variable expansions in changed lines.
- `shellcheck` passes (or documented exceptions) for touched scripts.

Source: Google Shell Style Guide (google.github.io/styleguide/shellguide.html), ShellCheck.
