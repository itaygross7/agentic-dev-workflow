---
name: agent-info
description: Explain a specific agent in short — what it does, and whether/why it fits the current situation. Explicit command "/agent-info <agent>".
disable-model-invocation: true
---

# /agent-info <agent>

1. Validate `<agent>` against `agent-routing`'s list
   (`~/.claude/skills/agent-routing/SKILL.md`). If unknown, say so and stop.
2. Read that agent's own definition (`~/.claude/agents/<agent>.md`) for its
   actual description and mandate — `agent-routing`'s one-liner is a
   pointer, not the source of truth.
3. Answer in a few lines, not a wall of text:
   - What it does (from its own frontmatter description).
   - Whether it fits the *current* conversation right now — give an honest
     verdict either way:
     - Fits -> cite it the same way as elsewhere: "per agent-routing:
       `<situation>` -> `<agent>`".
     - Doesn't fit -> say so plainly and name what would fit instead
       (check `agent-routing`'s table), don't force a fit that isn't there.

Launch nothing; this only explains. To actually run it, use `/consult
<agent>`.
