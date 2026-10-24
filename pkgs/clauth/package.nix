{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clauth";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "uwuclxdy";
    repo = "clauth";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hbiBVUMZ0RO1+JqohtlwJ+NpBOl/jOZpkVDdEHShuNs=";
  };

  cargoHash = "sha256-A897WAfqn5YP09b1IKo8wV4avzzjNm6wUJ2tL6hHLE0=";

  doCheck = false;

  meta = {
    description = "Claude Code multi-account manager and usage monitor";
    homepage = "https://github.com/uwuclxdy/clauth";
    license = lib.licenses.mit;
    mainProgram = "clauth";
  };
})
