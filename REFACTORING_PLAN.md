# Nix Configuration Refactoring Analysis

## Current Structure Overview

### Home-Manager Configuration
- **Location**: `home/hatim/`
- **Files**: 29 mod.*.nix files + host.eagle.hatim.nix
- **Pattern**: Each module handles a specific category (editors, shells, apps, etc.)
- **Issues**:
  - All modules are always imported (no enable/disable mechanism)
  - Each module file imports all related packages and programs
  - Difficult to selectively enable/disable functionality
  - Deep nesting of configuration options makes evaluation complex

### NixOS Configuration
- **Location**: `hosts/`
- **Structure**: 
  - `hosts/eagle/` - host-specific files (configuration.nix, hardware-configuration.nix, default.nix)
  - `hosts/mod.*.nix` - host-level modules (14 files)
- **Pattern**: Each module handles host-wide configuration
- **Issues**:
  - Modules always enabled globally
  - Mix of hardware config, services, and package management in single files
  - No granular control over which features are active

### Module Structure
- **Location**: `modules/`
- **Current**: Only 2 basic modules (onlyoffice.nix, os.onlyoffice.nix)
- **Opportunity**: Should be the central place for both home-manager and NixOS modules

## Identified Pain Points

### 1. **Evaluation Performance**
- **Cause**: All modules imported regardless of usage
- **Result**: Every configuration option evaluated even if disabled
- **Solution**: Implement enable/disable flags to skip unused modules

### 2. **Module Organization**
- **Cause**: Modules split between `home/hatim/`, `hosts/`, and `modules/`
- **Result**: Unclear where configuration should go
- **Solution**: Centralize in `modules/` with clear subdirectories

### 3. **Complexity in Each Module**
- **Cause**: Each module contains program setup, packages, and configuration
- **Result**: Hard to understand relationships; difficult to maintain
- **Solution**: Extract into separate concerns (programs, packages, services)

### 4. **No Conditional Loading**
- **Cause**: All imports are unconditional
- **Result**: Cannot easily enable/disable features without commenting code
- **Solution**: Use options with proper defaults and enable/disable mechanism

### 5. **Redundant Configuration**
- **Cause**: Similar patterns repeated across modules
- **Result**: Maintenance burden; changes must be made in multiple places
- **Solution**: Extract common patterns into base modules

## Current Module Categories (Home-Manager)

| Category | Modules |
|----------|---------|
| Editing | mod.editors.nix (Emacs, VSCode, Nvf) |
| Shells | mod.shells.nix (Bash, Zsh, Fish, Nu) |
| Terminals | mod.terminals.nix |
| Development | mod.version-control.nix, mod.cli-utils.nix, mod.dsdv.* (4 files) |
| Applications | mod.apps.gui.nix, mod.apps.web-browsers.nix, mod.apps.science.nix |
| Tools | mod.tools.backups.nix, mod.tools.research.nix, mod.tools.secrets.nix |
| Study | mod.study.*.nix (2 files) |
| System | mod.desktop-wayland.nix, mod.networking.nix, mod.containers.nix, mod.multimedia.nix, mod.fonts.nix |
| Writing | mod.writing.nix |
| ML/AI | mod.language-machine.nix |
| Nix-specific | mod.nix.nix |

## Current Module Categories (NixOS)

| Category | Modules |
|----------|---------|
| Hardware | mod.hw.laptop.nix, mod.hw.lenovo-thinkpad-p52.nix |
| System | mod.os.networking.nix, mod.package-management.nix |
| Services | mod.containers.nix, mod.language-models.nix |
| Input | mod.input-devices.nix |
| Applications | mod.apps.*.nix (3 files) |
| Guests | mod.guest-systems.nix |

## Proposed Refactoring Strategy

### New Directory Structure

