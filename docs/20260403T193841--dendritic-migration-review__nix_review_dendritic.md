# Dendritic Migration Review

Phase 2 migration audit — comparing every old `mod.*.nix` source against
its new `modules/*.nix` dendritic module.

Branch: `refactor/dendritic`
Date: 2026-04-03
Build status: `nix build .#nixosConfigurations.eagle.config.system.build.toplevel` passes


## Scope

29 module pairs audited covering:
- 6 cross-cutting (NixOS + HM)
- 18 HM-only
- 4 NixOS-only
- 2 entry points (`configuration.nix`, `host.eagle.hatim.nix`)


## Summary

| Category | Count |
|----------|-------|
| Modules fully migrated | 26 / 29 |
| Intentional architectural changes | 3 |
| Pre-existing duplications carried over | 4 |
| Missing config (functional impact) | 0 |
| Missing config (no-ops / disabled) | 1 |
| Bug fixes applied during migration | 1 |
| Unmigrated old files (commented-out import) | 1 |


## Gaps

### G1. `system.autoUpgrade` block not migrated

**Old:** `hosts/eagle/configuration.nix` lines 88-96

```nix
system.autoUpgrade = {
  enable = false;
  flake = "/home/hatim/code/config";
  flags = [ "-L" ];
  dates = "02:00";
  randomizedDelaySec = "45min";
};
```

**New:** Not present in any module.

**Impact:** None — `enable = false` makes this a no-op. The replacement
`system.autoUpgradeFlake` IS migrated to `base.nix`. If the standard
`system.autoUpgrade` is ever needed again, it would need to be re-added.

**Action:** Optional. Add to `base.nix` if you want the disabled
declaration preserved for reference.


### G2. `hosts/mod.apps.productivity.nix` not migrated

**Old:** `hosts/mod.apps.productivity.nix` (`programs.onlyoffice.enable = true`)

This file was **commented out** in `configuration.nix`:
```nix
# ../mod.apps.productivity.nix
```

The HM-level `programs.onlyoffice.enable = true` in `gui-apps.nix` covers
the user-level configuration. The NixOS-level option was disabled.

**Impact:** None — import was disabled.

**Action:** None required.


## Intentional Changes

### C1. `firefox-csshacks` reference changed from `pkgs` to flake input

**Old:** `pkgs.firefox-csshacks` in `mod.apps.web-browsers.nix`

**New:** `inputs.firefox-csshacks` captured in `let` block of `browsers.nix`

Both resolve to the same fetched source from `github:MrOtherGuy/firefox-csshacks`
(a non-flake input). The old approach required `firefox-csshacks` to be in `pkgs`
via an overlay; the new approach references the input directly, which is cleaner
for non-flake sources.

**Impact:** Functionally equivalent.


### C2. `firefox-addons` overlay added to `overlays.nix`

**Old:** `pkgs.firefoxAddons` was referenced in HM browser config. The overlay was
likely applied through a mechanism not visible in the flat config (possibly
HM-specific pkgs with its own overlay).

**New:** `inputs.nix-firefox-addons.overlays.default` explicitly added to the
default overlay in `modules/overlays.nix`.

**Impact:** Ensures `pkgs.firefoxAddons` is available via the NixOS pkgs
(which HM inherits via `useGlobalPkgs = true`).


### C3. HM nixpkgs replaced with `useGlobalPkgs`

**Old:** `host.eagle.hatim.nix` set `nixpkgs.overlays` and `nixpkgs.config.allowUnfree`
directly in HM context.

**New:** `home-manager.useGlobalPkgs = true` in `infrastructure/home-manager.nix`
makes HM inherit the NixOS-level `pkgs`. The NixOS `base.nix` applies overlays
and `allowUnfree`.

**Impact:** Functionally equivalent. HM and NixOS now share a single pkgs
evaluation, which is simpler and avoids double-evaluation.


## Bug Fix Applied

### B1. `system.autoUpgradeFlake.user` was a placeholder

**Old:** `configuration.nix` line 103: `user = "your-user";`

**New:** `base.nix`: `user = owner.username;` (resolves to `"hatim"`)

This was clearly a placeholder that was never updated. The migration fixes it.


## Pre-existing Duplications (carried over faithfully)

### D1. `pkgs.distrobox` — different mechanisms in two modules

| Location | Mechanism |
|----------|-----------|
| `modules/dev-software.nix:63` | `pkgs.distrobox` in `home.packages` |
| `modules/containers.nix:42` | `programs.distrobox.enable = true` |

**Origin:** Old `mod.dsdv.software.nix` had the package; old HM section of
`mod.containers.nix` had the program enable.

**Recommendation:** Remove `pkgs.distrobox` from `dev-software.nix` —
`programs.distrobox.enable` in `containers.nix` is the idiomatic approach.


### D2. `pkgs.lldb` — in two modules

| Location | Context |
|----------|---------|
| `modules/dev-software.nix:81` | General dev tools |
| `modules/editors.nix:197` | Needed for CodeLLDB/LLDB DAP extensions |

**Origin:** Present in both `mod.dsdv.software.nix` and `mod.editors.nix`.

**Recommendation:** Keep in `editors.nix` (where the need is documented),
remove from `dev-software.nix`.


### D3. `pkgs.nvd` — listed twice within `nix.nix`

| Location |
|----------|
| `modules/nix.nix:41` |
| `modules/nix.nix:52` |

**Origin:** Duplicated in old `mod.nix.nix` at lines 37 and 48.

**Recommendation:** Remove one instance.


