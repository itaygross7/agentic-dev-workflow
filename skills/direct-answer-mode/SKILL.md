---
name: direct-answer-mode
description: Give a complete, copy-paste-ready answer or explanation without editing files or delegating to an agent. Use when the user asks "why"/"how"/"what should I change", wants a fix they apply themselves, or just wants a direct answer rather than an implementation.
---

# Direct Answer Mode Skill

Use when one direct reply closes the request. Don't route a simple question through agent delegation or a multi-stage workflow.

## When this applies
- "Why" / "how" / "what does this do" — understanding, not implementation.
- "What should I change" — the user will apply it.
- "Is this correct" — a verdict is wanted, not a rewrite.
- Diagnosis ("why is this broken") without an explicit ask to fix it in place.

Do **not** use this to implement/build/fix in the repo — use `code-creator`, `bug-fixer`, `code-improver`, or `disciplined-change-workflow` (`python-implementation-workflow` for Python). `fix-bug` and `improve-code` are ready-made templates for propose-don't-edit bug and improvement requests.

If the caller wants an **independent** read rather than an answer from this session's context, delegate to `senior-dev`.

Not for "which agent fits this" / "which agents do I have" — those route to `agent-routing` (or the explicit `/list-agents`, `/suggest-agent`, `/agent-info` commands), not a generic direct answer.

## Rules
- One reply should close the question: no phases, no approval loop, no file edits.
- Ask at most **one** clarifying question if required context is genuinely missing; never answer against assumed/unseen code.
- Show the **complete function or file section** for any code — never a fragment, never `...`.
- For a multi-file change, give an ordered copy-paste sequence: one block per file in apply order, each with a one-line "where / why" header.
- Match depth to the ask: terse verdict for "is this correct", prose for "why/how", full code for "what should I change."
- Append `Could break if: <concrete scenario>` after a code block, unless nothing plausible can break.
- If still unresolved after 2-3 exchanges, stop iterating incrementally and give one self-contained restatement (context, attempts, exact remaining question, constraints).

## Done conditions
- The user has what they need to apply the change or understand the answer without a follow-up, unless a follow-up was explicitly invited.
- No file was edited under this skill.
