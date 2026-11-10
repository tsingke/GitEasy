#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab04-history
cd lab04-history
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
mkdir docs
printf '# Course\n\nOffice hours: Tuesday.\n' > docs/course.md
printf '# Notes\n\nRead the course first.\n' > README.md
git add .
git commit -m "docs: establish course and office hours"
git tag history-good

printf '\nInspect each staged change.\n' >> docs/course.md
git add docs/course.md
git commit -m "docs: explain inspection before commit"
printf '# Course\n\nOffice hours: Thursday.\n\nInspect each staged change.\n' > docs/course.md
git add docs/course.md
git commit -m "docs: revise course arrangement"
git tag history-introduced
printf '\nThe notes follow the course.\n' >> README.md
git add README.md
git commit -m "docs: add reading order"
printf '\nKeep one purpose per commit.\n' >> docs/course.md
git add docs/course.md
git commit -m "docs: add commit guideline"
printf '\nRecord questions before practice.\n' >> README.md
git add README.md
git commit -m "docs: describe question collection"
git tag history-bad

git log --oneline --all
git log --oneline --grep="arrangement"
git log --oneline -- docs/course.md
git log --oneline -S "Thursday" -- docs/course.md
git log --oneline -G 'Office hours: (Tuesday|Thursday)' -- docs/course.md

git show --format=fuller history-introduced -- docs/course.md
git show history-introduced^:docs/course.md
git show history-introduced:docs/course.md
git blame -L 1,5 -- docs/course.md
git log --format='%h | %aI | %an | %s' -- docs/course.md

git log --oneline history-good..history-bad
git diff --stat history-good history-bad
git diff history-introduced^ history-introduced -- docs/course.md
git rev-parse history-bad~2
git rev-parse history-introduced

printf '%s\n' '#!/bin/sh' 'grep -q "Office hours: Tuesday[.]" docs/course.md' > ../check-hours04.sh
if sh ../check-hours04.sh; then exit 92; fi

git status --short
git bisect start history-bad history-good
git bisect run sh ../check-hours04.sh
git bisect log

git bisect log > ../bisect04.log
git bisect reset
git branch --show-current
git status --short

git switch --detach history-good
sh ../check-hours04.sh
git switch --detach history-bad
if sh ../check-hours04.sh; then exit 91; fi
git switch main

test "$(git branch --show-current)" = main
test -z "$(git status --porcelain)"
test "$(git rev-list --count HEAD)" = 6
grep -F "first 'bad' commit: [$(git rev-parse history-introduced)]" ../bisect04.log
test -z "$(git log --format=%H -S Thursday -- docs/course.md | grep -v "$(git rev-parse history-introduced)")"
test "$(git log --format=%H -S Thursday -- docs/course.md | wc -l | tr -d ' ')" = 1
