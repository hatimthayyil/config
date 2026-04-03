# Dendritic Migration Plan

## Context

Migrating from flat `mod.*.nix` files (25 home, 11 OS) with manual import lists to the **dendritic pattern** — feature-centric modules auto-imported via `import-tree`, with home-manager integrated into NixOS for true cross-cutting configuration.

**Why:** Current flat structure doesn't scale to multiple hosts, has no grouping, and splits related NixOS/HM config across separate files and evaluations. The partially-built `modules/` directory with `hatim.modules.*` options is the wrong abstraction (over-engineering for personal config, incorrect evaluation speed claims, more files not fewer).

**Decisions made:**
- Home-manager integrated into NixOS (single `nixos-rebuild switch`)
- Per-feature named groups (~20 groups, each host picks exactly what it needs)
- Auto-import via `import-tree` (no manual import lists)

---

## Architecture

### How dendritic works

Every `.nix` file under `modules/` is a **flake-parts module** (not a NixOS or HM module). Each file contributes to named groups via `flake.modules.nixos.<group-name>`. A host picks which groups to include. `import-tree` auto-discovers all files.

```
flake.nix
  └─ imports = [ (inputs.import-tree ./modules) ]
       └─ auto-imports every .nix under modules/
            └─ each file contributes to flake.modules.nixos.<group>
                 └─ hosts pick groups: [ base shells editors ... ]
```

### File anatomy

Cross-cutting feature (NixOS + HM in one file):
```nix
# modules/browsers.nix
{ config, ... }: {
  flake.modules.nixos.browsers = { pkgs, ... }: {
    # NixOS-level policy
    programs.firefox.enable = true;
    programs.chromium = { enable = true; extensions = [ ... ]; };

    # HM-level user config
    home-manager.users.${config.owner.username} = {
      programs.firefox.profiles.default = { ... };
    };
  };
}
```

HM-only feature:
```nix
# modules/fonts.nix
{ config, ... }: {
  flake.modules.nixos.fonts = { pkgs, ... }: {
    home-manager.users.${config.owner.username} = {
      home.packages = with pkgs; [ nerd-fonts.fira-code ... ];
    };
  };
}
```

NixOS-only feature:
```nix
# modules/hardware/eagle.nix
{
  flake.modules.nixos.eagle-hw = { config, pkgs, ... }: {
    hardware.nvidia = { modesetting.enable = true; ... };
    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
```

Host definition:
```nix
# modules/hosts/eagle.nix
{ config, inputs, ... }: {
  configurations.nixos.eagle.module = {
    imports = with config.flake.modules.nixos; [
      base shells editors terminals browsers
      desktop fonts multimedia containers
      networking version-control cli-utils
      dev-software dev-web dev-electronics dev-mechanical
      writing study-math study-linguistics
      language-machine gui-apps science
      tools-backups tools-secrets tools-research
      eagle-hw
    ];
  };
}
```

---

## Directory Structure (target)

```
modules/
├── infrastructure/              # Dendritic plumbing (one-time setup)
│   ├── flake-parts.nix          # Enables flake.modules system
│   ├── configurations.nix       # Defines how NixOS configs are built
│   ├── home-manager.nix         # Wires HM into NixOS
│   └── meta.nix                 # Owner username, shared constants
│
├── hosts/                       # Per-host definitions
│   └── eagle.nix                # Eagle's group selection + hardware config
│
├── overlays.nix                 # Package overlays (moved from overlays/)
│
├── base.nix                     # Nix settings, locale, boot, user, basic pkgs
├── shells.nix                   # zsh, bash, nushell, fish, starship + NixOS shell setup
├── editors.nix                  # neovim, vscode, emacs, helix, zed
├── terminals.nix                # kitty, foot, warp
├── browsers.nix                 # firefox + chromium (NixOS policies + HM profiles)
├── desktop.nix                  # KDE, pipewire, CUPS, wayland, touchpad
├── fonts.nix                    # Font packages
├── multimedia.nix               # Media tools
├── containers.nix               # docker, podman (NixOS) + distrobox (HM)
├── networking.nix               # nginx, avahi, opensnitch (NixOS) + UI (HM)
├── version-control.nix          # git, lazygit, delta
├── cli-utils.nix                # tmux, sesh, yazi, zoxide, fzf, bat, etc.
├── gui-apps.nix                 # GUI applications
├── science.nix                  # Scientific computing tools
├── dev-software.nix             # General dev tools, languages, runtimes
├── dev-web.nix                  # Web development
├── dev-electronics.nix          # EDA tools
├── dev-mechanical.nix           # CAD tools
├── writing.nix                  # Writing and documentation tools
├── study-math.nix               # Mathematics tools
├── study-linguistics.nix        # Linguistics tools
├── language-machine.nix         # LLM/AI (NixOS ollama + HM tools)
├── tools-backups.nix            # Backup tools
├── tools-secrets.nix            # Secrets management
├── tools-research.nix           # Research tools
│
├── hardware/                    # Hardware-specific (NixOS only)
│   ├── laptop.nix               # General laptop config
│   └── lenovo-thinkpad-p52.nix  # ThinkPad P52 specifics
│
└── nix.nix                      # Nix/home-manager settings (HM side)
```

