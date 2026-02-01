{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
  };
  services.swapspace = {
    enable = true;
    package = pkgs.swapspace; # default
    extraArgs = [ ];
    installWrapper = true; # default
    settings = {
      swappath = "/var/lib/swapspace"; # default
      lower_freelimit = 20; # default
      upper_freelimit = 60; # default
      freetarget = 30; # default
      min_swapsize = "4m"; # default
      max_swapsize = "2t"; # default
      cooldown = 600; # default
      buffer_elasticity = 30; # default
      cache_elasticity = 80; # default
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
}
