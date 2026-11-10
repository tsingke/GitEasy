#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab14-scale
cd lab14-scale
mkdir source14
cd source14
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
mkdir lessons docs assets
printf '# Course\n' > README.md
printf '# Git lesson\n\nInspect the index.\n' > lessons/git.md
printf '# Guide\n\nRead before practice.\n' > docs/guide.md
printf 'Flat diagram source.\n' > assets/diagram.txt
git add .
git commit -m "docs: establish three content areas"
printf '\nFirst reading note.\n' >> README.md
git add README.md
git commit -m "docs: record first reading note"
printf '\nSecond reading note.\n' >> README.md
git add README.md
git commit -m "docs: record second reading note"
printf '\nThird reading note.\n' >> README.md
git add README.md
git commit -m "docs: record third reading note"
cd ..
git clone --bare source14 center14.git
SOURCE14="$(pwd)/center14.git"

git clone --depth 2 "file://$SOURCE14" shallow14
git -C shallow14 rev-parse --is-shallow-repository
git -C shallow14 log --oneline
git -C shallow14 rev-list --count HEAD
test "$(git -C shallow14 rev-list --count HEAD)" = 2
git -C shallow14 fetch --unshallow
git -C shallow14 rev-parse --is-shallow-repository
git -C shallow14 rev-list --count HEAD

test "$(git -C shallow14 rev-list --count HEAD)" = 4

git clone "file://$SOURCE14" sparse14
git -C sparse14 sparse-checkout set --cone lessons
ls sparse14
ls sparse14/lessons
git -C sparse14 show HEAD:docs/guide.md
git -C sparse14 log --oneline
test ! -e sparse14/docs/guide.md
test -e sparse14/README.md
test "$(git -C sparse14 rev-list --count HEAD)" = 4
git -C sparse14 sparse-checkout disable
ls sparse14/docs

git --git-dir=center14.git config uploadpack.allowFilter true
git clone --filter=blob:none --no-checkout "file://$SOURCE14" partial14
git -C partial14 config --get remote.origin.promisor
git -C partial14 rev-list --objects --all --missing=print > partial-before14.txt
cat partial-before14.txt
git -C partial14 show HEAD:lessons/git.md
git -C partial14 rev-list --objects --all --missing=print

grep -q "^?" partial-before14.txt

mkdir dep14
cd dep14
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Shared lesson\n\nVersion one.\n' > README.md
git add README.md
git commit -m "docs: establish shared lesson"
cd ..
mkdir parent14
cd parent14
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Parent course\n' > README.md
git add README.md
git commit -m "docs: establish parent course"
git -c protocol.file.allow=always submodule add ../dep14 libs/dep
git add .gitmodules libs/dep
git commit -m "deps: pin the shared lesson"
git ls-tree HEAD libs/dep
cat .gitmodules

cd ..
git clone parent14 consumer14
git -C consumer14 submodule status
git -C consumer14 -c protocol.file.allow=always submodule update --init --recursive
git -C consumer14 submodule status
git -C consumer14/libs/dep log -1 --oneline
cat consumer14/libs/dep/README.md

cd dep14
printf '\nVersion two adds an observation task.\n' >> README.md
git add README.md
git commit -m "docs: extend the shared lesson"
cd ../parent14
git -C libs/dep fetch origin
git -C libs/dep switch --detach origin/main
git diff --submodule=log
git add libs/dep
git commit -m "deps: adopt the extended shared lesson"
cd ..
git -C consumer14 fetch origin
git -C consumer14 merge --ff-only origin/main
git -C consumer14 -c protocol.file.allow=always submodule update --init --recursive
cat consumer14/libs/dep/README.md

mkdir subtree14
cd subtree14
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Subtree course\n' > README.md
git add README.md
git commit -m "docs: establish subtree course"
git subtree add --prefix vendor/dep ../dep14 main --squash
git ls-tree HEAD vendor/dep
git log --oneline --graph -5
cd ..
git clone subtree14 subtree-reader14
cat subtree-reader14/vendor/dep/README.md

cd source14
printf 'Unfinished development note.\n' > draft.txt
git worktree add -b maintenance14 ../hotfix14 HEAD~1
git worktree list
git -C ../hotfix14 status --short
git status --short
printf '\nA maintenance correction.\n' >> ../hotfix14/README.md
git -C ../hotfix14 add README.md
git -C ../hotfix14 commit -m "docs: correct the maintained material"
git log --oneline -1 main
git log --oneline -1 maintenance14

git worktree remove ../hotfix14
git worktree list
git show maintenance14:README.md
mv draft.txt ../draft14-saved.txt
git status --short

test -z "$(git status --porcelain)"
test -f ../draft14-saved.txt
test ! -d ../hotfix14
test "$(git worktree list --porcelain | grep -c '^worktree ')" = 1
git show maintenance14:README.md | grep -q 'maintenance correction'
test "$(git -C ../parent14 rev-parse HEAD:libs/dep)" = "$(git -C ../consumer14/libs/dep rev-parse HEAD)"
git -C ../parent14 ls-tree HEAD libs/dep | grep -q '^160000 commit'
git -C ../subtree14 ls-tree HEAD vendor/dep | grep -q '^040000 tree'
grep -q 'Version two' ../subtree-reader14/vendor/dep/README.md
git -C ../partial14 config --get remote.origin.promisor | grep -qx true
test -e ../sparse14/docs/guide.md
