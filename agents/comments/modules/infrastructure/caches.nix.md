# caches.nix

## Why ssh://eu.nixbuild.net is not a substituter

nixbuild.net is configured as a remote *builder* only
(`modules/base.nix`, `nix.buildMachines`). It must stay that way.

Nix treats remote builders and substituters differently, and
`services.niks3-auto-upload` is a `nix.settings.post-build-hook`, which
fires on builds and not on substitutions.

- As a builder: eagle sends the derivation, nixbuild serves back a
  result it already has without rerunning the build, and Nix fetches it
  into the local store as a completed build. The post-build-hook fires,
  and niks3 pushes the path to cache.thayyil.net.
- As a substituter: Nix finds the path during the substitution phase and
  downloads it directly. No build happens, the hook never fires, and the
  path never reaches cache.thayyil.net.

nixbuild's own documentation recommends adding remote builders as
substituters, to avoid fetching build inputs that are only needed
remotely. That advice is correct in general and wrong here — taking it
would silently stop cache.thayyil.net from being filled, with no error
to notice. The wasted input bandwidth is the accepted cost.

See `agents/log/2026-08-06---ci-verify-only-cache-on-eagle.md`.
