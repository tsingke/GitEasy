#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir split11
cd split11
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Course baseline\n' > README.md
git add README.md
git commit -m "docs: establish the baseline"
printf 'Room: A101\n' > room.txt
printf 'Read the candidate diff.\n' > reading.txt
git add room.txt reading.txt
git commit -m "docs: add room and reading information"
git branch backup/before-split
ORIGINAL_TREE11=$(git rev-parse HEAD^{tree})
test -z "$(git status --porcelain)"

git reset --mixed HEAD^
git status --short
git add room.txt
git diff --cached --name-only
git commit -m "docs: record the course room"
git add reading.txt
git diff --cached --name-only
git commit -m "docs: add the reading reminder"
test "$(git rev-parse HEAD^{tree})" = "$ORIGINAL_TREE11"
test "$(git rev-list --count HEAD)" = 3
test "$(git diff HEAD~2 HEAD~1 --name-only)" = room.txt
test "$(git diff HEAD~1 HEAD --name-only)" = reading.txt
test -z "$(git status --porcelain)"
