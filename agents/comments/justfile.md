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

## `claude-plugins`

`settings.json` (`enabledPlugins`, `extraKnownMarketplaces`) is the declared
intent; Claude Code registers declared marketplaces but never installs a plugin
just because it is enabled, so the recipe installs what is missing. `install`
enables a plugin, so declared-`false` ones are disabled right after; both write
back the same value already in `settings.json`.

Undeclared plugins and marketplaces are only reported. Project/local-scope
installs live in each project's settings and are ignored, but a marketplace they
need is global, so it shows up as undeclared. Marketplaces named by an
`enabledPlugins` key count as declared, which covers the built-in
`claude-plugins-official`.

Third-party marketplaces omit `autoUpdate`, keeping the default (manual); run
`claude plugin marketplace update` to refresh them. `<name>@synced` plugins come
from the claude.ai account and are left alone.

On a config that has never started interactively, `claude-plugins-official` is
not yet registered and installs from it fail; start `claude` once, or run
`claude plugin marketplace add anthropics/claude-plugins-official`, then rerun.
