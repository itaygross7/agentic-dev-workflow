---
name: fix-bug
description: "Diagnose then fix a known bug with the smallest safe change (minimal vs defensive option). Invoke deliberately once the root cause is known — not for open-ended investigation, use investigate-bug for that."
disable-model-invocation: true
---

Fix this bug with the smallest possible change to the exact failure point.

## Inputs needed
If any of these are missing, stop and ask for them instead of guessing:
- File/function containing the bug (e.g. `path/to/file.py::function_name`).
- The exact wrong lines (paste the real code, not a description).
- Evidence (traceback/log/failing assertion text).
- Callers affected (any callers whose behavior might change).

## Required output
1. Root cause — one sentence: the exact line and why it is wrong.
2. "This fix could break if" — one concrete scenario.
3. **Option A — Minimal fix**: change only the exact wrong lines. Show the complete existing function and the complete replacement function (never a fragment), with changed lines marked `# CHANGED` and added lines marked `# ADDED`.
4. **Option B — Defensive fix** (only if Option A leaves an obvious gap): same format, plus one sentence on why the extra guard is justified.

## Constraints
- Read the actual code before proposing a fix; never reconstruct or assume it.
- Do not rename, reformat, or restructure outside the exact failure point.
- Do not change function signatures unless the bug is in the signature itself.
- Preserve all existing comments exactly.
- Default to Option A; add Option B only for a concrete justified gap, not "just in case" (YAGNI).
- If required context (exact code, traceback) is missing, stop and list exactly what is needed instead of guessing.
