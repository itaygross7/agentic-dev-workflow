---
name: agent-routing
description: Situation map for which agent (or none) fits a task — checked before escalating to a specialist, and answers "which agents do I have" / "which agent fits now".
---

# Agent routing situation map

Explicit commands built on this map: `/list-agents` (prints the roster
below), `/suggest-agent` (states the best fit, launches nothing),
`/agent-info <agent>` (explains one agent and whether it fits now, launches
nothing), `/consult` (states the best fit and launches it), `/consult
<agent>` (validates the name, then launches it).

Every specialist agent also has its own same-named direct-launch command
(`/architect`, `/bug-fixer`, `/bug-investigator`, `/code-creator`,
`/code-improver`, `/code-reviewer`, `/senior-dev`, `/tech-lead`,
`/security-auditor`, `/devops-engineer`, `/product-clarifier`,
`/test-writer`, `/tune-skills`) — the token-cheapest way to run one:
no `agent-routing` lookup, no fit-check, no confirmation, just launch with
the rest of the command as its task. Use these when you already know which
agent you want; use `/consult` (unnamed) or this map when you don't.

`/team <message>` and `/team-custom <lead-agent> <message>` talk to a
persistent team lead instead of one agent at a time — the lead (`senior-dev`
by default, or any of `architect`, `tech-lead`, `code-reviewer`,
`bug-investigator`, `security-auditor`, `product-clarifier` via
`/team-custom`) decomposes the task, spawns whichever specialists it needs
per this map, and owns the one shared `junior-dev` for the whole team — the
lead briefs it, consolidates what comes back, and fans that out to the
specialists. Continuing the conversation resumes the same lead rather than
respawning.

For resuming, finding, or retiring agent work across sessions (not which
agent to pick), see `agent-lifecycle`.

Not for: deciding whether to deviate from steps an already-approved plan
explicitly named — that's a plan-adherence question (see CLAUDE.md's Agent
invocation section), not an agent-choice question. Surface it as a
check-in, don't silently substitute your own approach.

## Agents available
- Explore, Plan, junior-dev — always free to launch, no confirmation.
- architect — new structural/cross-module design, before code, trade-off doc.
- code-creator — implement a new well-specified feature.
- code-improver — behavior-preserving refactor/cleanup.
- bug-investigator — root-cause a bug (read-only).
- bug-fixer — fix a bug whose cause is already confirmed.
- code-reviewer — line-by-line correctness/security/quality review of a diff.
- senior-dev — independent fresh-eyes second opinion / sanity check.
- tech-lead — ship/hold/defer judgment call, priority trade-offs.
- security-auditor — adversarial vulnerability review.
- devops-engineer — CI/CD, containers, deploy config, observability.
- product-clarifier — turn a vague ask into scope + acceptance criteria.
- test-writer — write/refresh pytest coverage.
- tune-skills — audit the skill/agent library itself.
- junior-dev — persistent read-only scout for scrub work. Route to it directly, and auto-fire it without being asked whenever a task is plain bulk reading. Only main (solo) or the team lead (team) briefs it; it reads a source once, returns a consolidated brief, and that brief gets fanned out to whoever needs it rather than each agent re-reading. It names structures (Strategy, Adapter, Repository, layer) and measures them as facts — grading them stays with the senior that receives the brief.

## Situation -> best fit
| Situation | Use |
|---|---|
| "where is X" / "which files reference Y" — breadth unknown, still locating | Explore |
| Target already known, just needs reading through — scrub work, no judgment | junior-dev (auto, no confirmation) |
| The same source will be needed by 2+ agents | junior-dev once, then main/lead fans the brief out |
| Bulk read where an agent would otherwise grind through files itself | junior-dev |
| "why is this built this way" / "what does this do" — answerable from what's already been read | direct-answer-mode (no agent) |
| Same, but an independent take not anchored to the current framing is the actual point | senior-dev |
| Vague/underspecified ask, unclear what "done" means | product-clarifier |
| New component/design spanning modules, before writing code | architect |
| Reviewing a diff/PR for correctness/security/quality | code-reviewer |
| Bug, cause unknown | bug-investigator, then bug-fixer once confirmed |
| Bug, cause already confirmed | bug-fixer |
| New well-specified feature | code-creator |
| Behavior-preserving refactor/cleanup | code-improver |
| Ship/hold/defer, speed-vs-quality call | tech-lead |
| Security/vuln-specific concern | security-auditor |
| CI/CD, Docker, deploy, observability | devops-engineer |
| Need pytest coverage for new/changed behavior | test-writer |
| Auditing the skill/agent library itself | tune-skills |

## Reads go through the junior
One `junior-dev` per task, never several, and never each agent reading the
same source for itself. Who owns it depends on the mode:

- **Solo (no team):** *main* owns it. Main briefs the junior, gets back one
  consolidated brief, and relays that brief in parallel to every agent that
  needs it. Agents receive the brief in their task prompt; they do not go
  fetch it.
- **Team:** the *lead* owns it — same loop, with the lead doing the
  consolidating and distributing instead of main. Main stays out of it.

Either way the junior has exactly one caller. Specialists never message it
peer-to-peer (that path proved unreliable) and never spawn their own.

## Tiers
- **Read-only (safe to auto-fire without a human checkpoint):** Explore, Plan,
  junior-dev, architect, code-reviewer, senior-dev, tech-lead,
  security-auditor, bug-investigator, product-clarifier.
- **Action-capable (Edit/Write/Bash — needs a checkpoint if not user-named):**
  bug-fixer, code-creator, code-improver, devops-engineer, test-writer,
  tune-skills (has Bash despite being prompt-restricted to read-only
  behavior — tiered by tool grant, not by documented behavior).

## Answering "which agent is best now"
Match current accumulated context against the table above and name the
single best fit, cited as "per agent-routing: `<situation>` -> `<agent>`" —
or say "none" if the default (Explore / direct-answer-mode) already covers
it. Don't invoke anything just from being asked — naming the fit is not the
same as launching it.
