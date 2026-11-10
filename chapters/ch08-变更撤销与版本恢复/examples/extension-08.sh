#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir correction08
cd correction08
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Room: A101\n' > room.txt
git add room.txt
git commit -m "docs: establish the course room"
printf 'Room: Wrong\n' > room.txt
git add room.txt
git commit -m "docs: change the room incorrectly"
BAD08=$(git rev-parse HEAD)
printf 'Read the staged diff before committing.\n' > guide.txt
git add guide.txt
git commit -m "docs: add the review guide"
git revert --no-edit "$BAD08"

git log -4 --oneline
git show HEAD:room.txt
git show HEAD:guide.txt
git merge-base --is-ancestor "$BAD08" HEAD
test "$(git rev-list --count HEAD)" = 4
grep -q 'Room: A101' room.txt
grep -q 'Read the staged diff' guide.txt
test -z "$(git status --porcelain)"
