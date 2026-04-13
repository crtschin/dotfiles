#!/usr/bin/env bash
set -euo pipefail

# Usage: repeat <N> <command...>

if [[ $# -lt 2 ]] || ! [[ $1 =~ ^[0-9]+$ ]]; then
  echo "Usage: repeat <N> <command...>" >&2
  exit 1
fi

count=$1; shift

for ((i = 0; i < count; i++)); do
  "$@"
done
