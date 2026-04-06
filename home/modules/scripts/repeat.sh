#!/usr/bin/env bash
times=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --times)
      times="$2"
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

if [[ $# -eq 0 ]]; then
  echo "Usage: repeat --times N <command> [args...]" >&2
  exit 1
fi

for (( i = 0; i < times; i++ )); do
  "$@"
done
