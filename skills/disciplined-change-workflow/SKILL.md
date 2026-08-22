---
name: disciplined-change-workflow
description: Lock, classify, conform, stage, verify, and report a multi-step code or config change in any non-Python context — scripts, CI/CD config, infra-as-code, SQL, Dockerfiles. NOT for Python application code (use python-implementation-workflow) or a single-line trivial edit. Invoke once ownership of the task is decided — if it's still unclear who/what should own this, use start-task first.
---

# Disciplined Change Workflow Skill

Language-agnostic execution discipline for non-trivial changes. `python-implementation-workflow` specializes this for Python; use this skill for bash, YAML/CI config, Dockerfiles, SQL, and infra-as-code. If ownership is still unclear, use `start-task` first; this skill assumes ownership is already decided.

## Workflow
1. **Lock the task**
   - Restate the requested outcome in one sentence.
   - Confirm scope boundaries (files/contracts that must stay stable).
   - If the exact file(s), entry point, or shared contract is unknown, stop and ask instead of guessing.
2. **Classify the change**
   - No change: "why"/"investigate"/"is this correct" -> use `direct-answer-mode` or `bug-investigator`.
   - Surgical: exact failure point only; no rename, reformat, or drive-by edits.
   - Surgical+ (improvement): one qualifying concern, no interface/behavior change.
   - Targeted: bounded feature/change using existing patterns.
   - Structural: cross-component redesign; requires an approved plan first (`architect` agent / `plan-change` prompt). If none exists, stop and ask.
   - Default to the smallest class the task allows. If it can't stay there, stop and report rather than silently widening scope.
3. **Conform before writing**
   - Read the target file's style and 1-2 sibling files with the same role; match existing naming, structure, error handling, and tools.
   - Reuse existing helpers/config patterns instead of reimplementing.
4. **Plan stages**
   - Build an ordered stage list; each stage has explicit verification.
5. **Implement incrementally**
   - Never leave the tree in a broken intermediate state.
   - Avoid unrelated refactors and speculative abstractions.
   - If a stage shows the plan is wrong or scope must grow, stop, report, and ask before improvising a structural change.
6. **Verify**
   - Run the right check for the file type: tests, linter, `shellcheck`, CI-config syntax check, `terraform plan`, or equivalent dry-run.
7. **Report**
   - Summarize what changed, why, what was verified, and any residual risks/follow-ups.

## Guardrails
- Preserve existing contracts/interfaces unless the task explicitly authorizes a change.
- No secrets in code, config, or logs.
- No silent failure paths.
- Prefer reuse over duplication.

## Completion checklist
- [ ] Requested outcome implemented within locked scope.
- [ ] Conforms to surrounding-file conventions.
- [ ] Relevant verification for this change kind passed.
- [ ] Report includes changed files and verification summary.
