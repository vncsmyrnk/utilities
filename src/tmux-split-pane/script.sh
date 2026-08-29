#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

if ! current_pane_id=$(tmux list-panes -F '#{pane_id}' -f '#{m:1,#{pane_active}}'); then
  echo "failed to fetch current pane id." >&2
fi

tmux split-window -h
tmux split-window -v

if [[ -n "$current_pane_id" ]]; then
  tmux select-pane -t "$current_pane_id"
fi
