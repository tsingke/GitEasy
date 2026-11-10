#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab16-course
cd lab16-course
mkdir course-project
cd course-project
git init -b main
git config user.name "Course Maintainer"
git config user.email "maintainer@example.invalid"
mkdir docs lessons
printf '# GitEasy course\n\nA course about traceable collaboration.\n' > README.md
printf '# Syllabus\n\nSchedule: Monday.\n' > docs/syllabus.md
printf '# Lab 01\n\nCreate and inspect a commit.\n' > lessons/lab01.md
printf '# Lab 02\n\nCompare working tree, index and HEAD.\n' > lessons/lab02.md
printf '# Changelog\n\nInitial course materials.\n' > CHANGELOG.md
printf '*.tmp\n' > .gitignore
git add .
git diff --cached --stat
git commit -m "docs: establish course materials"
git tag course-start

cd ..
git clone --bare course-project course-center.git
git clone course-center.git course-alice
git clone course-center.git course-bob
cd course-alice
git config user.name "Alice"
git config user.email "alice@example.invalid"
cd ../course-bob
git config user.name "Bob"
git config user.email "bob@example.invalid"

cd ../course-alice
git switch -c feature/schedule
printf '# Syllabus\n\nSchedule: Wednesday lecture.\n' > docs/syllabus.md
printf '\nInspect the staged diff before committing.\n' >> lessons/lab01.md
git add docs/syllabus.md lessons/lab01.md
git diff --cached
git commit -m "docs: set lecture schedule and inspection task"
git switch main
git merge --ff-only feature/schedule
git push origin main

cd ../course-bob
git switch -c feature/support
printf '# Syllabus\n\nSchedule: Tuesday office hours.\n' > docs/syllabus.md
printf '# Support\n\nQuestions are collected before office hours.\n' > docs/support.md
git add docs/syllabus.md docs/support.md
git commit -m "docs: establish office hours and support process"
git switch main
git merge --ff-only feature/support
if git push origin main; then exit 91; fi

git fetch origin
git log --oneline --graph --decorate --all
git log --oneline main..origin/main
git log --oneline origin/main..main
if git merge origin/main; then exit 92; fi

git status --short
git ls-files -u
git show :1:docs/syllabus.md
git show :2:docs/syllabus.md
git show :3:docs/syllabus.md

printf '# Syllabus\n\nLecture: Wednesday.\nOffice hours: Tuesday.\n' > docs/syllabus.md
git add docs/syllabus.md
git ls-files -u
git diff --cached --stat
git diff --cached -- docs/syllabus.md
git commit -m "merge: preserve lecture and office hours"
git rev-list --parents -n 1 HEAD
git push origin main

cd ../course-alice
git fetch origin
git merge --ff-only origin/main
cat docs/syllabus.md
cat docs/support.md
cat lessons/lab01.md
git status --short

git branch maintenance/course
git switch -c feature/new-lab
printf '# Lab 03\n\nObserve branch movement.\n' > lessons/lab03.md
git add lessons/lab03.md
git commit -m "docs: add branch observation lab"
printf '\nCompare candidate content with HEAD.\n' >> lessons/lab01.md
git add lessons/lab01.md
git commit -m "docs: clarify the comparison baseline"
FIX=$(git rev-parse HEAD)
git switch main
git merge --ff-only feature/new-lab

git switch maintenance/course
git cherry-pick "$FIX"
git log --oneline -3
cat lessons/lab01.md
test ! -e lessons/lab03.md
git diff main -- lessons/lab01.md
git switch main

git status --short
git tag -a course-v1.0.0 -m "Course practice release 1.0.0"
git cat-file -t course-v1.0.0
git rev-parse 'course-v1.0.0^{commit}'
git archive --format=zip --output=../course-v1.0.0.zip course-v1.0.0
git push origin main
git push origin refs/tags/course-v1.0.0

git bundle create ../course-backup.bundle --all
git bundle verify ../course-backup.bundle
git clone ../course-backup.bundle ../course-restored
git -C ../course-restored rev-parse 'course-v1.0.0^{commit}'
git -C ../course-restored show course-v1.0.0:docs/syllabus.md
git -C ../course-restored fsck --full

COURSE_CHECKER="${GITEASY_COURSE}/tools/check_course.py"
python3 "$COURSE_CHECKER" --repo .
python3 "$COURSE_CHECKER" --repo . --index

printf 'GitEasy course\n\nA course about traceable collaboration.\n' > README.md
git add README.md
printf '# GitEasy course\n\nA course about traceable collaboration.\n' > README.md
python3 "$COURSE_CHECKER" --repo .
if python3 "$COURSE_CHECKER" --repo . --index; then exit 93; fi

git add README.md
python3 "$COURSE_CHECKER" --repo . --index
git status --short

test -z "$(git status --porcelain)"
test "$(git rev-parse main)" = "$(git --git-dir=../course-center.git rev-parse main)"
git merge-base --is-ancestor feature/schedule main
git merge-base --is-ancestor origin/main main
git cat-file -p main~2 | grep '^parent ' > ../merge-parents.txt
test "$(wc -l < ../merge-parents.txt | tr -d ' ')" = 2
test "$(git cat-file -t course-v1.0.0)" = tag
test "$(git rev-parse 'course-v1.0.0^{commit}')" = "$(git -C ../course-restored rev-parse 'course-v1.0.0^{commit}')"
test -z "$(git diff main maintenance/course -- lessons/lab01.md)"
test -n "$(git diff main maintenance/course -- lessons/lab03.md)"
git -C ../course-restored show course-v1.0.0:docs/syllabus.md | grep -q 'Lecture: Wednesday.'
git -C ../course-restored show course-v1.0.0:docs/syllabus.md | grep -q 'Office hours: Tuesday.'
