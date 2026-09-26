# settings.json

## Why pi-code's extensions are filtered

pi packages share one global namespace for commands, shortcuts, tools, and status keys, and any
number of extensions may subscribe to the same lifecycle events. Two packages doing the same job
therefore collide, and the package filter form in `packages` is the only lever pi exposes.

`subagent` — pi-code (`extensions/subagent/index.ts`) and pi-subagents
(`src/extension/index.js`) register a tool under that name, and both inject a roster into the
system prompt. pi-subagents is kept: it adds supervisor intercom, lanes, missions, and scripted
workflows, where pi-code's is the simpler Claude-compatible delegation.

`git-checkpoint.ts` — pi-code and pi-rewind both register `/rewind` and both hook `session_start`,
`before_agent_start`, `turn_start`, `tool_call`, `turn_end`, and `session_before_fork`. Together
they snapshot twice per turn and prompt twice on fork. pi-rewind is kept because its refs live in
the repository (`refs/pi-checkpoints/*`) and travel with it, while pi-code's shadow repo under
`~/.pi/agent/checkpoints/<session-slug>` is keyed to the session file and the original work tree,
leaving checkpoints unrestorable after a directory move. pi-rewind also carries the diff preview,
redo stack, and `Esc Esc` shortcut.

Both filters are leaves: no pi-code extension imports either file.
