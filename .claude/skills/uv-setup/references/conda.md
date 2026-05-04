# Migrating a conda / mamba project

This is the highest-warning migration. conda is a general package manager (it ships compiled C/Fortran libraries, not just Python packages), and a non-trivial fraction of conda environments cannot be reproduced through pip/PyPI alone. Be honest about this in UV_SETUP.md.

## Detection

Hallmarks:

- `environment.yml` or `environment.yaml`
- README says `conda env create -f environment.yml` or `mamba env create ...`
- `.conda/` directory or references to conda channels
- Sometimes `requirements.txt` alongside, used for the pip-installable subset

## The conda dependency model

`environment.yml` looks like:

```yaml
name: myproj
channels:
  - conda-forge
  - pytorch
  - defaults
dependencies:
  - python=3.10
  - numpy=1.24
  - pytorch-cuda=11.8
  - pip
  - pip:
    - some-pypi-pkg==1.2
```

Two layers:

1. Top-level `dependencies` — installed via conda. May or may not be on PyPI.
2. `pip:` sub-list — installed via pip. Always pip-installable.

Channels matter: `pytorch`, `nvidia`, `bioconda` ship packages that may not exist on PyPI at all.

## Strategy

1. Categorize each top-level dep:
   - **PyPI-equivalent**: `numpy`, `pandas`, `scikit-learn`, `matplotlib`, `requests`, `flask`, etc. → translates 1:1 to `uv add`.
   - **Conda-only or conda-preferred**: `cudatoolkit`, `cudnn`, `mkl`, `mpich`, `openmpi`, `gdal` (sometimes), `r-base`, `pymol-open-source`, etc. → **warning**.
   - **System libs masquerading as conda packages**: `libgl`, `ffmpeg`, `graphviz`, `pkg-config`, `cmake`. uv can't install these — they need apt/brew/dnf.
   - **Python itself**: `python=3.10` → `uv python pin 3.10`.
   - **`pip` and friends**: drop them; uv replaces them.
2. Move the `pip:` sub-list into `uv add` as-is.
3. Document everything in the conda-only / system bucket in UV_SETUP.md.

## Step-by-step

### 1. Read environment.yml carefully

Pay attention to:

- `channels` — order matters in conda (priority). For uv, only `pytorch`, `nvidia`, and similar matter (those have non-PyPI packages).
- Version syntax — conda uses `=` (one equals) for "starts with" semantics. `python=3.10` means any 3.10.x. Translate to `python>=3.10,<3.11` or just pin to a specific 3.10.x.
- `pip:` block — straightforward to add via `uv add`.
- `prefix:` line — ignore (it's a local artifact).

### 2. Initialize uv project

```bash
uv init --no-workspace --bare
uv python pin <version-from-environment.yml>
```

### 3. Add the obvious pip-equivalents

Build a list of conda deps that are 1:1 with PyPI. Common ones:

| conda | PyPI |
|---|---|
| `numpy`, `pandas`, `scipy`, `scikit-learn` | same |
| `matplotlib`, `seaborn`, `plotly` | same |
| `pytorch` | `torch` |
| `tensorflow` | `tensorflow` |
| `jupyter`, `jupyterlab` | same |
| `pyyaml` | `pyyaml` |
| `ipython`, `ipykernel` | same |
| `tqdm`, `requests`, `pillow` | same |
| `opencv` | `opencv-python` (usually) |

Add them with version constraints translated:

```bash
uv add 'numpy>=1.24,<1.25' pandas 'scikit-learn>=1.3'
```

### 4. Translate the pip: block

```bash
uv add <each pip dep>
```

These are PyPI-native by definition.

### 5. Handle GPU / ML stacks

PyTorch with CUDA is the canonical case. uv has first-class support; see https://docs.astral.sh/uv/guides/integration/pytorch/.

For PyTorch + CUDA 11.8, you'd configure in `pyproject.toml`:

```toml
[tool.uv.sources]
torch = [{ index = "pytorch-cu118" }]

[[tool.uv.index]]
name = "pytorch-cu118"
url = "https://download.pytorch.org/whl/cu118"
explicit = true
```

Then `uv add torch` pulls from the CUDA-pinned index.

For TensorFlow GPU and JAX, the wheels are on PyPI but require matching CUDA on the host. **The host CUDA driver is the user's responsibility** — flag it in UV_SETUP.md.

### 6. Bucket the rest as warnings

For any remaining top-level conda dep, decide:

- **System library** → document in UV_SETUP.md "System prerequisites" with apt/brew install commands per OS.
- **Conda-only Python package** (no PyPI equivalent) → warn loudly. The user may need to keep using conda for this, or find a substitute (e.g. older `rdkit-pypi` instead of `rdkit`).
- **Conda-managed runtime** (R, Java, node) → install via system package manager and document.

See `references/warnings.md` for the catalog.

### 7. Validate

```bash
uv sync
```

If imports fail at runtime due to missing system libs (e.g. `ImportError: libGL.so.1`), that confirms a system prerequisite is needed. Add it to UV_SETUP.md.

## What about hybrid projects?

If the project genuinely needs both conda (for system stuff) and uv (for Python deps), that's a valid pattern but it defeats the goal of "one `uv sync` reproduces everything." Be explicit in UV_SETUP.md if you can't fully migrate — say "this project still requires conda for X, Y, Z; uv handles the Python layer."

Don't pretend a hybrid setup is a pure-uv setup.

## Don't

- Don't blindly map every conda dep to `uv add` — many of them aren't on PyPI and you'll get cryptic resolver failures.
- Don't preserve conda channel URLs in `pyproject.toml`. uv indexes are PyPI-format only.
- Don't try to recreate conda's binary distribution model with uv — they're different tools. The escape valve is **system prerequisites in UV_SETUP.md**.
