# nixbuild.nix

## Why the builder and the substituter live together

A host that sends builds to nixbuild should also substitute from it, and a host
that does neither should have neither. Keeping `buildMachines` and the
substituter in one group makes that impossible to get half-right. They were
split before: `buildMachines` sat in `base.nix`, so every host importing base
inherited one host's remote builder.

`nix.settings.substituters` is `types.listOf types.str` (nixpkgs
`nixos/modules/config/nix.nix:243`), so list options concatenate across modules.
This group appends to the public list base sets; neither has to know about the
other.

## Why substituting from nixbuild is now correct

It used to be forbidden. Nix does not consult remote *builders* during
substitution, so a build was always scheduled, and nixbuild served the result
back as a completed build — which fired the niks3 post-build-hook and filled
cache.thayyil.net. Substituting instead would skip the hook silently.

That reasoning was sound but the cost was hidden: to schedule a remote build,
Nix must first realise the derivation's entire input closure locally. nixbuild
documents this ("Build dependencies are fetched locally" — inputs are *always*
fetched before Nix interacts with a builder). Eagle was downloading gigabytes of
build-only inputs it never needed, purely to hand them to a builder that already
had the result. Measured on 2026-08-08: 2.0 GB of CUDA 12.9 fetched as build
inputs for nvtop, which keeps no CUDA at runtime.

## Why the substituter carries an explicit priority

nixbuild exposes no HTTP endpoint — access is SSH-only — so there is no
`nix-cache-info` to advertise a `Priority`, and the store falls back to the
`priority` default of 0 (`store-api.hh:293`). Lower wins, so it outranks
cache.nixos.org (40) and cache.thayyil.net (30) and ends up serving the entire
closure. That is the worst case on two counts: `ssh://` streams uncompressed
NAR, while the HTTP caches serve it compressed.

Observed before the fix: 22.0 GiB moving over SSH with the HTTP download counter
at 25.6 KiB. With `?priority=100` the HTTP caches serve the bulk again (6.1 GiB
compressed) and nixbuild only supplies what would otherwise be built.

Client-side query params are the only lever here, and `priority` is a real store
setting — an unrecognised one warns ("unknown setting").

`builders-use-substitutes` does not fix this. It has one call site
(`build-remote.cc:303`) and only controls whether the builder may substitute
what would otherwise be uploaded to it. Measured: identical local downloads with
it on and off.

Cache filling moved to an explicit push of the system closure instead — see
`agents/comments/modules/niks3-auto-upload.nix.md`.
