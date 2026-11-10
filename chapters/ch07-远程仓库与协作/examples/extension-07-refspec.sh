#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
git init --bare --initial-branch=main selective07.git
mkdir producer07
cd producer07
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Main course\n' > README.md
git add README.md
git commit -m "docs: establish the main course"
git switch -c experiment
printf 'Optional experiment\n' > optional.txt
git add optional.txt
git commit -m "docs: add an optional experiment"
git remote add origin ../selective07.git
git push origin main experiment
cd ..
mkdir observer07
cd observer07
git init -b main
git remote add origin ../selective07.git
git fetch origin \
  refs/heads/experiment:refs/remotes/origin/experiment

git show-ref
if git show-ref --verify --quiet refs/remotes/origin/main; then
  echo "Unexpected remote main observation" >&2
  exit 1
fi
git show origin/experiment:optional.txt
git switch -c study --track origin/experiment
test -f optional.txt
test "$(git branch --show-current)" = study
