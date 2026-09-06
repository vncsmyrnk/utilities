#!/usr/bin/env bash
# vim: set ft=sh:
set -eou pipefail

RETRIES=5
BASE_MS=100
MULTIPLIER=2
MAX_MS=$((60000 * 5))

expotential_backoff_wait_time() {
  base_ms="$1"
  multiplier="$2"
  n="$3"
  max_ms="$4"
  bc < <(
    cat <<EOF
w = $base_ms * $multiplier ^ $n
if (w > $max_ms) $max_ms \
else w
EOF
  )
}

print_ms() {
  s="${2:-1}"
  bc < <(
    cat <<EOF
scale=$s; \
if ($1 < 1000) print $1, "ms" \
else if ($1 < 60000) print $1/1000, "s" \
else if ($1 < 3600000) print $1/60000, "min" \
else print $1/3600000, "h"
EOF
  )
}

usage() {
  echo "usage: $0 [options]"
  column -t -s '|' < <(
    cat <<EOF
|-c,--count|limit number of retries (default: $RETRIES)
|-b,--base|initial value in milliseconds (default: $(print_ms "$BASE_MS"))
|-m,--multiplier|factor by which the delay increases (default: $MULTIPLIER)
|-l,--limit|ceiling limit in milliseconds (default: $(print_ms "$MAX_MS" 0))
EOF
  )
}

_retries="$RETRIES"
_base_ms="$BASE_MS"
_multiplier="$MULTIPLIER"
_max_ms="$MAX_MS"

while [[ $# -gt 0 ]]; do
  case $1 in
  -c | --count)
    _retries="$2"
    shift 2
    ;;
  --count=*)
    _retries="${1#*=}"
    shift
    ;;
  -b | --base)
    _base_ms="$2"
    shift 2
    ;;
  --base=*)
    _base_ms="${1#*=}"
    shift
    ;;
  -m | --multiplier)
    _multiplier="$2"
    shift 2
    ;;
  --multiplier=*)
    _multiplier="${1#*=}"
    shift
    ;;
  -l | --limit)
    _max_ms="$2"
    shift 2
    ;;
  --limit=*)
    _max_ms="${1#*=}"
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

if [[ -z "$*" ]]; then
  usage
  exit 1
fi

n=0
while ! ("$@"); do
  if [[ "$((n++))" -ge "$_retries" ]]; then
    exit 1
  fi
  time_ms="$(expotential_backoff_wait_time "$_base_ms" "$_multiplier" "$n" "$_max_ms")"
  echo "($n/$_retries) next retry in $(print_ms "$time_ms")" >&2
  sleep "$(bc <<<"$time_ms / 1000")"
done
