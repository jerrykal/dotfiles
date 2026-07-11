# Migrating a Poetry project

Poetry projects are usually the cleanest migration — they already have a `pyproject.toml` and structured deps. The main work is translating Poetry's `[tool.poetry]` table to PEP 621 `[project]` format.

## Detection

- `pyproject.toml` with `[tool.poetry]` section
- `poetry.lock` file
- README says `poetry install`

## Strategy

uv reads PEP 621 (`[project]`), not `[tool.poetry]`. You need to either:

1. **Migrate `[tool.poetry]` → `[project]`** (preferred — clean, future-proof).
2. **Use `uvx migrate-to-uv`** if available — does the translation automatically.

## Step-by-step

### 1. Try the automated migration

```bash
uvx migrate-to-uv
```

`migrate-to-uv` is a community tool (https://github.com/mkniewallner/migrate-to-uv) that handles Poetry, Pipenv, and pip-tools. If it works cleanly, jump to validation.

If it doesn't exist or fails, do it manually below.

### 2. Manual migration: translate sections

Poetry `[tool.poetry]`:

```toml
[tool.poetry]
name = "myproj"
version = "0.1.0"
description = "..."
authors = ["Jane <jane@example.com>"]
readme = "README.md"
python = "^3.10"

[tool.poetry.dependencies]
requests = "^2.28"
numpy = ">=1.24,<2.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.0"
ruff = "*"

[tool.poetry.scripts]
myproj = "myproj.cli:main"
```

Becomes PEP 621 `[project]`:

```toml
[project]
name = "myproj"
version = "0.1.0"
description = "..."
authors = [{ name = "Jane", email = "jane@example.com" }]
readme = "README.md"
requires-python = ">=3.10,<4.0"
dependencies = [
    "requests>=2.28,<3.0",
    "numpy>=1.24,<2.0",
]

[project.scripts]
myproj = "myproj.cli:main"

[dependency-groups]
dev = [
    "pytest>=7.0,<8.0",
    "ruff",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

### Translating Poetry version specifiers

Poetry uses caret/tilde syntax that PEP 440 doesn't:

| Poetry | PEP 440 / pyproject.toml |
|---|---|
| `^1.2.3` | `>=1.2.3,<2.0.0` |
| `^0.2.3` | `>=0.2.3,<0.3.0` (caret on 0.x bumps minor, not major) |
| `~1.2.3` | `>=1.2.3,<1.3.0` |
| `~1.2` | `>=1.2,<2.0` |
| `1.2.*` | `==1.2.*` |
| `>=1.2,<2.0` | same |
| `*` | (omit, or `>=0`) |

**Caret on 0.x is a common gotcha** — `^0.2.3` is NOT `>=0.2.3,<1.0.0`, it's `>=0.2.3,<0.3.0`.

### Translating Python version

| Poetry `python = ...` | `requires-python` |
|---|---|
| `^3.10` | `>=3.10,<4.0` |
| `~3.10` | `>=3.10,<3.11` |
| `>=3.10,<3.13` | same |

### Translating dependency groups

Poetry's `[tool.poetry.group.<name>.dependencies]` → `[dependency-groups]` (PEP 735) in pyproject.toml.

Optional dependencies (extras, used like `pip install pkg[server]`) come from Poetry's `[tool.poetry.extras]` and translate to `[project.optional-dependencies]`.

Don't conflate the two:
- **Dependency groups** (PEP 735): for dev, test, docs, lint — internal to the project.
- **Optional dependencies**: for downstream users to opt into via extras.

### 3. Build backend

Poetry uses `poetry-core` as its build backend. For a uv project, switch to `hatchling` (uv's default):

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

If the project uses Poetry-specific build features (`include`, `exclude`, custom `packages`), translate to `[tool.hatch.build]`. For most projects, hatchling's defaults work.

### 4. Pin Python and lock

```bash
uv python pin 3.10  # whatever you migrated
uv lock
uv sync
```

### 5. Delete poetry artifacts (optional)

After validation, you can:

- Delete `poetry.lock` (uv has its own `uv.lock`).
- Remove `[tool.poetry]` and `[tool.poetry.*]` sections from `pyproject.toml`.
- Remove the `poetry-core` build backend if you switched to hatchling.

Confirm with the user before deleting `poetry.lock` — some teams have CI that still references it during transition.

## Validate

```bash
uv sync
uv tree
```

The tree should match `poetry show --tree` reasonably closely (versions may differ slightly because uv re-resolves; that's expected).

## Don't

- Don't keep both `[tool.poetry.dependencies]` and `[project.dependencies]` long-term — uv only reads the latter, and they'll drift.
- Don't try to convert Poetry's `path` deps with `develop = true` directly — use `uv add --editable <path>` or workspace members.
- Don't forget the build backend swap — leaving `poetry-core` will work for installs but is misleading.
