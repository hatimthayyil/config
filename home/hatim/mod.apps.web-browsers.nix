{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
#let
# see https://github.com/NixOS/nixpkgs/pull/292148
# vivaldi =
#   (pkgs.vivaldi.overrideAttrs (oldAttrs: {
#     buildPhase =
#       builtins.replaceStrings
#         [ "for f in libGLESv2.so libqt5_shim.so ; do" ]
#         [ "for f in libGLESv2.so libqt5_shim.so libqt6_shim.so ; do" ]
#         oldAttrs.buildPhase;
#   })).override
#     {
#       qt5 = pkgs.qt6;
#       commandLineArgs = [ "--ozone-platform=wayland" ];
#       # FIXME The following are non-free, remove if not needed
#       proprietaryCodecs = true;
#       enableWidevine = true;
#     };
#in
{
  programs = {
    firefox = {
      enable = true;

      # Policy settings
      # policies = {
      #   # Basic settings
      #   HardwareAcceleration = true;
      #   #DefaultDownloadDirectory = "\${home}/Downloads";

      #   # Disable annoying stuff
      #   AppAutoUpdate = false;
      #   DisableFirefoxStudies = true;
      #   DisablePocket = true;
      #   DisableTelemetry = true;
      #   DisplayBookmarksToolbar = "always";
      #   OfferToSaveLogins = false;

      #   # Hard-disable Firefox's DoH
      #   DNSOverHTTPS = {
      #     Enabled = false;
      #     Locked = true;
      #   };

      #   # Search configuration
      #   SearchSuggestEnabled = true;
      #   FirefoxSuggest = {
      #     SponsoredSuggestions = false;
      #     ImproveSuggest = false;
      #   };
      # };

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
            #zotero-connector # not available on Addons - TODO should package it myself
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

          engines = {
            # "Kagi" = {
            #   urls = [
            #     {
            #       template = "https://kagi.com/search";
            #       params = [
            #         {
            #           name = "q";
            #           value = "{searchTerms}";
            #         }
            #       ];
            #     }
            #   ];
            #   icon = "https://assets.kagi.com/v1/kagi_assets/logos/yellow_3.svg";
            #   updateInterval = 24 * 60 * 60 * 1000; # Daily
            #   definedAliases = [ "@kagi" ];
            # };

            # # Nix package search
            # "Nix Packages" = {
            #   urls = [{
            #       template = "https://search.nixos.org/packages";
            #       params = [
            #         { name = "type"; value = "packages"; }
            #         { name = "query"; value = "{searchTerms}"; }
            #       ];
            #   }];
            #   icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            #   definedAliases = ["@np"];
            # };

            # # Nix wiki search
            # "NixOS Wiki" = {
            #   urls = [{ template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; }];
            #   icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            #   definedAliases = ["@nw"];
            # };
          };
        };

        settings = {
          "browser.startup.homepage" = "https://kagi.com";
          # without this the addons need to be enabled manually after first install
          "extensions.autoDisableScopes" = 0;
          "gfx.webrender.all" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.donottrackheader.value" = 1;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          # disable libadwaita theming for Firefox
          "widget.gtk.libadwaita-colors.enabled" = false;
          # selected from https://github.com/arkenfox/user.js
        };

        # https://mrotherguy.github.io/firefox-csshacks/
        userChrome = ''
          @import url(${pkgs.firefox-csshacks}/chrome/urlbar_centered_text.css);
          @import url(${pkgs.firefox-csshacks}/chrome/hide_tabs_toolbar_v2.css);
        '';
      };
    };

    floorp = {
      enable = true;

      profiles.default = {
        # optional: without this the addons need to be enabled manually after first install
        settings = {
          "extensions.autoDisableScopes" = 0;
        };

        # Add-ons
        # Search for available addons by running: 'nix run github:osipog/nix-firefox-addons#search-addon ublock-origin'
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
            #zotero-connector # not available on Addons - TODO should package it myself
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
              updateInterval = 24 * 60 * 60 * 1000; # Daily
              definedAliases = [ "@kagi" ];
            };
          };
          default = "Kagi";
          privateDefault = "ddg";
          force = true;
        };
      };
    };

    # See https://gitlab.com/engmark/root/-/merge_requests/892/diffs
    # TODO Set up default search engine
    chromium =
      let
        package = pkgs.ungoogled-chromium;
        installExtensions = false;
      in
      {
        inherit package;
        commandLineArgs = [
          # Required for chromium-web-store
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
          { id = "ikclbgejgcbdlhjmckecmdljlpbhmbmf"; } # https everywhere
          { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
          { id = "ikdjjgioalkbdihbhcfffjnanhnilipa"; } # English syntax highlighter
        ];
      };
  };

  home.packages = [
    # Browsers
    #pkgs.librewolf
    pkgs.nyxt
    inputs.zen-browser.packages."x86_64-linux".default
    pkgs.tangram
    #vivaldi
  ];
}
