# nixbuild.net remote builder auth

## Problem

`eu.nixbuild.net` distributed builds were falling back to local
builds. `nix.conf`, `/etc/nix/machines`, and SSH host-key trust were
correct. No valid SSH key was present for authentication, so
`ssh eu.nixbuild.net shell` returned `Permission denied (publickey)`.
An unreachable remote builder fails silently (falls back to local
build), so `just build` gave no error signal.

## Fix

- **Eagle:** `modules/ssh.nix` uses `/etc/ssh/ssh_host_ed25519_key` as
  the `eu.nixbuild.net` identity (home-manager `programs.ssh` block
  and system `programs.ssh.extraConfig` block). Root/nix-daemon
  already reads this file for sops-nix age-key derivation
  (`modules/secrets.nix`). Key registered on the nixbuild.net account
  via `ssh eu.nixbuild.net shell` -> `keys add`.
- **CI:** `nixbuild-action` added to `.github/actions/setup-nix`,
  authenticated via `NIXBUILD_TOKEN` (nixbuild.net auth token) as a
  GitHub Actions secret, passed through explicitly in `build.yml` and
  `update-flake.yml`.

## Verified

- `ssh -F /etc/ssh/ssh_config eu.nixbuild.net shell` succeeds as root
  after switch.
- `nix build .#nixosConfigurations.eagle.config.system.build.toplevel`
  builds clean.

## Not yet verified

CI path (`NIXBUILD_TOKEN` -> `nixbuild-action`) not exercised by an
actual workflow run.