---

## Flake Changes

### New inputs
```nix
import-tree.url = "github:vic/import-tree";
```

### Outputs rewrite
```nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];

    imports = [ (inputs.import-tree ./modules) ];

    # perSystem stays the same (formatter, apps)
  };
```

Note: `flake-parts.flakeModules.modules` is imported inside `modules/infrastructure/flake-parts.nix`, not in flake.nix.
The `import-tree` call auto-imports all `.nix` files under `modules/`, which includes the infrastructure files.

### Removed from flake.nix
- `flake.nixosConfigurations` block (moved to modules/hosts/eagle.nix + modules/infrastructure/configurations.nix)
- `flake.homeConfigurations` block (HM now integrated into NixOS)
- `imports = [ ./overlays ]` (moved to modules/overlays.nix)

---

## Feature-to-Module Mapping

| Current file | → Dendritic module | Group name | Cross-cutting? |
|---|---|---|---|
| `home/hatim/mod.shells.nix` + `configuration.nix` shell setup | `modules/shells.nix` | `shells` | Yes (NixOS default shell + HM shell configs) |
| `home/hatim/mod.editors.nix` | `modules/editors.nix` | `editors` | No (HM only) |
| `home/hatim/mod.cli-utils.nix` | `modules/cli-utils.nix` | `cli-utils` | No (HM only) |
| `home/hatim/mod.version-control.nix` | `modules/version-control.nix` | `version-control` | No (HM only) |
| `home/hatim/mod.apps.web-browsers.nix` + `hosts/mod.apps.web-browsers.nix` | `modules/browsers.nix` | `browsers` | **Yes** |
| `home/hatim/mod.containers.nix` + `hosts/mod.containers.nix` | `modules/containers.nix` | `containers` | **Yes** |
| `home/hatim/mod.networking.nix` + `hosts/mod.os.networking.nix` | `modules/networking.nix` | `networking` | **Yes** |
| `home/hatim/mod.dsdv.software.nix` + `hosts/mod.dsdv.software.nix` | `modules/dev-software.nix` | `dev-software` | **Yes** |
| `home/hatim/mod.language-machine.nix` + `hosts/mod.language-models.nix` | `modules/language-machine.nix` | `language-machine` | **Yes** |
| `home/hatim/mod.desktop-wayland.nix` + `configuration.nix` KDE/pipewire | `modules/desktop.nix` | `desktop` | **Yes** |
| `home/hatim/mod.terminals.nix` | `modules/terminals.nix` | `terminals` | No |
| `home/hatim/mod.fonts.nix` | `modules/fonts.nix` | `fonts` | No |
| `home/hatim/mod.multimedia.nix` | `modules/multimedia.nix` | `multimedia` | No |
| `home/hatim/mod.apps.gui.nix` | `modules/gui-apps.nix` | `gui-apps` | No |
| `home/hatim/mod.apps.science.nix` | `modules/science.nix` | `science` | No |
| `home/hatim/mod.dsdv.web.nix` | `modules/dev-web.nix` | `dev-web` | No |
| `home/hatim/mod.dsdv.electronics.nix` | `modules/dev-electronics.nix` | `dev-electronics` | No |
| `home/hatim/mod.dsdv.mechanical.nix` | `modules/dev-mechanical.nix` | `dev-mechanical` | No |
| `home/hatim/mod.writing.nix` | `modules/writing.nix` | `writing` | No |
| `home/hatim/mod.study.mathematics.nix` | `modules/study-math.nix` | `study-math` | No |
| `home/hatim/mod.study.linguistics.nix` | `modules/study-linguistics.nix` | `study-linguistics` | No |
| `home/hatim/mod.tools.backups.nix` | `modules/tools-backups.nix` | `tools-backups` | No |
| `home/hatim/mod.tools.secrets.nix` | `modules/tools-secrets.nix` | `tools-secrets` | No |
| `home/hatim/mod.tools.research.nix` | `modules/tools-research.nix` | `tools-research` | No |
| `home/hatim/mod.nix.nix` | `modules/nix.nix` | (part of `base`) | No |
| `hosts/mod.hw.laptop.nix` | `modules/hardware/laptop.nix` | `eagle-hw` | No (NixOS only) |
| `hosts/mod.hw.lenovo-thinkpad-p52.nix` | `modules/hardware/lenovo-thinkpad-p52.nix` | `eagle-hw` | No (NixOS only) |
| `hosts/mod.guest-systems.nix` | `modules/base.nix` or standalone | `base` or `guest-systems` | No (NixOS only) |
| `hosts/mod.input-devices.nix` | `modules/desktop.nix` | `desktop` | No (NixOS only) |
| `hosts/mod.package-management.nix` | `modules/base.nix` | `base` | No (NixOS only) |

