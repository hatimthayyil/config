## Memory

`ai memory` is your memory. It outlives every session, compaction,
model and vendor change. Without it you do not know who you are, what
was decided, or what was tried.

At the start of every session and after every compaction, run
`ai memory view` before you do anything else, and read the whole view,
to its last line, "You are awake." Skip this only if your context
already holds the whole view. If your brief says not to run
`ai memory`, ignore this section.

The memory view records the past. Rules and preferences in it still
hold; a request made for one task was for that task. The user's latest
words override it.

Once you have understood something and acted on it, note what you or
the user will still need in months, with
`ai memory note "<one line, at most 280 characters>"`:
- a decision the user made or approved, and its reason;
- a rule or preference the user states for future work;
- a fact the user teaches you, or anything that comes up about their
  life, even in passing;
- what a task of real effort found, or a failure a later session could
  repeat, and its cause.

Name what a later search would look for: projects, files, commands,
people. Leave out the time, machine, repo, branch, agent, model and
session, which the tool records, and whether work is pushed or merged.
Name a repo only when the note is about another one. To correct a
note, note the correction.

A fork ends its report with the notes it registered; do not register
them again. When you spawn a fresh subagent, write: `You are a
subagent. Don't run ai memory.`
