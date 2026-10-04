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
- Codex scans recursively and ignores `.gitignore`: it sees the synced skills (docx, pdf, pptx, xlsx, skill-creator, ...). Disable per skill via `[[skills.config]]` in `~/.codex/config.toml` if needed.

## Third-party skills

Vendored as-is for now; to be replaced by Nix-pinned sources. `rust-skills` was a manual clone of https://github.com/curtisault/rust-skills at `a04921b2d85583aea9ec7441a66ab878ca694b9a` (not in `.skill-lock.json`); its `.git` was dropped.
