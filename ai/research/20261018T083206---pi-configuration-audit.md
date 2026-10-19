# Pi configuration audit

Author: Codex (GPT-6)

Installed state inspected on 2026-10-18, from `/hatimthayyil/code/config`. This is a local configuration and runtime audit; upstream release currency was not checked. No configuration changes or removals were made. The existing Claude settings edits and pi settings removal of `npm:pi-blackhole` predate this audit.

## What pi exposes

Pi **1.1.0** loads **43 skill commands**, of which **42 appear in the model's skill catalogue**. `figma-create-new-file` is explicit-command-only. The startup probe found **16 active tools**, **26 registered tools**, **33 extension commands**, **6 workflow prompts**, and **13 built-in subagent definitions**. Registered tools can be inactive until a workflow enables them. These counts describe this repository; project configuration can change them elsewhere.

| Skill source | Count | Skills |
| --- | ---: | --- |
| Shared `~/.agents/skills` | 9 | conversation-compiler, readchat, searchchat, recall, rust-skills, deslop, stop-slop, bd-to-br-migration, find-skills |
| pi-autoresearch | 3 | autoresearch-create, autoresearch-finalize, autoresearch-hooks |
| pi-subagents | 2 | pi-subagents, council-mode |
| Claude frontend-design plugin | 1 | frontend-design |
| Claude Superpowers plugin | 14 | brainstorming, writing-plans, executing-plans, subagent-driven-development, dispatching-parallel-agents, using-git-worktrees, test-driven-development, systematic-debugging, requesting-code-review, receiving-code-review, verification-before-completion, finishing-a-development-branch, writing-skills, using-superpowers |
| Claude Figma plugin | 7 | figma-code-connect, figma-create-design-system-rules, figma-create-new-file, figma-generate-design, figma-generate-library, figma-implement-design, figma-use |
| Claude Nx plugin | 7 | link-workspace-packages, monitor-ci, nx-generate, nx-import, nx-plugins, nx-run-tasks, nx-workspace |

**29 of 43 skill commands arrive through pi-code's Claude skill bridge.** They are inherited from enabled Claude plugins rather than individually selected in pi settings. Installed plugin paths identify Superpowers 5.1.0, Figma 2.0.7 and Nx 0.2.34; frontend-design's cache directory is `unknown`.

Plugin discovery also honors enabled-by-default cached plugins; appearance in pi does not prove an explicit user selection. Pi-code separately imports Claude global hooks and plugin hooks. **Superpowers also injects instructions through a SessionStart hook**, so removing its skill descriptions alone would leave that behavior active.

The shared tree also contains **13 synced Claude skills that pi does not load**: skill-creator, deep-research, pdf, docx, pptx, xlsx, docs, google-workspace, import-memory, morning, built-in-browser, chrome-browser and computer-use. Their presence on disk does not add their descriptions to pi's current prompt. See the [shared skill inventory](20261018T083206---pi-configuration-audit/shared-skills.md) for sources and dependencies.

## Packages and local configuration

| Configured package | Installed version | Role |
| --- | --- | --- |
| pi-autoresearch | 1.9.0 | Experiment loops and three skills |
| pi-zotero | 0.1.0 | Zotero tool |
| pi-reasonix | 1.1.0 | Provider reasoning compatibility/cache repair |
| pi-hatim, local directory | private, unversioned | Prompt directory; currently only `.gitkeep` |
| pi-subagents | 0.79.1 | Delegation, agents, council, workflows and administration |
| pi-code | 1.5.2 | Claude interoperability, skills, hooks, memory, planning, questions, todos and web tools |
| pi-rewind | 0.5.0 | Conversation/file rewind |

pi-blackhole **0.5.13 remains installed in npm**, but is no longer selected in live settings. Its local data directory also exists. This is distinct from the separate source checkout at `/hatimthayyil/code/pi-blackhole`. Removing a package selection and deleting its stored data are separate actions.

The pi-code package filter already excludes `extensions/subagent/index.ts`, `extensions/git-checkpoint.ts` and `extensions/mcp/index.ts`, avoiding the competing subagent/rewind implementations and its MCP bridge.

Four local extension files also load from `home/hatim/pi/extensions`: git-ai.ts, herdr-agent-state.ts, memory-reminder.ts and workmux-status.ts. These files are ignored by Git. They are active local configuration rather than reproducible tracked source.

