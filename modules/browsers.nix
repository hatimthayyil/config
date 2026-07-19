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
    { pkgs, ... }:
    {
      # NixOS: browser policies
      programs.firefox.enable = true;

      # ExtensionInstallForcelist (set via `extensions = [...]`) is a no-op on
      # ungoogled-chromium: the policy fetch goes to clients2.google.com, which
      # u-c's stripped network code can't reach. extraOpts policies *are*
      # honored — keep those.
      programs.chromium = {
        enable = true;
        defaultSearchProviderEnabled = true;
        defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
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
      home-manager.users.${owner.username} = {
        programs = {
          firefox = {
            enable = true;
            configPath = ".mozilla/firefox";

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
                  onetab
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

          # ungoogled-chromium can't reach Google's update server, so neither
          # the ExtensionInstallForcelist policy nor the HM `extensions =
          # [{id;}]` list (which writes External Extensions/<id>.json with
          # external_update_url=clients2.google.com) actually installs
          # anything. Bootstrap is manual: install chromium-web-store once
          # via drag-drop onto chrome://extensions (with developer mode on),
          # then use that extension to install/update everything else.
          #
          # Bootstrap CRX:
          #   https://github.com/NeverDecaf/chromium-web-store/releases/latest
          #
          # Extensions to install via chromium-web-store after bootstrap:
          #   ikclbgejgcbdlhjmckecmdljlpbhmbmf  HTTPS Everywhere
          #   cjpalhdlnbpafiamejdnhcphjbkeiagm  uBlock Origin
          #   ikdjjgioalkbdihbhcfffjnanhnilipa  English syntax highlighter
          #   cceholfnmlnolphmanhbnmnjikblgnnm  Treedent
          #   nngceckbapebfimnlniiiahkandclblb  Bitwarden
          #   ekhagklcjbdpajgpjgmbionohlpdbjgc  Zotero
          #   mnjggcdmjocbbbhaepdhchncahnbgone  SponsorBlock
          #   iplffkdpngmdjhlpjmppncnlhomiipha  Unpaywall
          #   ldpochfccmkkmhdbclfhpagapcfdljkj  Decentraleyes
          #   dffbjiomnajbmlhjelpipfldgkijdemn  URL Cleaner
          #
          # Local custom extension dev: chrome://extensions → Developer mode
          # → Load unpacked → pick the source folder.
          chromium = {
            enable = true;
            package = pkgs.ungoogled-chromium;
            commandLineArgs = [
              "--extension-mime-request-handling=always-prompt-for-install"
            ];
          };
        };
      };
    };
}
