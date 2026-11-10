#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir repeated06
cd repeated06
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
git config rerere.enabled true
git config rerere.autoupdate false
printf 'Room: A101\n' > room.txt
git add room.txt
git commit -m "docs: establish the baseline room"
git switch -c topic
printf 'Room: B202\n' > room.txt
git add room.txt
git commit -m "docs: propose room B202"
git switch main
printf 'Room: C303\n' > room.txt
git add room.txt
git commit -m "docs: propose room C303"
git branch before-integration
if git merge topic; then exit 1; fi
git rerere status
printf 'Room: D404, confirmed by the instructor.\n' > room.txt
git rerere
git add room.txt
git commit -m "merge: use the confirmed room D404"

git reset --hard before-integration
if git merge topic; then exit 1; fi
grep -q 'Room: D404' room.txt
test -n "$(git ls-files -u)"
git diff -- room.txt
git add room.txt
git commit -m "merge: review and accept the reused resolution"
test -z "$(git status --porcelain)"
