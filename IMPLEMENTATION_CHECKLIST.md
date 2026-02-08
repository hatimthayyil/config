# Implementation Checklist: Module Structure

This checklist tracks the migration of configurations from the old structure to the new modularized structure.

## Phase 1: Structure Setup ✅ COMPLETE

- [x] Create new directory structure in `modules/home/`
- [x] Create new directory structure in `modules/os/`
- [x] Create entry point modules (`modules/home/default.nix`, `modules/os/default.nix`)
- [x] Create category-level default.nix files with imports
- [x] Create all stub modules with enable/disable options
- [x] Create README files for both home and os modules
- [x] Document enable/disable pattern
- [x] Create migration guide (MIGRATION_GUIDE.md)

## Phase 2: Home-Manager Module Migration (Estimated: 5-6 hours)

### High Priority (Core Functionality)

- [ ] **Shells** - `modules/home/shells/default.nix`
  - Source: `home/hatim/mod.shells.nix`
  - Status: STUB (needs p10k config file handling)
  - Notes: Includes p10k.zsh file symlink

- [ ] **Editors** - `modules/home/editors/default.nix`
  - Source: `home/hatim/mod.editors.nix`
  - Status: PARTIAL (basic structure done, needs testing)
  - Notes: VSCode settings symlink, very complex module

- [ ] **Terminals** - `modules/home/terminals.nix`
  - Source: `home/hatim/mod.terminals.nix`
  - Status: STUB
  - Notes: Simple module, straightforward migration

- [ ] **Nix Tools** - `modules/home/nix.nix`
  - Source: `home/hatim/mod.nix.nix`
  - Status: STUB
  - Notes: home-manager autoUpgrade service configuration

- [ ] **Version Control** - `modules/home/development/version-control.nix`
  - Source: `home/hatim/mod.version-control.nix`
  - Status: STUB
  - Notes: Git and related tools

### Medium Priority (Development)

- [ ] **Development: Web** - `modules/home/development/web.nix`
  - Source: `home/hatim/mod.dsdv.web.nix`
  - Status: STUB
  - Notes: Web dev stack

- [ ] **Development: Software** - `modules/home/development/software.nix`
  - Source: `home/hatim/mod.dsdv.software.nix`
  - Status: STUB
  - Notes: General software dev

- [ ] **Development: Electronics** - `modules/home/development/electronics.nix`
  - Source: `home/hatim/mod.dsdv.electronics.nix`
  - Status: STUB
  - Notes: EDA tools

- [ ] **Development: Mechanical** - `modules/home/development/mechanical.nix`
  - Source: `home/hatim/mod.dsdv.mechanical.nix`
  - Status: STUB
  - Notes: CAD tools

- [ ] **Applications: GUI** - `modules/home/applications/gui/default.nix`
  - Source: `home/hatim/mod.apps.gui.nix`
  - Status: STUB
  - Notes: Multimedia, mail, communication apps

- [ ] **Applications: CLI** - `modules/home/applications/cli/default.nix`
  - Source: `home/hatim/mod.cli-utils.nix`
  - Status: STUB
  - Notes: Command-line utilities

### Lower Priority (Specialized)

- [ ] **Applications: Web Browsers** - `modules/home/applications/web-browsers.nix`
  - Source: `home/hatim/mod.apps.web-browsers.nix`
  - Status: STUB
  - Notes: Very complex (259 lines), Firefox config

- [ ] **Applications: Science** - `modules/home/applications/science.nix`
  - Source: `home/hatim/mod.apps.science.nix`
  - Status: STUB

- [ ] **System: Desktop** - `modules/home/system/desktop.nix`
  - Source: `home/hatim/mod.desktop-wayland.nix`
  - Status: STUB
  - Notes: Wayland configuration

- [ ] **System: Networking** - `modules/home/system/networking.nix`
  - Source: `home/hatim/mod.networking.nix`
  - Status: STUB

- [ ] **System: Multimedia** - `modules/home/system/multimedia.nix`
  - Source: `home/hatim/mod.multimedia.nix`
  - Status: STUB

- [ ] **System: Fonts** - `modules/home/system/fonts.nix`
  - Source: `home/hatim/mod.fonts.nix`
  - Status: STUB

- [ ] **System: Containers** - `modules/home/system/containers.nix`
  - Source: `home/hatim/mod.containers.nix`
  - Status: STUB

- [ ] **Tools: Backup** - `modules/home/tools/backup.nix`
  - Source: `home/hatim/mod.tools.backups.nix`
  - Status: STUB

- [ ] **Tools: Research** - `modules/home/tools/research.nix`
  - Source: `home/hatim/mod.tools.research.nix`
  - Status: STUB

- [ ] **Tools: Secrets** - `modules/home/tools/secrets.nix`
  - Source: `home/hatim/mod.tools.secrets.nix`
  - Status: STUB

- [ ] **Study: Mathematics** - `modules/home/study/mathematics.nix`
  - Source: `home/hatim/mod.study.mathematics.nix`
  - Status: STUB

- [ ] **Study: Linguistics** - `modules/home/study/linguistics.nix`
  - Source: `home/hatim/mod.study.linguistics.nix`
  - Status: STUB

- [ ] **Writing** - `modules/home/writing.nix`
  - Source: `home/hatim/mod.writing.nix`
  - Status: STUB

- [ ] **Language Machine** - `modules/home/language-machine.nix`
  - Source: `home/hatim/mod.language-machine.nix`
  - Status: STUB

