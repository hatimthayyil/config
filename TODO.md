# Dendritic Migration TODO

## Phase 0: Infrastructure
- [ ] Add `import-tree` to flake.nix inputs
- [ ] Create `modules/infrastructure/flake-parts.nix`
- [ ] Create `modules/infrastructure/meta.nix` (owner username/fullName)
- [ ] Create `modules/infrastructure/configurations.nix` (NixOS config builder)
- [ ] Create `modules/infrastructure/home-manager.nix` (HM-into-NixOS wiring)
- [ ] Create `modules/overlays.nix` (move from `overlays/default.nix`)
- [ ] Create `modules/base.nix` (minimal bootable: nix, locale, boot, user, packages)
- [ ] Create `modules/hosts/eagle.nix` (eagle group selection)
- [ ] Rewrite `flake.nix` outputs (remove nixos/homeConfigurations, use dendritic)
- [ ] Verify: `nix build .#nixosConfigurations.eagle.config.system.build.toplevel`

## Phase 1: First cross-cutting feature
- [ ] Create `modules/containers.nix` (NixOS docker/podman + HM distrobox)
- [ ] Add `containers` to eagle's group list
- [ ] Remove `home/hatim/mod.containers.nix` and `hosts/mod.containers.nix`
- [ ] Verify build and functionality

## Phase 2: Migrate remaining features

### Cross-cutting (NixOS + HM in one file)
- [ ] `modules/shells.nix` ← `mod.shells.nix` + `configuration.nix` shell setup
- [ ] `modules/browsers.nix` ← `mod.apps.web-browsers.nix` + `hosts/mod.apps.web-browsers.nix`
- [ ] `modules/networking.nix` ← `mod.networking.nix` + `hosts/mod.os.networking.nix`
- [ ] `modules/desktop.nix` ← `mod.desktop-wayland.nix` + `configuration.nix` KDE/pipewire/input
- [ ] `modules/dev-software.nix` ← `mod.dsdv.software.nix` + `hosts/mod.dsdv.software.nix`
- [ ] `modules/language-machine.nix` ← `mod.language-machine.nix` + `hosts/mod.language-models.nix`

### HM-only features
- [ ] `modules/editors.nix` ← `mod.editors.nix`
- [ ] `modules/cli-utils.nix` ← `mod.cli-utils.nix`
- [ ] `modules/version-control.nix` ← `mod.version-control.nix`
- [ ] `modules/terminals.nix` ← `mod.terminals.nix`
- [ ] `modules/fonts.nix` ← `mod.fonts.nix`
- [ ] `modules/multimedia.nix` ← `mod.multimedia.nix`
- [ ] `modules/gui-apps.nix` ← `mod.apps.gui.nix`
- [ ] `modules/science.nix` ← `mod.apps.science.nix`
- [ ] `modules/dev-web.nix` ← `mod.dsdv.web.nix`
- [ ] `modules/dev-electronics.nix` ← `mod.dsdv.electronics.nix`
- [ ] `modules/dev-mechanical.nix` ← `mod.dsdv.mechanical.nix`
- [ ] `modules/writing.nix` ← `mod.writing.nix`
- [ ] `modules/study-math.nix` ← `mod.study.mathematics.nix`
- [ ] `modules/study-linguistics.nix` ← `mod.study.linguistics.nix`
- [ ] `modules/tools-backups.nix` ← `mod.tools.backups.nix`
- [ ] `modules/tools-secrets.nix` ← `mod.tools.secrets.nix`
- [ ] `modules/tools-research.nix` ← `mod.tools.research.nix`
- [ ] `modules/nix.nix` ← `mod.nix.nix`

### NixOS-only features (absorbed into base or hardware)
- [ ] `modules/hardware/laptop.nix` ← `hosts/mod.hw.laptop.nix`
- [ ] `modules/hardware/lenovo-thinkpad-p52.nix` ← `hosts/mod.hw.lenovo-thinkpad-p52.nix`
- [ ] Absorb `hosts/mod.package-management.nix` into `modules/base.nix`
- [ ] Absorb `hosts/mod.guest-systems.nix` into `modules/base.nix` or standalone
- [ ] Absorb `hosts/mod.input-devices.nix` into `modules/desktop.nix`

## Phase 3: Clean up
- [ ] Delete all `home/hatim/mod.*.nix` files
- [ ] Delete all `hosts/mod.*.nix` files
- [ ] Delete `home/hatim/host.eagle.hatim.nix`
- [ ] Delete `modules/home/` directory (old hatim.modules.* approach)
- [ ] Delete `modules/os/` directory (old hatim.modules.* approach)
- [ ] Delete `overlays/default.nix` (moved to modules/)
- [ ] Delete `BEFORE_AND_AFTER.md`
- [ ] Update `justfile` (remove `home:`, simplify `switch:`)
- [ ] Update `CLAUDE.md` with dendritic conventions and module authoring guide
- [ ] Run `nix fmt` on entire repo
- [ ] Final verification: `nix flake check && just switch`
