{
  pkgs,
  ...
}:
{
  home.packages = [
    # GPU
    pkgs.glxinfo # glxinfo, OpenGL (MESA)
    pkgs.vulkan-tools # vulkaninfo : OpenGL alt (MESA)
    pkgs.libva-utils # vainfo : Video Acceleration
    pkgs.clinfo # clinfo : OpenCL (CUDA alt)
    pkgs.lact # GPU config tool

    # Language Machine
    pkgs.lmstudio
    pkgs.llama-cpp
    pkgs.master.gpt4all
    #pkgs.master.gpt4all-cuda # build is broken
    pkgs.local-ai
    pkgs.jan
    pkgs.aider-chat
    #pkgs.aider-chat-full # broken on unstable
    pkgs.master.claude-code # Coder agent from Anthropic
    pkgs.master.codex # Coder agent from OpenAI
    pkgs.llm # LLM cli from Simon Willison
  ];
}
