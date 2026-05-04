# Migrating a setup.py / setup.cfg project

Older Python projects use `setup.py` and/or `setup.cfg` for packaging metadata, with deps in `install_requires` (and a `requirements.txt` for app-style projects). The migration goal is a PEP 621 `[project]` table in `pyproject.toml`.

## Detection

- `setup.py` (with or without `setup.cfg`)
- No `pyproject.toml`, or one that only has `[build-system]`
- README says `pip install .` or `pip install -e .`

## Strategy

1. Read `setup.py` / `setup.cfg` carefully.
2. Translate metadata to `[project]` in `pyproject.toml`.
3. Translate `install_requires` to `[project] dependencies`.
4. Translate `extras_require` to `[project.optional-dependencies]`.
5. Choose a build backend (hatchling is uv's default; setuptools is fine if the project has custom build steps).
6. Lock and sync.

## Translation

### `setup.py` style

```python
# setup.py (old)
from setuptools import setup, find_packages

setup(
    name="myproj",
    version="0.1.0",
    description="...",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    author="Jane",
    author_email="jane@example.com",
    python_requires=">=3.10",
    packages=find_packages(),
    install_requires=[
        "requests>=2.28",
        "numpy",
    ],
    extras_require={
        "dev": ["pytest", "ruff"],
        "docs": ["sphinx"],
    },
    entry_points={
        "console_scripts": [
            "myproj=myproj.cli:main",
        ],
    },
)
```

Becomes:

```toml
# pyproject.toml (new)
[project]
name = "myproj"
version = "0.1.0"
description = "..."
readme = "README.md"
authors = [{ name = "Jane", email = "jane@example.com" }]
requires-python = ">=3.10"
dependencies = [
    "requests>=2.28",
    "numpy",
]

[project.optional-dependencies]
docs = ["sphinx"]

[project.scripts]
myproj = "myproj.cli:main"

[dependency-groups]
dev = ["pytest", "ruff"]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

Note: `extras_require["dev"]` is conventionally a dependency group (PEP 735), not an optional dependency, since it's for project developers, not downstream users. Migrate it to `[dependency-groups]` not `[project.optional-dependencies]`.

### `setup.cfg` style

`setup.cfg` is declarative TOML-ish; the same fields map the same way. The `options.install_requires` block (one dep per line) is the source for `dependencies`.

### Dynamic version from `__version__.py` or git

If the project has `version = attr: myproj.__version__` or uses `setuptools-scm`:

- For `attr:` → use `[project] dynamic = ["version"]` and `[tool.hatch.version] path = "src/myproj/__init__.py"`.
- For `setuptools-scm` → use the `hatch-vcs` plugin, or keep setuptools as the backend.

## Step-by-step

### 1. Inventory setup.py / setup.cfg

Note these fields:

- `name`, `version`, `description`, `long_description`, `author`, `python_requires`
- `install_requires` → `[project] dependencies`
- `extras_require` → split into `[dependency-groups]` (dev/test/docs) and `[project.optional-dependencies]` (user-facing extras)
- `entry_points["console_scripts"]` → `[project.scripts]`
- `entry_points` for plugin discovery → `[project.entry-points."group.name"]`
- `package_data`, `include_package_data` → `[tool.hatch.build]` config (or keep setuptools)
- Custom `cmdclass` / `Extension` (C extensions) → keep setuptools as the build backend

### 2. Choose build backend

- **No custom build steps** → use hatchling (uv's default).
- **C extensions, custom build_ext, setuptools-scm** → keep setuptools.

If keeping setuptools:

```toml
[build-system]
requires = ["setuptools>=61", "wheel"]
build-backend = "setuptools.build_meta"

[tool.setuptools.packages.find]
where = ["src"]  # or wherever
```

### 3. Initialize uv side

If `pyproject.toml` doesn't exist:

```bash
uv init --no-workspace --bare
```

Then merge the translated `[project]` block into the generated file. Don't run `uv init` if `pyproject.toml` already has content — edit it instead.

### 4. Pin Python and add deps

```bash
uv python pin <version>
```

You can skip `uv add` for the deps you wrote into `pyproject.toml` directly — `uv lock` will pick them up. But running `uv add` per dep is more robust (it validates names/versions and resolves incrementally).

### 5. Lock and sync

```bash
uv lock
uv sync
```

If sync fails due to a missing C compiler or system library (common with C extensions), document the prerequisite in UV_SETUP.md.

### 6. setup.py / setup.cfg cleanup

You can usually delete `setup.py` and `setup.cfg` after migration. Exceptions:

- `setup.py` has custom build logic (Extension, cmdclass) — keep it.
- `setup.cfg` is used by other tools (flake8 config, coverage config) — keep those sections, remove the packaging metadata sections.

Don't delete without confirming `uv sync` and `uv build` (if it's a library) both succeed first.

## Common gotchas

- **`find_packages()` vs explicit packages list**: hatchling auto-detects in most cases. If your package layout is non-standard, configure `[tool.hatch.build.targets.wheel] packages`.
- **`src/` layout vs flat layout**: hatchling handles both, but you may need to be explicit. Check that the wheel built by `uv build` has the right contents.
- **C extensions**: hatchling doesn't compile C; stick with setuptools or use a backend like `meson-python` / `scikit-build-core`.
- **`tests_require` / `setup_requires`**: deprecated; move to dev dependency group.
