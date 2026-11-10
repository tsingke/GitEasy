#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
git init --bare --initial-branch=main center07.git
git clone center07.git alice07
cd alice07
git config user.name "Alice Learner"
git config user.email "alice@example.invalid"
printf 'Course baseline\n' > README.md
git add README.md
git commit -m "docs: establish the course"
git push -u origin main
cd ..
git clone center07.git bob07
cd bob07
git config user.name "Bob Learner"
git config user.email "bob@example.invalid"
printf 'Exercise: compare local and remote state.\n' > task.txt
git add task.txt
git commit -m "docs: add the comparison task"
git push origin main
cd ../alice07
BEFORE07=$(git rev-parse main)
OBSERVED07=$(git rev-parse origin/main)
test "$BEFORE07" = "$OBSERVED07"

git fetch origin
test "$(git rev-parse main)" = "$BEFORE07"
test "$(git rev-parse origin/main)" != "$OBSERVED07"
test ! -e task.txt
git log --oneline main..origin/main
git merge --ff-only origin/main
test -f task.txt
test "$(git rev-parse main)" = "$(git rev-parse origin/main)"
