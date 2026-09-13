---
paths:
  - "**/*aws*/**/*.py"
  - "**/*s3*.py"
  - "**/*lambda*.py"
  - "**/*boto*.py"
---

# AWS SDK (boto3) rules (scoped)

Apply when writing or editing code that talks to AWS services.

## Credentials and identity
- Never hardcode access keys/secrets; rely on boto3's default credential chain (env vars, `~/.aws`, instance/task role, SSO).
- Prefer IAM roles (EC2/ECS/Lambda execution role) over long-lived static credentials.
- Scope IAM policies to least privilege for the specific actions/resources used; do not request wildcard (`*:*`) permissions for convenience.

## Clients and resilience
- Create one boto3 client/resource per service per process and reuse it; avoid re-creating clients per call.
- Configure retries explicitly via `botocore.config.Config(retries={"max_attempts": N, "mode": "standard"})` instead of relying on undocumented defaults.
- Set explicit timeouts (`connect_timeout`, `read_timeout`) on the `Config` for any network-facing client.
- Always paginate list/describe APIs with the built-in paginator instead of assuming a single page of results.

## Data handling
- Validate and sanitize any user-supplied S3 keys/prefixes before use; reject path traversal (`..`) and unexpected absolute paths.
- Set explicit, short expirations on presigned URLs and scope them to the minimum required action.
- Do not log full ARNs, account IDs, or credentials; log resource identifiers only as needed for debugging.

## Local development/testing
- Use `moto` or LocalStack to mock AWS services in tests; do not hit real AWS accounts from unit tests.

## Done conditions
- No static credentials in code, config, or logs.
- IAM policy referenced/assumed is least-privilege for the task.
- Retries/timeouts are explicit, not implicit defaults.

Source: AWS IAM Best Practices, Boto3 Retries/Config guide, Boto3 Credentials guide (docs.aws.amazon.com/boto3).
