#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir split03
cd split03
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Room: A101\n' > room.txt
printf 'Guide: https://example.invalid/old\n' > links.txt
git add room.txt links.txt
git commit -m "docs: establish course information"
printf 'Room: B202\n' > room.txt
printf 'Guide: https://example.invalid/guide\n' > links.txt
git diff --stat
git add room.txt
git diff --cached --name-only
git diff --name-only

git commit -m "docs: move the course to room B202"
git diff HEAD^ HEAD --name-only
git add links.txt
git commit -m "docs: correct the reading guide link"
git log -3 --oneline
git diff HEAD^ HEAD --name-only
test -z "$(git status --porcelain)"
test "$(git rev-list --count HEAD)" = 3
