{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.writing =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        imports = [ ./_enchant-hm-module.nix ];

        programs.enchant = {
          enable = true;

          ordering = {
            "*" = [
              "aspell"
              "hunspell"
              "nuspell"
            ];
            "en" = [ "aspell" ];
          };
        };

        home.packages = with pkgs; [
          languagetool

          (aspellWithDicts (
            dicts: with dicts; [
              en
              en-computers
              en-science
            ]
          ))
          (hunspell.withDicts (d: [
            d.en_GB-large
            d.en_US-large
          ]))
          (nuspell.withDicts (d: [
            d.en_GB-large
            d.en_US-large
          ]))
        ];

        # see https://github.com/minad/jinx/discussions/173
        systemd.user.settings.Manager.DefaultEnvironment = {
          ASPELL_CONF = "dict-dir ${
            pkgs.aspellWithDicts (
              ds: with ds; [
                en
                en-computers
                ar
                ml
              ]
            )
          }/lib/aspell";
        };

        xdg.configFile = {
          "enchant/hunspell/en_US.aff".source = "${pkgs.hunspellDicts.en_US-large}/share/hunspell/en_US.aff";
          "enchant/hunspell/en_US.dic".source = "${pkgs.hunspellDicts.en_US-large}/share/hunspell/en_US.dic";
          "enchant/hunspell/en_GB.aff".source = "${pkgs.hunspellDicts.en_GB-large}/share/hunspell/en_GB.aff";
          "enchant/hunspell/en_GB.dic".source = "${pkgs.hunspellDicts.en_GB-large}/share/hunspell/en_GB.dic";
          "enchant/aspell/en-computers.rws".source =
            "${pkgs.aspellDicts.en-computers}/lib/aspell/en-computers.rws";
          "enchant/aspell/en_US-science.rws".source =
            "${pkgs.aspellDicts.en-science}/lib/aspell/en_US-science.rws";
          "enchant/aspell/en_GB-science.rws".source =
            "${pkgs.aspellDicts.en-science}/lib/aspell/en_GB-science.rws";
        };
      };
    };
}
