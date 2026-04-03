{
  config,
  inputs,
  ...
}:
let
  inherit (config) owner;
  inherit (inputs) firefox-csshacks;
in
{
  flake.modules.nixos.browsers =
    { pkgs, lib, ... }:
    {
      # NixOS: browser policies
      programs.firefox.enable = true;

      programs.chromium = {
        enable = true;
        defaultSearchProviderEnabled = true;
        defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
        extensions = [
          "ikclbgejgcbdlhjmckecmdljlpbhmbmf" # https everywhere
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
          "ikdjjgioalkbdihbhcfffjnanhnilipa" # English syntax highlighter
          "cceholfnmlnolphmanhbnmnjikblgnnm" # Treedent
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
          "ekhagklcjbdpajgpjgmbionohlpdbjgc" # Zotero
          "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
          "iplffkdpngmdjhlpjmppncnlhomiipha" # Unpaywall
          "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
          "dffbjiomnajbmlhjelpipfldgkijdemn" # URL Cleaner
        ];
        extraOpts = {
          BrowserSignin = 0;
          SyncDisabled = true;
          PasswordManagerEnabled = false;
          SpellcheckEnabled = true;
          SpellcheckLanguage = [ "en-GB" ];
          CloudReportingEnabled = false;
          CloudProfileReportingEnabled = false;
        };
      };

      services.flatpak.packages = [
        "com.microsoft.Edge"
      ];

      # HM: browser configuration
      home-manager.users.${owner.username} =
        { config, ... }:
        {
          programs = {
            firefox = {
              enable = true;

              profiles.default = {
                isDefault = true;

                extensions = {
                  force = true;
                  packages = with pkgs.firefoxAddons; [
                    ublock-origin
                    clearurls
                    sponsorblock
                    bitwarden-password-manager
                    darkreader
                    decentraleyes
                    sidebery
                    unpaywall
                  ];
                  settings."uBlock0@raymondhill.net".settings = {
                    selectedFilterLists = [
                      "ublock-filters"
                      "ublock-badware"
                      "ublock-privacy"
                      "ublock-unbreak"
                      "ublock-quick-fixes"
                    ];
                  };
                };

                search = {
                  default = "ddg";
                  privateDefault = "ddg";
                  force = true;
                  engines = { };
                };

                settings = {
                  "extensions.autoDisableScopes" = 0;
                  "gfx.webrender.all" = true;
                  "privacy.donottrackheader.enabled" = true;
                  "privacy.donottrackheader.value" = 1;
                  "privacy.trackingprotection.enabled" = true;
                  "privacy.trackingprotection.socialtracking.enabled" = true;
                  "widget.gtk.libadwaita-colors.enabled" = false;
                  "browser.low_commit_space_threshold_mb" = 16384;
                  "browser.tabs.unloadOnLowMemory" = true;
                  "browser.tabs.discarding.enabled" = true;
                  "browser.tabs.discarding.priority" = 2;
                  "browser.tabs.min_inactive_duration_before_unload" = 600000;

                  fastfox.enable = true;
                  smoothfox.enable = true;
                  peskyfox = {
                    enable = true;
                    mozilla-ui.enable = false;
                  };
                  securefox = {
                    enable = true;
                    tracking-protection."browser.download.start_downloads_in_tmp_dir".value = false;
                  };
                };

                userChrome = ''
                  @import url(${firefox-csshacks}/chrome/urlbar_centered_text.css);
                  @import url(${firefox-csshacks}/chrome/hide_tabs_toolbar_v2.css);
                '';
              };
            };

            floorp = {
              enable = false;

              profiles.default = {
                settings = {
                  "extensions.autoDisableScopes" = 0;
                };

                extensions = {
                  force = true;
                  packages = with pkgs.firefoxAddons; [
                    ublock-origin
                    clearurls
                    sponsorblock
                    bitwarden-password-manager
                    darkreader
                    decentraleyes
                    sidebery
                  ];
                  settings."uBlock0@raymondhill.net".settings = {
                    selectedFilterLists = [
                      "ublock-filters"
                      "ublock-badware"
                      "ublock-privacy"
                      "ublock-unbreak"
                      "ublock-quick-fixes"
                    ];
                  };
                };

                search = {
                  engines = {
                    "Kagi" = {
                      urls = [
                        {
                          template = "https://kagi.com/search";
                          params = [
                            {
                              name = "q";
                              value = "{searchTerms}";
                            }
                          ];
                        }
                      ];
                      icon = "https://assets.kagi.com/v1/kagi_assets/logos/yellow_3.svg";
                      updateInterval = 24 * 60 * 60 * 1000;
                      definedAliases = [ "@kagi" ];
                    };
                  };
                  default = "Kagi";
                  privateDefault = "ddg";
                  force = true;
                };
              };
            };

            chromium =
              let
                package = pkgs.ungoogled-chromium;
                installExtensions = false;
              in
              {
                inherit package;
                commandLineArgs = [
                  "--extension-mime-request-handling=always-prompt-for-install"
                ]
                ++ lib.optionals installExtensions (
                  [
                    "https://github.com/NeverDecaf/chromium-web-store/releases/latest/download/Chromium.Web.Store.crx"
                  ]
                  ++ map (
                    extension:
                    "https://clients2.google.com/service/update2/crx?response=redirect\\&acceptformat=crx2,crx3\\&prodversion=${package.version}\\&x=id%3D${extension.id}%26uc"
                  ) config.programs.chromium.extensions
                );

                enable = true;
                extensions = [
                  { id = "ikclbgejgcbdlhjmckecmdljlpbhmbmf"; }
                  { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
                  { id = "ikdjjgioalkbdihbhcfffjnanhnilipa"; }
                  { id = "cceholfnmlnolphmanhbnmnjikblgnnm"; }
                  { id = "nngceckbapebfimnlniiiahkandclblb"; }
                  { id = "ekhagklcjbdpajgpjgmbionohlpdbjgc"; }
                  { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; }
                  { id = "iplffkdpngmdjhlpjmppncnlhomiipha"; }
                  { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; }
                  { id = "dffbjiomnajbmlhjelpipfldgkijdemn"; }
                ];
              };
          };
        };
    };
}
