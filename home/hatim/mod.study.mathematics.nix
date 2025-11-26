{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.maxima # symbolic
    pkgs.octave
    pkgs.coq # theorem prover
    pkgs.lean4 # theorem prover
    pkgs.stable.sage # computer algebra system
    # pkgs.wolfram-notebook # Installed imperatively due to license
    # pkgs.wolfram-engine # Installed imperatively due to license
  ];
}
