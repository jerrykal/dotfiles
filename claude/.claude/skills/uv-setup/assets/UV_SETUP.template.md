# UV setup notes

This document records how this project was migrated to be managed by [uv](https://docs.astral.sh/uv/), and what a contributor needs to do to reproduce the environment.

## TL;DR — Quick start

```bash
{{system_prereqs_oneliner_or_omit}}
uv sync
{{post_install_commands}}
```

Then run anything Python via `uv run`:

```bash
{{example_run_commands}}
```

## Migration summary

- **Source ecosystem**: {{source_ecosystem}}  <!-- pip / conda / poetry / pipenv / setuptools / mixed -->
- **Migrated on**: {{date}}
- **Python pinned to**: {{python_version}}
- **uv version used**: {{uv_version}}

### Files added

- `pyproject.toml` — project metadata and dependencies (PEP 621 format)
- `uv.lock` — locked dependency graph (commit this)
- `.python-version` — Python version pin

### Files preserved

{{preserved_files_list}}
<!--
  e.g.
  - `requirements.txt` — kept as a fallback for non-uv contributors and CI
  - `environment.yml` — kept; some contributors still use conda for the full stack
-->

### Files removed

{{removed_files_list_or_none}}

## System prerequisites

These must be installed **before** running `uv sync`. uv can't manage them because they're system libraries, hardware drivers, or non-Python runtimes.

{{system_prereqs_section}}
<!--
  For each prereq, write:

  ### <name>
  <what / why uv can't manage it>

  - Debian/Ubuntu: `sudo apt install <pkg>`
  - macOS (Homebrew): `brew install <pkg>`
  - Fedora/RHEL: `sudo dnf install <pkg>`

  If there are no system prereqs, write: "None — `uv sync` is sufficient."
-->

## Post-install steps

Run these once after `uv sync`:

{{post_install_section}}
<!--
  e.g.
  1. Download spaCy model: `uv run python -m spacy download en_core_web_sm`
  2. Install playwright browsers: `uv run playwright install chromium`
  3. Set up pre-commit hooks: `uv run pre-commit install`

  If none, write "None."
-->

## Warnings

{{warnings_section}}
<!--
  Surface anything that didn't translate cleanly. For each item:

  ### <thing>

  <one-paragraph explanation of what the original setup did, what we did instead, and any caveats>

  Examples:
  - GPU PyTorch was pinned to CUDA 11.8 via conda; we've configured uv to pull from
    `https://download.pytorch.org/whl/cu118`. The CUDA driver on the host must support
    CUDA 11.8 or later (`nvidia-smi` should report driver 450.80.02+).
  - The original environment.yml included `pymol-open-source` (conda-only). It is not
    available on PyPI. If you need pymol, install it separately via conda or your
    system package manager.

  If everything translated cleanly, write "None — full environment reproducibility via `uv sync`."
-->

## Daily workflow

### Running Python

```bash
uv run python script.py            # not `python script.py`
uv run pytest                      # not `pytest`
uv run <cli-tool>                  # not `<cli-tool>`
```

### Adding / removing dependencies

```bash
uv add <package>                   # add runtime dep
uv add --dev <package>             # add dev dep
uv remove <package>                # remove
uv lock --upgrade                  # refresh lockfile
```

### Updating the environment

```bash
uv sync                            # idempotent; safe to rerun
uv sync --upgrade                  # upgrade everything within constraints
```

## For non-uv contributors

If a contributor can't install uv, the {{fallback_file}} file is preserved for compatibility:

```bash
{{fallback_install_command}}
```

This path is not actively maintained — `uv.lock` is the source of truth.
