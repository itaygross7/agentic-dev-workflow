---
name: shed
description: Cut the current session down to what still matters — extract the decisions, changes, and open questions worth carrying, name what has become dead weight, and write a handoff you can start a fresh session from. Triggers on "this session is getting heavy", "shed the context", "summarize and drop the rest", "hand this off", or before a long task when the window is already crowded. NOT for cross-session recall of past projects (auto-memory already does that) and NOT for auditing the skill library (use tune-skills).
disable-model-invocation: true
argument-hint: [optional: what the next session should focus on]
---

# /shed [focus]

Produce a handoff that makes the current session disposable. Everything stays on
this machine — no transcript is sent anywhere.

A subagent cannot do this. It has its own context window, and its report lands in
yours, so delegating makes the session heavier. Run this in the main thread.

## 1. Measure first
Tell the user to run `/context` and read the breakdown, or state plainly that you
are estimating without it. Name the three largest consumers you can actually see:
whole-file reads, long command output, subagent reports, repeated reads of the same
path. Do not guess at token numbers you cannot observe — say "large" and name the
source instead of inventing a figure.

## 2. Keep — the load-bearing set
Extract only what the next session cannot re-derive from the repo:

- **Decisions and their reasons.** "We chose X over Y because Z." The reason is the
  part that is expensive to recover; the choice alone is not enough.
- **Changes made**, as paths plus one line each. Never restage file contents — the
  files are on disk and re-reading them is cheap.
- **Open questions** and anything waiting on the user.
- **Active constraints** discovered this session: a version pin, a broken upstream
  behavior, an approach already tried and ruled out.
- **Live state**: running agents and their nicknames, background tasks, uncommitted
  work, anything with a rollback path.

## 3. Name the dead weight explicitly
Do not silently omit — list what you are dropping so the user can object:

- File contents already read and since edited, superseded by what is on disk
- Approaches abandoned mid-session (keep one line saying it was ruled out, and why)
- Errors that were resolved, and the debugging that led there
- Tool output that has been summarized already
- Anything the repo, `git log`, or CLAUDE.md already states

## 4. Write it
Save to the scratchpad as `handoff-<topic>-<YYYY-MM-DD>.md`. Keep it under 100
lines: past that it stops being a reduction. Structure it as **Goal / Decisions /
Changed / Open / Constraints / Live state**, in that order, so the next session
reads the reason before the detail.

If `$ARGUMENTS` names a focus, bias the Keep set toward it and be more aggressive
about dropping the rest.

## 5. Hand back
Report the path, then state the choice plainly:

- `/clear` and paste the handoff — same terminal, empty window, full control.
- `/compact` instead — cheaper, but the summary is the harness's, not this one, and
  it keeps material this pass judged droppable.
- A fresh session started against the handoff, when the next task is genuinely
  separate work rather than a continuation.

Do not run `/clear` or `/compact` yourself. Dropping context is irreversible and
the user decides when.

## Boundary
This is in-session weight reduction. Cross-session recall is already handled by
built-in auto-memory, which writes to `~/.claude/projects/<project>/memory/` on its
own — do not duplicate it, and do not write memories from here.
