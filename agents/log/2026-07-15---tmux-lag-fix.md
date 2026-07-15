# tmux periodic lag

Recurring tmux stall, roughly every few seconds, traced to two bugs in
`modules/cli-utils.nix`'s `programs.tmux` block. Nushell as
`default-shell` made the symptom worse but was not the root cause.

## Root causes

1. `tokyo-night-tmux`'s GitHub PR/issue/review widget
   (`wb-git-status.sh`) was silently enabled. Its "off" check only
   treats the literal string `"0"` as off; `@tokyo-night-tmux_show_wbg`
   was never set, so it defaulted to on. Each invocation runs `gh pr
   list`, `gh pr status`, `gh issue list` (3 network calls). It
   self-throttles with `sleep 20` when `status-interval < 20`;
   `status-interval` was 5 (tmux-sensible's default, never overridden),
   so it produced a burst of GitHub API calls roughly every 20-25s per
   attached tmux session with a github.com remote as its active pane
   path.
2. `default-shell` was nushell. tmux uses `default-shell` for all
   internal job execution — status-bar `#()` commands, popups, plugin
   scripts — not just interactive panes. Measured `nu -c` at ~180ms vs
   `bash -c` at ~120ms for the same status-right widget chain (~50%
   more fork/exec overhead), incurred every `status-interval` seconds.
   nushell is also semantically the wrong tool here: `nu -c "... 2>&1"`
   fails to parse (nushell uses `out+err>`, not POSIX redirection); it
   only worked because the widget scripts re-exec via their own
   `#!/usr/bin/env bash` shebang.

## Fix

- `shell = "${pkgs.bash}/bin/bash"` — keeps tmux's internal job
  execution POSIX and fast.
- `set -g default-command "exec ${pkgs.nushell}/bin/nu -l"` in
  `extraConfig` — panes still land in nushell interactively; standard
  split for running a non-POSIX login shell under tmux (same approach
  fish users use).
- `set -g @tokyo-night-tmux_show_wbg 0` — explicitly disables the
  GitHub widget.
- `set -g status-interval 15` in `extraConfig`, overriding
  tmux-sensible's `5`. Config ordering is `tmuxConf` (mkBefore) →
  plugin blocks → `extraConfig` (mkAfter), so this wins.

## Verified

- `nix build .#nixosConfigurations.eagle.config.system.build.toplevel`
  succeeds.
- Generated `xdg.configFile."tmux/tmux.conf"` output confirmed:
  `default-shell` is bash, `@tokyo-night-tmux_show_wbg 0` is set,
  `default-command` execs nu, and `status-interval 15` is the only
  line setting that option (wins over tmux-sensible's `5`).

## Residual, not fixed

`git-status.sh` (the git-status widget, still in use) runs a
synchronous `git fetch --atomic origin` when `.git/FETCH_HEAD` is >5
minutes stale, blocking that status-bar render until the fetch
completes. Could still cause an occasional multi-second stall on a
slow connection. Left as-is — much less frequent than the wbg issue.
Open decision: background it or remove it.

## Not yet applied

Change is written but not committed or switched. Requires `just
switch` plus a tmux server restart (`tmux kill-server`) or fresh
sessions — `default-shell`/`default-command` only take effect for new
sessions/panes, not the currently running server.
