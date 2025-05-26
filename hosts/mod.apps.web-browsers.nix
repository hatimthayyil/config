{ ... }:
{
  # TODO Move default search engine to Kagi

  # Firefox.
  programs.firefox.enable = true;

  # Google chromium.
  # This option does not install a browser. It sets up policies
  # for chromium based browsers (Chromium, Brave, Google Chrome).
  # see https://github.com/wimpysworld/nix-config/blob/main/nixos/_mixins/desktop/apps/web-browsers/martin.nix
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
    #
    extraOpts = {
      BrowserSignin = 0;
      SyncDisabled = true;
      PasswordManagerEnabled = false;
      SpellcheckEnabled = true;
      SpellcheckLanguage = [
        "en-GB"
      ];
      CloudReportingEnabled = false;
      CloudProfileReportingEnabled = false;
    };
  };

  services.flatpak.packages = [
    "com.microsoft.Edge"
  ];
}
