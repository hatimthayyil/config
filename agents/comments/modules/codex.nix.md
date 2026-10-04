# modules/codex.nix

`~/.codex` -> `home/hatim/codex` (out-of-store). `.gitignore` whitelists user config; everything else (auth.json, sqlite DBs, sessions, logs, caches, `packages/`, `skills/.system`, `installation_id`, legacy `config.json`/`instructions.md`/`history.json`) is runtime state.

## config.toml

- Untracked: Codex writes `[projects.*]` trust entries (local project paths) into it, and the repo is public.
- Codex rewrites it via atomic temp-file + rename after resolving symlinks, so a directory symlink is safe.
- Without `CODEX_HOME`, Codex keeps `~/.codex` un-canonicalised, so `hooks.state` keys (`/home/hatim/.codex/config.toml:...`) stay stable. Setting `CODEX_HOME` would canonicalise to `/hatimthayyil/...` and invalidate hook trust.
- Expected churn: `[projects.*]` trust entries, `/model`, `[notice.*]`, `[tui.model_availability_nux]`, `hooks.state` trusted hashes. git-ai writes absolute `/nix/store/...git-ai.../bin/git-ai` hook commands; a git-ai upgrade rewrites them and their trusted hashes.
- `hooks.json` and `herdr-agent-state.sh` are installed and overwritten by herdr.
- `rules/default.rules` is untracked: Codex appends "always allow" approvals, which can contain local paths.

## Synced claude.ai skills

Codex scans `~/.agents/skills` recursively and sees Claude Code's `synced/<bucket>/<skill>` copies. `[[skills.config]]` (codex-rs/config/src/skills_config.rs) has only exact selectors: `path` (canonicalised SKILL.md path; directories do not match) or `name`. No glob/exclude exists. Rules apply in order, later wins.

- Disabled by `name` because the bucket directory is account-specific.
- `name = "skill-creator"` also disables Codex's bundled skill-creator, so a later `path` rule re-enables `~/.codex/skills/.system/skill-creator/SKILL.md`.
- New synced skills need a new entry. Check with `codex debug prompt-input hi | grep -c synced`.
