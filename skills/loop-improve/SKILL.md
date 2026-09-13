---
name: loop-improve
description: Run a bounded improve -> re-read -> review convergence loop over a target, led by senior-dev in [LOOP MODE]. code-improver fixes, the shared junior-dev re-reads only the delta, code-reviewer judges the diff, and the lead re-loops or stops on one of four exit conditions. Use when code is known to need work but the work is open-ended enough that one improver pass won't settle it. NOT for a diagnosed bug (use /fix-bug) or a one-shot cleanup (use /improve-code). Only invoked explicitly via /loop-improve.
disable-model-invocation: true
argument-hint: [--lead <agent>] <target — file, module, or diff scope>
---

# /loop-improve <target>

Parse an optional leading `--lead <agent>` off `$ARGUMENTS`; the rest is the target.
Default lead is `senior-dev`, nickname `loop`. With `--lead <agent>`, validate it against the
7 Loop-Mode-capable agents — `senior-dev`, `architect`, `tech-lead`, `code-reviewer`,
`bug-investigator`, `security-auditor`, `product-clarifier` — and if it is not one of these,
say so, list the valid choices, and launch nothing. The nickname is then `loop-<lead-agent>`.

If the lead is `code-reviewer`, say in its spawn prompt that it must spawn a **separate**
`code-reviewer` for step 3 rather than judging the diff itself — a lead grading its own loop
is exactly the self-report the delta re-read exists to avoid.

The loop keeps **three standing members** — improver, junior, reviewer — spawned once and resumed by message thereafter. That is what makes the churn and divergence exits mean anything: a reviewer comparing against its own memory is comparing, a fresh one each round is only re-reading a summary you handed it.

This is `/team` with one added grant: the lead may spawn `code-improver` without checkpointing, bounded by the caps in its Loop Mode block. Every other action-capable specialist still checkpoints as usual.

## Before spawning
Confirm `<target>` is scoped to something a reviewer can hold at once — a file, a module, or a diff. An unscoped target ("the codebase") makes the churn and divergence exits meaningless, because each round reviews different code. If it's unscoped, ask Itay to narrow it and launch nothing.

## Procedure
1. Look up nickname `<nickname>` in this session's `agent-registry.md` (scratchpad directory; per `agent-lifecycle`).
   - **Found, status running/completed** → `SendMessage({to: <its agentId>, message: "[LOOP MODE] [TEAM LEAD MODE] " + $ARGUMENTS, summary: "<short recap>"})`. Log `main -> <nickname>: resumed` in `## Communications`.
   - **Not found** (first call, or file doesn't exist yet):
     a. Spawn a `junior-dev` instance via the Agent tool. Register it in `agent-registry.md` as nickname `<nickname>_junior` (row: `<nickname>_junior | <agentId> | junior-dev | running | shared read service for loop`).
     b. Spawn `<lead-agent>` via the Agent tool with prompt: `"[LOOP MODE] [TEAM LEAD MODE] shared junior-dev: loop_junior (agentId <its agentId>) — you are its only caller, and it is the loop's memory: brief it once for a baseline read of the target, then ask only for deltas on later iterations. Specialists must not message it or spawn their own. Target: " + $ARGUMENTS`, **overriding `model: opus`** for this call. Register it as nickname `<nickname>`.
     c. Register the two other standing members as they are spawned on iteration 1 — `<nickname>_improver` (`code-improver`) and `<nickname>_reviewer` (`code-reviewer`) — so `agent-lifecycle` can find and resume them, and so a later `/session-agents` shows the whole loop rather than just the lead.
     d. Log all spawns in `## Communications`: `main -> <nickname>_junior: spawned (shared junior)`, `main -> <nickname>: spawned (lead, <lead-agent>)`.
2. Relay what the lead returns. Always surface, verbatim, the **exit reason** and the **per-iteration `must_fix` count** — those two are how Itay tells convergence from a cap that merely ran out, and summarizing them away defeats the loop.

## Exits that are not "converged"
`cap reached`, `churn`, and `diverging` are checkpoints, not failures. Surface the lead's report as-is and wait — do not re-run the loop to try for a cleaner result, and do not fix the remaining `must_fix` yourself. A follow-up `/loop-improve [--lead <agent>] <reply>` continues the same instance via step 1's "found" branch.

If the exit is `diverging`, say so plainly: the improver is making the code worse under review, and the next move is Itay's call, not another iteration.
