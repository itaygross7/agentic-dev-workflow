---
name: python-implementation-workflow
description: Execute a Python change end to end — lock the scope, stage the edit, verify it runs, report what changed — for prompts like "implement X", "add this to <file>.py", "change how Y works", "fix this function". Keeps the change inside the stated scope and refuses silent extras. NOT for non-Python files (use disciplined-change-workflow), a one-line trivial edit, or an undiagnosed bug (investigate first).
---

# Python Implementation Workflow Skill

Python-specific specialization of `disciplined-change-workflow`. Read that skill for the full lock/classify/conform/stage/verify/report process; this file adds only Python-specific requirements.

## Python-specific additions
- **Contracts**: add type hints to new/changed signatures; keep function/return contracts backward-compatible unless the task requires a break; prefer explicit domain models over ad-hoc dicts across boundaries.
- **Verification**: run the relevant `pytest` command for touched areas (broader suite when impact is wide), not a generic "tests" check.
- **Reporting**: for non-trivial work, produce both a short **Change Doc** (task, approach, files changed, verified, follow-ups — presentable next to a ticket) and a detailed **Final Report** (completed items, files changed with change type, test results, any rule violations and why, known limitations).

## Guardrails (Python-specific, in addition to the general skill's)
- Validate untrusted input at boundaries.
- Use `logging`, never `print`, in production code.

## Completion checklist
- [ ] Everything in `disciplined-change-workflow`'s checklist is satisfied.
- [ ] Type hints present on new/changed signatures.
- [ ] Relevant `pytest` run passed; security and error-handling constraints preserved.
- [ ] Final report includes changed files and verification summary.
