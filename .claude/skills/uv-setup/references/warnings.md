# Warnings: dependencies uv can't fully manage

The honest framing: uv is a Python package manager. It manages **PyPI-distributable Python packages** and the Python interpreter itself. It doesn't manage system libraries, GPU drivers, conda-only packages, or non-Python data.

When you encounter any of these in a migration, surface them as warnings and document them in UV_SETUP.md as **prerequisites** the user must install outside of `uv sync`. Be specific — name the package and give install commands per OS.

## Categories

### 1. Conda-only Python packages

Some Python packages are distributed only via conda (or have stale/abandoned PyPI mirrors). Common ones:

| conda package | PyPI status | What to do |
|---|---|---|
| `pymol-open-source` | not on PyPI | document as prerequisite (install via conda or system pkg) |
| `r-base`, `r-essentials` | not Python | install R via system package manager |
| `cudatoolkit`, `cudnn`, `nccl` | not on PyPI as standalone | host CUDA driver is the user's responsibility |
| `mkl`, `mkl-devel` | available as `mkl` on PyPI but rarely needed standalone | usually not needed; numpy/scipy ship their own BLAS |
| `mpich`, `openmpi` | system libs | install via apt/brew |
| `proj`, `geos`, `gdal` (lib, not Python) | system libs | install via apt/brew/dnf |
| `rdkit` (older) | newer versions on PyPI as `rdkit` | switch to PyPI; flag if version pin requires conda |
| `dlib` (some builds) | available on PyPI but build can fail without cmake | document cmake as system prereq |
| `pytorch-cuda=X.Y` | use PyTorch's index | configure `[tool.uv.sources]`, see references/conda.md |

**Action**: For each, document in UV_SETUP.md "System prerequisites" with install commands.

### 2. System libraries

Python wheels that link against system libs work after `uv sync` only if the system lib is already installed. The Python wheel can't bring it.

| Python package | System library needed | apt | brew |
|---|---|---|---|
| `psycopg2` | libpq | `libpq-dev` | `libpq` |
| `mysqlclient` | libmysqlclient | `default-libmysqlclient-dev` | `mysql-client` |
| `pillow` (some features) | libjpeg, libpng, libtiff | `libjpeg-dev libpng-dev libtiff-dev` | usually already there |
| `lxml` | libxml2, libxslt | `libxml2-dev libxslt1-dev` | `libxml2 libxslt` |
| `pycairo`, `pygobject` | gtk, cairo, gobject | `libgirepository1.0-dev libcairo2-dev` | `gtk+3 cairo` |
| `pyaudio` | portaudio | `portaudio19-dev` | `portaudio` |
| `opencv-python` | libgl, libglib | `libgl1 libglib2.0-0` | usually fine |
| `pygraphviz` | graphviz | `graphviz graphviz-dev` | `graphviz` |
| `pytesseract` | tesseract | `tesseract-ocr` | `tesseract` |
| `ffmpeg-python`, `imageio-ffmpeg` | ffmpeg binary | `ffmpeg` | `ffmpeg` |
| `cryptography` (older) | libssl, libffi | `libssl-dev libffi-dev` | usually fine |

Tip: workarounds like `psycopg[binary]` (instead of `psycopg2`) bundle the system lib in the wheel and avoid the prereq. Suggest these where applicable.

### 3. GPU / accelerator stacks

PyTorch, TensorFlow, JAX, and similar all have CUDA/ROCm-pinned variants. uv supports them via custom indexes, but the **host driver** is always the user's responsibility.

For PyTorch specifically:

```toml
# pyproject.toml
[tool.uv.sources]
torch = [{ index = "pytorch-cu121" }]

[[tool.uv.index]]
name = "pytorch-cu121"
url = "https://download.pytorch.org/whl/cu121"
explicit = true
```

In UV_SETUP.md, write:

> This project uses GPU-accelerated PyTorch (CUDA 12.1). You must have a compatible NVIDIA driver installed (`nvidia-smi` should report driver supporting CUDA 12.1+). The CUDA toolkit itself is bundled in the PyTorch wheel — you don't need to install it separately.

