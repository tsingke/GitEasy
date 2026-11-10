#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir search04
cd search04
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
mkdir docs
printf 'Index: candidate content for the next commit.\n' > README.md
git add README.md
git commit -m "docs: define the index briefly"
printf '# Course guide\n' > README.md
printf 'Index: candidate content for the next commit.\n' > docs/index.txt
git add README.md docs/index.txt
git commit -m "docs: move the index definition into the guide"
git grep -n -F 'candidate content' HEAD -- README.md docs
git grep -n -F 'candidate content' HEAD^ -- README.md docs
git log --oneline -S 'candidate content' -- README.md

ORIGINAL04=$(git rev-parse HEAD)
git notes add -m "Teaching review: definition moved without changing its wording."
git notes show HEAD
test "$(git rev-parse HEAD)" = "$ORIGINAL04"
git log -1 --show-notes
git show-ref refs/notes/commits
