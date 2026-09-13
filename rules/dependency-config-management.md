---
paths:
  - "**/pyproject.toml"
  - "**/requirements*.txt"
  - "**/setup.py"
  - "**/setup.cfg"
  - "**/Pipfile*"
  - "**/config*.py"
  - "**/env.py"
---

# Dependency & configuration management rules (scoped)

Apply when adding/updating dependencies or reading/writing runtime configuration.

## Dependencies
- Pin versions (exact or compatible-release `~=`) in the lockfile; never leave a new dependency
  unpinned in a committed lockfile.
- Justify a new dependency: prefer the standard library or an existing dependency already in the
  project before adding one — a new dependency is a new supply-chain and maintenance liability.
- Separate runtime from dev/test dependencies explicitly (`[project.optional-dependencies]`,
  separate requirements files, or equivalent).
- Do not add a dependency with no recent maintenance activity or known unpatched advisories for
  the version being pinned without flagging the risk explicitly.

## Configuration
- Read config from environment/config files, never hardcode environment-specific values
  (URLs, ports, feature flags) in source.
- Provide a documented example (`.env.example`) with placeholder values only — never real
  secrets or credentials.
- Fail fast at startup on missing required config rather than defaulting silently to a value
  that masks a misconfiguration.
- Validate/coerce config values at load time (e.g. via `pydantic-settings` or an explicit
  parse-and-validate step), not scattered `os.environ.get(...)` calls with ad-hoc fallbacks
  throughout the codebase.

## Done conditions
- New dependency is pinned, justified, and placed in the correct runtime/dev group.
- No secret/credential value is committed in code or example config.
- Required config is validated at startup, not discovered as a runtime `KeyError`.

Source: Python Packaging User Guide (packaging.python.org), pip documentation on requirements files (pip.pypa.io).
