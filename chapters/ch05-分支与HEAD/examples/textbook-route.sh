#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab05-model
cd lab05-model
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
git symbolic-ref --short HEAD
if git rev-parse --verify HEAD; then exit 91; fi

printf 'Room: A101\n' > course.txt
printf 'Initial observation.\n' > notes.txt
git add course.txt notes.txt
git commit -m "docs: establish branch observation baseline"
git tag branch-base
git branch lesson
git symbolic-ref --short HEAD
git rev-parse main lesson
git show-ref --heads

git switch lesson
printf 'Task: inspect the staged content.\n' > task.txt
git add task.txt
git commit -m "docs: introduce the inspection task"
git switch main
printf 'Schedule: Monday.\n' > schedule.txt
git add schedule.txt
git commit -m "docs: record the course schedule"
git log --oneline --graph --decorate --all
git show lesson:task.txt
git show main:schedule.txt

printf 'Personal observation before staging.\n' > notes.txt
git diff -- notes.txt
git switch lesson
git status --short
git diff -- notes.txt
git restore -- notes.txt

git switch main
printf 'Local draft that must be preserved.\n' > task.txt
git status --short
if git switch lesson; then exit 92; fi

mv task.txt ../task05-saved.txt
git switch lesson
cat task.txt
git status --short

git switch main
printf 'Room: A102\n' > course.txt
git add course.txt
git commit -m "docs: update the main lecture room"
git switch lesson
printf 'Room: B201\n' > course.txt
git status --short
if git switch main; then exit 93; fi

cp course.txt ../course05-saved.txt
git restore -- course.txt
git switch main
cat course.txt
cat ../course05-saved.txt

cd ..

mkdir lab05
cd lab05
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Course: Git\n' > course.txt
git add course.txt
git commit -m "docs: create course baseline"
git tag base05
git branch feature
git symbolic-ref --short HEAD
git rev-parse main feature

git switch feature
printf 'Task: compare three states\n' > task.txt
git add task.txt
git commit -m "docs: add practice task"
git switch main
printf 'Schedule: Monday\n' > schedule.txt
git add schedule.txt
git commit -m "docs: add schedule"
git log --graph --oneline --all --decorate

git switch --detach base05
printf 'An experimental note\n' > experiment.txt
git add experiment.txt
git commit -m "docs: try a teaching note"
if git symbolic-ref --short HEAD; then exit 94; fi
git switch -c experiment

cd ../lab05-model
git switch main
git check-ref-format --branch 'docs/first-lab'
git branch saved-start branch-base
git branch -m saved-start archive/start
git rev-parse archive/start branch-base
git branch -v
if git check-ref-format --branch 'bad name'; then exit 95; fi

git branch -d archive/start
git branch --merged main
git branch --no-merged main
if git branch -d lesson; then exit 96; fi

LESSON05=$(git rev-parse lesson)
git branch -D lesson
git show "$LESSON05":task.txt
git branch rescued/lesson "$LESSON05"
git show rescued/lesson:task.txt
git status --short

test "$(git branch --show-current)" = main
test -z "$(git status --porcelain)"
test "$(git rev-list --count main)" = 3
git show rescued/lesson:task.txt | grep -q 'inspect the staged content'
grep -q 'Room: B201' ../course05-saved.txt
grep -q 'Local draft' ../task05-saved.txt
grep -q 'Room: A102' course.txt
grep -q 'Initial observation.' notes.txt
test "$(git -C ../lab05 branch --show-current)" = experiment
