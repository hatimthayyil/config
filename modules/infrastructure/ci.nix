{
  lib,
  config,
  inputs,
  ...
}:
let
  input = lib.types.enum (builtins.attrNames inputs);
in
{
  options.ci.updates = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          inputs = lib.mkOption {
            type = lib.types.listOf input;
            default = [ ];
            description = "Inputs to update; empty updates every input and pinned package.";
          };
          trigger = lib.mkOption {
            type = input;
            description = "Input whose locked revision must move for the update to build and commit.";
          };
        };
      }
    );
  };

  config = {
    ci.updates = {
      all.trigger = "nixpkgs";
      fast = {
        inputs = [ "llm-agents" ];
        trigger = "llm-agents";
      };
    };

    flake.ci = {
      inherit (config.ci) updates;
    };
  };
}
