---
paths:
  - "**/dal/**/*.py"
  - "**/db/**/*.py"
  - "**/migrations/**/*.py"
  - "**/alembic/**/*.py"
---

# Relational DB / ORM rules (scoped)

Apply when writing or editing SQLAlchemy/ORM data-access code or migrations.

## Sessions and connections
- Scope one session per request/unit-of-work; never share a session across threads/requests.
- Use a connection pool with explicit size/overflow/timeout config; don't rely on undocumented defaults.
- Always close/return sessions via a context manager, even on error paths.

## Queries
- Select only needed columns/relations; avoid `SELECT *`-style full-entity loads in hot paths.
- Use eager loading (`joinedload`/`selectinload`) deliberately to avoid N+1 queries in loops; lazy
  loading inside a loop is a default suspect for an N+1 bug.
- Never build SQL via string formatting/concatenation from user input — use parameterized
  queries/ORM constructs exclusively.
- Wrap multi-statement writes in an explicit transaction; commit once per unit of work, not per statement.

## Migrations
- Every schema change ships an Alembic (or equivalent) migration alongside the model change —
  never let the model and live schema drift.
- Make migrations additive/backward-compatible by default (new nullable column, new table);
  a breaking migration (drop/rename/NOT NULL without default) needs an explicit justification
  and a rollout plan for existing data.
- Migrations must be idempotent and reversible (`downgrade()` implemented, not `pass`).

## Done conditions
- No raw user input reaches SQL text unparameterized.
- New/changed queries avoid N+1 patterns (verified by inspecting emitted queries, e.g. `echo=True` in dev).
- Every model change has a matching migration.

Source: SQLAlchemy 2.0 documentation (docs.sqlalchemy.org/en/20), Alembic documentation (alembic.sqlalchemy.org).
