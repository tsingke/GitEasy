#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir evidence06
cd evidence06
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Course baseline\n' > README.md
git add README.md
git commit -m "docs: establish the baseline"
git switch -c topic
printf 'Exercise: inspect the index.\n' > exercise.txt
git add exercise.txt
git commit -m "docs: add the index exercise"
git switch main
printf 'Lecture: Wednesday.\n' > schedule.txt
git add schedule.txt
git commit -m "docs: record the lecture schedule"
git merge --no-ff topic -m "merge: integrate the index exercise"

git show HEAD:exercise.txt
git show HEAD:schedule.txt
git rev-list --parents -n 1 HEAD
git diff HEAD^1 HEAD --name-status
git diff HEAD^2 HEAD --name-status
test "$(git rev-list --parents -n 1 HEAD | wc -w | tr -d ' ')" = 3
test -z "$(git status --porcelain)"
