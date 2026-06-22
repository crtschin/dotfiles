#!/usr/bin/env bash
# git-duw: wait for the current branch's in-flight GitHub CI run to settle,
# then push. The wait only lets the existing run (the one on whatever was last
# pushed) reach a terminal state; the push always happens afterwards. A passing
# run pushes quietly, a failing/cancelled run is logged first — CI never blocks
# the push the user asked for. All arguments are forwarded to `git push`.

# `|| branch=""` so a detached HEAD does not trip errexit before we handle it.
branch=$(git symbolic-ref --short HEAD 2>/dev/null) || branch=""
if [ -z "$branch" ]; then
  echo "git-duw: HEAD is detached; pushing without waiting for CI" >&2
  exec git push "$@"
fi

# Newest run for the branch is the one running on its current remote head.
# Fall back to an empty array if gh fails (no auth, non-GitHub remote, offline)
# so we degrade to a plain push instead of aborting under errexit.
run=$(gh run list --branch "$branch" --limit 1 \
  --json databaseId,headSha,workflowName 2>/dev/null) || run='[]'
run_id=$(jq -r '.[0].databaseId // empty' <<< "$run")

if [ -z "$run_id" ]; then
  echo "git-duw: no CI run found for '$branch'; pushing without waiting" >&2
  exec git push "$@"
fi

workflow=$(jq -r '.[0].workflowName // "?"' <<< "$run")
head_sha=$(jq -r '.[0].headSha[0:12] // "?"' <<< "$run")
echo "git-duw: waiting on '$workflow' run $run_id ($head_sha) for '$branch'..."

# --exit-status makes gh return non-zero for any non-success conclusion.
if gh run watch "$run_id" --exit-status; then
  echo "git-duw: CI passed; pushing"
else
  echo "git-duw: CI did not pass for run $run_id; failed jobs:" >&2
  # Skipped/successful jobs are noise here; list only the ones that broke.
  # `>&2` keeps the job lines next to our log; `|| true` guards errexit.
  gh run view "$run_id" --json jobs --jq \
    '.jobs[] | select(.conclusion != "success" and .conclusion != "skipped" and .conclusion != null and .conclusion != "") | "  - \(.name) [\(.conclusion)] \(.url)"' \
    >&2 2>/dev/null || true
  echo "git-duw: pushing anyway" >&2
fi

exec git push "$@"
