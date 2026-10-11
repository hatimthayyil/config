#!/usr/bin/env bash
# Usage: update-issue.sh seen <key>
#        update-issue.sh report <key> <build-log>
#        update-issue.sh close
# Reads ISSUE_TITLE and RUN_URL from the environment.
set -euo pipefail

find_issue() {
  gh issue list --state open --limit 100 --json number,title |
    jq -r --arg title "$ISSUE_TITLE" 'first(.[] | select(.title == $title) | .number) // empty'
}

seen() {
  local number
  number=$(find_issue)
  [[ -n $number ]] || return 1
  gh issue view "$number" --json body,comments |
    jq -e --arg key "Key: \`$1\`" '[.body, .comments[].body] | any(contains($key))' >/dev/null
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
  local key=$1 log=$2 body number name
  seen "$key" && return 0
  body=$(mktemp)
  [[ -f $log ]] || : >"$log"
  {
    echo "Run: $RUN_URL"
    echo "Key: \`$key\`"
    echo
    echo "Failed derivations:"
    while read -r name; do
      [[ -n $name ]] || continue
      echo "- \`$name\`"
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

  number=$(find_issue)
  if [[ -n $number ]]; then
    gh issue comment "$number" --body-file "$body"
  else
    gh issue create --title "$ISSUE_TITLE" --body-file "$body"
  fi
}

close() {
  local number
  number=$(find_issue)
  if [[ -n $number ]]; then
    gh issue close "$number" --comment "Fixed by $RUN_URL"
  fi
}

case $1 in
  seen) seen "$2" ;;
  report) report "$2" "$3" ;;
  close) close ;;
  *) echo "unknown command: $1" >&2; exit 1 ;;
esac
