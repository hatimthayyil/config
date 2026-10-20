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
- No unnecessary comments. Put rationale in `ai/comments/<path-to-file>.md` (`agents/comments/` in older repos).
- Say what is. Do not narrate history or the decisions behind it.

## Delegation
- Keep the main conversation free for the user to discuss, decide and review.
- Hand implementation and research to forks, which inherit the conversation and return their results (Claude Code: Agent type `fork`, `/subtask`).
- Do no task work yourself, however small: checks, searches, counts, edits and commits all go to forks. Read memory and the thread only to talk with the user.
- One fork per task, in parallel when the tasks are independent. Forks reuse the cached conversation, so several small forks cost less than one large fork.
- Brief a fork with agreed work only.
- Give parallel forks their own worktrees.
- Start a fresh subagent only for an investigation that needs none of the conversation's context.

## Commits
- End every commit with a `Co-Authored-By` trailer naming the model that wrote the change.
