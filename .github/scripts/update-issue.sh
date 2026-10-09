#!/usr/bin/env bash
# Usage: update-issue.sh report <mode> <build-log> <nixpkgs-rev>
#        update-issue.sh close <mode>
#        update-issue.sh last-rev <mode>
set -euo pipefail

title() {
  case $1 in
    full) echo "Flake update failed" ;;
    llm-agents) echo "llm-agents update failed" ;;
    *) echo "unknown mode: $1" >&2; exit 1 ;;
  esac
}

find_issue() {
  gh issue list --state open --limit 100 --json number,title |
    jq -r --arg title "$(title "$1")" 'first(.[] | select(.title == $title) | .number) // empty'
}

failed_drvs() {
  awk -v q="'" '
    drv != "" { if (!/dependenc/) print drv; drv = "" }
    index($0, "Cannot build " q "/nix/store/") {
      drv = $0
      sub(".*Cannot build " q, "", drv)
      sub(q ".*", "", drv)
    }
    END { if (drv != "") print drv }
  ' "$1" |
    sed -E 's|^/nix/store/[a-z0-9]{32}-(.*)\.drv$|\1|' |
    sort -u
}

report() {
  local mode=$1 log=$2 rev=$3 body number name pname
  body=$(mktemp)
  {
    echo "Run: $RUN_URL"
    echo "nixpkgs: $rev"
    echo
    echo "Failed derivations:"
    while read -r name; do
      [[ -n $name ]] || continue
      pname=$(sed -E 's/-[^a-zA-Z].*$//' <<<"$name")
      echo "- \`$name\` ([Hydra](https://hydra.nixos.org/job/nixpkgs/trunk/$pname.x86_64-linux))"
    done < <(failed_drvs "$log")
    echo
    echo "<details><summary>Log tail</summary>"
    echo
    echo '```'
    tail -n 40 "$log"
    echo '```'
    echo "</details>"
    echo
    echo "Re-run with workflow_dispatch after fixing."
  } >"$body"

  number=$(find_issue "$mode")
  if [[ -n $number ]]; then
    gh issue comment "$number" --body-file "$body"
  else
    gh issue create --title "$(title "$mode")" --body-file "$body"
  fi
}

close() {
  local modes=("$1") mode number
  if [[ $1 == full ]]; then modes+=(llm-agents); fi
  for mode in "${modes[@]}"; do
    number=$(find_issue "$mode")
    if [[ -n $number ]]; then
      gh issue close "$number" --comment "Fixed by $RUN_URL"
    fi
  done
}

last_rev() {
  local number
  number=$(find_issue "$1")
  [[ -n $number ]] || return 0
  gh issue view "$number" --json body,comments --jq '.body, .comments[].body' |
    sed -nE 's/^nixpkgs: ([0-9a-f]+)$/\1/p' |
    tail -n 1
}

case $1 in
  report) report "$2" "$3" "$4" ;;
  close) close "$2" ;;
  last-rev) last_rev "$2" ;;
  *) echo "unknown command: $1" >&2; exit 1 ;;
esac