---

## Migration Phases

### Phase 0: Infrastructure (blocks everything else)
Set up the dendritic plumbing. Nothing migrates yet — just verify the infrastructure builds.

1. Add `import-tree` to flake inputs
2. Create `modules/infrastructure/flake-parts.nix` — import `flakeModules.modules`
3. Create `modules/infrastructure/meta.nix` — define `owner.username`, `owner.fullName`
4. Create `modules/infrastructure/configurations.nix` — define `configurations.nixos` option, build `nixosConfigurations` from collected modules
5. Create `modules/infrastructure/home-manager.nix` — wire `home-manager.nixosModules.home-manager` into the `base` group
6. Move overlays into `modules/overlays.nix`
7. Create `modules/hosts/eagle.nix` — minimal host definition that imports `base` only
8. Create `modules/base.nix` — minimal base config (just enough to boot: nix settings, locale, boot, user)
9. Rewrite `flake.nix` outputs to use dendritic wiring
10. Verify: `nix build .#nixosConfigurations.eagle.config.system.build.toplevel` succeeds

### Phase 1: Migrate one cross-cutting feature
Prove the pattern works end-to-end with a real feature.

1. Pick `containers` (small, clear cross-cutting: NixOS docker/podman + HM distrobox)
2. Create `modules/containers.nix` with both NixOS and HM config
3. Add `containers` to eagle's group list
4. Remove from old config
5. Verify: `just switch` works, docker/podman/distrobox functional

### Phase 2: Migrate remaining features
Work through all modules systematically. Each migration:
1. Create dendritic module
2. Add group to eagle's imports
3. Remove old mod.*.nix
4. Verify build

Order: cross-cutting features first (browsers, networking, shells, desktop, dev-software, language-machine), then HM-only features (editors, cli-utils, etc.), then tiny modules last.

### Phase 3: Clean up
1. Delete all `home/hatim/mod.*.nix` files
2. Delete all `hosts/mod.*.nix` files
3. Delete `home/hatim/host.eagle.hatim.nix`
4. Delete old `modules/home/` and `modules/os/` directories (the hatim.modules.* approach)
5. Delete `overlays/default.nix` (moved to modules/overlays.nix)
6. Update `justfile` (remove `home:` target, simplify `switch:`)
7. Delete `BEFORE_AND_AFTER.md`
8. Update `CLAUDE.md` with dendritic conventions
9. Run `nix fmt`

---

## What to preserve

- `hosts/eagle/hardware-configuration.nix` — keep as-is, imported by eagle's base config
- `home/hatim/file.vscode-settings.json` — keep, referenced by editors module
- `home/hatim/TMUX_KEYBINDINGS.md` — keep as reference doc
- `templates/` — keep, unrelated
- `pkgs/` — keep, unrelated
- `scratch/` — keep, unrelated

