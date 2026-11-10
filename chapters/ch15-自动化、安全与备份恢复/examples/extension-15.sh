#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir backup15
cd backup15
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Backup exercise\n' > README.md
git add README.md
git commit -m "docs: establish the backup exercise"
printf 'Room: A101\n' > room.txt
git add room.txt
git commit -m "docs: record the room"
SAVED15=$(git rev-parse main)
printf 'Uncommitted planning notes\n' > draft.txt
git bundle create ../full15.bundle --all
git bundle verify ../full15.bundle
cp draft.txt ../draft15-preserved.txt
cd ..
git clone full15.bundle restored15-extra

test "$(git -C restored15-extra rev-parse main)" = "$SAVED15"
git -C restored15-extra fsck --full
grep -q 'Room: A101' restored15-extra/room.txt
test ! -e restored15-extra/draft.txt
test -f draft15-preserved.txt
test -z "$(git -C restored15-extra status --porcelain)"
