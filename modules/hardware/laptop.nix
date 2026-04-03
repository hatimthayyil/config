_: {
  flake.modules.nixos.hardware-laptop =
    { pkgs, ... }:
    {
      hardware.bluetooth.enable = true;

      services.swapspace = {
        enable = true;
        package = pkgs.swapspace;
        extraArgs = [ ];
        installWrapper = true;
        settings = {
          swappath = "/var/lib/swapspace";
          lower_freelimit = 20;
          upper_freelimit = 60;
          freetarget = 30;
          min_swapsize = "4m";
          max_swapsize = "2t";
          cooldown = 600;
          buffer_elasticity = 30;
          cache_elasticity = 80;
        };
      };

      services.earlyoom = {
        enable = true;
        freeMemThreshold = 2;
        freeSwapThreshold = 2;
        extraArgs = [
          "-g"
          "--avoid '^(X|plasma.*|kitty|kwin)$'"
          "--prefer '^(firefox|electron|libreoffice|gimp)$'"
        ];
      };
    };
}
