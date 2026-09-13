---
name: devops-workflow
description: Design or change a CI/CD pipeline, containerization setup, or deployment configuration with fail-fast gates and a rollback path. Use for build/test/deploy pipeline changes, Dockerfiles, or environment/observability configuration.
---

# DevOps Workflow Skill

Use when changing how code is built, tested, deployed, or observed — not application business logic. For a fully delegated isolated pass, use `devops-engineer`; use this skill for lighter in-session reasoning.

## Workflow
1. **Read existing conventions first**
   - Match current stage naming, script structure, and tooling instead of introducing a second pattern.
2. **Order stages to fail fast**
   - Lint/type-check -> unit tests -> security/dependency scan -> build -> integration tests -> deploy.
3. **Pin for reproducibility**
   - Pin base images and dependency locks; avoid `:latest` or unpinned installs in shared/prod paths.
4. **Design the secrets path first**
   - Secrets come from a secret manager/CI secret store at runtime — never hardcoded, logged, or baked into an image layer.
5. **Scope deployment credentials to least privilege**
   - Prefer short-lived/OIDC-based credentials over long-lived static ones (see `~/.claude/rules/aws-conventions.md` for AWS).
6. **Design rollback with deploy**
   - Every deploy change needs a fast rollback path (previous image tag, reversible migration).
7. **Add observability before calling it done**
   - Structured logs, health checks, and basic metrics/alerts for anything newly deployed.
8. **Verify**
   - Lint CI syntax if a tool exists; dry-run where possible; otherwise state how correctness was reasoned about when it can't run locally.

## Guardrails
- A red gate (lint/test/scan failure) must block promotion, not just warn.
- Never let a secret reach a log line, build cache, or image layer.
- Never ship a deploy change with no rollback path.

## Completion checklist
- [ ] Pipeline stages are ordered cheapest/fastest-fail first.
- [ ] No hardcoded secrets; credentials are least-privilege and short-lived where possible.
- [ ] Rollback path and basic observability exist for the deployed change.
