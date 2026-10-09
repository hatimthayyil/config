#!/usr/bin/env bash
# Writes mode (full, llm-agents or none) and nixpkgs-rev to $GITHUB_OUTPUT.
set -euo pipefail

min_age=$((3 * 24 * 3600))
script_dir=$(dirname "$0")

channel=$(curl -fsSL https://channels.nixos.org/nixos-unstable/git-revision)
locked=$(jq -r '.nodes[.nodes.root.inputs.nixpkgs].locked
  | .rev // (.url | capture("\\.(?<rev>[0-9a-f]+)/nixexprs").rev)' flake.lock)
last_full=$(git log -1 --format=%ct --fixed-strings --grep="$FULL_COMMIT_MESSAGE")
age=$(($(date +%s) - ${last_full:-0}))
last_failed=$("$script_dir/update-issue.sh" last-rev full)

echo "channel=$channel locked=$locked last-full-age=$((age / 3600))h last-failed=${last_failed:-none}"

mode=none
if [[ $EVENT_NAME == workflow_dispatch ]]; then
  mode=$DISPATCH_MODE
elif [[ $channel != "$locked"* && $channel != "$last_failed" ]] && ((age >= min_age)); then
  mode=full
elif [[ $SCHEDULE == "$LLM_AGENTS_CRON" ]]; then
  mode=llm-agents
fi

if [[ $mode == full ]]; then rev=$channel; else rev=$locked; fi

echo "mode=$mode"
{
  echo "mode=$mode"
  echo "nixpkgs-rev=$rev"
} >>"$GITHUB_OUTPUT"
