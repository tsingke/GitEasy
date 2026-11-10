#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab07
cd lab07
git init --bare --initial-branch=main center.git
git clone center.git alice
cd alice
git config user.name "Alice"
git config user.email "alice@example.invalid"
printf 'Course: Git\n' > README.md
git add README.md
git commit -m "docs: start shared notes"
git push -u origin main
cd ..
git clone center.git bob
cd bob
git config user.name "Bob"
git config user.email "bob@example.invalid"
printf 'Bob: inspect status\n' > bob.txt
git add bob.txt
git commit -m "docs: add Bob notes"
cd ../alice
printf 'Alice: inspect diff\n' > alice.txt
git add alice.txt
git commit -m "docs: add Alice notes"
git push origin main
cd ../bob
if git push origin main; then echo "Expected refusal did not occur" >&2; exit 91; fi
git fetch origin
git log --graph --oneline --all --decorate
git merge --no-edit origin/main
git push origin main
cd ../alice
git fetch origin
git merge --ff-only origin/main
git ls-tree --name-only HEAD
git remote -v
git config --get remote.origin.fetch
git config --get branch.main.remote
git config --get branch.main.merge
git rev-parse main refs/remotes/origin/main
git --git-dir=../center.git rev-parse refs/heads/main
git branch -vv
git remote rename origin shared
git remote -v
git branch -vv
git config --get branch.main.remote
git remote rename shared origin
git config push.default simple
git switch -c course-local
printf 'Review the direction of each reference.\n' > review.txt
git add review.txt
git commit -m "docs: add reference review exercise"
git push -u origin HEAD:refs/heads/course-notes
git branch -vv
git config --get branch.course-local.merge
git rev-parse '@{upstream}'
if git push; then echo "Expected refusal did not occur" >&2; exit 91; fi
git push origin HEAD:refs/heads/course-notes
cd ../bob
git fetch origin
git switch --track -c review-notes origin/course-notes
git branch -vv
cat review.txt
cd ../alice
git switch main
git push origin --delete course-notes
git branch --list course-local
cd ../bob
git branch -r
git show-ref --verify refs/remotes/origin/course-notes
git fetch --prune origin
if git show-ref --verify refs/remotes/origin/course-notes; then echo "Expected refusal did not occur" >&2; exit 91; fi
git branch -vv
cat review.txt
git branch --unset-upstream
git switch main
git status --short
test "$(git branch --show-current)" = main
test -z "$(git status --porcelain)"
test -f alice.txt && test -f bob.txt
test "$(git rev-parse main)" = "$(git --git-dir=../center.git rev-parse main)"
git show review-notes:review.txt | grep -q 'direction of each reference'
if git show-ref --verify refs/remotes/origin/course-notes; then exit 92; fi
if git --git-dir=../center.git show-ref --verify refs/heads/course-notes; then exit 93; fi
git -C ../alice show course-local:review.txt | grep -q 'direction of each reference'
test "$(git -C ../alice config --get remote.origin.url)" = "$(git config --get remote.origin.url)"
