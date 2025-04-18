{
  ...
}: {
  # TODO Setup a backup routine. NixOS has services for the restic backup tool.
  programs.borgmatic = {
    enable = true;
  };
  #services.borgmatic.enable = true;
}
