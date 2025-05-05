{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.enchant;
in {
  options.programs.enchant = {
    enable = mkEnableOption "Enchant spell checker";

    package = mkOption {
      type = types.package;
      default = pkgs.enchant;
      description = "Enchant package to use.";
    };

    ordering = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = {};
      example = {
        "*" = [ "aspell" "hunspell" ];
        "en" = [ "hunspell" ];
        "en-computers" = [ "aspell" ];
      };
      description = "Language-to-backend priority map for Enchant.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.enchant ];

    xdg.configFile."enchant/enchant.ordering".source =
      builtins.toFile "enchant.ordering" (let
        header = ''
          ###------------------------------
          ##    Spell Check Priority
          #--------------------------------
        '';
        body = builtins.concatStringsSep "\n" (
          builtins.attrValues (builtins.mapAttrs (lang: backends:
            "${lang}:${builtins.concatStringsSep "," backends}") cfg.ordering)
        );
      in header + "\n" + body + "\n");
  };
}
