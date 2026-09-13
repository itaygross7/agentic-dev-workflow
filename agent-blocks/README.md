# agent-blocks

Single source of truth for prose duplicated across `~/.claude/agents/*.md`.

## Why

Three sections were byte-identical across many agent files with no include
mechanism, so every wording change meant editing up to 7 files by hand. On
2026-08-11 that hand-sync happened three times in one day, and nothing detected
a missed copy — a stale copy is a silently divergent agent.

Markdown has no transclusion, and most agents do not carry the `Skill` tool, so
a block cannot be resolved at runtime. These blocks are expanded ahead of time
instead: the agent files on disk stay fully self-contained, so **agent behaviour
is unchanged** by the mechanism.

## Blocks

| Block | Lines | Sites | What it says |
|---|---|---|---|
| `reads-lead.md` | 4 | 7 | Team Lead Mode owns the one shared `junior-dev`; forward its brief, read the judged artifact yourself |
| `team-lead-mode.md` | 8 | 7 | Decompose, route via `agent-routing`, spawn read-only tiers directly, checkpoint action-capable ones |
| `reads-consumer.md` | 2 | 6 | Don't self-read in bulk; a brief is orientation, not the artifact you're judging |
| `loop-mode.md` | 12 | 7 | `[LOOP MODE]` bounded pre-auth: lead may spawn `code-improver` uncheckpointed, capped at 3 iterations with churn/divergence exits |

## Workflow

```bash
python3 build_agents.py            # expand blocks into every marked site
python3 build_agents.py --check    # report drift, change nothing, exit 1
```

Edit the block file, run `build_agents.py`, done. Never edit text inside a
`<!-- begin: … -->` / `<!-- end: … -->` region in an agent file — the next
rebuild overwrites it. `--check` exists to catch exactly that, and is worth
wiring into a pre-commit hook.

## Caveat that bites

Agent definitions load when Claude Code **starts**. A rebuild does not affect
subagents spawned in a session that was already running — testing a block change
requires restarting Claude first. To confirm which definition a session is
actually running, compare the agent file's mtime against the process start time:

```bash
stat -c '%y' ~/.claude/agents/junior-dev.md
ps -eo pid,lstart,cmd | grep '[c]laude'
```

Process newer than file means the edits are loaded. Do not try to infer this
from a subagent's output — a cheap model will normalise a changed section header
on its own, which produces a false "not loaded" reading.
