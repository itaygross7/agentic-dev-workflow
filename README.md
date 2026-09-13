# agentic-dev-workflow

A working Claude Code configuration, used daily on production Python backend
work. It is the contents of a real `~/.claude` directory rather than a
demonstration: 11 path-scoped convention rules, 32 skills covering workflows and
the agent control surface, 14 subagents filling specialist roles, a routing map
that decides which specialist a task warrants, and a small build system that
keeps text shared across the agent definitions from drifting out of sync. The
top-level `CLAUDE.md` is deliberately short — it holds the response contract, the
coding defaults, and the agent-invocation rules, and delegates everything else.

## How it is organized

Three layers, each with a different trigger mechanism. The mechanism is the
interesting part, because it determines what can be relied on.

### Conventions are path-scoped rules

Eleven passive conventions live in `rules/` as markdown files with a `paths:`
glob in their frontmatter:

```yaml
---
paths:
  - "**/*.py"
---
```

They were skills once, and they never fired. Skill matching is event-driven on a
request, and a passive convention has no event — nobody asks "please apply my
Python conventions", they just ask for a change to a `.py` file. A `paths:` glob
fires on the event that actually exists: Claude opening a matching file.

The eleven are `python-conventions`, `api-rest-conventions`,
`mongodb-conventions`, `relational-db-conventions`, `aws-conventions`,
`bash-scripting-conventions`, `networking-security`, `security-boundaries`,
`web-crawling-conventions`, `dependency-config-management`, and
`documentation-standards`.

These are user-level, so they apply to every repo including ones that do not
exist yet — no per-repo setup. A repo can still add its own `.claude/rules/` for
repo-specific conventions; user-level rules load first, so project rules take
precedence.

**What is actually verified about this mechanism.** Open issues #21858 and
#22170 claim user-level `paths:` is ignored. That has not reproduced here, on
either version tested:

| Date | Version | Result |
|---|---|---|
| 2026-09-06 | 2.1.263 | A rule with `paths: ["**/*.py"]` loaded on reading a `.py` file |
| 2026-09-13 | 2.1.270 | Same, re-probed in a clean container with unique marker tokens |

Two further properties came out of the second probe, and neither is obvious from
the docs:

- **`paths:` is project-relative, not filesystem-absolute.** `**/*.py` means "any
  `.py` under the project root", not "any `.py` on disk". Reading
  `/tmp/scratch.py` fired nothing; reading a `.py` inside the workspace fired
  immediately. Two different rules, same split. This only bites on scratch files
  outside the repo and on extra directories added to a session.
- **Rules resolve at match time, not at session start.** A rules file dropped
  into `~/.claude/rules/` mid-session fired on the next matching read, with no
  restart. This is the opposite of agents and skills, which are read once at
  startup.

If conventions ever stop loading, re-run that probe before assuming anything
else. `/context` shows what loaded under Memory files, and
`~/.claude/instructions-loaded.log` records it per session.

### Workflows and the agent control surface are skills

Thirty-two of them. A skill fires when its `description` matches the
conversation, which makes the description the whole trigger — that is why they
are written with concrete rules and trigger phrasing rather than abstract
summaries, and why each carries a "NOT for" boundary against its nearest
neighbour.

**Six are knowledge skills** that stayed skills because they answer a question
rather than decorate a file: `architecture-layering`, `design-patterns-selection`,
`code-quality`, `code-review-standards`, `testing-conventions`,
`networking-fundamentals`.

**Sixteen are workflows** — multi-step procedures rather than rule sets:
`plan-change` (design-first plan with options and a trade-off matrix),
`python-implementation-workflow` (lock, stage, verify),
`disciplined-change-workflow` (the same discipline for non-Python changes),
`investigate-bug` and `fix-bug`, `improve-code`, `loop-improve`,
`review-from-perspectives`, `api-endpoint-design-workflow`,
`async-python-workflow`, and the AWS, MongoDB, devops, bash, crawling and
`resilient-network-client-workflow` procedures.

**Seven are the agent control surface**: `agent-routing`, `consult`,
`agent-lifecycle`, `session-agents`, `team`, `name`, `tell`.

**Two maintain the library itself**: `tune-skills` and `why-no-skill`.

**One is session hygiene**: `shed`, which cuts a heavy session down to a handoff
you can start fresh from.

Twelve carry `disable-model-invocation: true` and are explicit commands only —
`/consult`, `/fix-bug`, `/improve-code`, `/investigate-bug`, `/loop-improve`,
`/name`, `/plan-change`, `/review-from-perspectives`, `/session-agents`, `/shed`,
`/tell`, `/why-no-skill`.