- [ ] **Enchant** - `modules/home/enchant.nix`
  - Source: `modules/home/enchant.nix` (already in modules/)
  - Status: Needs refactoring to enable/disable pattern

## Phase 3: NixOS Module Migration (Estimated: 2-3 hours)

### High Priority

- [ ] **Hardware: Laptop** - `modules/os/hardware/laptop.nix`
  - Source: `hosts/mod.hw.laptop.nix`
  - Status: STUB

- [ ] **Hardware: ThinkPad P52** - `modules/os/hardware/lenovo-thinkpad-p52.nix`
  - Source: `hosts/mod.hw.lenovo-thinkpad-p52.nix`
  - Status: STUB

- [ ] **System: Networking** - `modules/os/system/networking.nix`
  - Source: `hosts/mod.os.networking.nix`
  - Status: STUB
  - Notes: Nginx, Avahi, OpenSnitch configuration

- [ ] **System: Package Management** - `modules/os/system/package-management.nix`
  - Source: `hosts/mod.package-management.nix`
  - Status: STUB
  - Notes: Guix, XDG Portal, Flatpak

- [ ] **System: Containers** - `modules/os/system/containers.nix`
  - Source: `hosts/mod.containers.nix`
  - Status: STUB

### Medium Priority

- [ ] **System: Input Devices** - `modules/os/system/input-devices.nix`
  - Source: `hosts/mod.input-devices.nix`
  - Status: STUB

- [ ] **System: Guest Systems** - `modules/os/system/guest-systems.nix`
  - Source: `hosts/mod.guest-systems.nix`
  - Status: STUB

- [ ] **System: Language Models** - `modules/os/system/language-models.nix`
  - Source: `hosts/mod.language-models.nix`
  - Status: STUB

### Lower Priority

- [ ] **Applications: Web Browsers** - `modules/os/applications/web-browsers.nix`
  - Source: `hosts/mod.apps.web-browsers.nix`
  - Status: STUB

- [ ] **Applications: Productivity** - `modules/os/applications/productivity.nix`
  - Source: `hosts/mod.apps.productivity.nix`
  - Status: STUB

- [ ] **OneOffice (OS)** - Integrate into appropriate system module
  - Source: `modules/os.onlyoffice.nix`
  - Status: STUB

## Phase 4: Host Configuration Refactoring (Estimated: 1-2 hours)

- [ ] Update `home/hatim/host.eagle.hatim.nix`
  - Replace individual imports with `../../modules/home/default.nix`
  - Add `hatim.modules` enable/disable section
  - Test home-manager configuration

- [ ] Update `hosts/eagle/configuration.nix`
  - Replace individual imports with `../../modules/os/default.nix`
  - Add `hatim.modules` enable/disable section
  - Test NixOS configuration

- [ ] Verify `home/hatim/host.eagle.hatim.nix` no longer needs file.zsh.p10k.zsh symlink import

## Phase 5: Testing & Validation (Ongoing)

### Before Each Major Migration

- [ ] Record evaluation time: `time nix flake check` (in root)
- [ ] Record build time: `time nixos-rebuild dry-run`

### After Each Module Migration

- [ ] Run `home-manager switch --flake . -- hatim@eagle --dry-run`
- [ ] Run `sudo nixos-rebuild switch --flake . --dry-run`
- [ ] No evaluation errors
- [ ] Test module enable/disable with different configurations

### Final Validation

- [ ] Full system rebuild works
- [ ] home-manager switch works
- [ ] Evaluation time has improved (target: 20-40% reduction)
- [ ] All functionality still works as before
- [ ] No modules are missed

## Phase 6: Cleanup (After Full Migration)

- [ ] Verify all content has been migrated
- [ ] Remove old `home/hatim/mod.*.nix` files
- [ ] Remove old `hosts/mod.*.nix` files
- [ ] Remove old `modules/os.onlyoffice.nix` if consolidated
- [ ] Archive removed files (git history preserved)

## Notes

### Files to Keep
- `home/hatim/file.vscode-settings.json` - Referenced by editors module
- `home/hatim/file.zsh.p10k.zsh` - Referenced by shells module
- `hosts/eagle/hardware-configuration.nix` - Hardware scan output
- `hosts/files/*` - Signing keys for substituters

### Special Considerations

1. **VSCode Settings**: Referenced via hardcoded path, consider making configurable
2. **P10K Configuration**: File is stored in `home/hatim/`, may want to move to `modules/home/shells/`
3. **File Symlinks**: Some modules use `mkOutOfStoreSymlink` - verify these work in new locations
4. **nix-index Database**: Home-manager module from flake - verify it still works

## Progress Tracking

- **Phase 1**: 100% Complete ✅
- **Phase 2**: 0% Complete (Waiting on Phase 1)
- **Phase 3**: 0% Complete (Waiting on Phase 1)
- **Phase 4**: 0% Complete (Waiting on Phases 2-3)
- **Phase 5**: Ongoing (From Phase 2 onwards)
- **Phase 6**: 0% Complete (Waiting on Phases 2-5)

**Overall Progress**: ~10% (Structure only)

## Recommended Next Steps

1. Start with **Phase 2 High Priority** modules (Shells, Editors, Terminals)
2. Test after each module is migrated
3. Move to **Phase 2 Medium Priority** (Development modules)
4. Then **Phase 3** (NixOS modules)
5. Finally **Phases 4-6** (Refactoring and cleanup)
