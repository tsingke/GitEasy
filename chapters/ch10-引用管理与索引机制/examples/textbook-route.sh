#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab10-refs
cd lab10-refs
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
git symbolic-ref HEAD
git rev-parse --git-dir
git rev-parse --show-toplevel

printf 'version one\n' > note.txt
git add note.txt
git commit -m "docs: create reference baseline"
git tag ref-base
git branch topic
git show-ref --heads
OLD=$(git rev-parse refs/heads/topic)
printf 'version two\n' >> note.txt
git add note.txt
git commit -m "docs: extend the note"
NEW=$(git rev-parse HEAD)
git rev-parse main topic

git update-ref -m "lesson: advance topic" refs/heads/topic "$NEW" "$OLD"
git rev-parse refs/heads/topic

if git update-ref refs/heads/topic "$OLD" "$OLD"; then exit 91; fi

git update-ref refs/heads/topic "$OLD" "$NEW"
git show topic:note.txt
cat note.txt
git branch --show-current
git status --short

git switch --detach ref-base
git rev-parse HEAD
if git symbolic-ref HEAD; then exit 92; fi
git switch main

git rev-parse --verify 'refs/heads/main^{commit}'
git rev-parse --verify 'refs/tags/ref-base^{commit}'
git rev-parse --symbolic-full-name main
git rev-parse 'HEAD^{tree}'

git ls-files --stage
git ls-files --debug
printf 'an unstaged observation\n' >> note.txt
git ls-files --stage
git diff -- note.txt
git restore -- note.txt

BEFORE_TREE=$(git write-tree)
printf 'not selected\n' >> note.txt
AFTER_TREE=$(git write-tree)
printf '%s\n%s\n' "$BEFORE_TREE" "$AFTER_TREE"
git restore -- note.txt

cd ..
mkdir lab10-index
cd lab10-index
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Meeting: Monday\n' > plan.txt
git add plan.txt
git commit -m "docs: set baseline meeting"
git switch -c side
printf 'Meeting: Tuesday\n' > plan.txt
git add plan.txt
git commit -m "docs: propose Tuesday"
git switch main
printf 'Meeting: Wednesday\n' > plan.txt
git add plan.txt
git commit -m "docs: choose Wednesday"
if git merge side; then exit 93; fi

git ls-files --unmerged
git show :1:plan.txt
git show :2:plan.txt
git show :3:plan.txt

if git write-tree; then exit 94; fi

printf 'Meeting: Wednesday\nOffice hours: Tuesday\n' > plan.txt
git add plan.txt
git ls-files --stage
git ls-files --unmerged
RESULT_TREE=$(git write-tree)
git cat-file -t "$RESULT_TREE"
git show :plan.txt

LEFT=$(git rev-parse HEAD)
RIGHT=$(git rev-parse MERGE_HEAD)
MERGED=$(printf 'docs: agree on meeting and office hours\n' | git commit-tree "$RESULT_TREE" -p "$LEFT" -p "$RIGHT")
git cat-file -p "$MERGED"
git rev-list --parents -n 1 "$MERGED"
git show "$MERGED":plan.txt

git update-ref refs/heads/manual-result "$MERGED"
git commit -m "docs: finish the agreed merge"
git diff manual-result HEAD
git rev-list --parents -n 1 HEAD
git status --short

test -z "$(git status --porcelain)"
test "$(git rev-list --parents -n 1 HEAD | wc -w | tr -d ' ')" = 3
test -z "$(git diff manual-result HEAD)"
grep -q "Office hours: Tuesday" plan.txt
