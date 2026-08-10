# vscode.nix

## Why extensions are a flake package, not home-manager config

Anything reachable from `system.build.toplevel` can fail a `nixos-rebuild`.
Extensions are fetched from the marketplace as FODs, so a pulled release or a
moved artifact used to take the whole system build down with it — an editor
plugin blocking a system rebuild.

Declaring them does not require that reachability. `packages.vscode-extensions`
is built on demand by `just vscode-sync`, so the list stays in git, pinned and
reproducible through the nix4vscode input, while the switch path never touches
it. Both CI workflows build `nixosConfigurations.eagle` and neither runs
`nix flake check`, so the output is outside their reach too.

The trade is deliberate: a rebuild no longer proves the editor works. Extension
breakage moves out of the build, where it blocks, and into a sync step, where it
is recoverable.

## Why the version is not a literal

`forVscodeVersion` takes the version to resolve extension compatibility against.
It was pinned to `"1.108.1"` while `package` tracked `pkgs.unstable.vscode`,
which had reached 1.130.0 — 22 minor versions of drift. `matchesVscodeVersion`
silently drops releases whose `engines.vscode` floor exceeds the given version
and picks the newest survivor, so nothing warned. Measured 2026-08-10: 48/48
extensions still resolved, but github.copilot-chat was frozen at 0.36.2 against
0.48.1, because it raises its floor with nearly every VSCode release.

It is a ratchet, not a one-off: each extension that lifts its floor past the
literal freezes at its last compatible release. Binding both to `editor.version`
makes the drift unrepresentable.

## Why a second nixpkgs instance

`perSystem` gets bare `inputs.nixpkgs.legacyPackages`, which has no
`nix4vscode` — the overlay is applied inside the NixOS config
(`modules/base.nix:50`). The instance here re-applies
`config.flake.overlays.default` so extensions resolve against the same package
set as the editor. Referencing `config.flake.overlays` rather than
`inputs.self.overlays` keeps it inside flake-parts and avoids the `self`
indirection.

## Why no FHS wrapper

nix4vscode sets `dontPatchELF = true` (`nix/vscode-utils/default.nix:40`) and
ships two decorators, neither patching ELF. Extensions carrying prebuilt
binaries — rust-analyzer, cpptools, vscode-lldb, dart-code — run because
`programs.nix-ld.enable` is true and supplies the loader. An FHS variant would
address a problem this host does not have.

## Why the sync reconciles instead of appending

`code --install-extension` over a list only ever adds. Deleting the store
symlinks first and relinking makes removal from the list take effect, which is
what separates a manifest from a wishlist. Real directories are left alone, so
extensions installed through the VSCode UI survive — `mutableExtensionsDir`
stays at its default of true. Nix paths are named `publisher.name` while VSCode
appends a version, so the two namespaces do not collide.

Deleting `extensions.json` and running `--list-extensions` is home-manager's own
trick for forcing VSCode to regenerate its index
(`modules/programs/vscode/mkVscodeModule.nix:483`).

## Why the sync builds through an out-link

Symlinks under `$HOME` are not GC roots — Nix only scans
`/nix/var/nix/gcroots`, where indirect roots are registered by out-links. Built
with `--no-link`, the extension closure is unrooted, so `just clean` collects it
and leaves dangling symlinks in `~/.vscode/extensions`: extensions disappear at
the next VSCode restart with nothing to point at. The out-link at
`$XDG_STATE_HOME/nix/vscode-extensions` roots the closure; the extension
symlinks still resolve to real store paths so the `-lname '/nix/store/*'`
cleanup keeps working.

## Ordering

The build runs before the delete. Eval errors (unknown extension id, no release
matching the editor version — `forVscodeVersionRaw.nix` throws and names them)
and fetch failures both abort while the existing extensions are still in place.
The window where the directory is empty is between the delete and the relink;
re-running closes it.

`buildEnv` is all-or-nothing, so one unfetchable extension blocks every update
until it is commented out of the list.