The active tools are read, bash, edit, write, zotero, subagent, contact_supervisor, bg_wait, plan_mode_complete, memory, question, todo, web_search, web_fetch, subagent_supervisor and slash_command. The normal-startup probe registered zero MCP servers. This does not test Zotero connectivity or external CLI authentication.

Settings select `deepseek/deepseek-flash`, thinking level `high`, and the `light` theme. `enabledModels` also contains `zai/glm-5.3`; startup reports **“No models match pattern \"zai/glm-5.3\".”** This proves a stale/unavailable selection in the installed model catalogue, not that the provider has no such model upstream.

## Instructions and agents

`modules/pi.nix` links the entire `~/.pi/agent` directory into `home/hatim/pi`. Its `AGENTS.md` points to `~/.config/agents/pi.md`, generated by `modules/agent-instructions.nix` from `core.md`, `codegraph.md` and `memory.md`. The deployed file matches these sources. Claude and Codex receive the same composed instructions; pruning the shared text affects all three agents after activation.

Pi also loads its own tracked `APPEND_SYSTEM.md`: an additional working agreement requiring INTENT, EXPECTATION, RISK and USER WISH before acting, and agreement before anything beyond a trivial edit. This is a separate place to decide pi's interaction style. Its rigid reporting format is not part of the shared global instructions.

The 13 effective pi-subagents definitions are **scout, researcher, worker, reviewer, oracle, evidence-auditor, delegate**, plus **claude-code, claude-code-writer, codex-exec, codex-exec-writer, cursor-agent, cursor-agent-writer**. They come from the installed pi-subagents package. No user or project agent overrides or chain definitions were found. The six external CLI definitions are available definitions; discovery does not prove their executables or accounts work.

Default definition metadata inherits project context, with global context and skills inheritance disabled. Explicit fork execution can carry additional context; this metadata alone does not establish what every launched child sees.

## Findings worth deciding on

| Item | Evidence | Proposed decision |
| --- | --- | --- |
| Claude plugin skill imports | 29 skills appear through pi-code, including broad mandatory Superpowers and Nx triggers | Decide whether these workflows belong globally in pi. This is the largest single skill-list reduction. |
| Two memory interfaces | Shared instructions require `ai memory`; pi-code also exposes a separate Claude-style `memory` tool and `/memory` | Choose which memory behavior pi should expose; the stores and commands have different contracts. |
| Broken memory reminder | Local memory-reminder.ts invokes `ai memory hook`; installed ai rejects that obsolete subcommand | Repair or remove this extension. The current command is `ai memory prompt-hook`; its output contract also needs checking before changing the caller. |
| Duplicate reminder route | Pi-code imports Claude's working UserPromptSubmit `ai memory prompt-hook`, alongside other Claude hooks | Check whether the local broken reminder is needed at all before repairing it. |
| Workmux integration | workmux-status.ts invokes workmux, which is absent from the inspected PATH | Remove if workmux is retired, or retain only where the executable is provided. Herdr integration is separately present. |
| Writing overlap | deslop is a short explicit command; stop-slop is a broader writing guide; global instructions already cover writing | Keep both deliberately or consolidate. They are distinct scopes, not identical files. |
| Retired migration workflow | bd-to-br-migration is globally advertised, with a trigger that includes updating AGENTS.md; beads was previously removed | Remove globally unless another project still needs that migration. |
| Skill installer guidance | find-skills recommends imperative `npx skills` installation; four shared skills are Nix-managed | Keep discovery if useful, and decide whether its install workflow fits the declarative configuration. |
| Claude-history helpers | conversation-compiler reads Claude JSONL; readchat/searchchat/recall use a CWD-relative `.claude/skills/conversation-compiler/SKILL.md` loader that is absent here | Retain if pi should inspect Claude history; fix resolution if retained. These do not read native pi sessions. |
| Optional packages | Autoresearch, Zotero and reasoning repair add separate capabilities | Decide by intended use; installation alone is not evidence they are needed or obsolete. |
| Empty local prompt package | pi-hatim declares only `./prompts`; that directory has no actual templates | Consider dropping the package-list entry while retaining the directory's role as global pi configuration. |
| Local extension ownership | Four active extensions are ignored by Git | Choose which belong in the maintained configuration before pruning files. |
| Old local README | Describes individual file symlinks, omits the MCP exclusion, and claims nothing else overlaps | Update after the desired configuration is chosen. |

