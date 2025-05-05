build:
    nh os build . && nh home build .

switch:
    nh os switch . && nh home switch .

clean:
    nh clean all

os:
    nh os switch .

home:
    nh home switch .

update:
    nix flake update

upgrade:
    just update && just build && just switch

emx:
    nh home switch . -- --override-input emx path:$HOME/src/emx && emx

# Show packages that would be rebuilt for system configuration (with nix-community cache)
forecast-os:
    nix-forecast -c ".#nixosConfigurations.eagle" -b https://cache.nixos.org -b https://nix-community.cachix.org -s | grep -v "\.service\|\.conf\|\.pub\|\.rules\|\.d\|\.sh\|\.pam\|\.json"

# Show packages that would be rebuilt for home configuration (with nix-community cache)
forecast-home:
    nix-forecast -o ".#homeConfigurations.\"hatim@eagle\"" -b https://cache.nixos.org -b https://nix-community.cachix.org -s | grep -v "\.desktop\|\.gz\|\.sh\|.json\|\.nu\|\.zsh\|\.zshenv\|\.fish\|\.conf\|\.keep\|\.zip\|\.toml\|\.yml\|\.bash\|\.el"

# Show packages that would be rebuilt (checking both nixos and nix-community caches)
forecast:
    just forecast-os && just forecast-home
