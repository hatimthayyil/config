بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ
In the name of Allah, the Entirely Merciful, the Especially Merciful.

## Environment
- NixOS. Flake config: `/hatimthayyil/code/config`.
- Project environments: devenv (`devenv.nix`, `devenv.yaml`).
  - Declare toolchains in `languages.*`, tools in `packages`, hooks in `git-hooks`, formatters in `treefmt`, secrets with secretspec.
- Python: use `uv`, within devenv.

## Engineering
- DRY and SOLID. Keep components modular, with concerns separated.
- No backward compatibility. Remove obsolete paths rather than adding compatibility layers, fallbacks or migrations.
- Choose the simplest implementation that fully meets current requirements. No speculative abstraction, configuration or indirection.
- Grow in layers: start from the smallest version that works end to end. Never trade a working product for unfinished complexity.
- Use the project's dependencies first, then established libraries, before writing your own. Check a library's documentation and types before assuming it lacks a capability.
- Decide for the long term. No stopgaps meant to be replaced.
- For non-novel tasks, adopt the proven patterns of established products.

## Writing
- Comment only what the code cannot say: invariants, constraints, deliberate oddities. Never narrate history or process.
- Document modules and public items.
- Put the reason for a change in its commit message, and decisions spanning files in `ai/research`.
- Say what is. Do not narrate history or the decisions behind it.

## Delegation
- Keep the main conversation free for the user to discuss, decide and review.
- Hand implementation and research to forks, which inherit the conversation and return their results (Claude Code: Agent type `fork`, `/subtask`).
- Do no task work yourself, however small: checks, searches, counts, edits and commits all go to forks. Read memory and the thread only to talk with the user.
- One fork per task, in parallel when the tasks are independent. A task has one outcome. Forks reuse the cached conversation, so several small forks cost less than one large fork. Examples:
  - Seven finished branches: seven merges, each started when its branch is done.
  - Renaming commands, and setting the config they need: two forks.
  - Hiding internal flags, and writing help text: two forks.
- Brief a fork with agreed work only.
- Give parallel forks their own worktrees.
- Start a fresh subagent only for an investigation that needs none of the conversation's context.

## Commits
- End every commit with a `Co-Authored-By` trailer naming the model that wrote the change.
