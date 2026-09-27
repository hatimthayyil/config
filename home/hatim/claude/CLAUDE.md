## Instructions
- NOTE You are on a Nix machine. The flake config is at `/hatimthayyil/code/config`
- NOTE For python, use `uv python`. There is no
- IMPORTANT You must clearly state your intent with "INTENT: <intent>" prior to requesting tool calls. 
- IMPORTANT You may state your expectation of your actions with "EXPECTATION: <expectation>".
- IMPORTANT When appropriate, you must state any risks involved with your actions, including tool calls. With "RISK: <risk>".
- IMPORTANT: You can state alternative course of action you are contemplating with "ALTERNATIVES: 1. <alt-1>; 2. <alt-2>"
- Discussed the task with me and has agreed that the shared reasoning is sound. It is expected that you will engage and will allow him to lead action.
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

Your memory is OptMem:
- The tool is `~/.optmem/memo`
- Your memories are in `~/.optmem/memory`

OptMem outlives every session, compaction, model and vendor change.
Without it you do not know who you are, or what was decided and tried.

Only use the memory if you are explicitly instructed with "use memory" in the
beginning of the session.

### At startup: activating OptMem

Run `~/.optmem/memo wake` before any other tool call, in every session, and
then do exactly what it prints, to the end of its output.

### While working: register memories

Call `~/.optmem/memo note "<1 line, max 280 chars>"` whenever you learn
something new, or something worth keeping happens. That covers a task
worth real effort, a fact or insight the user teaches you, anything you
learn about their life (even indirectly), any event of lasting effect.

Do not register redundant memories.

If `~/.optmem/memo note` asks a compression: do it before your next action.

Never edit or delete anything under `~/.optmem/memory`: the tool manages it.

### When you need an old memory: search, or navigate

`~/.optmem/memo recall <regex>` searches every memory, word for word.

Your memories also form a binary tree: #0-1, #2-3 ... exist as one-line
summaries, pairs of those as #0-3, and so on -- every `#a-b` line wake
prints is one node of it. `~/.optmem/memo zoom <a-b>` opens a node into its
two halves, down to the raw memories.

### If you're a subagent: skip everything above

Parallel sessions on this machine are all you, and may all write memories.
A subagent is not: it must never run `memo`, because it cannot judge what
is already known, and its notes would arrive duplicated and incorrectly.
When you spawn one, write: `You are a subagent. Don't run memo.`
