# Remote-store CI builds on nixbuild.net

## Problem

The `Build` workflow took ~30 min per run. Log analysis of run
29658925333: ~21 min was the runner downloading 9,709 store paths
(the whole system closure) from cache.thayyil.net, because `nix build`
against a local store must realize every output locally. Remote
builds of ~408 trivial drvs plus copy-back accounted for the rest.

## Change

- `build.yml` builds with
  `--eval-store auto --store ssh-ng://eu.nixbuild.net --builders ""
  --max-jobs 2 --print-build-logs` (flags per nixbuild-action README,
  "Remote Store Building"). Evaluation stays on the runner; builds,
  substitution, and outputs stay inside nixbuild.net. Only the drv
  closure is copied to nixbuild (~35k tiny files first time,
  delta-only afterwards; `inputClosureTtlSeconds` 90 days).
- `setup-nix` passes `skip-push: true` to niks3-action for this
  workflow: nothing lands in the runner store, so the post-build-hook
  push cannot work. `update-flake.yml` keeps the old local-store flow
  and remains the cache-filling job.
- Cache lists de-hardcoded: `modules/infrastructure/caches.nix` is
  the single source (flake output `lib.caches`). Consumed by eagle
  (`base.nix`), the runner (`NIX_CONFIG` in `setup-nix`), and
  nixbuild.net (nixbuild-action `settings:` block, delivered per
  invocation via SSH `SetEnv`; account has `settingsFromSshEnv:
  true`). Account-level nixbuild settings deliberately left at
  defaults — repo stays the source of truth.

## False alarm during rollout

First remote-store run appeared to rebuild "cached" packages and was
cancelled twice. Diagnosis via nixbuild HTTP API (`/builds`, tagged
`GITHUB_RUN_ID`) + narinfo probes: the built packages (kimi-code,
plannotator, claude-desktop bun/npm graphs) were introduced by
commits never built by any pushing CI run — they existed in no cache
(`bun-cache` narinfo 404s). nixbuild behaved correctly; env-delivered
settings demonstrably reach ssh-ng builds (tags on build records,
helix and unchanged config drvs reused, only 3 changed etc-drvs
rebuilt). Build outputs are retained on nixbuild ~90 days, so
cancelled work is reused.

## Verified

- `nix eval --json .#lib.caches` returns the list; eagle's effective
  `nix.settings` byte-identical before/after the refactor (checked
  against `git+file` eval of the prior commit).
- actionlint clean; full-system `--dry-run` evaluates.
- Not yet measured: steady-state remote-store run time (first
  attempts cancelled). Expect eval ~2-3 min + drv-copy delta +
  builds/substitution on nixbuild.

## Open items (phase 2: cache filling)

- Teach the niks3 client a `--store ssh-ng://…` mode so update-flake
  can do remote-store builds and still push to cache.thayyil.net:
  closure via `nix path-info --store`, NAR bytes via `nix store
  dump-path --store`, plus a streaming NAR parser to produce `.ls`
  listings (`DumpPathWithListing` currently walks the filesystem).
  Server/Postgres untouched — all uploads go through the pending-
  closure API, so no DB desync. Sources: /hatimthayyil/code/niks3
  (codegraph-indexed), niks3-action.
- With `skip-push`, new outputs from Build runs reach cache.thayyil.net
  only after eagle builds+auto-uploads them, or once phase 2 lands.
- Consider `git remote set-url` — GitHub reports the repo moved to
  hatimthayyil/config (push still works via redirect).
