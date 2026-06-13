#!/usr/bin/env bash
# Spawns a temporary database for the duration of the given command
# and preloads PG* variables so it can connect to it.
set -euo pipefail

test_directory="$(mktemp -d)"
# Always tear down the server and temp dir, even when the command fails.
cleanup() {
  pg_ctl -D "$test_directory" stop || true
  rm -rd "$test_directory"
}
trap cleanup EXIT

export PGHOST=$test_directory
PGPORT=$(free-port)
export PGPORT
initdb -D "$test_directory"
pg_ctl -D "$test_directory" start -o "-k $PGHOST"
createuser -s postgres
PGUSER=postgres PGCONNECT="user=postgres password=postgres dbname=postgres host=$test_directory" PGDATABASE=postgres "$@"
