#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab11-replay
cd lab11-replay
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Course\n' > README.md
git add README.md
git commit -m "docs: establish course"
git switch -c topic
printf '# Exercise\n\nInspect the staged change.\n' > exercise.md
git add exercise.md
git commit -m "docs: add inspection exercise"
printf '\nExplain the result before continuing.\n' >> exercise.md
git add exercise.md
git commit -m "docs: add reflection prompt"
git branch backup/topic-before
git switch main
printf '\nRead the course before practice.\n' >> README.md
git add README.md
git commit -m "docs: add reading prerequisite"
git switch topic

OLD_TOPIC=$(git rev-parse HEAD)
git rebase main
git log --oneline --graph --decorate --all
git diff backup/topic-before topic -- exercise.md
git diff main topic -- README.md
git rev-parse HEAD
git rev-parse backup/topic-before

test "$OLD_TOPIC" != "$(git rev-parse HEAD)"
git merge-base --is-ancestor main topic
test -z "$(git diff backup/topic-before topic -- exercise.md)"
test -z "$(git diff main topic -- README.md)"

cd ..
mkdir lab11-conflict
cd lab11-conflict
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Room: A101\n' > room.txt
git add room.txt
git commit -m "docs: record initial room"
git switch -c topic
printf 'Room: B201\n' > room.txt
git add room.txt
git commit -m "docs: propose another room"
git branch backup/conflict-before
git switch main
printf 'Room: A102\n' > room.txt
git add room.txt
git commit -m "docs: confirm main lecture room"
git switch topic
if git rebase main; then exit 91; fi

git status
git ls-files -u
git show :1:room.txt
git show :2:room.txt
git show :3:room.txt
git rebase --show-current-patch

git show :2:room.txt | grep -q A102
git show :3:room.txt | grep -q B201

git rebase --abort
git diff backup/conflict-before topic
git branch --show-current
if git rebase main; then exit 91; fi

printf 'Room: A102\nSupport: online office hours.\n' > room.txt
git add room.txt
git diff --cached
git rebase --continue
git status --short
git log --oneline --graph --decorate --all

cd ..
mkdir lab11-organize
cd lab11-organize
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Course\n' > README.md
git add README.md
git commit -m "docs: establish course"
git tag organize-base
printf '# Inspection\n\nInspect the change.\n' > inspection.md
git add inspection.md
git commit -m "docs: add inspection exercise"
FIRST=$(git rev-parse HEAD)
printf '# Reflection\n\nExplain the observed state.\n' > reflection.md
git add reflection.md
git commit -m "docs: add reflection exercise"
printf '\nUse the staged diff.\n' >> inspection.md
git add inspection.md
git commit --fixup="$FIRST"
git branch backup/organize-before

GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash organize-base
git log --oneline organize-base..HEAD
git diff backup/organize-before HEAD
git rev-list --count organize-base..HEAD
git cat-file -p HEAD

test "$(git rev-list --count organize-base..HEAD)" = 2
test -z "$(git diff backup/organize-before HEAD)"
git show HEAD^:inspection.md | grep -q "Use the staged diff."

git switch -c maintenance organize-base
git switch main
printf '\nA new course feature.\n' >> reflection.md
git add reflection.md
git commit -m "docs: extend reflection feature"
printf '\nUse a clean practice directory.\n' >> README.md
git add README.md
git commit -m "docs: fix missing environment prerequisite"
PATCH=$(git rev-parse HEAD)
git switch maintenance
git cherry-pick -x "$PATCH"
git log -1 --format=full
cat README.md
test ! -e reflection.md
git switch main

test "$(git branch --show-current)" = main
test -z "$(git status --porcelain)"
test "$(git rev-list --count main)" = 5
test "$(git rev-list --count maintenance)" = 2
test -z "$(git diff main maintenance -- README.md)"
git log -1 --format=%B maintenance | grep -q 'cherry picked from commit'
git -C ../lab11-conflict show topic:room.txt | grep -q 'Support: online office hours.'
git -C ../lab11-conflict merge-base --is-ancestor main topic
