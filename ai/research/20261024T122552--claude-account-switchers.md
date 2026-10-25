# Claude Code account switchers

Written by Claude Opus 5.5.

Use case: switching between the user's own distinct accounts (personal, until about 2026-11-14, and a Claude Team seat) on NixOS with Claude Code CLI 2.1.x. Rotating seats to get around per-member limits is a policy risk and is out of scope.

## Claude Code itself

The authentication docs now document multiple accounts under "Log in with multiple accounts" ([authentication](https://code.claude.com/docs/en/authentication#log-in-with-multiple-accounts)):

> To stay signed in to multiple accounts at once, such as work and personal accounts, give each account its own configuration directory. When you start `claude`, set the `CLAUDE_CONFIG_DIR` environment variable to the directory for the account you want to use. Each directory has its own settings, session history, and claude.ai login or API key.

- On Linux, the login lives in `$CLAUDE_CONFIG_DIR/.credentials.json`, mode 0600. On macOS, the Keychain entry is keyed to the directory.
- Project and local settings cannot set `CLAUDE_CONFIG_DIR`. It must come from the environment.
- Caveat: Console sign-ins without an API key are stored outside the config directory (`~/.config/anthropic`), so separate directories don't keep two of them apart. Claude.ai logins (Pro/Max/Team) are not affected.
- There is no in-app account picker. `/login` replaces the login in the current config directory.
- `CLAUDE_CODE_OAUTH_TOKEN` (from `claude setup-token`, one year) also selects an account per process. It is limited to model requests: no Remote Control and no claude.ai connectors.

## Candidates

| Tool | Switching | Token storage | Activity | nixpkgs | Linux, CLI 2.1.x |
|---|---|---|---|---|---|
| [claude-swap](https://github.com/realiti4/claude-swap) (Python, `cswap`) | Swaps `~/.claude/.credentials.json` in place (global, hot); `cswap run` gives a per-terminal session with `CLAUDE_CONFIG_DIR` | Plain files under `~/.local/share/claude-swap/credentials/`; exports plaintext JSON | 3.9k stars, 0.28.0 on 2026-10-22 | no | yes |
| [clauth](https://github.com/uwuclxdy/clauth) (Rust, TUI) | Swaps `.credentials.json` and the `env` block of `settings.json` in place; `clauth start` runs against a temporary `~/.claude` mirror | Files under `~/.clauth/`, mode 0600, no encryption | 256 stars, 0.17.0 on 2026-10-02 | no | yes; names Team support |
| [ccswitch](https://github.com/vyshnavsdeepak/ccswitch) (Rust) | Credential swap, restart required | Linux: `~/.claude-switch-backup/credentials/`, 0600; macOS: Keychain | 13 stars, no releases | no | yes |
| [cc-account-switcher](https://github.com/fairy-pitta/cc-account-switcher) (Bash + jq, fork of ming86) | Credential swap with rollback; `ccs exec` runs in parallel via `CLAUDE_CONFIG_DIR` | `~/.claude-switch-backup/`, 0600 | 67 stars | no | yes |
| [ccsw](https://github.com/jv-vogler/ccsw) (Rust) | Per terminal: `CLAUDE_CONFIG_DIR=~/.claude-profiles/<name>`, symlinks shared files from `~/.claude`, then `execvp claude` | Claude Code's own `.credentials.json` per profile; never copied | 0.1.1 on 2026-04-22, dormant | no | yes |
| [claude-multiprofile](https://github.com/jmdarre-v/claude-multiprofile) | Per-profile `CLAUDE_CONFIG_DIR` aliases, plus Claude Desktop launchers on macOS | Claude Code's own storage | 128 stars | no | Code profiles yes; Desktop macOS only |
| [CCSwitcher](https://github.com/XueshiQiao/CCSwitcher), [Symbioose switcher](https://github.com/Symbioose/claude-account-switcher) | Menu-bar credential swap | Keychain | active | no | macOS only |
| [CCS (guoy0701)](https://github.com/guoy0701/claude-code-account-switch) | Local proxy swaps tokens mid-session | — | — | no | Windows only |
| cc-switch, cc-switch-cli | Switch API providers and endpoints, not claude.ai accounts | SQLite `~/.cc-switch/` | 5.4k stars | yes (3.16.5, 5.10.5) | out of scope |

## How the two approaches compare

There are two mechanisms.

1. **Credential swap** (claude-swap `switch`, clauth, ccswitch, cc-account-switcher):
   - Copies tokens out of Claude Code's store into the tool's own files.
   - Rewrites `~/.claude/.credentials.json` underneath running sessions.
   - Depends on Claude Code internals: lock files, refresh-token rotation, and `/logout` revoking the refresh token.
   - Holds a second copy of every refresh token. Those copies go stale when Claude Code rotates the token, which is why claude-swap has quarantine and capture-back logic.
   - Its main feature, automatic rotation at the limit, is the use case the policy risk covers.
2. **Per-directory** (Claude Code's documented method; ccsw; claude-multiprofile; `cswap run`):
   - Each account keeps its own login, and Claude Code refreshes it itself.
   - No token is copied, and the tool touches no internals.
   - Accounts can run side by side in different terminals.
   - Cost: the shared files (settings, CLAUDE.md, skills, plugins) must be linked into each directory.

A per-account `CLAUDE_CONFIG_DIR` wrapper in `modules/claude.nix` covers the per-directory method:
- One `writeShellApplication` per account, for example `claude-personal`, which sets `CLAUDE_CONFIG_DIR=~/.claude-personal` and runs `claude "$@"`.
- Home-manager links the shared entries into that directory (`settings.json`, `CLAUDE.md`, `skills/`, `agents/`, `commands/`, `plugins/`), either from `home/hatim/claude` or with `mkOutOfStoreSymlink`.
- `.credentials.json`, `projects/` and history stay per account. Linking `projects/` would share session history, as `cswap run --share-history` does.
- Managed settings in `/etc/claude-code` apply to every config directory, so the ai plugin works in both.

None of the tools is in nixpkgs. The per-directory tools only automate what the wrapper declares.

## Recommendation

Declare a per-account wrapper (`claude-personal`) in `modules/claude.nix`, using Claude Code's documented `CLAUDE_CONFIG_DIR` method:
- Keep `~/.claude` for the Team seat.
- Link the shared files into `~/.claude-personal` through home-manager.
- Log in once with `claude-personal`, then `/login`.

Skip claude-swap and the other credential swappers, because they duplicate refresh tokens and depend on Claude Code internals. Once the personal account ends (about 2026-11-14), remove the wrapper.

## Sources

- https://code.claude.com/docs/en/authentication
- https://code.claude.com/docs/en/env-vars
- https://github.com/realiti4/claude-swap and PyPI claude-swap 0.28.0
- https://github.com/uwuclxdy/clauth and crates.io clauth 0.17.0
- https://github.com/vyshnavsdeepak/ccswitch
- https://github.com/fairy-pitta/cc-account-switcher
- https://docs.rs/crate/ccsw/latest
- https://github.com/jmdarre-v/claude-multiprofile
- https://github.com/SaladDay/cc-switch-cli; nixpkgs `pkgs/by-name/cc/cc-switch{,-cli}`
