## Memory

Your memory:
- The tool is `ai memory`
- Your memories are in `~/.ai/memory`

This memory outlives every session, compaction, model and vendor change.
Without it you do not know who you are, or what was decided and tried.

### At startup and after compaction: activating memory (mandatory)

Run `ai memory wake` before any other tool call, in every session, and
again after every compaction, then do exactly what it prints, to the end
of its output. Compaction drops your context; keep noting afterwards.

### While working: register memories (mandatory)

Call `ai memory note "<1 line, max 280 bytes>"` whenever you learn
something new, or something worth keeping happens. That covers a task
worth real effort, a fact or insight the user teaches you, anything you
learn about their life (even indirectly), any event of lasting effect.

The user forgets details too, and relies on this memory to recall them.
Note judiciously the details the future will need: decisions and their
reasons, names, paths, commands, open questions, what is left undone.

Write only what happened or what you learned: the tool records the time,
machine, repo, branch, agent, model and session of every note, so never
put a date, repo or session in it.

Do not register redundant memories.

Never edit or delete anything under `~/.ai/memory`: the tool manages it.

### Reading it: the view, zoom, grep

`wake` prints the view: the whole memory, oldest first, as one-line
summaries. Each line is `id+n|dates|text`: the n messages from id on, and
the UTC days they span. A short message is its own line, word for word;
the older the messages, the more a line covers. `--time` adds the time of
day; `-o repo,agent,...` adds where and by whom a line was noted.

`ai memory zoom <id+n>` opens a line two levels down: the four lines of
n/4 it was made from, or its messages when n is 2 or 4; `ai memory zoom
<id>+1` gives message id in full. Zoom whenever a line only mentions
something you need, before you act, guess or ask.

`ai memory grep <regex>` searches every message, word for word; `-t` adds
the summaries, `--help` lists the filters. `ai memory show <id+n>` prints
where a message or summary came from.

### If you're a subagent: skip everything above

Parallel sessions on this machine are all you, and may all write memories.
A subagent is not: it must never run `ai memory`, because it cannot judge what
is already known, and its notes would arrive duplicated and incorrectly.
When you spawn one, write: `You are a subagent. Don't run ai memory.`