### Specialist roles are subagents

| Agent | Fires when | Model |
|---|---|---|
| `architect` | A change spans modules or layers and needs a design with trade-offs before any code is written. Returns a design doc, not code. | sonnet |
| `code-creator` | A new feature is well specified and it is time to build it. Applies the change directly. | sonnet |
| `code-improver` | Existing code needs a behavior-preserving cleanup — readability, reliability, convention compliance. No new functionality. | sonnet |
| `bug-investigator` | A bug's cause is unknown. Read-only; returns ranked suspects with confirm/rule-out checks, never a fix. | sonnet |
| `bug-fixer` | The cause is already confirmed. Applies the smallest safe fix and adds a regression test. | sonnet |
| `code-reviewer` | A diff or PR needs line-by-line review for correctness, security, and quality. Returns findings, applies nothing. | sonnet |
| `senior-dev` | A second opinion that is not anchored to how the question was framed — "am I about to do something dumb", "is this actually true". | sonnet |
| `tech-lead` | The call is ship, hold, or defer — priority and speed-versus-quality judgment rather than code review. | sonnet |
| `security-auditor` | Adversarial review for injection, broken auth, secret leakage, path traversal, SSRF, unsafe deserialization. Reports, does not fix. | sonnet |
| `devops-engineer` | CI/CD pipelines, Dockerfiles, deploy configuration, infrastructure-as-code, observability. | sonnet |
| `product-clarifier` | The request is vague and "done" is undefined. Returns scope and acceptance criteria before any code. | haiku |
| `test-writer` | New or changed behavior needs pytest coverage. Writes the tests and runs them. | sonnet |
| `tune-skills` | Roughly monthly maintenance on the skill and agent library itself — which descriptions never fire, which are weak. Proposes only. | sonnet |
| `junior-dev` | Bulk reading with no judgment in it, or any source two or more agents will need. Reads once, returns one consolidated brief. | haiku |

`junior-dev` is the only agent granted the `Skill` tool and the context7
documentation tools. Agents carry `memory` scopes so a specialist's accumulated
notes persist where they are relevant: `project` for the nine that reason about a
specific codebase, `user` for `senior-dev`, `tech-lead` and `tune-skills` whose
judgment generalizes across repos, and `local` for `security-auditor` so findings
stay off shared storage.

## Agent routing

`agent-routing` is the situation map — a table from "what is happening right now"
to the single agent that fits, or to no agent at all. Before naming a specialist,
the fit is checked against that map and cited in the announcement:
`per agent-routing: <situation> -> <agent>`. Naming a fit is explicitly not the
same as launching it.

Two gates decide whether a call needs my go-ahead.

**Tier.** Read-only agents (`Explore`, `Plan`, `junior-dev`, `architect`,
`code-reviewer`, `senior-dev`, `tech-lead`, `security-auditor`,
`bug-investigator`, `product-clarifier`) can be auto-fired without a checkpoint —
the worst case is wasted tokens. Action-capable agents (`bug-fixer`,
`code-creator`, `code-improver`, `devops-engineer`, `test-writer`, `tune-skills`)
hold `Edit`, `Write`, and `Bash`, so they need a checkpoint unless I named them
myself. `tune-skills` is tiered as action-capable because it has `Bash`, even
though its prompt restricts it to read-only behavior — the tier follows the tool
grant, not the documented intent, because the grant is what actually constrains
it.

**Mode.** In confirm-required modes, a specialist waits for an explicit go-ahead —
"ok", "go", "yes" — in my next message, and feedback on a deliverable ("rerun",
"fix point 3") does not count as one. In auto mode it decides and calls directly.
Confirmation is skipped when I named the agent myself or ran `/consult <agent>`.

**The twelve direct-launch commands were retired.** `/architect`, `/bug-fixer`,
`/code-creator` and the rest were one-line wrappers that each launched their
same-named agent while skipping the fit-check. Not one had ever been used, and
two doors to the same confirmation exemption already existed: naming the agent in
prose ("`senior-dev`: check this"), which `CLAUDE.md` already treats as go-ahead,
and `/consult <agent>`. `/agent-info`, `/list-agents` and `/suggest-agent` went
with them — all three answered questions `agent-routing` answers directly —
`/team-custom` folded into `/team --lead <agent>`, and `/create-agent-task`,
`/start-task` and `/direct-answer-mode` described behavior that needed no command
to invoke. Nineteen skills of surface area removed, no capability lost.
`/tune-skills` survives because it is a real command, not a wrapper.