```
modules/
├── README.md (Module documentation)
├── home/
│   ├── default.nix (entry point, imports enabled modules)
│   ├── shells/
│   │   ├── default.nix (bash, zsh, fish, nushell configuration)
│   ├── editors/
│   │   ├── emacs.nix (emacs-specific configuration)
│   │   ├── neovim.nix (nvf neovim configuration)
│   │   ├── vscode.nix (vscode configuration)
│   │   ├── default.nix (imports based on enabled editors)
│   ├── applications/
│   │   ├── gui/
│   │   │   ├── multimedia.nix
│   │   │   ├── design.nix
│   │   │   ├── communication.nix
│   │   │   └── default.nix
│   │   ├── cli/
│   │   │   ├── dev-tools.nix
│   │   │   ├── research-tools.nix
│   │   │   └── default.nix
│   │   ├── web-browsers.nix
│   │   ├── science.nix
│   │   └── default.nix
│   ├── development/
│   │   ├── web.nix (web dev stack)
│   │   ├── software.nix (general software dev)
│   │   ├── electronics.nix
│   │   ├── mechanical.nix
│   │   ├── version-control.nix
│   │   └── default.nix
│   ├── system/
│   │   ├── desktop.nix (Wayland configuration)
│   │   ├── networking.nix
│   │   ├── multimedia.nix
│   │   ├── fonts.nix
│   │   ├── containers.nix
│   │   └── default.nix
│   ├── tools/
│   │   ├── backup.nix
│   │   ├── research.nix
│   │   ├── secrets.nix
│   │   └── default.nix
│   ├── study/
│   │   ├── mathematics.nix
│   │   ├── linguistics.nix
│   │   └── default.nix
│   ├── terminals.nix
│   ├── writing.nix
│   ├── language-machine.nix
│   ├── nix.nix
│   └── enchant.nix (moved from home-manager modules)
│
├── os/
│   ├── default.nix (entry point, imports enabled modules)
│   ├── hardware/
│   │   ├── laptop.nix
│   │   ├── lenovo-thinkpad-p52.nix
│   │   └── default.nix
│   ├── system/
│   │   ├── networking.nix
│   │   ├── package-management.nix
│   │   ├── containers.nix
│   │   ├── input-devices.nix
│   │   ├── guest-systems.nix
│   │   ├── language-models.nix
│   │   └── default.nix
│   ├── applications/
│   │   ├── web-browsers.nix
│   │   ├── productivity.nix
│   │   └── default.nix
│   └── onlyoffice.nix (moved and refactored)
│
└── profiles/ (Optional: pre-configured sets of modules)
    ├── workstation.nix
    ├── development.nix
    └── minimal.nix
```

### Enable/Disable Pattern

All modules will follow a standard enable/disable pattern:

```nix
{ config, lib, ... }:
let
  cfg = config.hatim.modules.shells; # or similar
in
{
  options.hatim.modules.shells = {
    enable = lib.mkEnableOption "shell configuration";
    bash.enable = lib.mkEnableOption "bash shell";
    zsh.enable = lib.mkEnableOption "zsh shell";
    # ... other options
  };

  config = lib.mkIf cfg.enable {
    # Implementation only when enabled
  };
}
```

### Host Configuration Simplification

New host configurations will be minimal:

```nix
# hosts/eagle/configuration.nix
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/os/default.nix
  ];

  hatim.modules = {
    # Enable/disable OS-level modules
    system.networking.enable = true;
    system.containers.enable = true;
    hardware.laptop.enable = true;
    # ... etc
  };
}

# home/hatim/home.nix (simplified)
{
  imports = [
    ../../modules/home/default.nix
  ];

  hatim.modules = {
    # Enable/disable home-manager modules
    shells.enable = true;
    shells.zsh.enable = true;
    editors.enable = true;
    editors.neovim.enable = true;
    # ... etc
  };
}
```

## Benefits of Refactoring

1. **Faster Evaluation**: Only enabled modules are evaluated
2. **Clearer Organization**: Centralized module location with logical structure
3. **Easier Maintenance**: Changes to categories affect all related configs
4. **Better Discoverability**: Related configs grouped together
5. **Flexible Enablement**: Easy to enable/disable features without code changes
6. **Scalability**: Easy to add new modules or hosts

## Implementation Phases

### Phase 1: Prepare Structure (Quick)
- Create new directory structure in `modules/`
- Create entry point files with proper enable/disable patterns

### Phase 2: Migrate Home-Manager Modules (Iterative)
- Move and refactor modules from `home/hatim/` to `modules/home/`
- Add enable/disable options

### Phase 3: Migrate NixOS Modules (Iterative)
- Move and refactor modules from `hosts/` to `modules/os/`
- Add enable/disable options

### Phase 4: Simplify Host Configs (Quick)
- Reduce host configuration files to minimal enable/disable settings
- Test evaluation performance

### Phase 5: Testing & Validation (Ongoing)
- Compare evaluation times before and after
- Test functionality with new structure

## Potential Risks & Mitigation

| Risk | Mitigation |
|------|-----------|
| Breaking evaluation | Keep old files until new structure works, then migrate gradually |
| Lost configurations | Git history preserved; test before deletion |
| Import cycles | Clear dependency tree with no circular imports |
| Complex enable logic | Test each module independently before integration |
