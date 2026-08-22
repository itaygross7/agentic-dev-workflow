---
name: security-auditor
description: Directly launch the `security-auditor` agent (adversarial vulnerability review — injection, broken auth, secret leakage, SSRF, etc., read-only) with the rest of the command as the scope. Explicit command "/security-auditor <scope>" — skips the agent-routing fit-check and confirmation gate; naming this command is the go-ahead.
disable-model-invocation: true
argument-hint: <route/file/module to audit>
---

# /security-auditor <scope>

Launch the `security-auditor` agent (Agent tool, `subagent_type: security-auditor`) directly using `$ARGUMENTS` as the task — no `agent-routing` lookup, no fit restatement, no confirmation step (read-only, always safe to auto-fire).

Relay its vulnerability report back to the user when it completes.
