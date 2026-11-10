#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab13-integration
cd lab13-integration
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Course\n' > README.md
git add README.md
git commit -m "docs: establish course"
git tag workflow-base
git switch -c topic
printf '# Index exercise\n\nEdit, stage, then edit again.\n' > index.md
git add index.md
git commit -m "docs: add index observation"
printf '\nCompare working tree, index and HEAD.\n' >> index.md
git add index.md
git commit -m "docs: explain the three contents"
git switch main
printf '\nRead prerequisites before practice.\n' >> README.md
git add README.md
git commit -m "docs: explain the prerequisite"

git switch -c result/merge main
git merge --no-ff topic -m "merge: integrate index exercise"
git rev-list --parents -n 1 HEAD
git log --oneline --first-parent
git merge-base --is-ancestor topic HEAD

git switch -c result/squash main
git merge --squash topic
git status --short
git diff --cached --stat
git commit -m "docs: add the complete index exercise"
git rev-list --parents -n 1 HEAD
if git merge-base --is-ancestor topic HEAD; then exit 91; fi

git switch -c result/rebase topic
git rebase main
git log --oneline --graph --decorate --all
git diff result/merge result/squash
git diff result/merge result/rebase
git rev-list --parents -n 1 HEAD
if git merge-base --is-ancestor topic HEAD; then exit 91; fi

test -z "$(git status --porcelain)"
test "$(git rev-parse 'result/merge^{tree}')" = "$(git rev-parse 'result/squash^{tree}')"
test "$(git rev-parse 'result/merge^{tree}')" = "$(git rev-parse 'result/rebase^{tree}')"
test "$(git rev-list --parents -n 1 result/merge | wc -w | tr -d ' ')" = 3
test "$(git rev-list --parents -n 1 result/squash | wc -w | tr -d ' ')" = 2
test "$(git rev-list --count result/merge)" = 5
test "$(git rev-list --count result/squash)" = 3
test "$(git rev-list --count result/rebase)" = 4
git merge-base --is-ancestor topic result/merge
