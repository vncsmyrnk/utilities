#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

usage() {
  echo "usage: $0 [name] [options]"
  column -t -s '|' < <(
    cat <<EOF
|-D,--delete|unstows target
EOF
  )
}

stow() {
  if output=$(command stow "$@" 2>&1); then
    return
  fi
  mapfile conflicting_files -t < <(grep -oP '[ ]+\* cannot stow \K.+(?= over existing target .+ since neither a link nor a directory and --adopt not specified)' <<<"$output")
  if [[ -z "${conflicting_files[*]}" ]]; then
    echo "$output"
    return 1
  fi
  printf "%s" "${conflicting_files[@]}"
  return 1
}

src=
while [[ $# -gt 0 ]]; do
  case $1 in
  -D | --delete)
    stow_flags+=("-D")
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
    if [[ -n "$src" ]]; then
      echo "invalid extra argument." >&2
      exit 1
    fi
    src="$1"
    shift
    ;;
  esac
done

config=$(cat "$CONFIG_PATH/$src.json" 2>/dev/null || echo '{}')
if ! stow_target=$(jq -cre '.stow' <<<"$config" 2>/dev/null); then
  stow_target="$HOME"
else
  stow_target=$(envsubst <<<"$stow_target")
fi

target_name="$UTILITIES_CRYPTSETUP_PREFIX$src"
if ! mountpoint=$(
  lsblk -Q "NAME=='$target_name'" -n -o MOUNTPOINT
); then
  exit 1
fi

if [[ -z "$mountpoint" ]]; then
  echo "device is not mounted."
  exit 1
fi

_stow+=(
  'stow' "${stow_flags[@]}" '-d' "$mountpoint"
  '-t' "$stow_target" '.'
)
if ! conflicts=$("${_stow[@]}" 2>&1); then
  tmp=$(mktemp -d -t utilities-cryptsetup-stow-conflicting.XXXX)
  while read -r conflict; do
    file="$stow_target/$conflict"
    cp --parents "$file" "$tmp"
    rm -f "$file"
  done < <(grep -oP ".+$mountpoint/\K.+" <<<"$conflicts")
  echo "conflicting files moved to $tmp." >&2
  "${_stow[@]}"
fi
