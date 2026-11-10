#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir packing09
cd packing09
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
for number in 1 2 3 4; do
  printf 'Course note version %s\n' "$number" > note.txt
  git add note.txt
  git commit -m "docs: record note version $number"
done
COMMIT09=$(git rev-parse HEAD)
TREE09=$(git rev-parse HEAD^{tree})
BLOB09=$(git rev-parse HEAD:note.txt)
git count-objects -v
git repack -ad
git count-objects -v

test "$(git rev-parse HEAD)" = "$COMMIT09"
test "$(git rev-parse HEAD^{tree})" = "$TREE09"
test "$(git rev-parse HEAD:note.txt)" = "$BLOB09"
test "$(git rev-list --count HEAD)" = 4
git cat-file -p "$BLOB09"
git fsck --full
test -z "$(git status --porcelain)"
