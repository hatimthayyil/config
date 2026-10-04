# modules/agent-skills.nix

Single skills directory shared by all coding agents.

- `~/.agents` -> `home/hatim/agents` (out-of-store). Codex, Gemini CLI, opencode and pi read `~/.agents/skills` natively.
- Claude reads only `~/.claude/skills`; `home/hatim/claude/skills` is a tracked relative symlink to `../agents/skills`.
- `npx skills` (vercel-labs/skills >= 1.7.0) skips creating the claude-code link when the canonical and agent paths share a realpath, so `-g` installs no longer create dangling `../../.agents/skills/X` links. `pi` was removed from `lastSelectedAgents` because pi already reads `~/.agents/skills`; selecting it would duplicate skills into `~/.pi/agent/skills`.

## `synced/`

Claude Code writes claude.ai-synced skills to `<user skills dir>/synced/<bucket>/<skill>` (plus `.staging/`, `.trash/`). The path is hardcoded, so it now lands in `home/hatim/agents/skills/synced`.

- `skills/.gitignore` excludes it from git. pi honours `.gitignore` inside skill roots, so pi also ignores it.
- Gemini CLI only scans `*/SKILL.md` (depth 1): not visible.
- opencode scans `~/.claude/skills/**/SKILL.md`: it already saw these before the merge.
- Codex scans recursively and ignores `.gitignore`: it sees the synced skills (docx, pdf, pptx, xlsx, skill-creator, ...). Disabled by name in the untracked `home/hatim/codex/config.toml`; see `modules/codex.nix.md`.

## Pinned third-party skills

`manifest` maps skill name -> store path. Sources: `agents-nix` (github:sudosubin/agents.nix, `pkgs.agent-skills.github.<owner>.<repo>.<skill>` via the overlay) unless its pin is older than wanted.

- `rust-skills`: https://github.com/curtisault/rust-skills (179 rules) is not in agents.nix. `leonardomso/rust-skills` is a different project (265 rules), so it is not a substitute. Hand-pinned with `fetchFromGitHub`.

- `bd-to-br-migration` (dicklesworthstone/beads_rust) was an unmodified upstream copy, so it is pinned too.
- `conversation-compiler`, `readchat`, `recall`, `searchchat` are not in agents.nix; they stay tracked.

### Activation (`agent-skills-sync.sh`)

Runs after `writeBoundary` with a `linkFarm` of the manifest (keeps targets GC-rooted via the generation).

- Links `skills/<name>` -> store path. An existing non-store entry (real dir or own symlink) wins and is reported on stderr.
- Removes symlinks into `/nix/store` that are no longer declared. Nothing else is deleted.
- Lists the linked names in a managed block of `.git/info/exclude`.

Why `.git/info/exclude`: pinned names cannot go in `skills/.gitignore` because pi applies `.gitignore`/`.ignore`/`.fdignore` found at or below a skills root, so it would hide the pinned skills. The exclude file is untracked, so switching never touches tracked files, and no agent reads it. `home/hatim/agents/.gitignore` uses anchored patterns (`/*`, `!/skills/`) instead of `*` + `!skills/**` because a `.gitignore` match outranks `info/exclude`; the anchored form leaves `skills/*` unmatched so the exclude applies. Runtime installs (`npx skills add -g`) are real dirs and still show in `git status`.

`just skills-promote` maps `.skill-lock.json` entries to manifest lines (owner/repo lowercased, skill = parent dir of `skillPath`, or repo name for a root `SKILL.md`) and checks each against the locked agents-nix. Compare its version with what was installed: agents.nix tags can be older than main.
