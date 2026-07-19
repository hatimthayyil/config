build:
    nh os build . -kK

switch:
    nh os switch .

clean:
    nh clean all

update:
    nix flake update

upgrade:
    just update && just build && just switch

# Rollback to previous generation, or a specific one: just rollback 42
rollback gen="":
    #!/usr/bin/env bash
    if [ -z "{{gen}}" ]; then
        sudo nixos-rebuild switch --rollback
    else
        sudo nix-env --profile /nix/var/nix/profiles/system --switch-generation "{{gen}}" && sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
    fi

# List available NixOS generations
generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

emx:
    nh os switch . -- --override-input emx path:$HOME/code/emx && emx

# Sync nixbuild.net account substituters from the flake (modules/infrastructure/caches.nix).
# Account level is required: ssh-env settings are ignored for ssh-ng remote-store builds.
nixbuild-sync-caches:
    #!/usr/bin/env bash
    set -euo pipefail
    ssh() { sudo ssh -i /etc/ssh/ssh_host_ed25519_key -o IdentitiesOnly=yes hatim@eu.nixbuild.net "$@"; }
    caches="$(nix eval --json .#lib.caches)"
    current_subs="$(ssh api settings substituters --show | jq -r '.substituters[]')"
    for s in $(jq -r '.substituters[]' <<< "$caches"); do
        grep -qxF "$s" <<< "$current_subs" || ssh api settings substituters --add "$s" > /dev/null
    done
    current_keys="$(ssh api settings trusted-public-keys --show | jq -r '.trustedPublicKeys[]')"
    for k in $(jq -r '."trusted-public-keys"[]' <<< "$caches"); do
        grep -qxF "$k" <<< "$current_keys" || ssh api settings trusted-public-keys --add "$k" > /dev/null
    done
    ssh api settings substituters --show
    ssh api settings trusted-public-keys --show

# Show packages that would be rebuilt for system configuration (with nix-community cache)
forecast:
    nix-forecast -c ".#nixosConfigurations.eagle" -b https://cache.nixos.org -b https://nix-community.cachix.org -s | grep -v "\.service\|\.conf\|\.pub\|\.rules\|\.d\|\.sh\|\.pam\|\.json"