Pi-code's skill imports can be disabled **in pi only** by adding `-extensions/skills.ts` to its existing package extension exclusions. This would remove the 29 imported skill commands, leaving **14** from the shared tree and pi packages. It would also stop other Claude skill imports handled by that extension. It does not disable those plugins in Claude. This is a concrete possible pruning edit, not an applied change.

This skill filter **does not disable imported plugin hooks**. Excluding `-extensions/hooks/index.ts` would remove the entire hook bridge, including the currently imported ai memory prompt-hook, git-ai, docs-helper and herdr integrations. Pi-code's `--settings` JSON overlay can override plugin enablement for a pi invocation, but needs invocation wiring; no dedicated persistent pi-only per-plugin bridge switch was found. Selective imported-resource filtering was not tested. Choose the intended behavior before implementing a filter.

The pi-code memory extension's `/memory on|off` writes the Claude user settings file. A pi-only choice about that extension should therefore use pi package filtering rather than assuming the command changes pi alone.

Its separate store is `~/.pi/agent/memory/<project-slug>/`. That memory directory is currently absent, so there is no existing pi-code memory content being injected. Excluding `-extensions/memory.ts` would remove the extra capability while leaving `ai memory` available.

## Where durable changes belong

| Source | Change location |
| --- | --- |
| Pi packages, package extension exclusions, model selections | `home/hatim/pi/settings.json` |
| Pi-specific working agreement | `home/hatim/pi/APPEND_SYSTEM.md` |
| Instructions shared by all agents | `modules/agent-instructions/*.md` |
| Nix-managed shared skills | Manifest in `modules/agent-skills.nix`, followed by activation |
| Local shared skills | Tracked directories in `home/hatim/agents/skills/` |
| Pi-specific local extensions | Currently ignored `home/hatim/pi/extensions/` |
| Built-in agent definitions | Installed pi-subagents package; user/project overrides currently absent |

Deleting a Nix-managed skill symlink directly is temporary: activation recreates it while it remains in the manifest. Removing a shared skill affects the other agents using the same tree. Deleting package caches does not constitute a persistent package selection change.

## Evidence and limits

The audit used installed source, live symlink resolution, a pi RPC command catalogue, and startup extension probes. Catalogue probes used offline startup and disabled session persistence, without a model prompt. The first catalogue probe disabled MCP startup; an equivalent normal-startup probe confirmed the same active tool names, 42 prompt skills and 30,392-character base system prompt. The base measurement precedes before_agent_start hook injections. No user/project MCP configuration file was found in the inspected pi locations. External connector availability was not authenticated or exercised.

An earlier command-order probe, `pi --offline list`, was interpreted as a user prompt and attempted inference: offline mode suppresses startup networking rather than model requests. It created `~/.pi/agent/sessions/--hatimthayyil-code-config--/2026-10-18T08-31-33-616Z_01a14e23-38ef-7049-b1a1-0bc635751fb4.jsonl`, recording four request-timeout errors, no successful response and zero tool calls. The process exited 1 after interruption. The session is preserved; provider receipt of the request cannot be ruled out. Subsequent probes used explicit no-session RPC startup and sent no prompts. Configuration files were not modified by the probes. The package-list subcommand must come first: `pi list`.

While recording that command-line lesson, a shell-quoting mistake executed the same prompt command again. The second preserved record is `2026-10-18T08-37-34-293Z_01a14e28-b9d4-7068-ab46-12632c0d2aa9.jsonl` in the same directory. It likewise records four request-timeout errors and zero tool calls. No successful model response is recorded in either session. Literal command text must be passed with shell-safe quoting, including in memory notes.

The [command inventory](20261018T083206---pi-configuration-audit/commands.tsv) records all 82 returned commands, prompts and skill commands with source paths. The system prompt measurement includes ordinary pi instructions and loaded project context as well as global instructions and skill descriptions; it is not a measurement of removable skill overhead.

A small usage sample inspected nine session files modified within the preceding seven days, across their complete contents: 111 assistant messages and top-level calls to bash (114) and read (16). This sample does not establish that the remaining tools are unused; resumed older files, other projects, delegation children and skill use through ordinary reads limit that inference.

No live sessions, package data, skills or configurations were deleted. This report and its supporting files are the only repository additions from the audit.