The reason a specialist has to be justified before it is called is cost and noise.
Every specialist is a fresh context that re-reads the codebase and returns a
report I then have to read. Firing `architect` at a one-function fix produces a
trade-off document instead of a change. Requiring the citation forces the choice
to be defensible against a written map rather than made on vibe, and makes a
wrong pick visible in the transcript afterward.

The same principle drives the read discipline: exactly one `junior-dev` per task,
owned by the main thread (solo) or the team lead (in `/team` mode), and its brief
is fanned out to whichever specialists need it. Specialists never message it
peer-to-peer and never spawn their own. Without that rule, five agents each read
the same file five times.

## Loop Mode

`/loop-improve <target>` runs a bounded convergence loop: `code-improver` fixes,
the shared `junior-dev` re-reads only the delta, `code-reviewer` judges the diff,
and a lead decides whether to loop again. The lead defaults to `senior-dev`;
`--lead <agent>` picks any of the seven Loop-Mode-capable agents.

The parts that make it more than a retry loop:

**Three standing members, spawned once and resumed by message.** Recreating them
each round is the single most common way this degrades. A reviewer that remembers
its own previous verdict is genuinely comparing; a fresh one is re-deriving from
whatever it was handed, and the churn and divergence exits quietly become
guesses. An improver that remembers what it declined to change stops oscillating.
Three warm members also cost far less than nine cold ones.

**A hard cap of three iterations per instance lifetime**, not per invocation. A
resume does not grant a fresh budget.

**The project's own gate votes on convergence.** `must_fix` being empty is a
reviewer's judgment; `ruff` and `mypy` are a check. Non-zero exit means those
findings *are* `must_fix` for the round, whatever the reviewer concluded. Without
this, the cheapest way to fake convergence is to suppress findings — so
`code-improver` is explicitly barred from deleting a test, removing an assertion,
adding a skip marker, or writing `# noqa` / `# type: ignore`. If no gate can be
found, the loop exits as `converged (gate not run)` and says which gate it looked
for: a missing check must never read as a passing one.

**Four exit conditions**, and any exit other than converged is a checkpoint back
to the caller, not a failure to hide: `must_fix` empty and gate passing
(converged), three iterations done (cap), `new_since_prev` adding nothing outside
the previous round's findings (churn — rewording rather than fixing), or
`must_fix` longer than last round (diverging).

Loop Mode is a bounded pre-authorization covering exactly one agent,
`code-improver`. Every other action-capable specialist still requires the normal
checkpoint.

## Composition and drift control

Four sections of prose are byte-identical across multiple agent files. Markdown
has no include mechanism, and most agents do not carry the `Skill` tool, so a
shared block cannot be resolved at runtime. `agent-blocks/build_agents.py`
resolves them ahead of time instead.

The block text lives once in `agent-blocks/`:

| Block | Sites | What it says |
|---|---|---|
| `team-lead-mode.md` | 7 | Decompose, route via `agent-routing`, spawn read-only tiers directly, checkpoint action-capable ones |
| `loop-mode.md` | 7 | The standing-member loop, its cap, its gate requirement, and its four exits |
| `reads-lead.md` | 7 | Team Lead Mode owns the one shared `junior-dev`; forward its brief, read the judged artifact yourself |
| `reads-consumer.md` | 6 | Do not self-read in bulk; a brief is orientation, not the artifact you are judging |

The first three go to the seven lead-capable agents (`architect`,
`bug-investigator`, `code-reviewer`, `product-clarifier`, `security-auditor`,
`senior-dev`, `tech-lead`); `reads-consumer` goes to the six that consume a brief
without leading (`bug-fixer`, `code-creator`, `code-improver`, `devops-engineer`,
`test-writer`, `tune-skills`). Twenty-seven inclusion sites in total.

Each site is delimited:

    <!-- begin: reads-consumer -->
    ...expanded text...
    <!-- end: reads-consumer -->

Running `python3 build_agents.py` rewrites every marked region to its block's
current text. The agent files on disk stay fully self-contained, so agent
behavior is unchanged by the mechanism — it is a build step, not a runtime
indirection. `--check` reports drift and changes nothing, exiting 1 if any file
is out of date. `.githooks/pre-commit` runs exactly that and refuses the commit
when it fails.

