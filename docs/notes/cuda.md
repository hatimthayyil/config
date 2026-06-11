# CUDA / PyTorch on eagle

Config: `modules/cuda.nix` | GPU: Quadro P2000 (Pascal, **sm_61**, 4 GB)

The GPU is on the **Pascal** deprecation path. CUDA 13 and the `cu128`+ PyTorch
wheels removed Pascal support, so everything here is pinned to the **CUDA 12.6**
line — the last one that still ships `sm_61` kernels. Never use `cu128`/`cu130`
or `--torch-backend=auto` (auto picks the newest CUDA and silently drops this
card; torch then imports fine but crashes with *"no kernel image available for
execution on the device"*).

## What the system provides (set once)

| Piece | How | Why |
|-------|-----|-----|
| `libcuda.so` in any shell | nix-ld exposes the pinned driver | wheels dlopen the driver at runtime |
| Pascal torch build | `UV_TORCH_BACKEND=cu126` | `uv pip install torch` picks the right wheel |
| `nvcc` that just works | `cudaPackages_12_6.cudatoolkit` + `NVCC_PREPEND_FLAGS` | host gcc, headers, libs, runpath all injected |
| `CUDA_PATH`, `CUDAARCHS=61`, `TORCH_CUDA_ARCH_LIST=6.1` | session vars | default build target is this card |

The runtime plumbing is via **nix-ld**, so it survives into `devenv`/`direnv`
shells. The blessed Python is **uv-managed** (its standalone CPython is an FHS
binary that goes through nix-ld); a nixpkgs Python from a devenv would need a
different libcuda-discovery path and is not covered here.

## PyTorch

Imperative (`uv pip`) — fully covered by the global `UV_TORCH_BACKEND`:

```sh
uv venv && source .venv/bin/activate
uv pip install torch          # resolves to the cu126 / sm_61 wheel
python -c "import torch; print(torch.cuda.is_available(), torch.cuda.get_device_name(0))"
```

Project mode (`uv add` / `uv sync`) — `UV_TORCH_BACKEND` does **not** apply here;
pin the index once per `pyproject.toml`:

```toml
[[tool.uv.index]]
name = "pytorch-cu126"
url = "https://download.pytorch.org/whl/cu126"
explicit = true

[tool.uv.sources]
torch = { index = "pytorch-cu126" }
```

## CUDA C/C++ (nvcc)

`nvcc` works from any shell — a compatible host compiler (gcc 13), the toolkit's
headers/libs, and a runpath to libcuda/libcudart are injected via
`NVCC_PREPEND_FLAGS`, so a freshly compiled binary runs with no `LD_LIBRARY_PATH`:

```sh
nvcc kernel.cu -o kernel && ./kernel
```

Bare `nvcc` defaults to portable PTX (JIT-compiled to sm_61 at runtime). Add
`-arch=sm_61` for native SASS (no JIT). CMake projects pick up `CUDA_PATH` and
`CUDAARCHS=61` automatically. A project that sets its own `-ccbin` overrides the
injected one (nvcc uses the last value).

## Practical limits

- **4 GB VRAM** is the binding constraint — small models / inference / dev, not
  large training.
- **No Tensor cores** (Pascal) → no hardware BF16/FP16 acceleration, and
  **no FlashAttention** (needs sm_75/sm_80+). Effectively an FP32 card.

## Verify

```sh
nvidia-smi --query-gpu=name,compute_cap,driver_version --format=csv
python -c "import torch; assert torch.cuda.is_available(); print(torch.zeros(3, device='cuda') + 1)"
```
