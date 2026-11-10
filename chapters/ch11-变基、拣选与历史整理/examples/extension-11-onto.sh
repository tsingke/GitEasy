#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir onto11
cd onto11
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Stable course\n' > README.md
git add README.md
git commit -m "docs: establish the stable course"
git switch -c helper
printf 'Optional helper material\n' > helper.txt
git add helper.txt
git commit -m "docs: add the helper material"
git switch -c topic
printf 'Exercise: inspect the staged content.\n' > exercise.txt
git add exercise.txt
git commit -m "docs: add an independent exercise"
git branch backup/topic-with-helper
git log --oneline --graph --all

git log --oneline helper..topic
git rebase --onto main helper topic
git log --oneline --graph --all
test -f exercise.txt
test ! -e helper.txt
git merge-base --is-ancestor main topic
if git merge-base --is-ancestor helper topic; then exit 1; fi
test -z "$(git diff backup/topic-with-helper topic -- exercise.txt)"
test "$(git rev-list --count main..topic)" = 1
