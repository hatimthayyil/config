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

## Rollout finding: ssh-ng substitution broken on nixbuild.net

Remote-store runs rebuilt packages that were present in configured
caches. Initially looked like new-package builds (kimi-code etc.
were genuinely uncached), but successive experiments isolated a real
nixbuild.net defect:

- Env-level settings (nixbuild-action `settings:` via SSH `SetEnv`):
  substituters NOT applied to ssh-ng-scheduled builds, although
  `NIXBUILDNET_TAG_*` from the same SetEnv IS applied (build records
  tagged). kimi-code (in cache.thayyil.net since 2026-07-18 21:12)
  rebuilt — builds 10557157/10557159.
- Account-level settings (all six caches added via
  `api settings substituters --add`, verified with `--show`):
  still not consulted. Decisive repro: fresh never-queried path
  `agent-deck` (output on cache.numtide.com) via
  `nix build --eval-store auto --store ssh-ng://eu.nixbuild.net
  github:numtide/llm-agents.nix/<rev>#agent-deck` from eagle —
  client immediately descended into dependency builds (10557288
  source, 10557289 go-modules), i.e. the remote store answered the
  output-path query without consulting any substituter.
- Contrast: `ssh://` remote-builder flow substitutes inputs from the
  same env-delivered caches correctly (old runs: only 36 paths ever
  uploaded from the runner).

Conclusion: in ssh-ng remote-store mode nixbuild answers path
queries from its own store only; substituters are ignored at every
settings level. Reported to support@nixbuild.net. nixbuild's own
90-day store is the effective cache meanwhile: repeat builds are
reused (run 3 rebuilt only changed drvs, drv sync was 8 paths), but
first builds of cache-available paths cost CPU.

Account settings synced from the flake via `just
nixbuild-sync-caches` (harmless now, correct once support fixes
substitution; env `settings:` block also kept).

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
- Awaiting nixbuild support on ssh-ng substitution. If they decline
  to fix: either accept first-build CPU cost on nixbuild (current
  state), or revert build.yml to the local-store flow. Do NOT push
  manual flake.lock bumps through build.yml until resolved (mass
  rebuild risk); update-flake.yml still substitutes correctly.
- `queriedPathTtlSeconds` (7 days, not user-settable) may delay any
  support-side fix taking effect for already-queried paths.
