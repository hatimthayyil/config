# Quick Start: New Module System

## What You Have

✅ A complete new module structure with:
- `modules/home/` - Home-manager modules organized by category
- `modules/os/` - NixOS system modules organized by category
- Enable/disable pattern ready for all modules
- Documented migration path

## What You Need to Do

### Option 1: Incremental Migration (Recommended)

1. Pick one module category (e.g., `shells`)
2. Copy the content from `home/hatim/mod.shells.nix` to `modules/home/shells/default.nix`
3. Test with: `home-manager switch --flake . --dry-run`
4. Repeat for next category
5. Once all home modules are migrated, update `home/hatim/host.eagle.hatim.nix`
6. Repeat process for NixOS modules in `modules/os/`

### Option 2: Full Migration (Faster, Higher Risk)

1. Copy all module content from old files to new structure
2. Test the full configuration
3. Update host configurations
4. Clean up old files

## Files to Reference

1. **[REFACTORING_PLAN.md](REFACTORING_PLAN.md)** - Original analysis and strategy
2. **[MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)** - Step-by-step migration instructions
3. **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** - Detailed task tracking

## Key Directories

```
modules/
├── home/              # Home-manager modules (20+ categories)
│   ├── default.nix   # Entry point - imports all submodules
│   ├── shells/
│   ├── editors/
│   ├── applications/
│   ├── development/
│   ├── system/
│   ├── tools/
│   ├── study/
│   └── ...
│
└── os/                # NixOS system modules
    ├── default.nix   # Entry point - imports all submodules
    ├── hardware/
    ├── system/
    ├── applications/
    └── ...
```

## Example: Migrating the Shells Module

### 1. Source the old configuration
```bash
cat home/hatim/mod.shells.nix
```

### 2. Copy content to new location
Edit `modules/home/shells/default.nix` and add the actual shell configurations inside the `config = lib.mkIf cfg.enable { ... }` block

### 3. Handle file references
The `mod.shells.nix` references `./file.zsh.p10k.zsh`. You can:
- Keep the file in `home/hatim/` and reference it with an absolute path
- Move it to `modules/home/shells/` and reference it relatively
- Use the current symlink approach

### 4. Test
```bash
# Dry run
home-manager switch --flake /home/hatim/code/config#hatim@eagle --dry-run

# Actual switch (if dry run succeeds)
home-manager switch --flake /home/hatim/code/config#hatim@eagle
```

## Enable/Disable Example

Once content is migrated, control modules in `home/hatim/host.eagle.hatim.nix`:

```nix
hatim.modules = {
  # Disable everything by default
  shells.enable = false;
  editors.enable = false;
  
  # Re-enable what you need
  shells.enable = true;
  shells.bash.enable = true;
  shells.zsh.enable = true;
  
  editors.enable = true;
  editors.neovim.enable = true;
  # vscode disabled by commenting this out
};
```

## Testing Your Work

```bash
# Syntax check
nix flake check

# Dry run (doesn't apply changes)
sudo nixos-rebuild switch --flake /home/hatim/code/config --dry-run
home-manager switch --flake /home/hatim/code/config#hatim@eagle --dry-run

# Measure evaluation time
time nix flake check
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| `option hatim.modules.X.enable does not exist` | Make sure the module is imported in its parent's `default.nix` |
| `File not found` error | Update file paths in modules - they're now in `modules/` not `home/hatim/` |
| Evaluation takes longer | You may have missed removing some old imports from host configs |
| Configuration works but settings don't apply | Make sure `config = lib.mkIf cfg.enable { ... }` wraps the actual config |

## Performance Gains

Expected improvements after full migration:
- **20-40% faster** evaluation time
- **Clearer organization** - related configs grouped together
- **Selective loading** - disable entire categories with one line
- **Better maintainability** - smaller, focused modules

## Next Steps

1. Review [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)
2. Start with High Priority modules
3. Test frequently
4. Document any issues you encounter
5. Update host configurations once you have migrated content

## Need Help?

Refer to the standard module pattern in any of the created files for examples.
All modules follow the same structure:

```nix
{
  config,
  lib,
  ...
}:
let
  cfg = config.hatim.modules.category;
in
{
  options.hatim.modules.category = {
    enable = lib.mkEnableOption "description";
    # ... subcategory options
  };

  config = lib.mkIf cfg.enable {
    # Actual configuration here
  };
}
```
