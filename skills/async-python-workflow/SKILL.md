---
name: async-python-workflow
description: Write or review asyncio-based concurrent Python code correctly — avoiding blocking calls in the event loop, unhandled task exceptions, and race conditions. Use for asyncio, async/await, event loop, concurrent task, or async worker/queue-handler work.
---

# Async Python Workflow Skill

Use when writing or reviewing `asyncio`-based code — a distinct correctness domain from ordinary
sync Python; bugs here are concurrency bugs, not logic bugs, and don't show up in a single-threaded read.

## Core rules
- **Never block the event loop**: no synchronous network/file/DB calls, `time.sleep`, or CPU-heavy
  work directly inside an `async def` — use the async equivalent (`asyncio.sleep`, an async
  client/driver) or offload via `loop.run_in_executor`/a worker process.
- **Always await or track every coroutine/task** — a coroutine created but never awaited/scheduled
  silently does nothing (and raises a "coroutine was never awaited" warning); a `create_task()`
  result must be kept referenced (store it) or it can be garbage-collected mid-flight.
- **Handle task exceptions explicitly** — an exception inside a fire-and-forget task is swallowed
  unless you attach a done-callback or await the task; unhandled task exceptions must be logged,
  not lost silently.
- **Use `asyncio.gather`/`TaskGroup` for concurrent work**, not manual loops of `await` in sequence
  when the calls are independent — sequential `await` for independent I/O wastes the entire point
  of async.
- **Set timeouts on every awaited external call** (`asyncio.wait_for`/`asyncio.timeout`) — an
  un-timed-out await can hang a whole worker indefinitely, same principle as sync network timeouts.
- **Guard shared mutable state** — async concurrency still has race conditions (two coroutines
  interleaving on an `await` point mid-read-modify-write); use `asyncio.Lock` around
  check-then-act sequences on shared state, don't assume single-threadedness makes it safe.
- **Cancellation is cooperative** — catch `asyncio.CancelledError` only to clean up (close
  resources), then re-raise it; swallowing it silently breaks shutdown/timeout behavior for callers.

## Done conditions
- No synchronous blocking call sits inside an `async def` on the hot path.
- Every task's exception path is observed (awaited, gathered, or has an error callback).
- Every external await has an explicit timeout.
- Shared mutable state touched across an `await` point is lock-protected.

Source: Python `asyncio` official docs — "Developing with asyncio" common-mistakes guide
(docs.python.org/3/library/asyncio-dev.html), `asyncio-task`/`asyncio-sync` reference docs.
