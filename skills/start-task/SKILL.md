---
name: start-task
description: "Kick off any task without picking a role yourself — describe the problem and get a recommended agent/skill before work begins. Invoke deliberately when it's unclear who/what should own a task."
disable-model-invocation: true
---

Before doing any work, analyze this request and recommend the best-fit specialist agent (or plain default work if no specialist fits better than proceeding directly). Do not start implementing until the routing recommendation is stated, unless the fit is obvious and the task is trivial.

## Problem
What are you trying to solve or build? Describe the symptom/goal in your own words. If not given, ask for it.

## Requirements / definition of done
What must be true when this is finished? If not yet known, that's a signal to route to `product-clarifier`.

## Context
Relevant files, modules, prior decisions, or constraints (deadline, stack, existing patterns to follow).

## Rules to follow especially
Any specific skills, invariants, or constraints that matter most for this task — e.g. "security-boundaries", "must not change the public API".

## Required output
1. **Task shape** — one sentence: is this unclear/needs scope (→ `product-clarifier`), structural/cross-module (→ `architect`), a judgment call (→ `tech-lead`), a new build (→ `code-creator`), a fix for a known cause (→ `bug-fixer`), an unknown bug (→ `bug-investigator`), a non-behavior-changing improvement (→ `code-improver`), tests (→ `test-writer`), a review/audit (→ `code-reviewer` / `security-auditor`), or pipeline/infra (→ `devops-engineer`)?
2. **Recommended agent(s)**, in order if more than one is needed (for example `bug-investigator` → `bug-fixer`, or `product-clarifier` → `architect` → `code-creator`).
3. **Handoff prompt** — a ready-to-paste prompt for the first recommended agent, containing the problem, requirements, context, and rules so it does not need to be re-typed (agents start with no memory of this conversation).
4. If no specialist fits better than default work in this session, say so plainly and proceed directly instead of forcing delegation.

## Rules
- If the problem/requirements are too thin to route confidently, recommend `product-clarifier` rather than guessing.
- Never recommend more agents than the task needs; a trivial one-file fix does not need `architect`.
