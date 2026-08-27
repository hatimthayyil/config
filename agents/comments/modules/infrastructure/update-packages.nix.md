# update-packages.nix

## What it is for

`nix flake update` moves `flake.lock` and nothing else. A package that pins its
source with `fetchurl` — a released tarball rather than a flake input — keeps its
version and hash inside its own `.nix` file, beyond the lock file's reach. Left
alone such a package freezes silently at whatever version it was added with,
while the daily update job reports success.

This module builds a script that updates all of them, so the guarantee "the
daily job keeps this machine current" covers pinned tarballs too.

## Why it reads the overlay rather than the flake's packages

The obvious source is `self'.packages`, but `update-packages` is itself one of
those. Filtering that set forces evaluation of the derivation being defined and
evaluation does not terminate. `pkgs/overlay.nix` is applied directly instead.

It is also the more accurate list: the overlay holds exactly the packages this
repository defines, whereas `packages` also carries re-exports such as
`nix-fast-build` and build products such as `vscode-extensions`, neither of
which has an upstream tarball to track.

## Why the runner appends the attribute name

`nix-update-script` returns a bare command list and accepts an optional
`attrPath` that it appends itself. Leaving `attrPath` unset in each package and
appending the attribute name here keeps the name in one place — the overlay —
instead of repeating it as a string inside every package that wants updating.

## Alternative considered

`nvfetcher` solves the same problem from the other end: it tracks upstream
releases and generates a sources file that packages read, rather than rewriting
each package in place. It becomes the better fit once several packages track
moving upstreams, because the pins then collect in one generated file instead of
scattering across derivations. For a single tarball, `nix-update` rewriting the
derivation directly is the smaller mechanism.
