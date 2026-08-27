# zed-preview.nix

## Why the upstream binary and not a source build

nixpkgs ships only the stable channel: `zed-editor` is a `buildRustPackage` with
`channel = "stable"`, and it trails preview by two minor versions. Building
preview from source would mean a full Rust compile per release, on a channel that
ships weekly. The official tarball is the only practical source, so this package
is an unpack plus `autoPatchelfHook`.

## Why the vendored lib/ is discarded

The tarball carries its own `libxcb`, `libxkbcommon`, `libxkbcommon-x11`,
`libX11-xcb`, `libXau`, `libXdmcp`, `libbsd` and `libstdc++` in `lib/`, and the
binaries are built with RPATH `$ORIGIN/../lib`. Installing them would freeze
copies of libraries nixpkgs already maintains, hold them outside security
updates, and duplicate the closure. `installPhase` copies only `bin`, `libexec`
and `share`, so every `DT_NEEDED` resolves against nixpkgs instead.

Keeping them also collides. `buildEnv` merges each package's `lib/` into the
home-manager profile, where a vendored `libxcb-xkb.so.1` conflicts with the one
from `pkgs.libxcb` and fails the profile build.

## Why buildInputs and runtimeDependencies are separate

`autoPatchelfHook` resolves `DT_NEEDED` and fails the build when it cannot, so
everything in `buildInputs` is verified at build time.

Libraries reached through `dlopen` are invisible to it. `libvulkan.so.1`,
`libwayland-client.so.0` and `libEGL.so.1` appear in no `DT_NEEDED` entry, so
they are listed in `runtimeDependencies`, which appends them to RUNPATH. Moving
one of those into `buildInputs` silently drops it from RUNPATH: the build still
succeeds and GPU or Wayland initialisation fails at runtime instead.

Mesa and the NVIDIA driver libraries are deliberately absent. They are supplied
by `/run/opengl-driver` at runtime and carry their own RPATHs.

## The desktop-file substitution order is load-bearing

`TryExec=zed` contains the substring `Exec=zed`. The two `--replace-fail`
arguments must stay in the order written; reversing them rewrites TryExec into
`Try/nix/store/.../bin/zed` and the entry stops resolving. `--replace-fail`
rather than `--replace` is deliberate, so a change to the shipped `.desktop`
breaks the build instead of silently producing a launcher pointing nowhere.

## meta.mainProgram is required, not decoration

home-manager's `programs.zed-editor` wraps
`$out/bin/${cfg.package.meta.mainProgram}` and derives `EDITOR` and `VISUAL`
from the same value. Remove it and the module wraps a path that does not exist.

## Why the updater is disabled with --set

On 2026-08-27 Zed's own updater replaced the binary in place, adding a
`libgio-2.0.so.0` dependency the previous FHS wrapper did not provide. The editor
then died at exit 127 before it could write a log line, and the CLI that forked
it reported nothing. `ZED_UPDATE_EXPLANATION` disables the updater. It is `--set`
rather than `--set-default` so a stray value in the environment cannot re-enable
it.

## The version is not covered by `nix flake update`

Version and hash are pinned in this file, not in `flake.lock`, so the daily
update workflow cannot reach them through `nix flake update`.
`passthru.updateScript` carries the package-specific knowledge: `--flake`,
because this is a flake and not a nixpkgs checkout, and `^v(.*)-pre$`, because
preview tags are never the release GitHub marks latest.

Running it is not this file's business. `packages.update-packages`
(`modules/infrastructure/update-packages.nix`) enumerates every package in
`pkgs/overlay.nix` that declares an `updateScript` and invokes each with its
attribute name, so nothing outside this file names `zed-preview`. Adding another
pinned package to the overlay enrols it with no change to the workflow or the
justfile.

The package is additionally exposed as `packages.zed-preview` from
`modules/editors.nix` so that `nix-update --flake` can resolve the attribute it
is asked to update.
