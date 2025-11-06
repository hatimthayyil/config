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
    firefox.enable = true;
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
              urls = [{
                template = "https://kagi.com/search";
                params = [ { name = "q"; value = "{searchTerms}"; } ];
              }];
              iconUpdateURL = "https://assets.kagi.com/v1/kagi_assets/logos/yellow_3.svg";
              updateInterval = 24 * 60 * 60 * 1000; # Daily
              definedAliases = [ "@kagi" ];
            };
          };
          default = "Kagi";
          privateDefault = "DuckDuckGo";
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
        commandLineArgs =
          [
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
    pkgs.librewolf
    pkgs.nyxt
    inputs.zen-browser.packages."x86_64-linux".default
    pkgs.tangram
    #vivaldi
  ];
}
