# Migrating a Pipenv project

Pipenv projects use `Pipfile` (TOML-ish) and `Pipfile.lock` (JSON). Migration is straightforward — the dependency model maps cleanly to uv.

## Detection

- `Pipfile` and usually `Pipfile.lock`
- README says `pipenv install` / `pipenv shell` / `pipenv run`

## Strategy

1. Try `uvx migrate-to-uv` — it supports Pipenv.
2. If unavailable or it fails, translate `Pipfile` to `pyproject.toml` manually.

## Pipfile structure

```toml
[[source]]
url = "https://pypi.org/simple"
verify_ssl = true
name = "pypi"

[packages]
requests = "*"
flask = ">=2.0"
mypackage = {path = ".", editable = true}

[dev-packages]
pytest = "*"
ruff = "*"

[requires]
python_version = "3.10"
```

## Translation

| Pipenv | uv / pyproject.toml |
|---|---|
| `[packages]` | `[project] dependencies` |
| `[dev-packages]` | `[dependency-groups] dev` |
| `[requires] python_version` | `requires-python` + `uv python pin` |
| `pkg = "*"` | `pkg` (no version constraint) |
| `pkg = ">=2.0"` | `pkg>=2.0` |
| `pkg = {version = ">=1.0", extras = ["redis"]}` | `pkg[redis]>=1.0` |
| `pkg = {path = ".", editable = true}` | `uv sync` handles automatically if pyproject.toml has `[project]` |
| `pkg = {git = "https://...", ref = "main"}` | `uv add 'pkg @ git+https://...@main'` |
| `pkg = {file = "./vendor/pkg.tar.gz"}` | `uv add ./vendor/pkg.tar.gz` |

## Step-by-step

### 1. Initialize and pin Python

```bash
uv init --no-workspace --bare
uv python pin <version>  # match Pipfile [requires] python_version
```

If `python_version = "3.10"` in Pipfile, that's a "starts with 3.10" — pin to a concrete 3.10.x.

### 2. Add packages

For each entry in `[packages]`:

```bash
uv add <pkg><version-spec>
```

Skip the local-package self-install (`{path = ".", editable = true}`) — `uv sync` handles that automatically when there's a `[project]` table.

For each entry in `[dev-packages]`:

```bash
uv add --dev <pkg><version-spec>
```

### 3. Custom indexes

If `[[source]]` has a non-default URL (e.g. private PyPI), translate to `pyproject.toml`:

```toml
[[tool.uv.index]]
name = "private"
url = "https://private.example.com/simple"
```

If the index needs auth, document that in UV_SETUP.md (env vars, keyring, etc.).

### 4. Lock and sync

```bash
uv lock
uv sync
```

`Pipfile.lock` is dense and unfriendly to diff. Don't try to preserve it — uv generates its own `uv.lock`.

### 5. Clean up

After validation:

- Delete `Pipfile` and `Pipfile.lock` (or keep as fallback if user prefers).
- Update README sections that say `pipenv install` → `uv sync` and `pipenv run X` → `uv run X`.

## Common gotchas

- **`pipenv shell`**: maps to `uv run` (preferred) or `source .venv/bin/activate`. The README probably uses `pipenv shell`; flag it in UV_SETUP.md.
- **`pipenv run script-name`**: if `Pipfile` has a `[scripts]` section, those are Pipenv-specific aliases. Migrate them to `[project.scripts]` (if they're entry points) or document as `uv run <command>` invocations.
- **Pipenv's strict-by-default lock**: Pipenv pins everything tightly; uv may resolve to slightly different versions. That's expected.
