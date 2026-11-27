#!/usr/bin/env bash
# vim: set ft=sh:
set -euo pipefail

src="$DATA_PATH/$1.img"
if [[ ! -f "$src" ]]; then
  echo "container file not found." >&2
  exit 1
fi

loop_device=$(losetup -j "$src" -O NAME -n)
if [[ -z "$loop_device" ]]; then
  echo "device not mounted" >&2
  exit 1
fi

mountpoint=$(
  lsblk "$loop_device" -Q 'MOUNTPOINT' -np -o MOUNTPOINT
)
if [[ -z "$mountpoint" ]]; then
  echo "no mountpoint found for loop device." >&2
  exit 1
fi

if fuser -s -m "$mountpoint"; then
  fuser -v -m "$mountpoint"
  read -r -p "kill and procceed? (y/N) " answer
  if [[ ! "$answer" =~ ^([Yy])$ ]]; then
    exit 1
  fi
  fuser -s -m "$mountpoint" -k
fi

if ! umount "$mountpoint"; then
  echo "failed to umount." >&2
  exit 1
fi

target_name="$UTILITIES_CRYPTSETUP_PREFIX$1"
if ! cryptsetup close "$target_name"; then
  echo "failed close device." >&2
  exit 1
fi

rm -rf "$mountpoint"
