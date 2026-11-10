#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir ranges04
cd ranges04
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Course baseline\n' > README.md
git add README.md
git commit -m "docs: establish the baseline"
git branch topic
printf 'Main schedule\n' > schedule.txt
git add schedule.txt
git commit -m "docs: add the main schedule"
git switch topic
printf 'Topic exercise\n' > exercise.txt
git add exercise.txt
git commit -m "docs: add a topic exercise"
git log --oneline main..topic
git log --oneline topic..main
git log --left-right --oneline main...topic

git diff --name-status main topic
git diff --name-status main...topic
git merge-base main topic
test "$(git rev-list --count main..topic)" = 1
test "$(git rev-list --count topic..main)" = 1
test "$(git diff --name-only main...topic)" = exercise.txt