The failure this prevents is specific: text hand-edited *inside* a marked region
looks correct, passes review, and is committed — and then the next
`build_agents.py` run silently overwrites it. Nothing errors, nothing warns, and
the agent quietly reverts to the old wording. Before the hook existed the
symmetric failure was live: a wording change meant editing up to seven files by
hand, that hand-sync happened three times in one day, and nothing detected a
missed copy. A stale copy is a silently divergent agent, which is worse than a
broken one, because it still runs.

One caveat worth knowing: agent definitions load when Claude Code starts. A
rebuild does not reach subagents in a session that is already running, so testing
a block change means restarting first. Do not try to infer whether the new
definition loaded from a subagent's output — a cheap model will normalize a
changed section header on its own and produce a false negative. Compare the
file's mtime against the process start time instead.

## Hard constraints

From `CLAUDE.md`:

- **Check whether the codebase already solves this** before proposing any new
  tool, library, or dependency. Guards against dependency creep and
  reimplementation of something that already exists in the repo.
- **No unrequested improvements or boilerplate.** Keeps a diff reviewable, and
  keeps the change under discussion separable from opportunistic edits.
- **No renaming or signature change on a public function** without first checking
  its callers and reporting what was found.
- **Ask when the request is ambiguous; do not proceed on invented assumptions.**
  The failure mode being blocked is confident work built on a guess, which costs
  more to unwind than the question costs to ask.
- **Context modes.** Solo repos move fast; work and shared repos are conservative,
  surgical, and backward-compatible, with cross-component or public-API changes
  requiring explicit approval.
- **Plan adherence.** Once an approved plan names a specific agent for a step,
  skipping or substituting it needs the same go-ahead as naming a new specialist.

From `settings.json`, enforced by the harness rather than by prompt:

```
# Credentials and key material
Read(**/.env)          Read(**/.env.*)
Edit(**/.env)          Edit(**/.env.*)     Edit(**/secrets/**)
Edit(**/*.pem)         Edit(**/id_rsa*)

# This configuration's own definition
Edit(~/.claude/agents/**)         Edit(~/.claude/agent-blocks/**)
Edit(~/.claude/hooks/**)          Edit(~/.claude/settings.json)
Edit(~/.claude/settings.local.json)
Edit(**/.git/config)

# Irreversible git
Bash(git push --force*)   Bash(git push -f*)   Bash(git reset --hard*)
```

The read denials on `.env` files keep credentials out of the context window
entirely — a secret that is never read cannot be echoed into a transcript, a
commit, or a bug report. The edit denials cover the same files plus secret
directories, PEM certificates, and SSH private keys.

The second group is newer and protects this configuration from itself. An agent
that can rewrite `~/.claude/agents/`, `agent-blocks/`, `hooks/` or
`settings.json` can rewrite its own constraints, and the drift hook cannot catch
a change that edits the builder's inputs and outputs together. `.git/config`
covers remote and hook redirection. `git reset --hard` joins the force-push
denials: an ordinary push is recoverable, and so is a dirty tree — neither is
once discarded.

These are deny rules, not prompt instructions, which matters: an instruction can
be reasoned around under pressure, a permission denial cannot.

Three hooks run, all in `hooks/`:

- **`format-python.sh`** (PostToolUse on `Edit|Write|MultiEdit`) applies
  `ruff check --fix` and `ruff format`, then reports what ruff and mypy *cannot*
  fix on stderr with exit 2 — the edit already happened and cannot be undone, but
  the diagnostics land in the same turn. It no-ops if `jq` or the tools are
  missing, by design: a formatting hook must never be able to break an edit. It
  exports `PATH` before probing, because hooks do not inherit an interactive
  shell's `PATH`; without that line a tool under `~/.local/bin` is invisible and
  every check silently no-ops, which is exactly how this hook sat dead from
  2026-07-07 to 2026-09-06. It pins `mypy-hook.ini` so mypy never reads a
  repo-supplied config, which could name `plugins =` modules that mypy imports —
  arbitrary code execution from editing a file in a hostile repo.
- **`log-instructions-loaded.sh`** (InstructionsLoaded) records which
  `CLAUDE.md` and rules files actually loaded, when, and why. Self-rotating at
  5 MB.
- **`log-skill-use.sh`** (PreToolUse on `Skill`) records every skill invocation,
  one line each.

The last two exist to replace a hand-written audit log with measured data:
`tune-skills` can only tell you which skills never fire if something is counting.
Both are observational and always exit 0. Both logs are gitignored.

## Limitations

