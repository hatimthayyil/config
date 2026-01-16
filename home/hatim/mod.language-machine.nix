{
  pkgs,
  ...
}:
{
  home.packages = [
    # GPU
    pkgs.mesa-demos # glxinfo, OpenGL (MESA)
    pkgs.vulkan-tools # vulkaninfo : OpenGL alt (MESA)
    pkgs.libva-utils # vainfo : Video Acceleration
    pkgs.clinfo # clinfo : OpenCL (CUDA alt)
    pkgs.lact # GPU config tool

    # Language Machine
    #LEAN pkgs.stable.lmstudio
    #LEAN pkgs.stable.llama-cpp
    #LEAN pkgs.stable.gpt4all
    #pkgs.master.gpt4all-cuda # FIXME build is broken
    # pkgs.stable.local-ai
    #LEAN pkgs.jan
    pkgs.aider-chat
    #pkgs.aider-chat-full # FIXME broken on unstable
    pkgs.stable.claude-code # Coder agent from Anthropic
    pkgs.stable.codex # Coder agent from OpenAI
    pkgs.llm # LLM cli from Simon Willison
  ];
}
