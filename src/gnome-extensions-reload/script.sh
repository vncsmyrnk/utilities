#!/usr/bin/env bash
set -eou pipefail

usage() {
  echo "usage: $0 [name] [options]"
  column -t -s '|' < <(
    cat <<EOF
|-a,--all|reload all extensions
|-d,--dry-run|do not reload any extension
|-f REGEX,--filter=REGEX|use grep to filter extensions
EOF
  )
}

GREP_FILTER=.

all=false
dry_run=false
_grep_filter=$GREP_FILTER

while [[ $# -gt 0 ]]; do
  case $1 in
  -a | --all)
    all=true
    shift
    ;;
  -d | --dry-run)
    dry_run=true
    shift
    ;;
  -f | --filter)
    _grep_filter="$2"
    shift 2
    ;;
  --filter=*)
    _grep_filter="${1#*=}"
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  --)
    shift
    break
    ;;
  *)
    break
    ;;
  esac
done

if [[ -z "${1:-}" ]] && [[ "$all" = false ]] && [[ "$_grep_filter" = "$GREP_FILTER" ]]; then
  usage
  exit 1
fi

re_grep_good_input='^[A-Za-z0-9.@][A-Za-z0-9.@-]+[A-Za-z]$'

extensions_result=$(gnome-extensions list)
if [[ "$all" = true ]] || [[ "$_grep_filter" != "$GREP_FILTER" ]]; then
  if [[ ! "$_grep_filter" =~ $re_grep_good_input ]]; then
    echo "bad filter." >&2
    exit 1
  fi
  mapfile -t extensions < <(grep "$_grep_filter" <<<"$extensions_result")
  if [[ -z "${extensions[*]}" ]]; then
    echo "no extension found with the current filter." >&2
    exit 1
  fi
else
  if [[ ! "$1" =~ $re_grep_good_input ]]; then
    echo "bad filter." >&2
    exit 1
  fi
  if ! grep -qx "$1" <<<"$extensions_result"; then
    echo "no extension found." >&2
    exit 1
  fi
  extensions=("$1")
fi

for e in "${extensions[@]}"; do
  echo "$e" >&2
  if [[ "$dry_run" = true ]]; then
    continue
  fi
  gnome-extensions disable "$e"
  gnome-extensions enable "$e"
done
