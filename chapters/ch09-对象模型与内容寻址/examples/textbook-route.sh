#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab09-objects
cd lab09-objects
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'same content\n' > first.txt
cp first.txt second.txt
git add first.txt second.txt
git commit -m "docs: record two equal files"
FIRST=$(git rev-parse HEAD)
git cat-file -t "$FIRST"
git cat-file -p "$FIRST"

ROOT=$(git rev-parse 'HEAD^{tree}')
git cat-file -t "$ROOT"
git ls-tree HEAD
ONE=$(git rev-parse HEAD:first.txt)
TWO=$(git rev-parse HEAD:second.txt)
printf '%s\n%s\n' "$ONE" "$TWO"
git cat-file -p "$ONE"

git mv first.txt renamed.txt
git commit -m "docs: rename the first file"
SECOND=$(git rev-parse HEAD)
RENAMED=$(git rev-parse HEAD:renamed.txt)
printf '%s\n%s\n' "$ONE" "$RENAMED"
git cat-file -p HEAD
git diff-tree --no-commit-id --name-status -r -M "$FIRST" "$SECOND"

printf 'new content\n' > renamed.txt
git add renamed.txt
git commit -m "docs: revise one file"
THIRD=$(git rev-parse HEAD)
git ls-tree HEAD
git cat-file -p "$ONE"
git show HEAD:second.txt
git show HEAD:renamed.txt

SAME_TREE=$(git rev-parse 'HEAD^{tree}')
A=$(printf 'explanation A\n' | git commit-tree "$SAME_TREE" -p HEAD)
B=$(printf 'explanation B\n' | git commit-tree "$SAME_TREE" -p HEAD)
printf '%s\n%s\n' "$A" "$B"
git diff "$A" "$B"
git cat-file -p "$A"
git cat-file -p "$B"

cd ..
mkdir lab09-plumbing
cd lab09-plumbing
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
mkdir docs
printf 'A small reproducible course\n' > docs/intro.txt
BLOB=$(git hash-object -w docs/intro.txt)
git cat-file -t "$BLOB"
git cat-file -s "$BLOB"
git cat-file -p "$BLOB"
git update-index --add docs/intro.txt
TREE=$(git write-tree)
git ls-tree -r "$TREE"

COMMIT=$(printf 'docs: create a nested course file\n' | git commit-tree "$TREE")
git cat-file -t "$COMMIT"
git cat-file -p "$COMMIT"
git update-ref refs/heads/main "$COMMIT"
git log -1 --oneline
git status --short
git show HEAD:docs/intro.txt

printf 'Add a second learning objective\n' >> docs/intro.txt
git update-index --add docs/intro.txt
NEXT_TREE=$(git write-tree)
NEXT_COMMIT=$(printf 'docs: extend the objectives\n' | git commit-tree "$NEXT_TREE" -p "$COMMIT")
git update-ref refs/heads/main "$NEXT_COMMIT" "$COMMIT"
git rev-list --parents -n 1 HEAD
git diff HEAD~1 HEAD -- docs/intro.txt

git count-objects -v
git gc
git count-objects -v
git log --oneline
git show HEAD:docs/intro.txt

git fsck --full

test "$(git rev-list --count HEAD)" = 2
test -z "$(git status --porcelain)"
test "$ONE" = "$TWO"
test "$ONE" = "$RENAMED"
test "$A" != "$B"
