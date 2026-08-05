# update-flake.yml

## Why the build is verify-only

The job updates `flake.lock`, verifies the eagle closure builds, and
commits only if it does. It no longer fills cache.thayyil.net.

The build uses the same remote-store flags as `build.yml`, so the
closure is never copied to the runner. `niks3-skip-push: true` follows
from that: nothing lands in the runner store, so the post-build-hook has
nothing to push.

Cache filling moved to eagle, which runs `services.niks3-auto-upload`
and pushes exactly the paths it realises. See
`agents/comments/modules/infrastructure/caches.nix.md` for why that
depends on nixbuild staying a builder rather than a substituter.

## Why not push from CI

The previous local-store `nix build` had to copy the whole 54.9 GiB
system closure to the runner so niks3 could read NAR bytes off the
filesystem. That failed nightly from 2026-07-18: an SSH connection to
nixbuild would drop mid-stream (`error: unexpected end-of-file`), Nix
marked whichever derivation was in flight as failed, and the job died.
The failing derivation was arbitrary each run, and the last successful
run copied more paths than the failures — so it was transient
connection loss, not a size or disk ceiling.

Two alternatives were rejected:

- Patching the niks3 client for `--store ssh-ng://`. It would still pull
  every NAR byte over the same SSH channel, so the fragility is
  unchanged. It also needs a streaming NAR parser, since niks3 generates
  the `.ls` listing during the filesystem walk that produces the NAR and
  ships a NAR writer but no reader.
- nixbuild's `caches` setting, which uploads closures straight to S3
  server-side. It writes objects niks3's Postgres never learns about,
  and niks3's GC is DB-driven with no S3 listing sweep, so those objects
  would leak permanently.

A failed verification now just means the lock is not committed that
night, which is a safe failure mode and needs no retry.
