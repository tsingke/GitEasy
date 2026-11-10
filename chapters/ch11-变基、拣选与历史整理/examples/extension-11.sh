#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir transplant11
cd transplant11
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Room: A101\n' > room.txt
git add room.txt
git commit -m "docs: establish the stable baseline"
git branch maintenance
printf 'New optional experiment\n' > new-feature.txt
git add new-feature.txt
git commit -m "feat: add an optional experiment"
printf 'Room: B202\n' > room.txt
git add room.txt
git commit -m "fix: correct the room assignment"
FIX11=$(git rev-parse HEAD)
git switch maintenance
git cherry-pick -x "$FIX11"

grep -q 'Room: B202' room.txt
test ! -e new-feature.txt
test "$(git rev-parse HEAD)" != "$FIX11"
git log -1 --format=%B
git diff HEAD^ HEAD --name-only
if git merge-base --is-ancestor "$FIX11" HEAD; then
  echo "Original fix unexpectedly became an ancestor" >&2
  exit 1
fi
test -z "$(git status --porcelain)"
