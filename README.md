# agentic-dev-workflow

A working Claude Code configuration, used daily on production Python backend
work. It is the contents of a real `~/.claude` directory rather than a
demonstration: 60 skills covering coding conventions and multi-step workflows,
14 subagents filling specialist roles, a routing map that decides which
specialist a task warrants, and a small build system that keeps text shared
across the agent definitions from drifting out of sync. The top-level
`CLAUDE.md` is deliberately short — it holds the response contract, the coding
defaults, and the agent-invocation rules, and delegates everything else to the
skills.

## How it is organized

Three layers, described here the way `CLAUDE.md` actually describes them.

**Conventions load as skills, by topic matching.** There is no file-path
trigger mechanism in Claude Code — nothing binds `python-conventions` to
`*.py`. A skill loads when its `description` matches what is being discussed,
which means the description is the whole trigger. That is why the convention
skills are written with concrete rules in the description line rather than
abstract summaries: `python-conventions` opens with "Passive Python coding
rules to apply whenever writing or editing any Python file", and
`bash-scripting-conventions` names `set -euo pipefail` and `trap` directly.
Seventeen skills sit in this layer, covering Python, REST APIs, MongoDB,
SQLAlchemy, AWS, bash, networking and TLS, crawling, testing, documentation,
dependency and config handling, layering, pattern selection, code quality,
review standards, and security boundaries.

**Workflows are skills too.** Eighteen of them, each a multi-step procedure
rather than a rule set: `plan-change` (design-first plan with options and a
trade-off matrix), `python-implementation-workflow` (lock, stage, verify),
`disciplined-change-workflow` (the same discipline for non-Python changes),
`investigate-bug` and `fix-bug`, `review-from-perspectives`,
`api-endpoint-design-workflow`, `async-python-workflow`, the AWS, MongoDB,
devops, bash and crawling workflows, `resilient-network-client-workflow`,
`create-agent-task`, `start-task`, and `direct-answer-mode` for the case where
the right move is to answer without touching anything.

**Specialist roles are subagents.** The remaining 25 skills are the control
surface for them — 13 direct-launch commands, one per agent, plus
`agent-routing`, `consult`, `list-agents`, `suggest-agent`, `agent-info`,
`agent-lifecycle`, `session-agents`, `team`, `team-custom`, `name`, `tell`,
and `why-no-skill`.

### The agents

| Agent | Fires when |
|---|---|
| `architect` | A change spans modules or layers and needs a design with trade-offs before any code is written. Returns a design doc, not code. |
| `code-creator` | A new feature is well specified and it is time to build it. Applies the change directly. |
| `code-improver` | Existing code needs a behavior-preserving cleanup — readability, reliability, convention compliance. No new functionality. |
| `bug-investigator` | A bug's cause is unknown. Read-only; returns ranked suspects with confirm/rule-out checks, never a fix. |
| `bug-fixer` | The cause is already confirmed. Applies the smallest safe fix and adds a regression test. |
| `code-reviewer` | A diff or PR needs line-by-line review for correctness, security, and quality. Returns findings, applies nothing. |
| `senior-dev` | A second opinion is wanted that is not anchored to how the question was framed — "am I about to do something dumb", "is this actually true". |
| `tech-lead` | The call is ship, hold, or defer — priority and speed-versus-quality judgment rather than code review. |
| `security-auditor` | Adversarial review for injection, broken auth, secret leakage, path traversal, SSRF, unsafe deserialization. Reports, does not fix. |
| `devops-engineer` | CI/CD pipelines, Dockerfiles, deploy configuration, infrastructure-as-code, observability. |
| `product-clarifier` | The request is vague and "done" is undefined. Returns scope and acceptance criteria before any code. |
| `test-writer` | New or changed behavior needs pytest coverage. Writes the tests and runs them. |
| `tune-skills` | Roughly monthly maintenance on the skill and agent library itself — which descriptions never fire, which are weak. Proposes only. |
| `junior-dev` | Bulk reading with no judgment in it, or any source two or more agents will need. Reads once, returns one consolidated brief. |

`junior-dev` runs on Haiku and is the only agent granted the `Skill` tool and
the context7 documentation tools; `product-clarifier` is also Haiku; the rest
run on Sonnet. Agents carry `memory` scopes (`project`, `user`, or `local`)
so a specialist's accumulated notes persist where they are relevant.

## Agent routing

`agent-routing` is the situation map — a table from "what is happening right
now" to the single agent that fits, or to no agent at all. Before naming a
specialist, the fit is checked against that map and cited in the announcement:
`per agent-routing: <situation> -> <agent>`. Naming a fit is explicitly not
the same as launching it; `/suggest-agent` and `/agent-info` state a fit and
launch nothing.

Two gates decide whether a call needs my go-ahead.

