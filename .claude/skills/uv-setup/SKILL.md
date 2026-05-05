---
name: uv-setup
description: Migrate an existing Python project to be managed by uv so the user can reproduce the environment with a single `uv sync`. Use whenever the user invokes `/uv-setup`, asks to "set up uv for this project", "convert this repo to uv", "migrate from pip/conda/poetry/pipenv to uv", or otherwise wants to bootstrap a uv environment for a project that wasn't originally managed with uv. Reads the project's README and existing dependency files (requirements*.txt, environment.yml, setup.py/cfg, Pipfile, pyproject.toml), produces a working uv project, writes UV_SETUP.md summarizing what was done, and surfaces warnings for any dependencies that can't be expressed through uv (conda-only packages, system libraries, hardware-specific wheels, etc.).
allowed-tools: Bash(uv init *) Bash(uv python *) Bash(uv add *) Bash(uv lock *) Bash(uv sync *) Bash(uv pip list *) Bash(uv tree *) Bash(uv run *)
---

# uv-setup

Bootstrap an existing Python project so it can be managed by [uv](https://docs.astral.sh/uv/). The end state: the user (or a teammate) clones the repo and runs `uv sync` to get a working environment.

The project may have been originally managed by pip, conda/mamba, poetry, pipenv, or plain `setup.py`. Your job is to faithfully reproduce that environment under uv, document what you did, and clearly flag anything that uv can't fully own (system packages, conda-only deps, GPU toolchains).

## When to invoke

This skill is the right tool when the user says any of:

- `/uv-setup`
- "set up uv for this project"
- "migrate this repo to uv"
- "make `uv sync` work in this project"
- "convert this requirements.txt / environment.yml / Pipfile to uv"

If the project already has `uv.lock` and `pyproject.toml` and `uv sync` works as-is, say so and stop — don't re-migrate a working uv project.

## High-level workflow

Five phases, in order. Don't skip phases — each one feeds the next.

1. **Detect** — read README and dependency files; figure out the source ecosystem and Python version.
2. **Plan** — present what you'll do and what you'll warn about. Get user confirmation before mutating files.
3. **Migrate** — run uv commands to construct `pyproject.toml`, `.python-version`, `uv.lock`.
4. **Validate** — run `uv sync` and verify it works. Smoke-test if the README points to an obvious entrypoint.
5. **Document** — write `UV_SETUP.md` and (if appropriate) update `CLAUDE.md`.

The user's expectation is that after this skill runs, **`uv sync` is the one command that reproduces the environment**. Everything else (system packages, GPU drivers) goes into UV_SETUP.md as documented prerequisites.

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
| `setup.py` / `setup.cfg` | setuptools | needs migration to PEP 621 |

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
- **Warnings**: any dependency that uv won't be able to install. See `references/warnings.md` for the catalog.
- Whether you'll touch `CLAUDE.md`

Ask the user once: "Proceed with this migration plan?" Wait for confirmation. This is the right place to pause because the next phase mutates files in their repo.

If the user is in auto mode and the plan is unsurprising (pure-pip project, no warnings), you can proceed without confirming — but always still surface warnings before migrating.

## Phase 3: Migrate

Read the appropriate `references/<source>.md` for detailed steps. The general pattern:

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
2. Check that the venv contains the expected top-level packages: `uv pip list` (or `uv tree`).
3. **Smoke test** if the README has an obvious entrypoint:
   - CLI tool: `uv run <cli> --help`
   - Test suite: `uv run pytest --collect-only`
   - Notebook: import the main module via `uv run python -c "import <pkg>"`
   Don't run anything that takes more than a few seconds, hits the network, or could mutate state. The goal is "does it import cleanly" not "does the whole project work".
4. If validation fails, **stop and surface the error**. Don't silently leave a broken environment. The user should know `uv sync` doesn't work yet.

## Phase 5: Document

### Write UV_SETUP.md

Use the template at `assets/UV_SETUP.template.md`. Fill in:

- **Source ecosystem** detected (pip/conda/poetry/pipenv/etc.)
- **Files added** (`pyproject.toml`, `uv.lock`, `.python-version`, etc.)
- **Files preserved** (`requirements.txt`, `environment.yml`)
- **System prerequisites** that must be installed outside uv (with install commands per OS where known)
- **Post-install steps** (model downloads, etc.) the user must run after `uv sync`
- **Warnings** — anything that didn't translate cleanly
- **Quick start** for new contributors:
  ```bash
  uv sync
  uv run <whatever the README's entrypoint was>
  ```

Place `UV_SETUP.md` in the project root.

### Update CLAUDE.md (conditionally)

Update `CLAUDE.md` (or create a minimal one) **only if** any of these hold:

- The project is one a Claude Code agent will likely work in repeatedly (the user is actively developing it).
- The original README directs users to non-uv commands (`pip install`, `conda activate`) that an agent might mistakenly follow.
- There are post-install gotchas an agent needs to know (e.g., "always run via `uv run`, never `python` directly").

When updating, add a focused section:

```markdown
## Python environment

This project uses `uv` for environment management. See `UV_SETUP.md` for migration details.

- Run anything Python-related via `uv run` (e.g., `uv run pytest`, `uv run python script.py`).
- Add deps with `uv add <pkg>`, never `pip install`.
- The lockfile is `uv.lock` — commit it.
- System prerequisites are listed in UV_SETUP.md and must be installed manually.
```

If `CLAUDE.md` already exists, append a section rather than overwriting. If the user said "don't touch CLAUDE.md", skip this step.

## Warnings: dependencies uv can't fully own

This is the most important thing this skill gets right. Read `references/warnings.md` for the full catalog. The headline categories:

- **Conda-only packages** (no PyPI equivalent): `mkl`, `cudatoolkit`, `cudnn`, `nccl`, `mpich`, `gdal` (sometimes), `rdkit` (older), `pymol-open-source`, etc.
- **System libraries** that Python wheels link against: `libgl`, `ffmpeg`, `graphviz`, `libpq`, `tesseract`, `openssl-dev`, `libffi-dev`, etc. — uv installs the Python binding but the system lib must be installed via apt/brew/dnf.
- **GPU/CUDA stacks**: PyTorch, JAX, TensorFlow GPU builds often require an exact CUDA version. uv supports them via [extra-index-url](https://docs.astral.sh/uv/guides/integration/pytorch/), but the host CUDA driver is the user's responsibility.
- **Editable installs of sibling repos** (`pip install -e ../other-repo`): map to `uv add --editable ../other-repo` or workspace members.
- **Private indexes / git+ssh deps**: supported by uv but require credentials; flag for the user.
- **Compiler toolchains**: packages with `pip install`-time C/Fortran compilation need `gcc`/`clang`/`gfortran` on the host.
- **Post-install model/data downloads**: `python -m spacy download en_core_web_sm`, `playwright install chromium`, NLTK corpora, HuggingFace caches. Document as post-install steps; don't try to encode them in `pyproject.toml`.

For each warning, the UV_SETUP.md entry should say **what** is needed, **why** uv can't manage it, and **how** to install it.

## Source-specific playbooks

When you've identified the source ecosystem in Phase 1, read the corresponding reference file before starting Phase 3:

- `references/pip.md` — requirements*.txt projects (most common)
- `references/conda.md` — environment.yml / mamba projects (most warnings here)
- `references/poetry.md` — Poetry projects
- `references/pipenv.md` — Pipfile / Pipfile.lock projects
- `references/setuptools.md` — setup.py / setup.cfg projects
- `references/warnings.md` — the catalog of non-uv-configurable cases

Read only the one(s) you need — don't load all of them up front.

## Style

- Be concrete in UV_SETUP.md: paste the exact `uv` commands you ran. The user should be able to re-derive your work.
- Don't claim a project is fully reproducible via `uv sync` if there are system prereqs — be honest about what's needed outside uv.
- If the README is ambiguous, prefer the more conservative interpretation (more warnings, not fewer).
- Use the `astral:uv` skill (`uv` skill from the Astral plugin) for general uv usage questions — this skill focuses on the migration workflow, not uv fundamentals.
