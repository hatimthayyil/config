# justfile

## Why `why` reads the journal

`nh os switch` runs the built system's `bin/switch-to-configuration` and shows
that script's stderr on failure. Home Manager, when used as a NixOS module, does
not activate inline: it activates in the systemd unit
`home-manager-<user>.service` (`Type=oneshot`, `StandardOutput=journal`).
`switch-to-configuration` restarts that unit over systemd's D-Bus API, the
restart job succeeds, the unit then fails, and the actual error (for example
`Existing file '...' would be clobbered`) is written only to the journal.
`switch-to-configuration` prints a bare `warning: the following units failed:
home-manager-<user>.service`. So the actionable message never reaches `nh`.

`why` closes that gap by listing failed units and dumping their recent journal.
It covers both scopes because NixOS and Home Manager activation failures are
system units, while user services fail in the user manager.

`-n 50` bounds each dump. No elevation is used: this host lets the user read the
system journal.

## Why a helper instead of an upstream fix

`nh` has no journal or systemctl lookup anywhere in its codebase, and no flag
for it. Its `--show-activation-logs` only toggles streaming versus capturing the
activation script's own output, which does not include the unit's logs. Upstream
issues #350, #388, #437, #438, #500 and #643 cover the standalone
`nh home switch` path, where `nh` runs `activate` directly and can capture it;
the NixOS-module path worked around here is unfixed. A proper fix would have
`nh` print the journal of the units `switch-to-configuration` reported as
failed, gated behind a flag.
