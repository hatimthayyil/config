# Niks3 deployment — 2026-07-14 / 2026-07-15

Deployed [niks3](https://github.com/Mic92/niks3) (S3-backed Nix binary cache
with GC) to Cloudflare, serving `https://cache.thayyil.net`, and wired this
NixOS config up to use it as both a client (substituter) and operator
(`niks3` CLI on PATH).

## Architecture

- Cloudflare Worker (`infra/niks3/src/index.js`) fronts a Cloudflare
  Container running the niks3 server (Durable Object-backed, single
  instance, `getByName("primary")`).
- Reads bypass the Worker entirely: Nix clients fetch NAR/narinfo directly
  from the public R2 custom domain (`cache.thayyil.net`).
- Writes (`niks3 push`, GC) go through the Worker to the container.
- Secrets synced via `secretspec` → Cloudflare Worker Secrets
  (`infra/niks3/scripts/sync-secrets`).

## Bug: container startup failing with an HTTPS rejection

Deployment initially failed at container startup with:

> Connecting to a container using HTTPS is not currently supported; use
> HTTP instead.

Root cause: `@cloudflare/containers`' default `pingEndpoint` ("ping") probes
bare `/`. Niks3's root route (`RootRedirectHandler`) 301-redirects `/` to
the external HTTPS cache URL when read-proxying is disabled — the
readiness check then tried to follow that HTTPS redirect over the
container-only transport, which workerd rejects outright.

Fixed by pointing the ping at niks3's real unconditional-200 `/health`
route instead: `pingEndpoint = "localhost/health"` (the documented
`"host/path"` format, confirmed via Cloudflare's official docs and the
`containers-template` example — the canonical pattern never overrides
`Container.fetch()`, which a few dead-end attempts during debugging
mistakenly did before this was found).

## Nix-side integration

- `flake.nix`: added `niks3` as a flake input, tracking upstream `main`
  (not pinned to a release tag — the flake's own CI keeps `vendorHash`
  current via an `update-vendor-hash` workflow, so tracking main is safe).
- `modules/nix.nix`: added the `niks3` CLI (`inputs.niks3.packages.<system>.niks3`)
  to `home.packages`, alongside `cachix`/`attic-client`.
- `modules/base.nix`: added `cache.thayyil.net` as a trusted substituter
  (`cache.thayyil.net:OCyxFK7dzZQPwvpWU0SPSqjH9cpxTfREy/dIJSLRClM=`), and
  `cache.thalheim.io` (Mic92's personal cache, which niks3's own CI
  publishes builds to) so the CLI substitutes instead of building from
  source — the first from-source build hit a build-sandbox DNS flakiness
  issue fetching Go module dependencies; the cache sidesteps it entirely
  and is the same cache niks3 upstream already trusts in its own CI.

## Version: v1.6.0 → v1.7.0

Bumped `infra/niks3/Dockerfile`'s pinned server version to match the
niks3 CLI (which tracks latest). Verified before bumping:
- No new required environment variables between the two tags.
- Migrations apply automatically on server startup (`goose.Up(db,
  "migrations")` in `server/pg/pg.go`), so the new `pins` table needed
  no manual DB step.

This was necessary because the CLI's `pins` subcommand didn't exist in
v1.6.0 (`server/pins.go` was added after that tag) — running it against
the old server returned a 404. `push`/`gc` predate v1.6.0 and worked on
either version.

## Verified end-to-end

- `GET /` and `GET /health` through the Worker → Container.
- Read path: `nix store info --store https://cache.thayyil.net`,
  `nix-cache-info`, `nix path-info` for a real store path.
- Write path: `niks3 push` uploaded a real closure (`hello` + its
  runtime deps, 5 paths); confirmed readable back via `nix path-info`
  immediately after.
- `niks3 pins list` against the upgraded (v1.7.0) server.

## Deliberately not done: scheduled GC

Niks3's GC (`DELETE /api/closures`, polled via `GET /api/gc/status`) is
triggered manually — see `infra/niks3/README.md`. Not automated because:
1. Retention policy is a decision that hasn't been made yet.
2. The container's `sleepAfter` activity timeout is driven purely by
   inbound Worker requests, not by what the container process is doing
   internally (confirmed by reading `@cloudflare/containers`' source).
   A fire-and-forget scheduled trigger risks the container being stopped
   mid-GC on a large cache, since GC "can run from seconds to over an
   hour" per niks3's own metrics. The `niks3 gc` CLI avoids this by
   polling every 2s — each poll is a Worker request that resets the idle
   timer. A Cloudflare Worker Cron Trigger could replicate that
   poll-until-done loop (`scheduled()` + `ctx.waitUntil()`) instead of an
   external poller (e.g. a systemd timer running the CLI) — mechanism to
   be decided later.

## Known follow-ups

- No `nixos-rebuild switch`/build-verification loop is wired into CI —
  the substituter and CLI changes were verified locally
  (`nix build .#nixosConfigurations.eagle.config.system.build.toplevel`)
  before switching.
