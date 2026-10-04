#!/usr/bin/env bash
shopt -s nullglob

manifest=$1
skills=$2

if [[ ! -d $skills ]]; then
  echo "agent-skills: $skills not found, skipping" >&2
  exit 0
fi

declare -A pinned=()
linked=()

for src in "$manifest"/*; do
  name=${src##*/}
  pinned[$name]=1
  target=$(readlink "$src")
  dest=$skills/$name
  if [[ -L $dest && $(readlink "$dest") == /nix/store/* ]]; then
    if [[ $(readlink "$dest") != "$target" ]]; then
      ln -sfn "$target" "$dest"
    fi
    linked+=("$name")
  elif [[ -e $dest || -L $dest ]]; then
    echo "agent-skills: keeping local $dest instead of pinned $target" >&2
  else
    ln -s "$target" "$dest"
    linked+=("$name")
  fi
done

for dest in "$skills"/*; do
  name=${dest##*/}
  if [[ -L $dest && -z ${pinned[$name]:-} && $(readlink "$dest") == /nix/store/* ]]; then
    rm "$dest"
  fi
done

if ! exclude=$(git -C "$skills" rev-parse --path-format=absolute --git-path info/exclude 2>/dev/null); then
  exit 0
fi
prefix=$(git -C "$skills" rev-parse --show-prefix)
begin="# BEGIN agent-skills (managed)"
end="# END agent-skills (managed)"

mkdir -p "${exclude%/*}"
touch "$exclude"
current=$(<"$exclude")
updated=$(
  awk -v b="$begin" -v e="$end" '$0 == b { skip = 1; next } $0 == e { skip = 0; next } !skip' "$exclude"
  if ((${#linked[@]})); then
    printf '%s\n' "$begin"
    for name in "${linked[@]}"; do
      printf '/%s%s\n' "$prefix" "$name"
    done
    printf '%s\n' "$end"
  fi
)

if [[ $updated != "$current" ]]; then
  printf '%s\n' "$updated" >"$exclude"
fi
