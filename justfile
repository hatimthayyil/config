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

emx:
    nh os switch . -- --override-input emx path:$HOME/src/emx && emx

# Show packages that would be rebuilt for system configuration (with nix-community cache)
forecast:
    nix-forecast -c ".#nixosConfigurations.eagle" -b https://cache.nixos.org -b https://nix-community.cachix.org -s | grep -v "\.service\|\.conf\|\.pub\|\.rules\|\.d\|\.sh\|\.pam\|\.json"
