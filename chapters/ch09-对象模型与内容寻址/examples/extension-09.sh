#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir reuse09
cd reuse09
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Inspect the staged content.\n' > first.txt
cp first.txt second.txt
git add first.txt second.txt
git commit -m "docs: add two identical notes"
FIRST09=$(git rev-parse HEAD:first.txt)
SECOND09=$(git rev-parse HEAD:second.txt)
test "$FIRST09" = "$SECOND09"
git ls-tree HEAD
git cat-file -t "$FIRST09"
git cat-file -p "$FIRST09"

printf 'Inspect both staged and unstaged content.\n' > first.txt
git add first.txt
git commit -m "docs: refine the first note"
NEW09=$(git rev-parse HEAD:first.txt)
test "$NEW09" != "$FIRST09"
test "$(git rev-parse HEAD:second.txt)" = "$SECOND09"
test "$(git rev-parse HEAD^:first.txt)" = "$FIRST09"
git diff HEAD^ HEAD --name-only
