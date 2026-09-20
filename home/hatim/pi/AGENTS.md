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

## Comments
- No unnecessary comments. Rationale belongs in `agents/comments/<path-to-file>.md`.
