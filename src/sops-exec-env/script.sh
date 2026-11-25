#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

env_file="$CONFIG_PATH/default.env"

usage() {
  echo "usage: $0 [name] [options]"
  column -t -s '|' < <(
    cat <<EOF
|-f,--sops-file|path for the sops environment file (default: $env_file)
EOF
  )
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -f | --sops-file)
    env_file="$2"
    shift 2
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

command="${*:-""}"
if [[ -z "$command" ]]; then
  echo "a command is required." >&2
  usage >&2
  exit 1
fi

if [[ ! -f "$env_file" ]]; then
  echo "sops environment file not found." >&2
  exit 1
fi

sops exec-env "$env_file" "$command"
