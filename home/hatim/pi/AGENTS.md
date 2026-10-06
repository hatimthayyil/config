# Agent context

## Environment
- NixOS. Flake config at `~/code/config`.
- Python: use `uv`.
- Build `just build`, apply `just switch`, format `nix fmt`.

## Engineering
- DRY and SOLID.
- No backward compatibility. Remove obsolete paths rather than adding fallbacks or migrations.
- Simplest implementation that meets current requirements. No speculative abstraction.
- Grow in layers. Never trade a working product for unfinished complexity.
- Prefer established libraries over reimplementation. Check existing dependencies first.
- For non-novel tasks, follow established patterns rather than inventing an approach.

## Writing
- Do not narrate history. Say what is; do not recount what changed or the decisions behind it.
- No unnecessary comments. Rationale belongs in `agents/comments/<path-to-file>.md`.

## Commits
- End every commit with a `Co-Authored-By` trailer crediting the model that authored the change, e.g. `Co-Authored-By: DeepSeek V4.1 Flash <noreply@deepseek.com>`.

## Memory

Your memory:
- The tool is `ai memory`
- Your memories are in `~/.ai/memory`

This memory outlives every session, compaction, model and vendor change.
Without it you do not know who you are, or what was decided and tried.

### At startup: activating memory (mandatory)

Run `ai memory wake` before any other tool call, in every session, and
then do exactly what it prints, to the end of its output.

### While working: register memories (mandatory)

Call `ai memory note "<1 line, max 506 bytes>"` whenever you learn
something new, or something worth keeping happens. That covers a task
worth real effort, a fact or insight the user teaches you, anything you
learn about their life (even indirectly), any event of lasting effect.

Write only what happened or what you learned: the tool records the time,
machine, repo, branch, agent, model and session of every note, so never
put a date, repo or session in it.

Do not register redundant memories.

Never edit or delete anything under `~/.ai/memory`: the tool manages it.

### Reading it: the view, zoom, grep

`wake` prints the view: the whole memory, oldest first, as one-line
summaries. Each line is `id+n|text`, the n messages from id on. A short
message is its own line, word for word; the older the messages, the more
a line covers. Items are tagged with their kind: user, talk, tool, echo
(a chat with the user: their words, the agent's replies, its tool calls
and their results) or note (what sessions like this one noted).

`ai memory zoom <id+n>` opens a line into the two lines of n/2 it was made
from; `ai memory zoom <id>+1` gives message id in full. Zoom whenever a line
only mentions something you need, before you act, guess or ask.
`ai memory grep <regex>` searches every message, word for word; `-t` adds
the summaries, `--help` lists the filters. `ai memory show <id+n>` prints
where a message or summary came from.

### If you're a subagent: skip everything above

Parallel sessions on this machine are all you, and may all write memories.
A subagent is not: it must never run `ai memory`, because it cannot judge what
is already known, and its notes would arrive duplicated and incorrectly.
When you spawn one, write: `You are a subagent. Don't run ai memory.`
