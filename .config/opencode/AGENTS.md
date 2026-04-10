# Personal OpenCode Rules

## Python tool preference
When working in a Python project, prefer `uv` over `python`, `python3`, `pip`, or `pip3` if `uv` is available and the project appears to use it.

Before running Python-related commands:
- Check whether `uv` is available.
- Check whether the project appears to use `uv`, for example via `uv.lock`, `pyproject.toml`, or existing `uv` usage in project docs or scripts.

If `uv` is available and the project uses it, prefer:
- `uv run python ...` instead of `python ...` or `python3 ...`
- `uv run pytest ...` instead of `pytest ...`
- `uv add ...` instead of `pip install ...`
- `uv sync` instead of manual environment setup when appropriate

Do not switch to `uv` if the repository explicitly uses another Python toolchain and expects that instead.
