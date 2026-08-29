#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

if ! path=$(git worktree list |
  fzf --height=~10 |
  awk '{ print $1 }'); then
  echo "error: $path" >&2
  exit 1
fi
builtin cd "$path" || exit 1
echo "entering nested subshell"
PATH="${CURRENT_PATH:-"$PATH"}" exec "$SHELL"
