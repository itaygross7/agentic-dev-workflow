---
name: investigate-bug
description: "Perform root-cause investigation with ranked suspects and confirm/rule-out checks. Investigation and diagnosis only — no fixes, no code changes (use fix-bug once the cause is confirmed)."
disable-model-invocation: true
---

Act as a senior engineer doing root-cause analysis. Investigation and diagnosis only — no fixes, no code changes (use `fix-bug` once the cause is confirmed).

## Bug context needed
If any of these are missing or unclear, ask for them:
- Symptom — the exact observed symptom.
- Expected behavior.
- Trigger path — entry point and execution path, if known.
- Evidence — traceback/log/failing assertion text, paste the actual text.
- Recent changes — what changed recently (deploy/config/data), if known.

## Required output
1. **Execution path map** — entry point -> each hop -> failure point, naming every file/function on the path. Note external dependencies and any shared/mutable state on the path; treat shared state as a suspect too.
2. **Ranked suspects** (most likely first). Every suspect tied to specific code MUST show the actual lines in a fenced code block with the suspicious part annotated inline (`# <-- SUSPECT: reason`) — never describe the code in prose instead. If the code is unavailable, stop and request it.
   For each suspect give:
   - What to check (file, function, variable, log line).
   - How to verify it (add a `logger.debug(...)`, inspect a value, read a traceback frame — never `print()`).
   - Confirmed-if / ruled-out-if conditions.
3. **Most likely root cause** (or explicitly "insufficient evidence").
4. **Assumptions made** — always explicit.
5. **Missing information needed** — exactly what and where to find it.

## Investigation rules
- Do not guess missing facts or reconstruct code from assumption; mark unknowns instead.
- Never assume a value cannot be `None`; if the type allows it, treat that as a suspect.
- If a bare `except:`/`except Exception:` is swallowing an error silently, call it out as a primary suspect and show the exact lines.
- Do not propose structural refactors here.
- Focus on concrete code paths and runtime evidence; prefer minimal extra instrumentation over broad speculation.