---

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Infrastructure wiring is wrong, nothing builds | Phase 0 is minimal — just base. Debug before migrating features. |
| HM integration changes `just home` workflow | Accept this — user chose integrated. `just switch` replaces both commands. |
| `import-tree` auto-imports something unexpected | Only `.nix` files under `modules/`. Keep non-module files elsewhere. |
| `nh` tool can't find new config structure | `nh os switch .` uses `nixosConfigurations.<hostname>` — same flake output name. Should work. |
| Deferred module errors are hard to debug | Migrate one feature at a time. Verify build after each. |
| `extraSpecialArgs` no longer works for HM | In integrated HM, use `home-manager.extraSpecialArgs` within NixOS config, or use flake-parts top-level config. |
| External HM modules (emx, nvf, betterfox, nix-index) | Wire these into the home-manager base module imports. |

---

## Reference Source Code

Cloned to `/tmp/` for the implementing agent to read:

### Dendritic annotated example (`/tmp/dendritic/example/`)
- `flake.nix` — minimal: just inputs + `(inputs.import-tree ./modules)`
- `modules/flake-parts.nix` — one-liner: `imports = [ inputs.flake-parts.flakeModules.modules ]`
- `modules/nixos.nix` — defines `configurations.nixos` option with `deferredModule`, builds `nixosConfigurations`
- `modules/meta.nix` — defines `options.username` top-level option
- `modules/shell.nix` — cross-cutting example: `flake.modules.nixos.pc` + `flake.modules.nixOnDroid.base`
- `modules/desktop.nix` — host definition: picks groups with `imports = with nixos; [ admin shell ]`

### Real dendritic config (`/tmp/dendritic-infra/modules/`)
- `flake-parts.nix` — same one-liner
- `configurations/nixos.nix` — same as example but with checks
- `owner.nix` — defines owner under `flake.meta.owner` + creates user in `nixos.base`
- `meta-output.nix` — defines `options.flake.meta` (type: anything)
- `home-manager/base.nix` — sets `home.username`, `home.homeDirectory`, `programs.home-manager.enable`
- `home-manager/nixos.nix` — **KEY FILE**: wires HM into NixOS. `nixos.base` imports `home-manager.nixosModules.home-manager`, sets `useGlobalPkgs`, imports `homeManager.base` for the owner user. `nixos.pc` imports `homeManager.gui`.
- `ganoderma/imports.nix` — host picks groups: `[ efi nvidia-gpu pc swap wife ]`
- `audio/pipewire.nix` — cross-cutting: `nixos.pc` sets `services.pipewire`, `homeManager.gui` adds GUI tools
- `clipboard.nix` — HM-only but via `homeManager.gui` group
- `bluetooth.nix` — NixOS-only via `nixos.pc` group

### import-tree (`/tmp/import-tree/default.nix`)
- Auto-discovers `.nix` files recursively, ignores files starting with `_`

### Key patterns for implementation

**Owner username access in feature modules:**
The outer function is a flake-parts module (`config` = flake-parts config).
The inner function is a deferred NixOS module (`config`/`pkgs` = NixOS args).
```nix
# Outer config has owner.username; inner gets NixOS args
{ config, ... }: {                           # flake-parts module
  flake.modules.nixos.myfeature = { pkgs, ... }: {  # deferred NixOS module
    home-manager.users.${config.owner.username} = {  # references outer config
      home.packages = [ pkgs.something ];
    };
  };
}
```

**HM wiring (from home-manager/nixos.nix):**
The `base` NixOS group must import `inputs.home-manager.nixosModules.home-manager`.
All other groups can then freely set `home-manager.users.${username}.*`.
External HM modules (emx, nvf, betterfox, nix-index) go into `home-manager.users.${username}.imports`.

**Per-feature groups (our approach) vs shared groups (mightyiam's approach):**
mightyiam uses few groups (`pc`, `base`) — many files contribute to the same group.
We use per-feature groups — each file defines its own group name.
Both are valid dendritic. Per-feature gives hosts finer control.

---

## Verification

After each phase:
1. `nix flake check` — no evaluation errors
2. `nix build .#nixosConfigurations.eagle.config.system.build.toplevel` — system builds
3. `just switch` — applies successfully
4. Functional test: programs launch, shells work, browser extensions present

After full migration:
5. `nix fmt` — all files formatted
6. No old `mod.*.nix` files remain
7. Adding a new host requires only one file in `modules/hosts/`
