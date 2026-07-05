---
name: uv-migrate
description: Migrate an existing Python project (pip / conda / poetry / pipenv / setuptools) to uv so the environment reproduces with a single `uv sync`. Writes UV_SETUP.md and flags dependencies uv can't fully own.
allowed-tools: Bash(uv init:*), Bash(uv python:*), Bash(uv add:*), Bash(uv lock:*), Bash(uv sync:*), Bash(uv pip list:*), Bash(uv tree:*), Bash(uv run:*)
disable-model-invocation: true
---

# uv-migrate

Bootstrap an existing Python project so it can be managed by [uv](https://docs.astral.sh/uv/). The end state: the user (or a teammate) clones the repo and runs `uv sync` to get a working environment.

The project may have been originally managed by pip, conda/mamba, poetry, pipenv, or plain `setup.py`. Your job is to faithfully reproduce that environment under uv, document what you did, and clearly flag anything that uv can't fully **own** (system packages, conda-only deps, GPU toolchains).

**Preflight:** if the project already has `uv.lock` + `pyproject.toml` and `uv sync` works as-is, say so and stop — don't re-migrate a working uv project.

## High-level workflow

Five phases, in order. Don't skip phases.

1. **Detect** — read README and dependency files; figure out the source ecosystem and Python version.
2. **Plan** — present what you'll do and what you'll warn about. Get user confirmation before mutating files.
3. **Migrate** — run uv commands to construct `pyproject.toml`, `.python-version`, `uv.lock`.
4. **Validate** — run `uv sync` and verify it works. Smoke-test if the README points to an obvious entrypoint.
5. **Document** — write `UV_SETUP.md`.

The contract: **`uv sync` reproduces everything uv owns**. Everything it can't own — system packages, GPU drivers, post-install downloads — becomes a documented prerequisite in UV_SETUP.md.

## Phase 1: Detect

### Read the README

Look for `README.md`, `README.rst`, `README.txt`, `README` (in that order). Extract:

- **Python version requirement** — explicit (`Python 3.10+`) or implicit (CI matrix, version classifiers).
- **Install command(s)** — `pip install -r requirements.txt`, `conda env create -f environment.yml`, `pip install -e .`, `poetry install`, `pipenv install`, etc.
- **Optional/dev/test extras** — separate dev requirements files, `[dev]` extras, etc.
- **Pre-install steps** — system packages (`apt install`, `brew install`), CUDA toolkit, Java, compilers.
- **Post-install steps** — model downloads, `playwright install`, NLTK data, `python -m spacy download`, etc.

If there's no README or it's empty, say so and continue based on dependency files alone.

### Inventory dependency files

Check for, in order of authority:

| File | Source ecosystem | Notes |
|---|---|---|
| `pyproject.toml` + `uv.lock` | already uv | usually a no-op; verify and stop |
| `pyproject.toml` + `poetry.lock` | poetry | see `references/poetry.md` |
| `pyproject.toml` (PEP 621) | modern pip / hatch / flit | usually mostly compatible |
| `Pipfile` + `Pipfile.lock` | pipenv | see `references/pipenv.md` |
| `environment.yml` / `environment.yaml` | conda / mamba | see `references/conda.md` |
| `requirements*.txt` | pip | see `references/pip.md` |
| `setup.py` / `setup.cfg` | setuptools | PEP 621 migration — see `references/setuptools.md` |

A project may have several. Use the most authoritative one as the source of truth, but cross-check the others — README often points at one and the others are CI/dev-only.

### Detect the Python version

Sources, in order of preference:

1. `.python-version` file
2. `pyproject.toml` `project.requires-python`
3. `setup.cfg` / `setup.py` `python_requires`
4. `environment.yml` `dependencies: - python=...`
5. `Pipfile` `[requires] python_version`
6. README mentions
7. CI config (`.github/workflows/*.yml`, `tox.ini`)

If only a range is specified (e.g. `>=3.9`), pin to a concrete version that satisfies it. Default to the latest stable Python that satisfies the constraint unless the README/CI suggests otherwise.

## Phase 2: Plan and confirm

Before changing any files, summarize the plan to the user. Cover:

- Detected source ecosystem
- Python version you'll pin
- Where dependencies will come from
- Whether you'll preserve a `requirements.txt` (you usually should — it's a useful fallback for non-uv users)
- **Warnings**: before writing the plan, read `references/warnings.md` and check every dependency against its catalog — every match becomes a warning in the plan, and later an entry in UV_SETUP.md.

