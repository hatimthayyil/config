{ lib, ... }:
{
  options.flake.meta = lib.mkOption {
    type = lib.types.anything;
  };

  options.owner = {
    username = lib.mkOption {
      type = lib.types.singleLineStr;
      readOnly = true;
    };
    fullName = lib.mkOption {
      type = lib.types.singleLineStr;
      readOnly = true;
    };
  };

  config = {
    owner = {
      username = "hatim";
      fullName = "Hatim Thayyil";
    };
    flake.meta.owner = {
      username = "hatim";
      fullName = "Hatim Thayyil";
    };
  };
}
