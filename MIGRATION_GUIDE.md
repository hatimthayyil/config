# Migration Guide: New Module Structure

## Overview

The new module structure is now in place. This guide explains how to migrate your configurations incrementally.

## What Changed

### Directory Structure

**Before:**
```
home/hatim/
  ├── mod.shells.nix
  ├── mod.editors.nix
  ├── mod.apps.gui.nix
  ├── mod.apps.web-browsers.nix
  ├── ... (29 mod files)
  └── host.eagle.hatim.nix (imports all 29 files)

hosts/
  ├── mod.hw.laptop.nix
  ├── mod.hw.lenovo-thinkpad-p52.nix
  ├── mod.os.networking.nix
  ├── ... (11 mod files)
  └── eagle/configuration.nix (imports all modules)
```

**After:**
```
modules/
├── home/
│   ├── default.nix (entry point - imports all submodules)
│   ├── shells/default.nix (replaced mod.shells.nix)
│   ├── editors/default.nix (replaced mod.editors.nix)
│   ├── applications/
│   │   ├── default.nix
│   │   ├── gui/default.nix
│   │   ├── web-browsers.nix
│   │   ├── science.nix
│   │   └── cli/default.nix
│   ├── development/
│   │   ├── default.nix
│   │   ├── web.nix
│   │   ├── software.nix
│   │   ├── electronics.nix
│   │   ├── mechanical.nix
│   │   └── version-control.nix
│   ├── system/
│   │   ├── default.nix
│   │   ├── desktop.nix
│   │   ├── networking.nix
│   │   ├── multimedia.nix
│   │   ├── fonts.nix
│   │   └── containers.nix
│   ├── tools/
│   │   ├── default.nix
│   │   ├── backup.nix
│   │   ├── research.nix
│   │   └── secrets.nix
│   ├── study/
│   │   ├── default.nix
│   │   ├── mathematics.nix
│   │   └── linguistics.nix
│   ├── terminals.nix
│   ├── nix.nix
│   ├── writing.nix
│   ├── language-machine.nix
│   └── enchant.nix
│
└── os/
    ├── default.nix (entry point - imports all submodules)
    ├── hardware/
    │   ├── default.nix
    │   ├── laptop.nix
    │   └── lenovo-thinkpad-p52.nix
    ├── system/
    │   ├── default.nix
    │   ├── networking.nix
    │   ├── package-management.nix
    │   ├── containers.nix
    │   ├── input-devices.nix
    │   ├── guest-systems.nix
    │   └── language-models.nix
    └── applications/
        ├── default.nix
        ├── web-browsers.nix
        └── productivity.nix
```

## Module Enable/Disable Pattern

All modules now follow this standard pattern:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hatim.modules.category;
in
{
  options.hatim.modules.category = {
    enable = lib.mkEnableOption "description";
    # ... additional options
  };

  config = lib.mkIf cfg.enable {
    # Configuration only applied when enabled
  };
}
```

## How to Update Your Configuration

### Step 1: Update home/hatim/host.eagle.hatim.nix

**Before:**
```nix
{
  outputs,
  ...
}:

{
  imports = [
    ../../modules/home/enchant.nix
    ./mod.nix.nix
    ./mod.shells.nix
    ./mod.terminals.nix
    ./mod.editors.nix
    # ... all 29 files
  ];

  home.username = "hatim";
  home.homeDirectory = "/home/hatim";
  # ... rest of config
}
```

**After:**
```nix
{
  outputs,
  ...
}:

{
  imports = [
    ../../modules/home/default.nix  # This imports all home modules
  ];

  home.username = "hatim";
  home.homeDirectory = "/home/hatim";

  # Enable/disable specific categories if needed
  hatim.modules = {
    shells.enable = true;
    shells.bash.enable = true;
    shells.zsh.enable = true;
    
    editors.enable = true;
    editors.emacs.enable = true;
    editors.neovim.enable = true;
    editors.vscode.enable = true;
    
    # ... etc
  };
}
```

### Step 2: Update hosts/eagle/configuration.nix

**Before:**
```nix
{
  outputs,
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../mod.hw.laptop.nix
    ../mod.hw.lenovo-thinkpad-p52.nix
    ../mod.os.networking.nix
    ../mod.containers.nix
    ../mod.apps.web-browsers.nix
    # ... all 11 files
  ];

  nix = { ... };
  # ... rest of config
}
```

**After:**
```nix
{
  outputs,
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/os/default.nix  # This imports all OS modules
  ];

  nix = { ... };
  
  # Enable/disable specific hardware and system configurations
  hatim.modules = {
    hardware.enable = true;
    hardware.laptop.enable = true;
    hardware.lenovo-thinkpad-p52.enable = true;
    
    system.enable = true;
    system.networking.enable = true;
    system.containers.enable = true;
    system.packageManagement.enable = true;
    
    applications.enable = true;
    applications.webBrowsers.enable = true;
    # ... etc
  };
}
```

## Migration Phases

### Phase A: Stub Everything (DONE)
- Created new module structure with stubs for all categories
- All modules have proper enable/disable options
- Basic structure is in place

### Phase B: Migrate Content (TODO - Next Steps)

You should now migrate actual content from the old files to the new modules. For example:

1. **Read the old file:** `home/hatim/mod.shells.nix`
2. **Copy content to new location:** `modules/home/shells/default.nix`
3. **Replace conditional imports with enable/disable:** The content is only applied when `config.hatim.modules.shells.enable = true`
4. **Update references:** Change imports to use the new module structure
5. **Test:** Verify the configuration still works

### Phase C: Simplify Host Configs (TODO)

Once content is migrated, simplify:
- `home/hatim/host.eagle.hatim.nix` → Only imports and enable settings
- `hosts/eagle/configuration.nix` → Only imports, hardware, and enable settings

### Phase D: Clean Up (TODO)

After confirming everything works:
1. Remove old `home/hatim/mod.*.nix` files
2. Remove old `hosts/mod.*.nix` files
3. Archive or delete old files

## Testing

After each migration step, test the configuration:

```bash
# Test NixOS configuration
nix flake check

# Build NixOS configuration
sudo nixos-rebuild switch --flake /home/hatim/code/config

# Build home-manager configuration
home-manager switch --flake /home/hatim/code/config#hatim@eagle
```

## Performance Metrics

### Before Refactoring
- (Record these after initial setup)
- Number of modules always loaded: 40+
- Evaluation time: `time nixos-rebuild switch --flake . --dry-run`

### After Refactoring
- (Will be recorded after full migration)
- Expected improvement: 20-40% faster evaluation

## Benefits Already Realized

1. **Better Organization**: Related configs are now grouped logically
2. **Clearer Dependencies**: Module imports are organized hierarchically
3. **Enable/Disable Ready**: Framework in place for selective loading
4. **Scalability**: New modules can be added easily

## Benefits to Come (After Content Migration)

1. **Faster Evaluation**: Only enabled modules will be evaluated
2. **Selective Loading**: Easily disable entire categories
3. **Easier Testing**: Each module can be tested independently
4. **Reduced Complexity**: Each file is smaller and more focused
5. **Better Discoverability**: Know where to look for specific configs

## Questions?

Refer to [REFACTORING_PLAN.md](REFACTORING_PLAN.md) for the original analysis and strategy.