Ask the user once: "Proceed with this migration plan?" Wait for confirmation. This is the right place to pause because the next phase mutates files in their repo.

Skip the confirmation only when the user pre-approved in the invocation (e.g. "migrate to uv, don't ask") or the session is non-interactive — even then, print the plan and warnings before migrating.

## Phase 3: Migrate

Read **only** the `references/<source>.md` matching the ecosystem you detected — not all of them. The general pattern:

1. **Initialize uv project** (if no `pyproject.toml` yet): `uv init --no-workspace` (use `--lib` for libraries, `--app` for apps; default is fine if unsure). Don't clobber an existing `pyproject.toml` — read and edit it instead.
2. **Pin Python**: `uv python pin <version>` — creates `.python-version`.
3. **Add dependencies**: prefer `uv add <pkg>` over hand-editing `pyproject.toml` so uv resolves and locks atomically. Use `uv add --dev` for dev-only deps, `uv add --optional <group>` for extras.
4. **Add the project itself if it's installable**: a project with `setup.py` / `pyproject.toml` that the README installs with `pip install -e .` should keep that behavior — `uv sync` installs the local package automatically when `pyproject.toml` is present.
5. **Lock and sync**: `uv lock` then `uv sync` (or just `uv sync` which does both). This creates `.venv/` and `uv.lock`.

### Things you should NOT do

- Don't preserve pinned hashes from old lockfiles — let uv re-resolve. Hashes from `pip-tools` or `poetry` aren't compatible with uv's lockfile.
- Don't try to encode conda-only dependencies into `pyproject.toml`. Document them as prerequisites.
- Don't delete the original `requirements.txt` / `environment.yml` unless the user asks. They're useful for non-uv contributors and CI fallback.
- Don't run `uv pip install` into a uv project — it bypasses the lockfile. Use `uv add`.

### Handling extras and dependency groups

Modern uv organizes optional deps as **dependency groups** (PEP 735) for dev/test/docs and **optional dependencies** for user-facing extras like `pip install pkg[gpu]`.

- Dev/test/docs/lint → `uv add --dev <pkg>` (group `dev`) or `uv add --group test <pkg>`.
- User-facing extras (`pkg[server]`, `pkg[gpu]`) → `uv add --optional <name> <pkg>`.

When migrating from `requirements-dev.txt`, treat it as the `dev` group. From `extras_require` in `setup.py`, map keys to optional dependencies.

## Phase 4: Validate

1. Run `uv sync` and watch for resolver errors. Common failures:
   - Conflicting version pins → loosen the offending pin or report as a warning.
   - Package not on PyPI → it might be conda-only or a private package; document as a warning.
   - Python version too restrictive → adjust `requires-python`.
2. Cross-check `uv tree` (or `uv pip list`) against the source dependency files: every dependency is either installed or listed as a warning — nothing silently dropped.
3. **Smoke test** if the README has an obvious entrypoint:
   - CLI tool: `uv run <cli> --help`
   - Test suite: `uv run pytest --collect-only`
   - Notebook: import the main module via `uv run python -c "import <pkg>"`
   Don't run anything that takes more than a few seconds, hits the network, or could mutate state. The goal is "does it import cleanly" not "does the whole project work".
4. If validation fails, **stop and surface the error**. Don't silently leave a broken environment. The user should know `uv sync` doesn't work yet.

## Phase 5: Document

Fill in `assets/UV_SETUP.template.md` and write it to the project root as `UV_SETUP.md`. Done when no `{{placeholder}}` remains — and every warning surfaced in Phase 2 appears in it.

## Style

- Be concrete in UV_SETUP.md: paste the exact `uv` commands you ran. The user should be able to re-derive your work.
- If the README is ambiguous, prefer the more conservative interpretation (more warnings, not fewer).
- Use the `astral:uv` skill (`uv` skill from the Astral plugin) for general uv usage questions — this skill focuses on the migration workflow, not uv fundamentals.
