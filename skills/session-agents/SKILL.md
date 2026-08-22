---
name: session-agents
description: List every agent instance spawned this session — nickname, persona, status, purpose. Add "chart" for a compact free ASCII tree, or "flow" for free bordered-box ASCII art. Only invoked explicitly via /session-agents.
disable-model-invocation: true
argument-hint: [chart|flow]
---

# List agent instances

Read the registry file (`agent-registry.md` in this session's scratchpad
directory, maintained by `agent-lifecycle`). If the file doesn't exist yet,
say no agents have been spawned this session.

## Default (no arguments): table
Print: nickname, persona, status (running/completed/failed), one-line
purpose, agentId.

## `$ARGUMENTS` contains "chart": ASCII diagram
Render directly from the file's own text — no extra tool calls, no
sub-agent, just reformatting what's already in the registry, so this stays
cheap. Nodes from the table, arrows from the `## Communications` log, oldest
first. Don't invent an edge that isn't in the log; if the log is empty, show
the node list only. Compact, no prose around it.

Use a status emoji instead of the word (🟢 running, ✅ done, ❌ failed) and
right-pad nicknames so the persona column lines up — this reads better in a
plain markdown chat than ANSI color (not guaranteed to render here) or a
mermaid block (not guaranteed to render as a diagram here either). One
legend line, then the tree. Shape:

```
Legend: 🟢 running  ✅ done  ❌ failed

main
 ├─▶ 🟢 architect_1     [architect]          design review
 ├─▶ ✅ senior-dev_1    [senior-dev]         sanity check
 └─▶ ❌ bugfix_1        [bug-fixer]          auth null check
        │
        └──🔁 relay──▶ architect_1
```

## `$ARGUMENTS` contains "flow": bordered-box ASCII art
Still pure text, still zero extra tool calls — just box-drawing characters
instead of a bullet tree. Stack one bordered box per registry row, oldest
spawn first, connected by a single vertical arrow chain (robust for any
number of agents — don't attempt side-by-side branching layouts, alignment
across multiple columns isn't reliable to render correctly every time).
Label each connecting arrow with the communications-log entry between those
two agents if one exists (e.g. "relay"); if two agents aren't adjacent in
the log, add a short text note instead of drawing a cross-page arrow. Box
width = its own longest content line + 2 chars padding, borders drawn with
`┌─┐│└─┘`. Shape:

```
┌────────────┐
│    main    │
└─────┬──────┘
      │
      ▼
┌────────────────────────┐
│ architect_1             │
│ [architect] 🟢 running  │
└─────┬───────────────────┘
      │
      ▼
┌────────────────────────┐
│ senior-dev_1              │
│ [senior-dev] ✅         │
└─────┬───────────────────┘
      │ relay
      ▼
┌────────────────────────┐
│ bugfix_1                 │
│ [bug-fixer] ❌ failed    │
└──────────────────────────┘
```
