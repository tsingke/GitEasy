#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir migration15
cd migration15
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Migration exercise\n' > README.md
git add README.md
git commit -m "docs: establish the migration exercise"
git branch feature/guide
git tag -a course-v1.0.0 -m "First migration checkpoint"
cd ..
git clone --mirror migration15 migration15-mirror.git
git init --bare --initial-branch=main migration15-target.git
git -C migration15-mirror.git push --mirror ../migration15-target.git

git -C migration15 for-each-ref \
  --format='%(refname) %(objectname)' refs/heads refs/tags > source15-refs.txt
git --git-dir=migration15-target.git for-each-ref \
  --format='%(refname) %(objectname)' refs/heads refs/tags > target15-refs.txt
cmp source15-refs.txt target15-refs.txt
git clone migration15-target.git migration15-reader
git -C migration15-reader fsck --full
git -C migration15-reader show course-v1.0.0:README.md