**Tier.** Read-only agents (`Explore`, `Plan`, `junior-dev`, `architect`,
`code-reviewer`, `senior-dev`, `tech-lead`, `security-auditor`,
`bug-investigator`, `product-clarifier`) can be auto-fired without a
checkpoint — the worst case is wasted tokens. Action-capable agents
(`bug-fixer`, `code-creator`, `code-improver`, `devops-engineer`,
`test-writer`, `tune-skills`) hold `Edit`, `Write`, and `Bash`, so they need a
checkpoint unless I named them myself. `tune-skills` is tiered as
action-capable because it has `Bash`, even though its prompt restricts it to
read-only behavior — the tier follows the tool grant, not the documented
intent, because the grant is what actually constrains it.

**Mode.** In confirm-required modes, a specialist waits for an explicit
go-ahead — "ok", "go", "yes" — in my next message, and feedback on a
deliverable ("rerun", "fix point 3") does not count as one. In auto mode it
decides and calls directly, optimizing for speed and tokens. Confirmation is
skipped entirely when I named the agent myself or ran a direct-launch command
such as `/security-auditor <scope>`, which bypasses the routing lookup and the
fit-check because naming the command is the go-ahead.

The reason a specialist has to be justified before it is called is cost and
noise. Every specialist is a fresh context that re-reads the codebase and
returns a report I then have to read. Firing `architect` at a one-function fix
produces a trade-off document instead of a change. Requiring the citation
forces the choice to be defensible against a written map rather than made on
vibe, and makes a wrong pick visible in the transcript afterward.

The same principle drives the read discipline: exactly one `junior-dev` per
task, owned by the main thread (solo) or the team lead (in `/team` mode), and
its brief is fanned out to whichever specialists need it. Specialists never
message it peer-to-peer and never spawn their own. Without that rule, five
agents each read the same file five times.

## Composition and drift control

Three sections of prose were byte-identical across seven agent files. Markdown
has no include mechanism, and most agents do not carry the `Skill` tool, so a
shared block cannot be resolved at runtime. `agent-blocks/build_agents.py`
resolves them ahead of time instead.

The block text lives once in `agent-blocks/`:

| Block | Sites | What it says |
|---|---|---|
| `reads-lead.md` | 7 | Team Lead Mode owns the one shared `junior-dev`; forward its brief, read the judged artifact yourself |
| `team-lead-mode.md` | 7 | Decompose, route via `agent-routing`, spawn read-only tiers directly, checkpoint action-capable ones |
| `reads-consumer.md` | 6 | Do not self-read in bulk; a brief is orientation, not the artifact you are judging |

Each inclusion site in an agent file is delimited:

    <!-- begin: reads-consumer -->
    ...expanded text...
    <!-- end: reads-consumer -->

Running `python3 build_agents.py` rewrites every marked region to its block's
current text. The agent files on disk stay fully self-contained, so agent
behavior is unchanged by the mechanism — it is a build step, not a runtime
indirection.

`--check` reports drift and changes nothing, exiting 1 if any file is out of
date. `.githooks/pre-commit` runs exactly that and refuses the commit when it
fails.

The failure this prevents is specific: text hand-edited *inside* a marked
region looks correct, passes review, and is committed — and then the next
`build_agents.py` run silently overwrites it. Nothing errors, nothing warns,
and the agent quietly reverts to the old wording. Before the hook existed the
symmetric failure was live: a wording change meant editing up to seven files by
hand, that hand-sync happened three times in one day, and nothing detected a
missed copy. A stale copy is a silently divergent agent, which is worse than a
broken one, because it still runs.

One caveat worth knowing: agent definitions load when Claude Code starts. A
rebuild does not reach subagents in a session that is already running, so
testing a block change means restarting first. Do not try to infer whether the
new definition loaded from a subagent's output — a cheap model will normalize a
changed section header on its own and produce a false negative. Compare the
file's mtime against the process start time instead.

## Hard constraints

From `CLAUDE.md`:

- **Check whether the codebase already solves this** before proposing any new
  tool, library, or dependency. Guards against dependency creep and
  reimplementation of something that already exists in the repo.
- **No unrequested improvements or boilerplate.** Keeps a diff reviewable, and
  keeps the change under discussion separable from opportunistic edits.
- **No renaming or signature change on a public function** without first
  checking its callers and reporting what was found. Guards against a local
  edit breaking a distant caller.
- **Ask when the request is ambiguous; do not proceed on invented
  assumptions.** The failure mode being blocked is confident work built on a
  guess, which costs more to unwind than the question costs to ask.
- **Context modes.** Solo repos move fast; work and shared repos are
  conservative, surgical, and backward-compatible, with cross-component or
  public-API changes requiring explicit approval.
