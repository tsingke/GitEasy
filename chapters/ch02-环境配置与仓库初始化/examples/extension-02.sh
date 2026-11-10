#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir inspect02
cd inspect02
git init -b main
git config --local user.name "Git Learner"
git config --local user.email "learner@example.invalid"
pwd
git rev-parse --show-toplevel
git rev-parse --is-inside-work-tree
git config --show-origin --get user.name
git -c user.name="Temporary Learner" config --get user.name
git config --get user.name

if git rev-parse --verify HEAD; then
  echo "Unexpected initial commit" >&2
  exit 1
fi
printf '# Environment notes\n' > README.md
git add README.md
git diff --cached --stat
git commit -m "docs: record the environment entry"
git rev-parse --verify HEAD
git log -1 --format='%h %s'
test -z "$(git status --porcelain)"
