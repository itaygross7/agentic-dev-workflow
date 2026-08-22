---
name: mongodb-conventions
description: "MongoDB access rules: single reused client per process, explicit timeouts/pool size, TLS+auth, explicit projections, indexed queries, validated ObjectId, explicit write concern. Apply when writing or reviewing MongoDB/repository code, or a prompt mentions Mongo, collections, or ObjectId — triggers on topic, not file path. For schema/index design when adding a new collection see mongodb-data-workflow."
---

# MongoDB rules (scoped)

Apply when writing or editing MongoDB access code (pymongo/motor).

## Connections
- Instantiate `MongoClient`/`AsyncIOMotorClient` once per process and reuse it; never open a new client per request.
- Set explicit `serverSelectionTimeoutMS` and a bounded `maxPoolSize`; do not rely on unbounded defaults.
- Require TLS (`tls=True`) and authentication (SCRAM) for any non-local deployment; never disable certificate verification.

## Queries and schema
- Always pass an explicit projection to return only needed fields; avoid unbounded `find()` scans on unindexed fields.
- Add/verify a supporting index for any new query or sort pattern before shipping it.
- Never build queries with `$where`/server-side JS or string-concatenated operators from user input.
- Validate and coerce `ObjectId` inputs (`ObjectId(id)` in a try/except) before querying; reject malformed ids at the boundary.
- Use an explicit write concern for multi-document or financially/consistency-sensitive writes instead of relying on defaults silently.

## Migrations and evolution
- Treat schema changes as additive/versioned (new optional fields) unless a task explicitly authorizes a breaking migration.
- Backfill/migrate existing documents via an explicit, idempotent script — never assume old documents match the new shape.

## Done conditions
- Queries use indexes that exist (verified via `explain()` or `getIndexes()` where practical).
- No raw user input reaches query operators unvalidated.
- Client lifecycle (create once, close on shutdown) is respected.

Source: MongoDB Production Notes & Security Checklist (mongodb.com/docs/manual), PyMongo connection pooling FAQ.
