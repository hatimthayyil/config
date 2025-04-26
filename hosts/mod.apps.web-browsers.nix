{ ... }: {
  # Firefox.
  programs.firefox.enable = true;

  # Google chromium.
  # This option does not install a browser. It sets up policies
  # for chromium based browsers (Chromium, Brave, Google Chrome).
  programs.chromium = {
    enable = true;
    defaultSearchProviderEnabled = true;
    defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
    # Extensions in the NixOS chromium config expects a list of string.
    # Home-manager has an attr set (?) with ids
    extensions = [
      "ikclbgejgcbdlhjmckecmdljlpbhmbmf" # https everywhere
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "ikdjjgioalkbdihbhcfffjnanhnilipa" # English syntax highlighter
    ];
  };
}
