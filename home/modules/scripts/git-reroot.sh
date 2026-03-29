#!/usr/bin/env bash
# Save original HEAD
orig=$(git rev-parse HEAD)

# Check if working tree is dirty (tracked files only)
needs_pop=false
if ! git diff --quiet || ! git diff --cached --quiet; then
  git stash push -m "git-reroot auto stash"
  needs_pop=true
fi

# Run git rebase, passing all arguments
if ! git rebase "$@"; then
  # Rebase failed — abort it, pop stash if needed, exit
  git rebase --abort 2>/dev/null || true
  if [ "$needs_pop" = true ]; then
    git stash pop
  fi
  exit 1
fi

# Pop stash if we pushed one
if [ "$needs_pop" = true ]; then
  if ! git stash pop; then
    # Pop failed (conflicts) — revert everything
    git checkout -- . && git clean -fd   # clear failed merge state
    git reset --hard "$orig"             # undo the rebase
    git stash pop                        # now pops cleanly against original base
    echo "git-reroot: stash pop conflicted with rebase result; reverted to original state" >&2
    exit 1
  fi
fi