### D4. `pkgs.nil` — in two modules (likely intentional)

| Location | Context |
|----------|---------|
| `modules/nix.nix:40` | Nix LSP, system-wide |
| `modules/editors.nix:173` | Zed editor `extraPackages` |

**Origin:** Present in both `mod.nix.nix` and `mod.editors.nix`.

**Recommendation:** Arguably intentional — `nix.nix` makes `nil` available
in PATH; `editors.nix` ensures Zed can find it. Keep both, or remove from
`editors.nix` since `nix.nix` already provides it system-wide.


## Module-by-Module Status

| Old Source | New Module | Status |
|------------|------------|--------|
| `mod.shells.nix` | `shells.nix` | Complete |
| `mod.apps.web-browsers.nix` (HM+NixOS) | `browsers.nix` | Complete (C1, C2 applied) |
| `mod.networking.nix` + `mod.os.networking.nix` | `networking.nix` | Complete |
| `mod.desktop-wayland.nix` + `configuration.nix` + `mod.input-devices.nix` | `desktop.nix` | Complete |
| `mod.dsdv.software.nix` (HM+NixOS) | `dev-software.nix` | Complete (D1, D2) |
| `mod.language-machine.nix` + `mod.language-models.nix` | `language-machine.nix` | Complete |
| `mod.editors.nix` | `editors.nix` | Complete |
| `mod.cli-utils.nix` | `cli-utils.nix` | Complete |
| `mod.version-control.nix` | `version-control.nix` | Complete |
| `mod.terminals.nix` | `terminals.nix` | Complete |
| `mod.fonts.nix` | `fonts.nix` | Complete |
| `mod.multimedia.nix` | `multimedia.nix` | Complete |
| `mod.apps.gui.nix` | `gui-apps.nix` | Complete |
| `mod.apps.science.nix` | `science.nix` | Complete |
| `mod.dsdv.web.nix` | `dev-web.nix` | Complete |
| `mod.dsdv.electronics.nix` | `dev-electronics.nix` | Complete |
| `mod.dsdv.mechanical.nix` | `dev-mechanical.nix` | Complete |
| `mod.writing.nix` + `mod.enchant.nix` | `writing.nix` + `_enchant-hm-module.nix` | Complete |
| `mod.study.mathematics.nix` | `study-math.nix` | Complete |
| `mod.study.linguistics.nix` | `study-linguistics.nix` | Complete |
| `mod.tools.backups.nix` | `tools-backups.nix` | Complete |
| `mod.tools.secrets.nix` | `tools-secrets.nix` | Complete |
| `mod.tools.research.nix` | `tools-research.nix` | Complete |
| `mod.nix.nix` | `nix.nix` | Complete (D3, D4; `home-manager.enable` moved to infra) |
| `mod.hw.laptop.nix` | `hardware/laptop.nix` | Complete |
| `mod.hw.lenovo-thinkpad-p52.nix` | `hardware/lenovo-thinkpad-p52.nix` | Complete |
| `mod.package-management.nix` | `package-management.nix` | Complete |
| `mod.guest-systems.nix` | `guest-systems.nix` | Complete |
| `mod.containers.nix` (HM+NixOS) | `containers.nix` | Complete (Phase 1) |
| `host.eagle.hatim.nix` | `infrastructure/home-manager.nix` | Complete (C3) |
| `configuration.nix` | `base.nix` + `eagle.nix` + `desktop.nix` | Complete (G1, B1) |


## Cross-module Dependencies

These module pairs have implicit dependencies (one sets an option that the
other configures):

| Provider | Consumer | Option |
|----------|----------|--------|
| `package-management.nix` | `browsers.nix` | `services.flatpak.enable` enables flatpak; browsers adds `services.flatpak.packages` |
| `infrastructure/home-manager.nix` | `writing.nix` | HM module system; writing imports `_enchant-hm-module.nix` |
| `base.nix` | `shells.nix` | NixOS-level `programs.zsh.enable` (base) + HM-level zsh config (shells) |
| `overlays.nix` | `browsers.nix` | `firefoxAddons` overlay provides `pkgs.firefoxAddons` |

All consumers are imported alongside their providers in `eagle.nix`, so
these dependencies are satisfied.


## Architectural Notes

- **Commented-out code** was intentionally not migrated. The original files
  contained many commented packages (`#LEAN`, `#FIXME`, `#BROKEN`). These
  are preserved as comments in their respective new modules only where they
  document something (e.g., `kicad-small` in `dev-electronics.nix`). Purely
  aspirational comments (package wishlists) were dropped.

- **`_enchant-hm-module.nix`** uses the underscore prefix convention so
  `import-tree` skips it. It's a raw HM module (defines `programs.enchant`
  options) imported explicitly by `writing.nix`.

- **`autoLogin.user`** in `desktop.nix` now uses `owner.username` instead
  of hardcoded `"hatim"`. This is a correct parameterisation, not a
  semantic change.

- **Build verified** with `nix build` and spot-checked via `nix eval` for
  `services.kanata.enable`, `programs.chromium.enable`,
  `services.opensnitch.enable`, `hardware.nvidia.modesetting.enable`,
  `programs.starship.enable`, `programs.git.enable`, and
  `programs.enchant.enable`.


## Conclusion

The migration is **functionally complete** with zero missing active config.
All gaps are either no-ops (disabled features) or deliberate architectural
improvements. The 4 duplications are all pre-existing and non-breaking, but
cleaning them up in Phase 3 would be good hygiene.
