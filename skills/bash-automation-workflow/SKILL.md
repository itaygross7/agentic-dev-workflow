---
name: bash-automation-workflow
description: Write, validate, and harden a shell script or CLI automation task from scratch. Use when creating a new script, automating a repeatable ops task, or hardening an existing one.
---

# Bash Automation Workflow Skill

Use before writing a new shell script or automating a repeatable operation (deploy step, data-migration helper, cron job, local dev tooling).

## Workflow
1. **Decide if bash is the right tool**
   - Good fit: file/process orchestration, gluing CLI tools, short-lived ops tasks.
   - Poor fit: work needing real data structures, deep error handling, or reuse across services — prefer Python.
2. **Scaffold with safety on by default**
   - Apply `~/.claude/rules/bash-scripting-conventions.md` from line 1: shebang, `set -euo pipefail`, `trap` cleanup, `mktemp` for temp files, upfront argument validation.
3. **Structure before logic**
   - Use small functions plus `main "$@"` even when the script looks tiny.
4. **Validate as you go**
   - Run `shellcheck` after every non-trivial edit so quoting/word-splitting bugs are caught early.
5. **Test failure paths, not just the happy path**
   - Run with a missing/invalid argument, a missing dependency (`command -v` check), and a simulated external-command failure to confirm `set -euo pipefail` stops execution where expected.
6. **Report**
   - Summarize what the script does, its inputs/exit codes, and the shellcheck result.

## Guardrails
- Never write output/state to a hardcoded predictable path — use `mktemp`.
- Never interpolate unvalidated input into a command string or `eval`.
- Never let the script continue past a failed step silently; don't paper over `set -e` with `|| true` unless the failure is genuinely expected and the reason is stated.

## Completion checklist
- [ ] `shellcheck` passes (or exceptions are documented and justified).
- [ ] Script fails loudly and immediately on bad input, missing dependency, or a failed step.
- [ ] Temp resources are cleaned up via `trap` even on failure.
