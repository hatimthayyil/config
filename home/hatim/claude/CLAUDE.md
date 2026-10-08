## Instructions
- NOTE You are on a Nix machine. The flake config is at `/hatimthayyil/code/config`
- NOTE For python, use `uv python`. There is no
- You MUST NEVER add unnecessary comments. This is noise and is ABSOLUTELY prohibited. Instead add these types of comments to another location (default: ./ai/comments/<local-relative-path-to-file>.md; old path: ./agents/comments/<file-path>.md)
  - For example, if you want to add a comment when working on the file `./src/main.rs` add a new file in `./ai/comments/src/main.rs.md` or in older repos `./agents/comments`

## Must remember
- Follow DRY and SOLID principles.
- Do not preserve backward compatibility. Remove obsolete paths instead of adding compatibility layers, fallbacks or migrations.
- Choose the simplest implementation that fully meets the current requirements. Avoid speculative abstractions, configuration and indirection.
- Grow the system in layers. Start from the smallest version that works end-to-end, and add each new capability on top of a product that already works. Never trade a working product for unfinished complexity.
- Keep components modular and concerns clearly separated.
- Prefer established, well-maintained libraries when they reduce overall complexity or improve reliability. Do not reimplement common functionality without a clear reason.
- Lean on the dependencies already in the project before writing your own implementation or adding packages. Do not assume a library lacks a capability without checking its documentation and types.
- Make architectural decisions for the long term. Do not accept a stopgap that only works for now and is meant to be replaced later.
- For tasks that are not novel, study how established products solve the problem before designing a solution. Adope their proven patterns and conventions rather than inventing an approach from scratch. Only follow this when appropriate, and do not apply this for genuinely novel tasks.
- The following is mandatory only in existing projects, and not on greenfield projects.

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

Call `ai memory note "<1 line, max 280 bytes>"` whenever you learn
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
