#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir names05
cd names05
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Course baseline\n' > README.md
git add README.md
git commit -m "docs: establish the baseline"
git switch -c topic
printf 'Read the staged diff before committing.\n' > guide.txt
git add guide.txt
git commit -m "docs: add a review guide"
SAVED05=$(git rev-parse HEAD)
git branch -m feature/guide
test "$(git branch --show-current)" = feature/guide
test "$(git rev-parse HEAD)" = "$SAVED05"
git log -2 --oneline

git switch main
git merge --ff-only feature/guide
git branch -d feature/guide
test "$(git rev-parse main)" = "$SAVED05"
git show main:guide.txt
test "$(git rev-list --count main)" = 2
