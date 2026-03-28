#!/usr/bin/env bash
# git-to-worktree: Convert a normal git checkout into a worktree layout.
#
# Result:
#   .bare/   - bare git data
#   .git     - file pointing to .bare/
#   main/    - worktree with all original contents preserved

# --- State tracking for rollback ---
STASH_CREATED=false
BARE_CREATED=false
WORKTREE_CREATED=false
GIT_DIR_REMOVED=false
TEMP_BACKUP=""

cleanup() {
  local exit_code=$?
  if [ $exit_code -eq 0 ]; then
    return
  fi

  echo "git-to-worktree: error encountered, rolling back..." >&2

  # Pop stash if we created one (try in main/ first, then current dir)
  if [ "$STASH_CREATED" = true ]; then
    if [ -d "main/.git" ] || [ -f "main/.git" ]; then
      git -C main stash pop 2>/dev/null || true
    else
      git stash pop 2>/dev/null || true
    fi
  fi

  # Remove worktree if partially created
  if [ "$WORKTREE_CREATED" = true ] && [ -d "main" ]; then
    git --git-dir=".bare" worktree remove --force main 2>/dev/null || rm -rf main
  fi

  # Restore .git directory if it was removed
  if [ "$GIT_DIR_REMOVED" = true ] && [ ! -d ".git" ]; then
    if [ -f ".git" ]; then
      rm -f .git
    fi
    cp -a .bare .git 2>/dev/null || true
    git config --file .git/config core.bare false
  fi

  # Remove .bare if we created it (only if .git is restored or still present)
  if [ "$BARE_CREATED" = true ] && [ -d ".bare" ] && [ -d ".git" ]; then
    rm -rf .bare
  fi

  # Restore working tree files from temp backup
  if [ -n "$TEMP_BACKUP" ] && [ -d "$TEMP_BACKUP" ]; then
    # Move files back (excluding .git which we handle separately)
    find "$TEMP_BACKUP" -maxdepth 1 -mindepth 1 | while read -r item; do
      name=$(basename "$item")
      mv "$item" "./$name"
    done
    rm -rf "$TEMP_BACKUP"
  fi

  echo "git-to-worktree: rollback complete, repo restored to original state." >&2
}
trap cleanup EXIT

# --- Step 1: Validate ---
if [ ! -d ".git" ]; then
  if [ -f ".git" ]; then
    echo "git-to-worktree: already converted (found .git file, not directory)" >&2
    exit 1
  fi
  echo "git-to-worktree: must be run from the repo root (no .git directory found)" >&2
  exit 1
fi

if [ -d ".bare" ]; then
  echo "git-to-worktree: .bare/ already exists, aborting" >&2
  exit 1
fi

if [ -d "main" ]; then
  echo "git-to-worktree: main/ already exists, aborting" >&2
  exit 1
fi

# Check we're not already a bare repo
if git rev-parse --is-bare-repository 2>/dev/null | grep -q true; then
  echo "git-to-worktree: repo is already bare" >&2
  exit 1
fi

# --- Step 2: Record current branch ---
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
if [ -z "$BRANCH" ]; then
  echo "git-to-worktree: HEAD is detached, aborting" >&2
  exit 1
fi

echo "git-to-worktree: converting branch '$BRANCH' to worktree layout..."

# --- Step 3: Stash if dirty ---
if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  echo "git-to-worktree: stashing working tree changes..."
  git stash push --include-untracked -m "git-to-worktree auto stash"
  STASH_CREATED=true
fi

# --- Step 4: Backup working tree (non-.git files) ---
TEMP_BACKUP=$(mktemp -d)
find . -maxdepth 1 -mindepth 1 ! -name ".git" | while read -r item; do
  mv "$item" "$TEMP_BACKUP/"
done

# --- Step 5: Copy .git/ to .bare/ ---
cp -a .git .bare
BARE_CREATED=true

# --- Step 6: Configure bare repo ---
git config --file .bare/config core.bare true

# Ensure fetch refspec exists for origin (if remote exists)
if git --git-dir=.bare remote | grep -q "^origin$"; then
  if ! git --git-dir=.bare config --get 'remote.origin.fetch' > /dev/null 2>&1; then
    git --git-dir=.bare config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
  fi
fi

# --- Step 7: Add worktree ---
git --git-dir=.bare worktree add main "$BRANCH"
WORKTREE_CREATED=true

# --- Step 8: Pop stash in main/ ---
if [ "$STASH_CREATED" = true ]; then
  echo "git-to-worktree: restoring stashed changes into main/..."
  git -C main stash pop
  STASH_CREATED=false
fi

# --- Step 9: Cleanup on success ---
# Remove original .git/ directory and replace with .git file pointing to .bare/
rm -rf .git
GIT_DIR_REMOVED=true
echo "gitdir: ./.bare" > .git

# Remove temp backup (tracked files already in main/ via worktree add)
rm -rf "$TEMP_BACKUP"
TEMP_BACKUP=""

# --- Step 10: Print summary ---
echo ""
echo "git-to-worktree: conversion complete!"
echo "  .bare/  -> bare git repository"
echo "  .git    -> points to .bare/"
echo "  main/   -> worktree for branch '$BRANCH'"
echo ""
echo "  cd main to continue working"
