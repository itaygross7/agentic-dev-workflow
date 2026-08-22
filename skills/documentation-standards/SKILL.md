---
name: documentation-standards
description: "Documentation-editing rules: accuracy first, never invent undocumented behavior, keep sections scannable, never document sensitive values. Apply when editing docs, README, or other markdown files."
---

# Documentation change rules (scoped)

Apply when editing docs.

## Accuracy first
- Document existing behavior; do not invent behavior not present in code.
- Keep setup/run/test commands aligned with repository reality.

## Quality
- Prefer short, scannable sections and concrete examples.
- Update docs when behavior, interfaces, or required configuration changes.
- Mark uncertain statements explicitly instead of guessing.

## Scope
- Do not include sensitive values, credentials, or private internal paths.
- Keep changes focused on the requested documentation task.

## Done conditions
- Every documented command/behavior matches current repository reality.
- No invented behavior, no sensitive values, no unrelated edits.
