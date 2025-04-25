{
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.maxima # symbolic
    pkgs.octave
    pkgs.coq # theorem prover
    pkgs.lean4 # theorem prover
  ];
}
