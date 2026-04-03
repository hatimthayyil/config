build:
    nh os build .

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
    nh os switch . -- --override-input emx path:$HOME/src/emx && emx

# Show packages that would be rebuilt for system configuration (with nix-community cache)
forecast:
    nix-forecast -c ".#nixosConfigurations.eagle" -b https://cache.nixos.org -b https://nix-community.cachix.org -s | grep -v "\.service\|\.conf\|\.pub\|\.rules\|\.d\|\.sh\|\.pam\|\.json"
