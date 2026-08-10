# caches.nix

## Why a registry rather than lists

Each cache is one entry pairing a URL with the key that signs it. Before, the
two lived in separate lists and nothing tied them together — `cache.numtide.com`
sits next to a `niks3.numtide.com-1:` key, which is correct but unverifiable by
reading either list alone.

Consumers call `select` with the names they want. `public` is the set every
consumer shares, and is what `flake.lib.caches` exposes, so the CI runner
(`.github/actions/setup-nix`) and `just nixbuild-sync-caches` are unaffected by
anything a host chooses to add.

## Why nixbuild is in the registry but not in `public`

`public` reaches three consumers, and two of them must not have it:

- the CI runner builds *into* nixbuild's store (`--store ssh-ng://`)
- `just nixbuild-sync-caches` writes to nixbuild's own account settings, which
  would make it substitute from itself

Only a host should select it. `modules/nixbuild.nix` does that, and eagle picks
up the group. See `agents/comments/modules/nixbuild.nix.md`.
