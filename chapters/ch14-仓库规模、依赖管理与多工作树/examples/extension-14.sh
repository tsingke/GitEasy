#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir parallel14
cd parallel14
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Room: A101\n' > room.txt
git add room.txt
git commit -m "docs: establish the stable baseline"
printf 'Unfinished optional lesson\n' > draft.txt
git worktree add -b maintenance ../maintenance14 HEAD
git -C ../maintenance14 config user.name "Git Learner"
git -C ../maintenance14 config user.email "learner@example.invalid"
printf 'Room: B202\n' > ../maintenance14/room.txt
git -C ../maintenance14 add room.txt
git -C ../maintenance14 commit -m "fix: correct the maintenance room"

git worktree list
grep -q 'Room: A101' room.txt
grep -q 'Room: B202' ../maintenance14/room.txt
test -f draft.txt
test ! -e ../maintenance14/draft.txt
test "$(git rev-parse main)" != "$(git rev-parse maintenance)"
git show maintenance:room.txt
git worktree remove ../maintenance14
test -f draft.txt
