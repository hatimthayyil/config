# Agent transcript preservation

For: Claude Code, Codex, Pi and VS Code chat logs on eagle. They live untracked inside the config repo's working tree (`home/hatim/{claude,codex,pi,vscode}`, symlinked from `~` by `mkOutOfStoreSymlink`), with no backup. Need: no transcript ever lost to `git clean -fdx`, `rm`, agent auto-cleanup, disk or machine loss; declarative in this flake; established tools.

Checked 2026-10-08 against: Claude Code 2.1.295 docs ([claude-directory](https://code.claude.com/docs/en/claude-directory), [settings-reference](https://code.claude.com/docs/en/settings-reference), [env-vars](https://code.claude.com/docs/en/env-vars)); Codex 0.162.0 source (`/hatimthayyil/code/codex` @ a6c5f3a9fa); Pi 1.0.2 source (`/hatimthayyil/code/pi` @ 19451accd); nixpkgs b1b875982b17 (flake.lock); GitHub API for project activity; local measurements.

## Local facts

- `/` and `/home` are ext4 (LUKS). `/hatimthayyil` is btrfs (zstd:3), one subvolume `/hatimthayyil` on the secondary SSD (`modules/disko.nix`), so the transcripts physically sit on btrfs.
- Sizes: claude/projects 192M, claude/file-history 4.2M, claude/history.jsonl 1.3M, codex/sessions 65M (75 `.jsonl`, 0 `.zst`), codex `thread_history_1.sqlite` 17M + `logs_2.sqlite` 53M, pi/sessions 20M, vscode/workspaceStorage 86M. Largest transcript is 18M.
- Secrets: sops-nix with the host SSH key (`modules/secrets.nix`). R2 credentials can live there the same way `niks3-auth-token` does.
- Syncthing does not follow symlinks, so a `~` folder never covers `~/.claude` etc. Nothing backs the transcripts up today.
- `~/.ai/memory` is a bare git object store written by `ai memory` (21M loose, no commits on `main`). It holds memories, not raw transcripts. It is also unbacked.

## What the agents delete or rewrite

- Claude Code: the retention sweep runs in the background after a session starts and silently deletes `projects/*.jsonl`, subagent transcripts, `tool-results/`, `file-history/`, `plans/`, `paste-cache/`, `tasks/` and the rest once they are older than `cleanupPeriodDays`. The default is 30, the **minimum is 1, and `0` is now a validation error** (it no longer disables persistence; `CLAUDE_CODE_SKIP_PROMPT_HISTORY=1` does that). The current `99999` is valid.
  - Scope is "Any file", with normal precedence: managed > local project > shared project > user. A repo that commits `.claude/settings.json` with a low `cleanupPeriodDays` overrides the user value whenever a session runs there. The docs do not say whether that sweep is global.
  - A settings parse error pauses the sweep.
  - `claude purge` deletes a project's transcripts.
  - `file-history/` keeps only the 100 most recent checkpoints' snapshots.
  - Claude sets old transcripts aside as `*.orphaned-*` / `*.jsonl.superseded-*` instead of overwriting. Transcripts are mostly, but not strictly, append-only.
- Claude Code, symlinks: it saves `settings.json` by writing a temp file and renaming it, which replaces a symlinked file with a regular one ([report](https://claudeissues.com/issue/40857-bug-symlinkdirectories-writing-to-symlinked-file-replaces-symlink-with-regular-f), [symlink chain](https://claudeissues.com/issue/78162-atomic-write-to-claude-settings-json-fails-with-erofs-eacces-when-the-file-is-a)). That is why the whole directory is symlinked today.
- Codex: rollout compression to `.zst` (`codex-rs/rollout/src/compression.rs`, 7-day age, zstd 3) sits behind `features.local_thread_store_compression`, which is `Stage::UnderDevelopment` and off by default (`features/src/lib.rs`). It does not run here: there are 0 `.zst` files.
  - Deletion: `/delete` in the TUI and the app-server `thread/delete` remove the rollout file (`thread-store/src/local/delete_thread.rs`). Revert swaps in a new rollout file (`revert_thread.rs`). Archive moves files to `archived_sessions/`.
  - Thread history is also projected into SQLite (`thread_history_1.sqlite`, WAL). JSONL stays the source of truth while `background_paginated_rollout_migration` is off (UnderDevelopment).
- Pi: sessions are append-only JSONL (`appendFileSync`; a whole-file write happens only once, on the first flush, with `wx`). No pruning code exists; `migrations.ts` touches only auth and binaries.
- Relocation knobs:
  - Claude: only `CLAUDE_CONFIG_DIR`, which moves settings, history and plugins together. There is no transcripts-only directory.
  - Codex: `CODEX_HOME` moves everything; `CODEX_SQLITE_HOME` moves only the SQLite files.
  - Pi: `PI_CODING_AGENT_SESSION_DIR`, the `sessionDir` setting or `--session-dir` moves only the sessions.

## Comparison

| option | rm / git clean | agent sweep | disk loss | machine loss | encrypted offsite | Nix effort | status |
|---|---|---|---|---|---|---|---|
| restic 0.19.1 → R2 | yes (≤ timer interval) | yes (old snapshots) | yes | yes | yes, client-side | `services.restic.backups` + 2 sops secrets | active, 36k stars, release 2026-07 |
| rustic 0.11.4 | same as restic (same repo format) | yes | yes | yes | yes | no NixOS module | active, smaller |
| kopia 0.23.1 | yes | yes | yes | yes | yes | no NixOS module; config is imperative | active, release 2026-06 |
| borg 1.4.5 / borgmatic 2.1.7 | yes | yes | yes | yes | yes, but needs an SSH target (Hetzner box, BorgBase); no S3 | `services.borgbackup.jobs` / `services.borgmatic` | active; borg 2 still beta (2.0.0b24) |
| git repo auto-commit + private remote | yes | yes | yes | yes | no (plaintext unless git-crypt/gcrypt) | HM `services.git-sync` or a custom timer | git 2.55 |
| bare git repo (`--git-dir/--work-tree`) | as normal git | yes | yes | yes | no | same as above | n/a |
| git-annex 10.20260421 / datalad 1.7.1 | yes | yes | yes | yes | depends on special remote | heavy | active |
| btrfs snapshots (btrbk 0.32.7 / snapper 0.13.1) | yes, instant restore | yes | no | no | no | `services.btrbk` / `services.snapper` | active |
| syncthing 2.1.6 versioning | only remote-side deletions | no (deletion propagates) | partly | partly | no | HM `services.syncthing.settings` | active |
| purpose-built archivers | varies | yes | if they upload | if they upload | some | none packaged | 0-12 stars, weeks old |

## Options

- **Relocate vs keep in repo.**
  - Linking only the config files breaks: Claude's atomic rename replaces the symlink and detaches `settings.json` from the repo.
  - `CLAUDE_CONFIG_DIR` cannot split config from data.
  - Symlinking data subdirs out (`projects/`, `sessions/`) works for those dirs, but every new data dir an agent adds lands in the repo again: per-directory bookkeeping forever.
  - Pi alone can be cleanly split with `sessionDir`.
  - Net: relocation reduces the `git clean` blast radius but does not remove the need for backup. Keep the layout and back up the agent directories directly.
- **restic.**
  - Chunking: content-defined (Rabin, 512 KiB-8 MiB, ~1 MiB target), zstd in repo v2, AES-256 + Poly1305 client-side ([references](https://restic.readthedocs.io/en/stable/100_references.html)).
  - Measured: 20 snapshots of the 18M transcript growing in 5% steps = 13M repo (final file zstd -3 = 2.4M). Each snapshot re-stores the changed tail chunk; the cost is negligible.
  - NixOS options (pinned nixpkgs): `paths exclude repository passwordFile environmentFile timerConfig user pruneOpts runCheck checkOpts backupPrepareCommand inhibitsSleep initialize`.
  - R2: the S3 backend with `s3:https://<account>.r2.cloudflarestorage.com/<bucket>` and `AWS_DEFAULT_REGION=auto`. R2 is not named in the restic docs.
  - Cost: [R2](https://developers.cloudflare.com/r2/pricing/) gives 10 GB-month free, then $0.015/GB, no egress fees. A 15-minute timer stays well inside the free Class A operations.
- **rustic.** Reads and writes restic repos and has a lock-free design, but there is no NixOS module and it is younger. Only worth it with a concrete need.
- **kopia.** Good dedup and native S3, but policies live in the repo and are set via CLI or UI, not declaratively; no NixOS module.
- **borg/borgmatic.** Best-in-class dedup with mature NixOS modules, but 1.x needs an SSH/borg server, so it cannot use R2. That means a second provider (Hetzner Storage Box, BorgBase). Borg 2 (rclone/S3 via borgstore) is still beta with alpha-quality warnings.
- **Normal git repo** (auto-commit by timer or hooks).
  - Deltas: work well for append-only text. Measured 20 commits of the growing 18M file: 43M loose → 3.6M after `git gc` (`gc.auto` 6700 loose objects, `gc.autoPackLimit` 50; [git-gc](https://git-scm.com/docs/git-gc)).
  - Costs:
    - plaintext history forever; removing a pasted API key needs `git filter-repo` and a force-push;
    - GitHub push protection rejects pushes containing secrets, and the backup then fails until history is rewritten;
    - `auth.json` and `.credentials.json` must be excluded by hand;
    - live SQLite cannot be committed safely;
    - repack memory grows with history.
  - Commit cadence:
    - a systemd timer covers every agent with one unit;
    - hooks (Claude `SessionEnd`, Codex `hooks.json`, Pi extension events) need three implementations and miss crashes;
    - Claude's `transcript_path` is written asynchronously and can lag the hook.
  - Nothing here needs the diffable, inspectable history git provides.
- **Bare git repo.** Same storage as a normal repo, with `--work-tree` pointed at the agent dirs. It only hides the `.git` directory, and adds a `git clean`-on-the-work-tree hazard of its own. No advantage here.
- **git-annex / datalad.** Annexed files are immutable content-addressed blobs, so a growing JSONL is stored in full at every commit: worse than plain git and far heavier. They suit large static files.
- **btrfs snapshots** (btrbk/snapper on `/hatimthayyil`).
  - Pros: instant, near-free, minute-level restore from `git clean`/`rm`. A read-only snapshot also gives restic a crash-consistent view of the SQLite WAL files.
  - Limit: same disk and same LUKS volume, so no protection from disk or machine loss. A second layer, not a backup.
- **Syncthing / Nextcloud.** Sync, not backup:
  - local deletions propagate;
  - [versioning](https://docs.syncthing.net/users/versioning.html) archives only changes received from other devices ("If Alice changes a file locally … Syncthing will not and can not archive the old version");
  - syncthing skips symlink targets.
  - Not an option for this goal.
- **Purpose-built archivers.**
  - [wangjohn/agent-archive](https://github.com/wangjohn/agent-archive): Claude, Codex, Cursor → S3/R2 via hooks; created 2026-09; v0.1.1 has no Linux binary; prunes on a retention schedule.
  - [bloodcarter/ai-session-backup](https://github.com/bloodcarter/ai-session-backup): macOS/iCloud only.
  - [djayuffe/agent-backup](https://github.com/djayuffe/agent-backup): Markdown/ZIP exports, created 2026-09.
  - [vredchenko/claude-transcripts](https://github.com/vredchenko/claude-transcripts): Claude only; CouchDB + S3 in Docker.
  - [neonplants/claude-code-session-archiver](https://github.com/neonplants/claude-code-session-archiver): Claude skill, dormant since 2025-10.
  - Viewers and exporters, not archives: [daaain/claude-code-log](https://github.com/daaain/claude-code-log) 1.7.0 (active, HTML/Markdown; Codex beta), [simonw/claude-code-transcripts](https://github.com/simonw/claude-code-transcripts) 0.6 (last push 2026-02), [specstoryai/getspecstory](https://github.com/specstoryai/getspecstory) 2.15.1 (Markdown capture), [ryoppippi/ccusage](https://github.com/ryoppippi/ccusage) (usage stats only).
  - Publishers: [badlogic/pi-share-hf](https://github.com/badlogic/pi-share-hf) publishes redacted Pi sessions to a public Hugging Face dataset (sharing, not backup).
  - None is Nix-packaged; all are young or single-agent. Useful for reading archives, not as the archive.

## Choice

Keep the agent directories where they are (Claude's rename-on-save makes any split worse than the risk it removes). Add one NixOS `services.restic.backups.agents` job to a private R2 bucket:

- **What it backs up:**
  - `user = "hatim"`;
  - paths `home/hatim/{claude,codex,pi,vscode}` plus `~/.ai`;
  - excludes `cache/`, `debug/`, `*.sqlite-shm`.
- **When:** `timerConfig.OnCalendar = "*:0/15"`, `Persistent = true`.
- **Credentials:** password and R2 keys from sops-nix.
- **Retention:** no `pruneOpts`. Keeping every snapshot is what makes "never lost" true, because files deleted by `/delete`, `claude purge` or a lowered `cleanupPeriodDays` survive only in old snapshots, and the cost is the new data plus small tail churn.
- **Checks:** a weekly `restic check --read-data-subset`.
- **Optional hardening:** an R2 bucket lock on the `data/`, `index/`, `snapshots/` and `keys/` prefixes (not `locks/`) makes the never-pruned repo undeletable from this machine; verify restic runs cleanly against it before relying on it.

Add `services.btrbk` hourly read-only snapshots of `/hatimthayyil` as the local layer only if 15-minute loss windows matter. Its `snapshot_preserve` can also feed restic a consistent view of the Codex SQLite files.

Not git: it gives worse secret handling (plaintext and permanent, push protection breaks pushes), needs per-file exclusions and has no SQLite story, for no benefit restic lacks. Not syncthing: sync propagates deletion. Not the purpose-built tools: none is mature, Linux-ready and multi-agent.
