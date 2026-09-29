# agentic-dev-workflow

A multi-agent Claude Code setup I designed, built, and use every day on
production Python backend work.

The full configuration is private. This page describes what it does, how it is
designed, and what makes it different.

---

## At a glance

| | |
|---|---|
| **14 specialist agents** | Architect, code reviewer, security auditor, bug investigator, bug fixer, test writer, DevOps engineer, tech lead, and more — each with a narrow role and the least tool access it needs |
| **32 skills** | Workflows (planning, bug fixing, refactoring, API design, async, AWS, MongoDB, CI/CD) plus a command surface for driving the agents |
| **11 convention rules** | Python, REST, MongoDB, SQL, AWS, Bash, networking security, and more — loaded automatically when a matching file is opened |
| **3 hooks** | Formatting and type-checking on every edit, plus measurement of what actually loads and fires |
| **A build system** | Keeps shared text across agent definitions in sync and blocks commits on drift |

---

## What makes it different

### It adapts to the situation instead of running one fixed pipeline

The same setup handles a one-line fix and a cross-module redesign, a personal
side project and a shared production codebase:

- **Right-sized help.** A small, clear change gets done directly. An unknown
  bug goes to an investigator that only diagnoses. A vague request goes to a
  clarifier before any code is written. A cross-cutting change gets an
  architect's design first. Sometimes the right answer is no agent at all, and
  the routing map says so.
- **Solo or team.** One specialist for a scoped question, or a persistent team
  lead that breaks down a larger task and brings in exactly the specialists it
  needs.
- **Personal or shared repos.** Personal repos move fast. Shared repos are
  conservative and backward-compatible, and public-API changes need explicit
  approval.
- **Hands-on or autonomous.** In confirm mode, anything that edits code waits
  for my go-ahead. In auto mode it decides and acts on its own.
- **Any stack in the repo.** Python, REST, MongoDB, SQL, AWS, Bash, CI/CD and
  networking conventions each load only when a matching file is opened, in any
  repository, with zero per-repo setup.

### Loops that know when to stop

For code that needs to be brought up to standard, an improve → review → decide
loop runs on its own:

- The same three agents stay alive across rounds, so the reviewer remembers
  what it flagged last time and the improver stops undoing its own changes.
- The project's real linters and type checker vote on whether it's done, not
  just an agent's opinion.
- The improving agent can't fake success: it may not delete tests, weaken
  assertions, or silence warnings.
- It stops by itself when it converges, hits its round limit, starts going in
  circles, or starts making things worse — and reports which one happened.

### Hooks that enforce quality on every edit

- **Every Python edit is formatted and type-checked automatically**, and
  anything the tools can't fix is reported back in the same turn, so problems
  never pile up.
- **Hardened against untrusted repositories.** The hook refuses to load a
  repository's own type-checker configuration, closing a path to code
  execution from simply editing a file in a hostile repo.
- **Built to never break an edit.** If a tool is missing, the hook stands down
  quietly instead of failing.
- **Measurement hooks** record which conventions actually loaded and which
  skills actually fired, every session.

### It tunes itself

A setup like this only works if the right piece fires at the right moment, so
tuning is built in rather than left to guesswork:

- A **library audit** finds skills and agents that never fire, overlap with
  each other, or have descriptions too weak to be picked — and proposes
  rewrites.
- A **"why didn't it fire?" diagnostic** takes a prompt that should have
  triggered something, explains which piece should have won and why it
  didn't, and proposes a fix.
- Both work from **real usage logs** collected by the hooks, not from memory.
- Every change is **proposed, not applied** — I approve each one.

### Built so it doesn't waste work

Every specialist starts fresh and has to read the code, so the setup is
designed to avoid paying for that twice. One shared reader agent does the bulk
reading once and hands a single brief to every specialist that needs it.
Specialists are resumed rather than respawned, so they keep their context.

### Safety enforced by the harness, not the prompt

Credentials are never read into context. Agents cannot edit their own
definitions, hooks, or permissions. Force-pushes and hard resets are blocked.
These are permission rules, not prompt instructions: an instruction can be
reasoned around under pressure, a permission rule cannot.

### Shared instructions never drift apart

Some instructions are shared across seven agent files. A small build script
keeps every copy identical, and a pre-commit hook refuses any commit where one
has drifted — because an agent running on stale instructions fails silently.

---

## What's next

Next I'm building an automated evaluation of routing quality: a scored set of
real prompts, each with a known correct agent, run against the setup so every
change to it can be measured.

---

## About me

Itay Gross — Python backend developer with a background in cyber research.

Access to the full configuration is available on request.
