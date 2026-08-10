# VSCode extensions leave the system closure

## Problem

Two unrelated faults, one of them load-bearing.

**Drift.** `modules/editors.nix:266` resolved extensions against a literal:

```nix
package   = pkgs.unstable.vscode;                              # 1.130.0
extensions = pkgs.nix4vscode.forVscodeVersion "1.108.1" [ … ];  # 22 minor behind
```

`forVscodeVersionRaw.nix` defaults `version ? pkgs.vscode.version`; passing
`forVscodeVersion` overrides it with a frozen string. `matchesVscodeVersion`
then drops every release whose `engines.vscode` floor exceeds 1.108.1 and picks
the newest survivor — no warning, no error.

**Breakage.** Extensions were reachable from `system.build.toplevel`, so a
marketplace FOD that 404s failed `nixos-rebuild`. An editor plugin could block a
system rebuild. `821d5d9 home: vscode extn temp remove` is that happening.

## Measured

All 48 extensions resolved at both versions:

| | 1.108.1 | 1.130.0 |
|---|---|---|
| resolved | 48 | 48 |
| github.copilot-chat | **0.36.2** | **0.48.1** |
| Selemondev.vscode-shadcn-svelte | 0.6.9 | 0.6.10 |

Nothing is dropped by raising the version — checked deliberately, because `~M.m.p`
and bare `=` selectors are upper-bounded and could have lost an extension.

Only two move because most publishers declare loose `^1.x` floors that 1.108.1
already satisfies. Copilot Chat is the exception: it raises its floor with nearly
every release. It is a ratchet, not a one-off — each extension that lifts its
floor past the literal freezes at its last compatible release.

## The drift fix does not address the breakage

Distinct causes. Drift produced silently stale versions; breakage comes from 48
marketplace FODs re-pinned on every `nix4vscode` bump, nightly, any one of which
can 404 when a publisher unpublishes a release.

Binding to `editor.version` arguably *increases* churn: frozen at 1.108.1,
extensions past their floor were stuck on old releases whose hashes had stopped
moving. Tracking the editor means following the newest compatible release, so
more hashes change per bump.

Where breakage lands depends on how the lock advances. `update-flake.yml` builds
before `git-auto-commit-action`, and a failed step fails the job, so a broken
extension is never committed. `just upgrade` is
`just update && just build && just switch` and `just update` is a local
`nix flake update`, which bypasses that gate entirely.

| | breaks a rebuild? | cost when an extension breaks |
|---|---|---|
| in closure, local `just upgrade` | yes, immediately | blocked until commented out |
| in closure, CI-verified locks only | no | lock silently stops advancing — no nixpkgs or security updates |
| out of closure | no | extension updates stop; system unaffected |

The middle row is the trap: one plugin quietly freezing all system updates, with
nothing to signal it.

## Change

- `modules/vscode.nix` (new) holds the extension list, a
  `perSystem.packages.vscode-extensions` `buildEnv`, and the home-manager
  `programs.vscode` config with **no** `extensions` attribute. Resolution binds
  to `editor.version`, so the two cannot diverge again.
- `modules/editors.nix` loses the vscode block. `lib` became an unused lambda
  pattern once `mkForce` went with it — deadnix caught this.
- `modules/hosts/eagle.nix` adds the `vscode` group.
- `justfile` gains `vscode-sync`.

`perSystem` gets bare `inputs.nixpkgs.legacyPackages`, which has no
`nix4vscode` — the overlay is applied inside the NixOS config
(`modules/base.nix:50`). The package re-applies `config.flake.overlays.default`
so extensions resolve against the same package set as the editor.

## Verified

- Package evaluates; copilot-chat 0.36.2 → 0.48.1.
- All 48 marketplace extensions gone from eagle's build closure.
- One `vscode-extension-*` remains: nixpkgs' eslint, reached by
  `toplevel → etc → home-manager → nvf → vscode-langservers-extracted`. It is
  neovim's LSP, not the VSCode list, and is substitutable from cache.nixos.org.
- `nix fmt`, deadnix, statix, shellcheck clean.

## Trap: an out-link is the GC root, not the symlinks

The sync first used `nix build --no-link`. Symlinks under `$HOME` are not GC
roots — Nix scans `/nix/var/nix/gcroots`, where indirect roots come from
out-links. `just clean` would have collected the closure and left dangling
symlinks: extensions vanishing at the next VSCode restart with no visible cause.
Fixed with `--out-link "$XDG_STATE_HOME/nix/vscode-extensions"`.

## Rejected

- **FHS VSCode.** nix4vscode sets `dontPatchELF = true`
  (`nix/vscode-utils/default.nix:40`) and ships two decorators, neither patching
  ELF. Prebuilt binaries — rust-analyzer, cpptools, vscode-lldb, dart-code — run
  because `programs.nix-ld.enable` is true and supplies the loader.
- **Imperative extensions** via `code --install-extension` over a manifest.
  Loses pinning entirely; nix-ld already covers the native-binary case that made
  FHS look necessary.
- **Chaining sync onto `switch`** (`-just vscode-sync`, error-tolerant). Would
  restore automatic updates without restoring the coupling, since the system is
  already switched by then. Left manual by choice.

## Open items

- `buildEnv` is all-or-nothing: one unfetchable extension blocks every update
  until commented out. Building each extension separately and linking what
  succeeds would confine it, at the cost of real complexity. Deferred until it
  bites.
- Cadence is manual. Extension versions change when `flake.lock` moves
  `nix4vscode` — nightly — but nothing applies them until `just vscode-sync`.
- A rebuild no longer proves the editor works. That is the trade: breakage moved
  out of the build, where it blocks, into a sync step, where it is recoverable.
- Non-default VSCode profiles are not synced; only `~/.vscode/extensions`.