For Apple Silicon (MPS), PyTorch from PyPI works out of the box. For ROCm, see the PyTorch docs for the right index URL.

### 4. Compiler toolchains

Some packages need a C/C++/Fortran compiler at install time (no pre-built wheels for the platform):

- `gcc` / `clang` / `gfortran` for C/C++/Fortran extensions
- `cmake` for cmake-based builds (e.g. `dlib`, `lightgbm` from source)
- `pkg-config` for finding system libs
- `rust` (`cargo`) for some newer packages (e.g. `pydantic-core`, `cryptography` source builds)

**Action**: If you see a package that builds from source, document the toolchain prerequisite. Modern wheels usually mean this isn't needed — flag only when you observe a `pip install` that triggers a compile.

### 5. Editable installs of sibling repos

`pip install -e ../shared-utils` translates to:

```bash
uv add --editable ../shared-utils
```

Or, if multiple sibling repos belong together, use a uv workspace:

```toml
# pyproject.toml
[tool.uv.workspace]
members = ["packages/*"]
```

In UV_SETUP.md, document:

- The expected directory layout (where the sibling repo lives)
- Any setup needed in the sibling repo first
- Whether the sibling needs its own `uv sync`

### 6. Private indexes / git+ssh deps

Supported by uv, but require credentials.

```toml
[[tool.uv.index]]
name = "internal"
url = "https://pypi.internal.example.com/simple"
```

Auth options uv supports: `UV_INDEX_<NAME>_USERNAME` / `UV_INDEX_<NAME>_PASSWORD` env vars, keyring, or URL embedding (don't commit credentials).

For `git+ssh://git@github.com/org/repo.git` deps, the user needs SSH access to the repo. Document this.

### 7. Post-install model / data downloads

`uv sync` installs Python packages. It does NOT run arbitrary post-install scripts. Common cases that need a manual step:

| Tool | Post-install command |
|---|---|
| spaCy models | `uv run python -m spacy download en_core_web_sm` |
| NLTK corpora | `uv run python -m nltk.downloader punkt stopwords` |
| Playwright browsers | `uv run playwright install chromium` |
| HuggingFace models | usually downloaded on first use; document expected disk usage |
| Detectron2 model weights | manual download per README |
| pre-commit hooks | `uv run pre-commit install` |

Document each as a numbered step in UV_SETUP.md "Post-install steps".

### 8. Non-Python runtime requirements

If the project needs a non-Python runtime (Node.js, Java, Go, R, Julia), uv can't install it. Document via system package manager.

Common cases:

- **Java** for `pyspark`, `tika-python`, etc. — install JDK via system pkg manager
- **Node.js** for `playwright`, `jupyterlab` extensions — install via nvm or system
- **R** for `rpy2` — install R via system pkg manager

### 9. Platform-specific deps

Watch for environment markers:

```toml
dependencies = [
    "pywin32; sys_platform == 'win32'",
    "pyobjc; sys_platform == 'darwin'",
    "uvloop; sys_platform != 'win32'",
]
```

These are fully supported by uv — preserve them. Just confirm the markers are correct after migration.

## How to write a warning in UV_SETUP.md

Each warning should answer three questions:

1. **What** — the specific dep that needs handling
2. **Why** — uv can't manage it because: it's not on PyPI / it's a system lib / it needs a host driver / etc.
3. **How** — the install command, with OS variants where relevant

Example:

> ### `psycopg2` requires libpq
>
> The `psycopg2` Python package links against PostgreSQL's libpq client library, which uv can't install. Install it via your system package manager:
>
> - Debian/Ubuntu: `sudo apt install libpq-dev`
> - macOS (Homebrew): `brew install libpq`
> - Fedora/RHEL: `sudo dnf install postgresql-devel`
>
> Alternative: replace `psycopg2` with `psycopg[binary]` in `pyproject.toml`, which bundles libpq in the wheel.

Don't bury warnings — put them prominently in UV_SETUP.md so the user sees them before running `uv sync`.
