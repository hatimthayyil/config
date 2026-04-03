{
  config,
  ...
}:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.multimedia =
    { pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        home.packages = [
          pkgs.imagemagick
          pkgs.poppler
          pkgs.mediainfo
          pkgs.yt-dlp
          pkgs.ffmpeg
        ];
      };
    };
}
