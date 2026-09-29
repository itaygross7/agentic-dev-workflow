# agentic-dev-workflow

A multi-agent Claude Code setup I designed, built, and use every day on
production Python backend work.

The full configuration is private. This page describes what it does, how it is
designed, and what I learned building it.

---

## At a glance

| | |
|---|---|
| **14 specialist agents** | Architect, code reviewer, security auditor, bug investigator, bug fixer, test writer, DevOps engineer, tech lead, and more — each with a narrow role and the least tool access it needs |
| **32 skills** | Workflows (planning, bug fixing, refactoring, API design, async, AWS, MongoDB, CI/CD) plus a command surface for driving the agents |
| **11 convention rules** | Python, REST, MongoDB, SQL, AWS, Bash, networking security, and more — loaded automatically when a matching file is opened |
| **3 hooks** | Auto-formatting and type-checking on every edit, plus logging of what actually loaded and fired |
| **A build system** | Keeps shared text across agent definitions in sync and blocks commits on drift |

---

## Design highlights

### Routing: the right specialist, or none at all

Every specialist is a fresh context that re-reads the codebase and returns a
report, so calling the wrong one is expensive. A written routing map decides
which agent a situation warrants, and every call has to cite it. That makes
each choice defensible and every wrong pick visible afterward.

Agents are split into two tiers by the tools they hold, not by what their
prompt says. Read-only agents run freely. Agents that can edit files or run
commands need an explicit go-ahead.

### Teams without duplicated work

For larger tasks, a persistent team lead breaks the work down and brings in
specialists. One shared reader agent does all the bulk reading once and hands
a single brief to every specialist that needs it. Without that rule, five
agents read the same file five times.

### Loop Mode: bounded self-improvement

An improve → review → decide loop that stops on its own:

- The project's real linters and type checker vote on convergence, not just an
  agent's opinion.
- The improving agent is barred from faking success: it may not delete tests,
  weaken assertions, or suppress warnings.
- There is a hard cap on rounds, plus automatic stops when the loop starts
  churning or diverging.

### Conventions that actually load

Coding conventions were originally skills, and they never fired: nobody asks
"please apply my Python conventions", they just edit a `.py` file. I moved
them to file-path rules that trigger on the event that actually happens, and
verified the behavior by probe across two versions — including edge cases the
documentation doesn't cover.

### Drift control

Some instructions are shared across seven agent files. Markdown has no
includes, so a small build script expands shared blocks ahead of time, and a
pre-commit hook refuses any commit where a copy has drifted. A stale copy is
worse than a broken one, because it still runs.

### Safety enforced by the harness, not the prompt

Credentials are never read into context. Agents cannot edit their own
definitions, hooks, or permissions. Force-pushes and hard resets are denied.
These are permission rules, not prompt instructions: an instruction can be
reasoned around under pressure, a denial cannot.

A formatting hook also refuses to load repository-supplied type-checker
configuration, closing a path to code execution from simply editing a file in
an untrusted repository.

---

## What I'd still improve

- **Routing quality isn't measured yet.** The next step is a scored set of
  prompts with known-correct routing targets.
- **Skill triggers are hand-tuned.** Usage logging now records what actually
  fires, so tuning can be based on data instead of impressions.
- **The rules mechanism has no automated regression test**, only a manual probe.

---

## About me

Itay Gross — Python backend developer with a background in cyber research.

Access to the full configuration is available on request.
