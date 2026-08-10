# Eagle substitutes from nixbuild

## Problem

Eagle downloaded 2.0 GB of CUDA 12.9 as build inputs for `nvtop`, a status
monitor that keeps no CUDA at runtime (its runtime closure is glibc,
systemd-minimal-libs, libdrm, ncurses). All 57 paths were substituted, not
built — 38 signed by nix-community.cachix.org, 19 by cache.thayyil.net.

The chain: `nvtopPackages.full` needs CUDA headers, so it takes nixpkgs' default
`cudaPackages` (12.9, unrelated to the 12.6 pinned in `modules/cuda.nix` for
Pascal). Hydra does not build the CUDA variant because CUDA is unfree, so nvtop
is 404 on cache.nixos.org and has to be built. To schedule that build on
nixbuild, Nix must first realise the input closure locally — nixbuild documents
this as "Build dependencies are fetched locally", inputs are *always* fetched
before Nix interacts with a builder.

CI did not help. Since 2026-08-06 `update-flake.yml` runs verify-only with
`niks3-skip-push`, so a green run publishes nothing eagle can consume.

## Measured: builders-use-substitutes does not fix it

Probe: a unique trivial derivation depending on
`cudaPackages_12_9.cuda_cupti.lib` (42 MB, on cache.thayyil.net), input deleted
before each run, `--max-jobs 0` to force remote scheduling.

| | `false` | `true` |
|---|---|---|
| fetched to eagle | 42 MB | 42 MB |
| uploaded to nixbuild | 0 paths | 0 paths |
| remote build | 667 ms | 661 ms |

Identical. The setting has one call site (`build-remote.cc:303`) and only
decides whether the builder may substitute what would otherwise be uploaded to
it; `derivation-goal.cc:97` has already substituted the inputs locally by then.
Uploads were 0 both times because nixbuild already had the input — eagle
downloaded 42 MB to hand over nothing.

It is also inert in CI, twice over: both workflows pass `--builders ""` with
`--store ssh-ng://`, so `build-remote.cc` never runs, and remote stores already
have the property ("Build dependencies are not copied from the local store").

## Change

- `modules/infrastructure/caches.nix` is now a registry: one entry per cache
  pairing url with key, a `select` helper, and `public` for the shared set.
  `flake.lib.caches` still exposes `public`, so CI and
  `just nixbuild-sync-caches` are untouched.
- `modules/nixbuild.nix` (new group) owns `distributedBuilds`, `buildMachines`
  — moved out of `base.nix`, where one host's builder leaked into every host —
  and selects `registry.nixbuild` as a substituter. `nix.settings.substituters`
  is `types.listOf types.str` (nixpkgs `nixos/modules/config/nix.nix:243`) so it
  concatenates with the public list rather than replacing it.
- `modules/hosts/eagle.nix` adds the `nixbuild` group and sets
  `services.niks3-auto-upload.serverUrl`.
- `modules/niks3-auto-upload.nix` keeps no cache identity, and pushes the
  activated system closure: an activation snippet writes `$systemConfig` to
  `/run/niks3-push-target` and starts a oneshot, with a daily timer as backstop.

## Verified

- `nix eval --json .#lib.caches` byte-identical to the committed tree.
- Eagle's substituters differ from the committed tree by exactly one line:
  `+ ssh://eu.nixbuild.net`. `buildMachines` unchanged after the move.
- Dry-run of the current pin, with and without the nixbuild substituter:

  | | baseline | nixbuild @ 0 | nixbuild @ 100 |
  |---|---|---|---|
  | derivations built | 155 | 59 | 52 |
  | download | 6.3 GiB | unreported | 6.1 GiB |
  | cuda12.9 paths fetched | 6 | 0 | 0 |
  | dry-run wall time | 7 s | 115 s | — |

  `nvtop` moves from the build list to the fetch list.

## Trap: ssh substituters outrank everything by default

The first real build streamed the whole closure from nixbuild — 22.0 GiB of
uncompressed NAR with the HTTP download counter stuck at 25.6 KiB. nixbuild is
SSH-only, so it serves no `nix-cache-info`, so `priority` stays at its default
of 0 (`store-api.hh:293`) and beats cache.nixos.org (40) and cache.thayyil.net
(30). Fixed with `?priority=100` on the store URL.
- `nix fmt` clean; activation snippet and push script render as intended.

## Open items

- The dry-run went from 7 s to 115 s. An `ssh://` substituter costs an SSH
  round-trip per path query, so some of the download saving is paid back as
  latency on every evaluation, not just the first. Worth measuring on a warm
  run before deciding it is acceptable.
- cache.thayyil.net's contents get narrower: the system runtime closure plus
  local builds, instead of the previous incidental sweep. The 19 cuda12.9 paths
  it currently serves will age out.
- cache.thayyil.net is anonymously readable, and the config repo is public, so
  store paths are derivable. niks3 can gate reads behind mTLS
  (`--mtls-bound-subject-read`, `--enable-read-proxy` for a private bucket) and
  Nix supports `tls-certificate` / `tls-private-key` per substituter. Not done.
- Still open from 2026-07-19: nixbuild support on ssh-ng substitution, and
  `git remote set-url` for the repo move.
