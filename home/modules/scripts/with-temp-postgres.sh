#!/usr/bin/env bash
# Spawns a temporary database for the duration of the given command
# and preloads PG* variables so it can connect to it.
set -euo pipefail

test_directory="$(mktemp -d)"
export PGHOST=$test_directory
PGPORT=$(freeport)
export PGPORT
initdb -D "$test_directory"
pg_ctl -D "$test_directory" start -o "-k $PGHOST"
createuser -s postgres
PGUSER=postgres PGCONNECT="user=postgres password=postgres dbname=postgres host=$test_directory" PGDATABASE=postgres "$@"
ret=$?
pg_ctl -D "$test_directory" stop
rm -rd "$test_directory"
exit $ret