Written honestly, because the parts that do not work are more useful to a reader
than the parts that do.

**I do not trust agent output uniformly.** Anything from an action-capable agent
gets reviewed as a diff before I accept it — `code-creator` and `bug-fixer`
produce plausible code that compiles and is occasionally wrong in ways their own
summary does not mention. I read `security-auditor` findings in full rather than
acting on the severity labels, because false positives are common enough that the
labels are not load-bearing. `junior-dev` runs on Haiku and I treat its briefs as
orientation, never as the artifact I am judging — that is exactly what the
`reads-consumer` block tells the other agents, and I hold myself to it too. Where
I do rely on agent output without re-derivation is the read-only advisory tier:
`architect`, `senior-dev`, and `tech-lead` produce arguments I can evaluate on
their merits without checking their work.

**Skill descriptions are still hand-tuned triggers.** For the workflow and
control-surface layer there is no path binding and no deterministic dispatch — a
skill fires because its description happened to match the conversation. That
makes every description a piece of tuning that can silently stop working when I
change how I phrase things. `why-no-skill` exists for this: I feed it the prompt
that should have matched, it enumerates the candidates, explains which should
have won and why the wording failed, and proposes a revision. It proposes only —
I want to approve every description change. Moving the eleven conventions to
`rules/` removed the worst offenders from this layer, since those never had a
matching event at all, but everything left is still description-matched.

**The feedback loop is now measured, and that is new enough to be unproven.** The
two logging hooks produce real invocation data where there used to be a
hand-maintained log, so the next `tune-skills` pass will be the first with
evidence behind it. Whether that changes any conclusion is not yet known — the
logs have been collecting since 2026-09-06.

**The rules layer depends on version-specific behavior with no regression test.**
It works on 2.1.263 and 2.1.270, and two open issues claim it should not. I have
a documented probe and I re-run it by hand; nothing runs it automatically, and a
silent failure would look exactly like Claude ignoring my conventions, which is
also what a bad day looks like.

**The gap I most want to close: there is no automated evaluation measuring how
often routing picks the wrong specialist.** I have a documented situation map, a
citation requirement, and a tier system, and no measurement of any of it. I do
not know my false-routing rate. I do not know which table rows are ambiguous in
practice, whether the confirm gate catches bad picks or just slows down good
ones, or how often the right answer was "no agent at all" and something fired
anyway. Everything I believe about this setup's routing quality is impression,
not data. Building that evaluation — a fixed set of prompts with known-correct
routing targets, run against the map, scored — is the next thing I want to do,
and until it exists this section should be read as the honest limit of what I can
claim.

**Known inconsistency.** `agents/junior-dev.md` lists `graphify` as a read source
under "Finding sources, in this order". That skill is installed locally but is
third-party and not vendored here, so for anyone cloning this repository the
reference is a dangling pointer. It degrades gracefully — the agent falls through
to its other sources — but it is wrong as written.

**`build_agents.py` has no tests**, and there is no CI. The pre-commit hook is
the only thing checking anything, and it only checks block drift.

## Installation

This repository is the contents of `~/.claude` itself, and `.gitignore` is
written on that assumption — it excludes session transcripts, caches, `plugins/`,
hook logs, and machine-local settings, while keeping durable memory under
`projects/*/memory/`.

Back up any existing configuration first, then place the contents:

```bash
mv ~/.claude ~/.claude.backup        # if you have one
git clone <this-repo> ~/.claude
```

To adopt it into a `~/.claude` you already keep under git, copy the tracked
directories in rather than cloning over the top:

```bash
cp -a agents agent-blocks hooks output-styles rules skills CLAUDE.md ~/.claude/
```

`settings.json` is worth merging by hand rather than overwriting — it carries
plugin and marketplace entries, a theme, and a model choice alongside the deny
rules, and only the `permissions` and `hooks` blocks are part of what this
repository is for.

Enable the drift hook, which requires `~/.claude` to be a git repository:

```bash
cd ~/.claude
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit hooks/*.sh
python3 agent-blocks/build_agents.py --check    # confirm a clean baseline
```

The formatting hook needs `jq` and `ruff` on `PATH`; `mypy` is optional and its
checks are skipped if absent. Both logging hooks need `jq` and no-op without it.

Restart Claude Code afterward. Agent definitions and skills are read at startup,
so nothing there takes effect in a session that was already running. Rules are
the exception — they resolve at match time and take effect immediately.

Verify what actually loaded with `/context` under Memory files, or read
`~/.claude/instructions-loaded.log`.
