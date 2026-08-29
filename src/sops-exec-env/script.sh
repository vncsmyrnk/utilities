#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

command="${*:-""}"
if [[ -z "$command" ]]; then
  echo "a command is required." >&2
  exit 1
fi

sops exec-env "$CONFIG_PATH/default.env" "$command"
