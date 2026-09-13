# ~/.claude/rules — path-scoped conventions

Eleven conventions that used to be skills. They never fired as skills: skill
matching is event-driven on a request, and a passive convention has no event.
A `paths:` glob fires on the right event — Claude opening a matching file.

**These are user-level and apply to every repo, including ones that don't exist
yet.** No per-repo setup. Verified working on Claude Code 2.1.263 on 2026-09-06
by probe: a rule here with `paths: ["**/*.py"]` loaded on reading a .py file.
Open issues #21858 / #22170 claim user-level `paths:` is ignored; that was not
true on this version. If conventions ever stop loading, re-run that probe
before assuming anything else.

Verify what loaded with `/context` (Memory files), or read
`~/.claude/instructions-loaded.log`, written by the InstructionsLoaded hook.

A repo can still add its own `.claude/rules/` for repo-specific conventions;
user-level rules load first, so project rules take precedence.
