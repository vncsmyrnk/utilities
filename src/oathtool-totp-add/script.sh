#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

usage() {
  echo "usage: $0 [entity]"
  echo
  echo "reads a secret from STDIN and creates the encrypted GPG file for TOTP generation."
}

entity="${1:-""}"
if [[ -z "$entity" ]]; then
  usage >&2
  exit 1
fi

cleanup() {
  rm -rf "$temp_dir"
}
trap cleanup EXIT

temp_dir=$(mktemp -d)
read -r secret
echo "$secret" >"$temp_dir/$entity"
unset secret

gpg -c "$temp_dir/$entity"
mv "$temp_dir/$entity.gpg" "$CONFIG_PATH/$entity.gpg"