- **Plan adherence.** Once an approved plan names a specific agent for a step,
  skipping or substituting it needs the same go-ahead as naming a new
  specialist. Prevents an approved plan being quietly re-planned mid-execution.

From `settings.json`, enforced by the harness rather than by prompt:

```
Read(**/.env)        Edit(**/.env)         Edit(**/secrets/**)
Read(**/.env.*)      Edit(**/.env.*)       Edit(**/*.pem)
                                           Edit(**/id_rsa*)
Bash(git push --force*)
Bash(git push -f*)
```

The read denials on `.env` files keep credentials out of the context window
entirely — a secret that is never read cannot be echoed into a transcript, a
commit, or a bug report. The edit denials cover the same files plus secret
directories, PEM certificates, and SSH private keys, so a careless rewrite
cannot corrupt or expose key material. The force-push denials protect published
history: an ordinary push is recoverable, a force push over someone else's
commits is not.

These are deny rules, not prompt instructions, which matters — an instruction
can be reasoned around under pressure, a permission denial cannot.

A `PostToolUse` hook runs `hooks/format-python.sh` after every `Edit`, `Write`,
or `MultiEdit`, applying `ruff check --fix` and `ruff format` to Python files.
It no-ops if `jq` or `ruff` is missing, by design: a formatting hook must never
be able to break an edit.

## Limitations

Written honestly, because the parts that do not work are more useful to a
reader than the parts that do.

I do not trust agent output uniformly, and there are places I still read
everything myself. Anything from an action-capable agent gets reviewed as a
diff before I accept it — `code-creator` and `bug-fixer` produce plausible code
that compiles and is occasionally wrong in ways their own summary does not
mention. I read `security-auditor` findings in full rather than acting on the
severity labels, because false positives are common enough that the labels are
not load-bearing. `junior-dev` runs on Haiku and I treat its briefs as
orientation, never as the artifact I am judging — that is exactly what the
`reads-consumer` block tells the other agents, and I hold myself to it too.
Where I do rely on agent output without re-derivation is the read-only
advisory tier: `architect`, `senior-dev`, and `tech-lead` produce arguments I
can evaluate on their merits without checking their work.

Skill descriptions are the actual trigger mechanism, and they are tuned by
hand. There is no path binding, no keyword registry, no deterministic
dispatch — a skill fires because its description happened to match the
conversation. That makes every description a piece of tuning that can silently
stop working when I change how I phrase things. `why-no-skill` exists for
precisely this: I feed it the prompt that should have matched, it enumerates
the candidate descriptions, explains which one should have won and why the
current wording failed (too abstract, missing my actual trigger words,
overlapping with a neighbor, missing a "Not for" boundary), proposes a revised
description, and appends a line to `~/.claude/trigger-audit.log`. The monthly
`tune-skills` pass reads that log. Both of them propose only — neither edits a
skill file, because I want to approve every description change. It works, but
it is a manual feedback loop that depends on me noticing a miss in the first
place. Misses I do not notice are not in the log.

The gap I most want to close: there is no automated evaluation measuring how
often routing picks the wrong specialist. I have a documented situation map, a
citation requirement, and a tier system, and no measurement of any of it. I do
not know my false-routing rate. I do not know which table rows are ambiguous in
practice, whether the confirm gate catches bad picks or just slows down good
ones, or how often the right answer was "no agent at all" and something fired
anyway. Everything I believe about this setup's routing quality is impression,
not data. Building that evaluation — a fixed set of prompts with known-correct
routing targets, run against the map, scored — is the next thing I want to do,
and until it exists this section should be read as the honest limit of what I
can claim.

## Installation

This repository is the contents of `~/.claude` itself, and `.gitignore` is
written on that assumption — it excludes session transcripts, caches,
`plugins/`, and machine-local settings, while keeping durable memory under
`projects/*/memory/`.

Back up any existing configuration first, then place the contents:

```bash
mv ~/.claude ~/.claude.backup        # if you have one
git clone <this-repo> ~/.claude
```

To adopt it into a `~/.claude` you already keep under git, copy the tracked
directories in rather than cloning over the top:

```bash
cp -a agents agent-blocks hooks output-styles skills CLAUDE.md ~/.claude/
```

`settings.json` is worth merging by hand rather than overwriting — it carries
plugin and marketplace entries, a theme, and a model choice alongside the deny
rules, and only the `permissions` and `hooks` blocks are part of what this
repository is for.

Enable the drift hook, which requires `~/.claude` to be a git repository:

```bash
cd ~/.claude
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit hooks/format-python.sh
python3 agent-blocks/build_agents.py --check    # confirm a clean baseline
```

The formatting hook needs `jq` and `ruff` on `PATH`; without them it exits
silently and edits are simply left unformatted.

Restart Claude Code afterward. Agent definitions and skills are read at
startup, so nothing here takes effect in a session that was already running.
