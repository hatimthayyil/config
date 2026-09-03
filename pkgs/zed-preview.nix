{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  nix-update-script,
  alsa-lib,
  glib,
  libglvnd,
  libx11,
  libxcb,
  libxkbcommon,
  vulkan-loader,
  wayland,
  xkeyboard-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zed-preview";
  version = "1.19.0";

  src = fetchurl {
    url = "https://github.com/zed-industries/zed/releases/download/v${finalAttrs.version}-pre/zed-linux-x86_64.tar.gz";
    hash = "sha256-Myi1i2VSIssAzqXkJtNTc2H4jTgSBs5NEDo7FEsDuQY=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    glib
    libx11
    libxcb
    libxkbcommon
    (lib.getLib stdenv.cc.cc)
  ];

  runtimeDependencies = [
    libglvnd
    vulkan-loader
    wayland
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a bin libexec share "$out"/
    install -Dm644 licenses.md "$out/share/doc/zed-preview/licenses.md"

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace "$out/share/applications/dev.zed.Zed-Preview.desktop" \
      --replace-fail "TryExec=zed" "TryExec=$out/bin/zed" \
      --replace-fail "Exec=zed" "Exec=$out/bin/zed"

    wrapProgram "$out/bin/zed" \
      --set-default XKB_CONFIG_ROOT "${xkeyboard-config}/share/X11/xkb" \
      --set ZED_UPDATE_EXPLANATION "Zed preview is installed with Nix. Update it through the flake."
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version-regex"
      "^v(.*)-pre$"
    ];
  };

  meta = {
    description = "High-performance, multiplayer code editor, preview channel";
    homepage = "https://zed.dev";
    license = lib.licenses.gpl3Only;
    mainProgram = "zed";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
