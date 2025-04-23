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
    pkgs.aider-chat
    #pkgs.aider-chat-full # broken on unstable
    pkgs.master.claude-code
    pkgs.master.codex
    pkgs.llm # LLM cli from Simon Willison
  ];
}
