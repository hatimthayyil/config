{
  pkgs,
  ...
}: {
  home.packages = [
    # GPU
    pkgs.glxinfo # glxinfo, OpenGL (MESA)
    pkgs.vulkan-tools # vulkaninfo : OpenGL alt (MESA)
    pkgs.libva-utils # vainfo : Video Acceleration
    pkgs.clinfo # clinfo : OpenCL (CUDA alt)
    pkgs.lact # GPU config tool

    # ML
    pkgs.lmstudio
    pkgs.llama-cpp
    pkgs.jan
  ];
}
