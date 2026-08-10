# niks3-auto-upload.nix

## Why the module carries no cache identity

The module owns plumbing only: enabling upstream, wiring the sops token, and the
system-closure push. `serverUrl` is the one host-specific value, so
`modules/hosts/eagle.nix` sets it.

## Why the system closure is pushed explicitly

The post-build-hook fires on builds and never on substitutions. Now that eagle
substitutes from nixbuild, most of the system closure arrives without a build,
so the hook alone would leave cache.thayyil.net progressively emptier. That
matters because nixbuild's retention is explicitly undefined — its docs say the
store "might be emptied at any time".

`niks3 push` expands closures itself via `nix path-info --recursive`
(`client/nixstore.go:226`), which is the *runtime* closure. Build-only inputs
are excluded, and everything in it is already on disk, so the push costs no
downloads and uploads only what the cache lacks.

The hook stays for whatever the host genuinely builds — dev shells and the like.

## Why activation passes the path in a file

Naming the generation in the unit is the obvious approach and it does not
evaluate: `ExecStart = "… push ${config.system.build.toplevel}"` is a cycle,
since toplevel is assembled from `etc`, which contains the units. The same
applies to `restartTriggers = [ config.system.build.toplevel ]`, which is
serialised into the unit as `X-Restart-Triggers=`. Without a per-generation
value the unit text never changes, so a switch never restarts it.

Reading `/run/current-system` from the activation script is also wrong: the
symlink is retargeted at `activate:136`, the last statement in the file, after
every named snippet has run. It would push the previous generation.

`$systemConfig` is in scope throughout activation and is always the generation
being activated, so the snippet writes it to `/run/niks3-push-target` and the
unit reads that. `switch-to-configuration` runs `activate` after the
daemon-reload phase (`switch-to-configuration-ng/src/main.rs:2230`), so the unit
is loaded by then. `systemctl start` is called directly rather than through
`RESTART_BY_ACTIVATION_LIST_FILE`, which is deprecated and slated for removal in
26.11.

The daily timer is a backstop for a push that never ran — no network at switch
time, or a failed start. It is idempotent; niks3 skips objects already uploaded.
