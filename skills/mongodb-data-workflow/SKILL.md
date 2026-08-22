---
name: mongodb-data-workflow
description: Design a MongoDB schema/query pattern, add a supporting index, and evolve it safely through migrations. Use when adding a new collection, a new query pattern, or changing an existing document schema.
---

# MongoDB Data Workflow Skill

Use when adding a collection, a new query/sort pattern, or a document-shape change — not for routine CRUD that already follows repo conventions.

## Workflow
1. **Design the access pattern first**
   - Write the queries before shaping the document; Mongo schema design is query-driven, not relational normalization.
   - Decide embed vs. reference: embed data always read together and bounded in size; reference data that's large, unbounded, or updated independently.
2. **Lock the index with the query**
   - Every new query/sort pattern gets its supporting index in the same step — see `mongodb-conventions` for connection/index rules.
   - Check `explain()` to confirm index use rather than a collection scan.
3. **Validate boundaries**
   - `ObjectId` and any user-supplied filter must be validated/coerced at the boundary (per `security-boundaries`) before reaching a query.
4. **Plan schema evolution as additive**
   - New fields are optional/additive by default; a breaking shape change needs an explicit idempotent backfill script.
5. **Implement in order**
   - Client/connection reuse -> query + projection + index -> boundary validation -> migration/backfill if breaking.
6. **Verify**
   - Confirm index use with `explain()`, reject malformed `ObjectId`/filters at the boundary, and prove migration idempotency.
7. **Report**
   - Summarize the access pattern, index, and any migration/backfill plan.

## Guardrails
- Never query without an explicit projection on a collection that can grow large.
- Never build a query operator from string-concatenated user input.
- Never assume old documents already have a newly-added required field.

## Completion checklist
- [ ] Every new query has a supporting index, confirmed via `explain()`.
- [ ] User-supplied ids/filters are validated before reaching the query layer.
- [ ] Schema change is additive, or has an explicit idempotent migration.
