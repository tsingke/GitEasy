#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir candidate10
cd candidate10
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Version: one\n' > note.txt
git add note.txt
TREE10=$(git write-tree)
printf 'Version: two\n' > note.txt
git show "$TREE10:note.txt"
cat note.txt
git diff -- note.txt
git commit -m "docs: record the selected first version"
test "$(git rev-parse HEAD^{tree})" = "$TREE10"
test "$(git show HEAD:note.txt)" = 'Version: one'
grep -q 'Version: two' note.txt

git add note.txt
NEXT10=$(git write-tree)
test "$NEXT10" != "$TREE10"
git commit -m "docs: record the revised second version"
test "$(git rev-parse HEAD^{tree})" = "$NEXT10"
test -z "$(git status --porcelain)"
