#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
COURSE_RESOURCE="${GITEASY_COURSE}"
python3 "$COURSE_RESOURCE/tools/init_course.py" lab15-checks
cd lab15-checks
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
mkdir tools .githooks
cp "$COURSE_RESOURCE/tools/check_course.py" tools/check_course.py
printf '%s\n' '#!/bin/sh' 'exec python3 tools/check_course.py --repo . --index' > .githooks/pre-commit
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
git add .
git commit -m "docs: establish checked course material"
git config --show-origin --get core.hooksPath

cp README.md ../readme15-original.md
sed '1s/^# //' ../readme15-original.md > README.md
git add README.md
cp ../readme15-original.md README.md
python3 tools/check_course.py --repo .
git diff --cached -- README.md
if git commit -m "docs: demonstrate an invalid staged title"; then exit 91; fi

git -c core.hooksPath=/dev/null commit -m "demo: bypass local hook with invalid candidate"
git show HEAD:README.md
git add README.md
git commit -m "docs: restore a valid course title"
git show HEAD:README.md
git status --short

git switch -c task/recovery
printf '# Recovery task\n\nPreserve this explanation.\n' > docs/recovery.md
git add docs/recovery.md
git commit -m "docs: explain a recovery task"
LOST15=$(git rev-parse HEAD)
git switch main
git branch -D task/recovery
git reflog --all --format='%h %gs'

git show --stat "$LOST15"
git show "$LOST15":docs/recovery.md
git branch rescued/recovery "$LOST15"
git log --oneline rescued/recovery -3
git show rescued/recovery:docs/recovery.md

git tag backup-base
printf 'Uncommitted draft; keep separately.\n' > draft.txt
git bundle create ../course-full15.bundle --all
git bundle verify ../course-full15.bundle
git clone ../course-full15.bundle ../restored15
git -C ../restored15 log --oneline --all

git -C ../restored15 show origin/rescued/recovery:docs/recovery.md
git -C ../restored15 rev-parse backup-base
test ! -e ../restored15/draft.txt

printf '\nBackup restoration has been exercised.\n' >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "docs: record the restoration exercise"
git bundle create ../course-increment15.bundle backup-base..main
git -C ../restored15 bundle verify ../course-increment15.bundle
git -C ../restored15 fetch ../course-increment15.bundle main:refs/remotes/transfer/main
git -C ../restored15 merge --ff-only refs/remotes/transfer/main
git -C ../restored15 fsck --full

git rev-parse main
git -C ../restored15 rev-parse main
git diff main refs/tags/backup-base -- CHANGELOG.md
mv draft.txt ../draft15-saved.txt
git status --short

test -z "$(git status --porcelain)"
test "$(git rev-parse main)" = "$(git -C ../restored15 rev-parse main)"
test "$LOST15" = "$(git -C ../restored15 rev-parse origin/rescued/recovery)"
test -f ../draft15-saved.txt
test ! -e ../restored15/draft.txt
test "$(git config --get core.hooksPath)" = .githooks
cmp README.md ../readme15-original.md
git log --format=%s | grep -q 'demo: bypass local hook'
git -C ../restored15 bundle verify ../course-increment15.bundle
