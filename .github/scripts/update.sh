#!/usr/bin/env bash
# Usage: update.sh <update>
# Applies .#ci.updates.<update> and writes `changed` and `key` to GITHUB_OUTPUT.
set -euo pipefail

spec=$(nix eval --json ".#ci.updates.$1")
trigger=$(jq -r .trigger <<<"$spec")
mapfile -t inputs < <(jq -r '.inputs[]' <<<"$spec")

locked_rev() {
  jq -er --arg input "$trigger" '.nodes[.nodes.root.inputs[$input]].locked.rev' flake.lock
}

before=$(locked_rev)
if ((${#inputs[@]})); then
  nix flake update "${inputs[@]}"
else
  nix flake update
  nix run .#update-packages
fi
after=$(locked_rev)

{
  if [[ $before == "$after" ]]; then
    echo "changed=false"
  else
    echo "changed=true"
  fi
  echo "key=$trigger@$after on $(git rev-parse HEAD)"
} >>"$GITHUB_OUTPUT"
