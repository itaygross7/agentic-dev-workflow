---
name: aws-integration-workflow
description: Wire up a new AWS service integration (client, IAM scope, retries, local testing) safely. Use when adding or changing code that calls an AWS service via boto3.
---

# AWS Integration Workflow Skill

Use when adding a new AWS service call (S3, SQS, DynamoDB, etc.) or changing how one is configured — not for routine business logic near AWS code.

## Workflow
1. **Scope IAM permissions first**
   - Identify the exact actions/resources needed before writing the client call.
   - Write the least-privilege policy statement down; don't start with a wildcard and promise to tighten it later.
2. **Build the client once, with explicit resilience config**
   - Reuse one client/resource per service per process; never recreate one per call.
   - Set explicit `Config(retries={...}, connect_timeout=, read_timeout=)` per `~/.claude/rules/aws-conventions.md`; never rely on undocumented SDK defaults.
3. **Handle pagination and partial failure explicitly**
   - Use the built-in paginator for list/describe calls.
   - For batch operations, handle partial failures in the response; HTTP success does not mean every item succeeded.
4. **Keep secrets out of the path**
   - Use the default credential chain / IAM role; never hardcode keys. Don't log ARNs, account IDs, or presigned URLs above debug level.
5. **Test locally without touching real infrastructure**
   - Use `moto`/LocalStack in unit tests; reserve real AWS for explicit, clearly labeled integration tests.
6. **Verify**
   - Confirm timeouts/retries are set, IAM scope matches step 1, and tests run without live AWS credentials.
7. **Report**
   - Summarize the service/actions used, required IAM scope, and test approach.

## Guardrails
- Never request `*:*` or overly broad resource ARNs for convenience.
- Never let a presigned URL have a long or unbounded expiration.
- Never rely on assumed default retry/timeout behavior — set it explicitly.

## Completion checklist
- [ ] IAM policy is least-privilege for the exact actions used.
- [ ] Client has explicit retries and timeouts configured.
- [ ] Unit tests use `moto`/LocalStack, not live AWS.
