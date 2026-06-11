{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.cuda =
    { config, pkgs, ... }:
    let
      cuda = pkgs.cudaPackages_12_6;
      toolkit = cuda.cudatoolkit;
    in
    {
      # PyTorch wheels and other prebuilt CUDA binaries dlopen the NVIDIA
      # userspace driver (libcuda.so) from the running driver; the wheel bundles
      # its own CUDA 12.6 runtime, so only the driver is needed from the system.
      # Exposing it through nix-ld lets uv-managed (FHS) Python resolve it in any
      # shell, including inside devenv. Generic libs (libstdc++, zlib) come from
      # dev-software's nix-ld set, which merges with this one.
      programs.nix-ld.libraries = [
        config.hardware.nvidia.package # libcuda.so, matched to the pinned driver
      ];

      environment.sessionVariables = {
        # The GPU is Pascal (sm_61). CUDA 13 and cu128+ torch wheels dropped
        # Pascal, so pin to the 12.6 line, which still ships sm_61 kernels. uv's
        # `auto` backend picks the newest CUDA and is wrong for this card.
        UV_TORCH_BACKEND = "cu126"; # `uv pip install torch` gets the Pascal build
        CUDA_PATH = "${toolkit}";
        CUDAARCHS = "61"; # default target for CMake CUDA builds
        TORCH_CUDA_ARCH_LIST = "6.1"; # default target for torch extension builds

        # Make a bare `nvcc` usable from any shell: a compatible host compiler
        # (gcc 13 — the toolkit predates the default gcc), the toolkit's headers
        # and libs, and a runpath so compiled binaries find libcuda (driver) and
        # libcudart without LD_LIBRARY_PATH. Additive only; a project passing its
        # own -ccbin wins (last value), so this never breaks a build.
        NVCC_PREPEND_FLAGS = builtins.concatStringsSep " " [
          "-ccbin ${cuda.backendStdenv.cc}/bin"
          "-I${toolkit}/include"
          "-L${toolkit}/lib"
          "-Xlinker -rpath -Xlinker /run/opengl-driver/lib"
          "-Xlinker -rpath -Xlinker ${toolkit}/lib"
        ];
      };

      # HM: CUDA 12.6 toolkit (nvcc) always on PATH.
      home-manager.users.${owner.username} = {
        home.packages = [
          toolkit
        ];
      };
    };
}
