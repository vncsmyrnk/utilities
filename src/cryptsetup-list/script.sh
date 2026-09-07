#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

block_devices_result=$(
  lsblk -Q "NAME =~ '$UTILITIES_CRYPTSETUP_PREFIX.*'" -np -o PKNAME,MOUNTPOINT,FSUSED,FSSIZE,FSUSE%
)

if [[ -z "$block_devices_result" ]]; then
  echo "no active container found." >&2
  exit 1
fi

rows=""
while read -r loop_device mountpoint fs_used fs_size fs_usage; do
  back_file=$(
    losetup "$loop_device" -O BACK-FILE -n
  )
  rows+="$back_file $mountpoint $fs_used $fs_size $fs_usage"$'\n'
done <<<"$block_devices_result"

column_flags=("-N" "FILE,MOUNTPOINT,USED,SIZE,USAGE")
column -t "${column_flags[@]}" <<<"$rows"
