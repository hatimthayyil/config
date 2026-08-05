# CI verifies, eagle fills the cache

## Problem

`update-flake.yml` failed on 12 of its last 14 scheduled runs, every
night from 2026-07-18 (07-24 excepted). Every sampled failure ended the
same way: an SSH connection to nixbuild dropped mid-stream, Nix printed
`error: unexpected end-of-file`, marked whichever derivation was in
flight as failed, and the cascade took out the job.

The failure is transient, not structural. The derivation varied per run
(`unit-cups.service`, `aspell-dict-en-science`, `cuda_nvrtc`,
`libcusolver`, `vscode-extension-redhat-java`) with nothing in common
but being in flight. In run 30410737575 nixbuild rebuilt and finished
the derivation successfully after its own OOM restart; the client had
already given up. Closure size is not the cause: the last successful run
copied 10,355 paths with no errors, against 8,074 before the failures
died.

The job was exposed because it was the only one left on the local-store
flow. `build.yml` moved to remote-store building in 536c106 and has been
fine since. `update-flake.yml` kept the local-store `nix build` because
it was the designated cache-filling job — niks3 reads NAR bytes off the
filesystem, so the whole 54.9 GiB system closure had to be copied to the
runner.

## Change

- `update-flake.yml` now builds with the same flags as `build.yml`
  (`--eval-store auto --store ssh-ng://eu.nixbuild.net --builders ""
  --max-jobs 2 --print-build-logs`) and passes `niks3-skip-push: true`.
  It updates the lock, verifies the closure builds, and commits only if
  it does. The closure never reaches the runner.
- Cache filling moved to eagle, which already runs
  `services.niks3-auto-upload`. cache.thayyil.net now collects exactly
  the paths eagle realises rather than every CI artifact.
- `modules/infrastructure/caches.nix` records that ssh://eu.nixbuild.net
  must never join the substituter list.

## Why eagle still gets nixbuild's cached builds

nixbuild stays a remote *builder* (`modules/base.nix`), never a
substituter. Per nixbuild's remote-builds docs, Nix does not query
remote builders during substitution, so it enters the build phase, ships
the derivation, and nixbuild "can serve it back without running the
build". Nix then fetches the result into the local store as a completed
build — which fires the post-build-hook and pushes to
cache.thayyil.net.

Adding nixbuild as a substituter would break this: the path would be
substituted, no build would occur, the hook would never fire, and
nothing would reach cache.thayyil.net. nixbuild's docs recommend exactly
that as a performance workaround. The cost of declining it is that eagle
fetches build inputs it only needs remotely.

## Rejected

- **Patch niks3 for `--store ssh-ng://`.** Does not fix the failure: NAR
  bytes still cross the same SSH channel, only streaming through instead
  of landing on disk. Threading `--store` into `nix path-info` is two
  lines (`client/nixstore.go:227`, `:344`), but niks3 generates the
  `.ls` listing during the same filesystem walk that produces the NAR
  (`client/nar.go:278`) and ships a NAR writer with no reader, so it
  would also need a streaming NAR parser. This closes the phase-2 open
  item from 2026-07-19.
- **nixbuild's `caches` setting** (server-side upload straight to S3,
  zero runner bandwidth). Objects would bypass niks3's Postgres, and its
  GC is DB-driven (`MarkStaleObjects` → `DeleteObjects` →
  `removeS3Objects`) with no S3 listing sweep, so they would leak
  permanently. `verify_s3` only checks S3 for keys the DB already has,
  and `POST /api/uploads/skipped` is a metrics counter — neither adopts
  existing objects. Viable only behind a new niks3 "register existing
  objects" API; niks3's NAR key is content-addressed
  (`nar/<NarHash-nix32>.nar.zst`) and derivable from `nix path-info`
  metadata alone, but nixbuild's own key layout is undocumented, so the
  keys may not line up.
- **Retry the local-store build.** Treats the symptom and keeps 54.9 GiB
  moving through the runner nightly.

## Verified

- `nix eval --json .#lib.caches` unchanged; eagle's effective
  `nix.settings.substituters` unchanged, with no ssh://eu.nixbuild.net.
- actionlint clean on both workflows; `nix fmt` produced no further
  changes.
- Not yet verified: a real scheduled run, and whether eagle and CI see
  the same nixbuild store. Store visibility is scoped per session by
  trusted-public-keys, CI delivers a settings block via SSH `SetEnv`
  while eagle sends none and uses account defaults. The docs say the
  account signing key is implicitly trusted, so these should agree —
  worth confirming once given the ssh-ng settings-delivery bug found on
  2026-07-19.

## Open items

- Cache population is now gated on eagle's switch cadence, not CI's. A
  lock bump that eagle never switches to reaches cache.thayyil.net not
  at all.
- The first switch after each lock bump is slower on eagle: it fetches
  build inputs, pulls outputs from nixbuild, and uploads to R2.
- nixbuild retention is explicitly undefined ("might be emptied at any
  time"). If it evicts between the CI run and a switch, eagle rebuilds.
- `build.yml` and `update-flake.yml` now carry the same six build flags.
  Left duplicated rather than abstracted behind a third composite action.
- Still open from 2026-07-19: nixbuild support on ssh-ng substitution,
  and `git remote set-url` for the repo move to hatimthayyil/config.
