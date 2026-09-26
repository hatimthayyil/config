# ai.nix

## Why `trace2.eventTarget` lives in this module

git-ai learns about git operations through git's trace2 mechanism, not through
git hooks (its git hook support was removed; `src/commands/git_hook_handlers.rs`
is a removal path). `git ai install-hooks` points the whole system at the
daemon by running:

```
git config --global trace2.eventTarget af_unix:stream:<daemon trace2 socket>
git config --global trace2.eventNesting 0
```

`programs.git` renders `~/.config/git/config` as a symlink into the Nix store,
so that command cannot write. git-ai treats the failure as non-fatal and
continues (`src/commands/install_hooks.rs`, `run_hooks_install`), which leaves
trace2 off without any visible error: agent checkpoints still work, but commits
and rewrites are only picked up later by the daemon's untraced reflog scan
(`UNTRACED_FIXUP_MIN_AGE` 5s, 10 commits per pass, `HEAD` reflog only).

Declaring the two keys in `programs.git.settings` restores the traced path.

The socket path comes from git-ai's own defaults: the daemon home is
`~/.git-ai` (`src/config.rs`), the internal dir is `<home>/internal`, and the
trace socket is `<internal>/daemon/trace2.sock`, rendered as
`af_unix:stream:<path>` (`src/daemon.rs`). It falls back to a hashed temp-dir
socket only when the path is 100 characters or longer, which does not apply
here.

A socket path that does not exist yet is harmless: git drops trace2 events
silently, with no warning and no exit-code change, so the config is valid before
the daemon has ever started.
