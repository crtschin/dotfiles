#!/usr/bin/env bash
# Check if working tree is dirty (tracked files only)
needs_pop=false
if ! git diff --quiet || ! git diff --cached --quiet; then
  git stash push -m "git-swing auto stash"
  needs_pop=true
fi

# Run git checkout, passing all arguments
if ! git checkout "$@"; then
  if [ "$needs_pop" = true ]; then
    git stash pop
  fi
  exit 1
fi

# Pop stash if we pushed one
if [ "$needs_pop" = true ]; then
  git stash pop
fi
