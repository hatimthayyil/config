# pi-hatim

Local pi package and configuration.

## Layout

- `settings.json` — pi settings; `packages` is the install list.
- `package.json` — declares this directory as a pi package.
- `AGENTS.md`, `APPEND_SYSTEM.md` — global context.

## Wiring

`modules/pi.nix` symlinks `settings.json`, `AGENTS.md`, and `APPEND_SYSTEM.md` into
`~/.pi/agent/`. This directory is listed in `settings.json` `packages`. npm packages install to
`~/.pi/agent/npm/`, which pi owns.

## Collisions

Packages share one namespace for commands, shortcuts, tools, and status keys. `settings.json`
force-excludes files through the package filter form; the package's other files still load.

| Collision | Competing | Resolution |
| --- | --- | --- |
| `/rewind` | pi-code `git-checkpoint.ts`, pi-rewind `commands.ts` | drop pi-code's |
| `subagent` | pi-code `subagent/index.ts`, pi-subagents | drop pi-code's |

```json
{
  "source": "npm:pi-code",
  "extensions": [
    "-extensions/subagent/index.ts",
    "-extensions/git-checkpoint.ts"
  ]
}
```

Nothing else overlaps. Drop a `-` line and restart pi to re-enable.

## npm

Never run bare npm in `~/.pi/agent/npm/`. pi installs with `--legacy-peer-deps`; omitting it
makes npm install hundreds of peer packages.

```
npm <verb> --prefix ~/.pi/agent/npm --legacy-peer-deps
```
