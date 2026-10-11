# Dormant tools and package sets

Author: @agent (Claude Opus 5.5, `claude-opus-5-5`)
Date: 2026-10-11

For: a config that holds many rarely used programs. Need: a tool researched once stays ready to use, with no re-research when it comes back into use. Most work happens in per-project devenv environments.

Checked against: this repo at 842bcb1, devenv source 34a93eec (`devenv-core/src/config.rs`, `devenv-nix-backend/bootstrap/bootstrapLib.nix`, docs), home-manager 17903129f, and the 66 `devenv.yaml` projects under `/hatimthayyil/code`.

## Changelog

- 2026-10-11: first version.
- 2026-10-11: sets and templates live in github.com/hatimthayyil/dev (`envs/<name>`, imported as `dev/envs/<name>`), not in this repo. devenv 2.4 has a user config (`~/.config/devenv/config.yaml`), but it covers only the TUI.

## Local facts

- The dendritic layout already gives a toggle per feature: each `modules/<feature>.nix` defines `flake.modules.nixos.<group>`, and `modules/hosts/eagle.nix` chooses the groups. The host's group list works as the profile.
- Groups are coarse. `dev-software.nix` puts about 50 packages in `home.packages`. These include language toolchains (rustup, clang, conda, bend) and C libraries for desktop app builds (gtk3, webkitgtk, pango, pkg-config, openssl).
- Those libraries do nothing in `home.packages`. Home Manager does not export `PKG_CONFIG_PATH` or the library paths that a build needs. Projects declare the same libraries again: of 39 Rust devenvs, 14 use `pkgs.xorg`, and gtk3, wayland, vulkan-loader, libxkbcommon and fontconfig each appear 4 to 5 times.
- `templates/` already contains devenv templates (python, python-uv, js-npm, dioxus, sagemath). A template copies its files once, so later improvements never reach projects created from it.
- No project imports shared devenv config yet. comma with nix-index-database is enabled (`modules/nix.nix`).

## What the tools support

**devenv imports from inputs.** `imports: [ name/sub/path ]` resolves to `inputs.name + "/sub/path"` and loads that directory's `devenv.nix`, plus its `devenv.yaml` if one exists (`bootstrapLib.nix` `importModule`). Inputs can be `path:`, `github:` or `git+file:`, with `flake: false`. Since 2.2, changes to files in a `path:` input are picked up without clearing `.devenv`. Local imports (`./`, `../`, `/`) must stay inside the project's git root (`validate_within_root`), so cross-repo sharing has to go through an input.

**devenv has no user-level config.** Nothing reads `~/.config/devenv`; XDG is used only for data and runtime paths. Shared config has to be imported explicitly by each project.

**devenv profiles** (`profiles.<name>.module`, `--profile`, `extends`) apply automatically by `hostname.<h>` and `user.<u>`. A shared module can therefore carry `profiles.user.hatim` extras that apply only to you, and stay inert for collaborators.

**devenv options modules.** A shared module can declare `options.<ns>.<set>.enable` and gate its config behind `mkIf` (`docs/src/extending.md`). Each project then turns sets on in one line.

**Home Manager.** `programs.<x>.enable = false` keeps a program's settings but installs nothing. `specialisation` exists but is marked experimental, needs a manual activation script, and creates a new generation per switch. It is not a practical profile mechanism.

## Patterns

### 1. Three tiers, by where a tool is used

| Tier | Contents | Lives in |
|---|---|---|
| Always on | Shell, editor, desktop, the apps used daily | HM groups selected by the host |
| Dormant | Researched GUI apps and system services not currently used | HM groups not selected by the host, still evaluated (pattern 2) |
| Project tooling | Toolchains, language servers, build libraries, project CLIs | devenv modules in this repo, imported by projects (pattern 3) |

Anything a build needs (compilers, `-dev` libraries, pkg-config) belongs to project tooling, never to `home.packages`.

### 2. Dormant groups that cannot rot

Taking a group out of `eagle.nix` disables it today. The risk is rot: an unselected module is never evaluated, so renamed options and removed packages go unnoticed until the day it is needed. The fix is a second configuration that selects every group and is only evaluated, never built:

- `configurations.nixos.catalogue` imports eagle's module plus every group in `config.flake.modules.nixos`.
- A flake check evaluates `catalogue.config.system.build.toplevel.drvPath`. This is pure evaluation: CI catches breakage in seconds, with no builds.
- The host list holds only the groups in use. Reactivating a tool means adding one line to the host list.

For finer control, split coarse files rather than adding a custom `features.*.enable` layer, since the host list already does that job. `dev-software.nix` would split into its HM parts (gh, direnv, devenv, CLIs) and move the toolchains and libraries to tier 3.

### 3. Package sets as devenv modules in this repo

Each set is a directory holding a plain `devenv.nix`:

```
devenv/
  rust/devenv.nix          languages.rust, cargo-nextest, bacon, watchexec
  rust-gui/devenv.nix      wayland, vulkan-loader, libxkbcommon, fontconfig, LD_LIBRARY_PATH
  tauri/devenv.nix         gtk3, webkitgtk_4_1, libsoup_3, pkg-config, openssl
  python-cuda/devenv.nix   uv, /run/opengl-driver library path
  sci/devenv.nix           ...
```

A project uses them like this:

```yaml
inputs:
  config:
    url: path:/hatimthayyil/code/config   # or github:hatimthayyil/config for shared repos
    flake: false
imports:
  - config/devenv/rust
  - config/devenv/rust-gui
```

- The modules are functions of `pkgs`, so they build against the project's own pinned nixpkgs and lock. Exporting derivations from this flake instead would pull this flake's nixpkgs into every project.
- A fix to a set reaches every importing project, which templates cannot do. Templates stay for scaffolding a new project, and they import the sets instead of copying their contents.
- `path:` is local-only. A project that is shared or built in CI uses `github:hatimthayyil/config` with a locked rev.
- Personal-only extras inside a set go under `profiles.user.hatim.module`.

### 4. One-off use without installing

`, <program>` (comma) already runs any nixpkgs program without installing it. For a tool that needs no configuration, this replaces a dormant entry.

## Recommendation

1. Add the `catalogue` evaluation check first. It is small, it guards everything that follows, and it makes removing groups from the host safe.
2. Create `devenv/<set>/devenv.nix` for the sets that already repeat across projects (rust, rust-gui, python-cuda). Move the toolchains and build libraries out of `dev-software.nix` into them.
3. Trim `eagle.nix` to the groups in use, splitting coarse files where a group mixes active and dormant tools.
4. Point `templates/` at the sets.

Not recommended: Home Manager specialisations as profiles (experimental, manual activation); a custom `features.*.enable` option layer on top of the host list (duplicates it); exporting package sets as flake derivations for devenv (couples every project to this flake's nixpkgs).
