"""Expand shared delegation blocks into the agent definitions that include them.

Markdown has no include mechanism, and most agents do not carry the ``Skill``
tool, so a shared block cannot be resolved at runtime. Instead the blocks live
here once and are expanded into ``~/.claude/agents/*.md`` ahead of time: the
files on disk stay fully self-contained, so agent behaviour is unchanged.

Each inclusion site is delimited in the agent file::

    <!-- begin: reads-consumer -->
    ...expanded text...
    <!-- end: reads-consumer -->

Edit the block once in ``agent-blocks/<name>.md``, run this script, and every
site is rewritten identically.

Usage::

    python3 build_agents.py            # rewrite drifted sites
    python3 build_agents.py --check    # report drift, change nothing, exit 1

``--check`` is the guard worth wiring into a pre-commit hook: it fails when an
agent file has been hand-edited inside a marked region, which is the drift this
whole mechanism exists to prevent.

Agent definitions load when Claude Code starts, so a rebuild only takes effect
in a session started afterwards. Restart before testing any change.
"""

import argparse
import logging
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
logger = logging.getLogger("build-agents")

BLOCKS_DIR = Path(__file__).resolve().parent
AGENTS_DIR = BLOCKS_DIR.parent / "agents"

#: Block names are embedded in agent files, so constrain them before any path
#: is built from one — a name like ``../../.ssh/id_rsa`` must never resolve.
BLOCK_NAME = re.compile(r"^[a-z0-9-]+$")

MARKER = re.compile(
    r"^<!-- begin: (?P<name>[^>]+?) -->$(?P<body>.*?)^<!-- end: (?P=name) -->$",
    re.DOTALL | re.MULTILINE,
)


class BlockError(RuntimeError):
    """A block is missing, misnamed, or its markers are malformed."""


def load_block(name: str) -> str:
    """Read one shared block by name.

    :param name: block name as it appears in the marker comment.
    :returns: the block's text, with a single trailing newline.
    :raises BlockError: the name is not a safe slug, escapes ``BLOCKS_DIR``, or
        has no corresponding file.
    """
    if not BLOCK_NAME.match(name):
        raise BlockError(f"unsafe block name {name!r}: expected lowercase slug")

    path = (BLOCKS_DIR / f"{name}.md").resolve()
    if path.parent != BLOCKS_DIR:
        raise BlockError(f"block {name!r} resolves outside {BLOCKS_DIR}")
    if not path.is_file():
        raise BlockError(f"block {name!r} has no file at {path}")

    return path.read_text().rstrip("\n") + "\n"


def expand(text: str, blocks: Dict[str, str]) -> Tuple[str, List[str]]:
    """Rewrite every marked region in one agent file to its block's current text.

    :param text: the agent file's full contents.
    :param blocks: cache of already-loaded blocks, mutated as new ones load.
    :returns: ``(new_text, names)`` where ``names`` lists the blocks expanded.
    :raises BlockError: a marked region names a block that cannot be loaded.
    """
    expanded: List[str] = []

    def replace(match: re.Match) -> str:
        name = match.group("name")
        if name not in blocks:
            blocks[name] = load_block(name)
        expanded.append(name)
        return f"<!-- begin: {name} -->\n{blocks[name]}<!-- end: {name} -->"

    return MARKER.sub(replace, text), expanded


def main() -> int:
    """Expand or verify every agent file carrying block markers.

    :returns: process exit status — ``1`` if ``--check`` found drift.
    """
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--check",
        action="store_true",
        help="report drift without writing; exit 1 if any file is out of date",
    )
    args = parser.parse_args()

    if not AGENTS_DIR.is_dir():
        raise BlockError(f"no agents directory at {AGENTS_DIR}")

    blocks: Dict[str, str] = {}
    drifted: List[str] = []
    sites = 0

    for path in sorted(AGENTS_DIR.glob("*.md")):
        original = path.read_text()
        rebuilt, names = expand(original, blocks)
        if not names:
            continue

        sites += len(names)
        if rebuilt == original:
            continue

        drifted.append(path.name)
        if args.check:
            logger.error("%s is out of date (blocks: %s)", path.name, ", ".join(names))
            continue

        path.write_text(rebuilt)
        logger.info("rewrote %s (blocks: %s)", path.name, ", ".join(names))

    if args.check and drifted:
        logger.error("%d file(s) drifted; run without --check to fix", len(drifted))
        return 1

    logger.info(
        "%d block(s) across %d site(s); %s",
        len(blocks),
        sites,
        "all in sync" if not drifted else f"{len(drifted)} rewritten",
    )
    logger.info("agent definitions load at startup — restart Claude Code to pick this up")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except BlockError as error:
        logger.error("%s", error)
        sys.exit(2)
