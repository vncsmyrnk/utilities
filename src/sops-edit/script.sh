#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

sops "$CONFIG_PATH/default.env"
