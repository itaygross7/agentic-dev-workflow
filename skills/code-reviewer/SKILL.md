---
name: code-reviewer
description: Directly launch the `code-reviewer` agent (line-by-line correctness/security/quality review of a diff or PR, read-only) with the rest of the command as the scope. Explicit command "/code-reviewer <scope>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <diff/PR/files to review>
---

# /code-reviewer <scope>

Launch the `code-reviewer` agent (Agent tool, `subagent_type: code-reviewer`) directly using `$ARGUMENTS` as the task — if empty, default to the current working diff — no `agent-routing` lookup, no fit restatement, no confirmation step (read-only, always safe to auto-fire).

Relay its must-fix/should-fix/nice-to-have findings back to the user when it completes.
