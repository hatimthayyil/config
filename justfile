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
    nix flake update emx-local && just home && emacs
