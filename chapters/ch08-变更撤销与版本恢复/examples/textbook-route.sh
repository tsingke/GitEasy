#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab08-reset-source
cd lab08-reset-source
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Version: A\n' > state.txt
printf 'Original tracked content\n' > obstacle.txt
git add state.txt obstacle.txt
git commit -m "docs: record version A"
git tag reset-base
printf 'Version: B\n' > state.txt
git rm obstacle.txt
git add state.txt
git commit -m "docs: advance to version B"
git tag reset-tip

printf 'Version: C\n' > state.txt
git add state.txt
printf 'Version: D\n' > state.txt
git show HEAD:state.txt
git show :state.txt
cat state.txt
git diff --cached
git diff
cp state.txt ../draft08-saved.txt
git restore --staged -- state.txt
git show :state.txt
cat state.txt

git show :state.txt | grep -q "Version: B"
grep -q "Version: D" state.txt

git restore -- state.txt
cat state.txt
git restore --source=reset-base --worktree -- state.txt
git show HEAD:state.txt
git show :state.txt
cat state.txt
git restore --source=HEAD --worktree -- state.txt
git status --short

cd ..
git clone lab08-reset-source lab08-soft
cd lab08-soft
printf 'Version: C\n' > state.txt
git add state.txt
printf 'Version: D\n' > state.txt
git reset --soft reset-base
git show HEAD:state.txt
git show :state.txt
cat state.txt
git status --short
git diff --cached -- state.txt
git diff -- state.txt

cd ..
git clone lab08-reset-source lab08-mixed
cd lab08-mixed
printf 'Version: C\n' > state.txt
git add state.txt
printf 'Version: D\n' > state.txt
git reset --mixed reset-base
git show HEAD:state.txt
git show :state.txt
cat state.txt
git status --short

cd ..
git clone lab08-reset-source lab08-hard
cd lab08-hard
printf 'Version: C\n' > state.txt
git add state.txt
printf 'Version: D\n' > state.txt
printf 'Temporary untracked note\n' > obstacle.txt
printf 'Unrelated untracked draft\n' > scratch.txt
cp obstacle.txt ../obstacle08-saved.txt
git reset --hard reset-base
git show HEAD:state.txt
git show :state.txt
cat state.txt
cat obstacle.txt
cat scratch.txt
git status --short

cd ..

mkdir lab08
cd lab08
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Room: A101\n' > room.txt
git add room.txt
git commit -m "docs: record room"
printf 'Room: A999\n' > room.txt
git add room.txt
git commit -m "docs: change room by mistake"
git tag mistake08
git branch saved08

git reset --soft HEAD~1
git diff --cached
git show HEAD:room.txt
cat room.txt

git restore --source=HEAD --staged --worktree -- room.txt
git switch saved08
git revert --no-edit mistake08
git log --oneline -3
git show HEAD:room.txt

cd ..
mkdir lab08-merge
cd lab08-merge
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Course baseline\n' > README.md
git add README.md
git commit -m "docs: establish baseline"
git switch -c topic
printf 'Feature exercise\n' > feature.txt
git add feature.txt
git commit -m "docs: add feature exercise"
git switch main
printf 'Main schedule\n' > schedule.txt
git add schedule.txt
git commit -m "docs: add main schedule"
git merge --no-ff topic -m "merge: integrate feature exercise"
git tag merged08
git rev-list --parents -n 1 merged08
git diff 'merged08^1' merged08

git revert --no-edit -m 1 merged08
git tag undone08
git ls-tree --name-only HEAD
git merge topic
git merge --no-ff topic
git merge-base --is-ancestor topic HEAD

git revert --no-edit undone08
cat feature.txt
cat schedule.txt
git log --graph --oneline --all

cd ..
mkdir lab08-amend
cd lab08-amend
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Base material\n' > README.md
git add README.md
git commit -m "docs: establish base"
printf 'Lesson material\n' > lesson.txt
git add lesson.txt
git commit -m "docs: add lesson material"
git tag before-amend
printf 'Exercise material\n' > exercise.txt
git add exercise.txt
git commit --amend --no-edit
git rev-parse before-amend HEAD
git rev-parse 'before-amend^' 'HEAD^'
git show --stat before-amend
git show --stat HEAD

git status --short
git diff --cached
git commit --amend -m "docs: add lesson and exercise materials"
git log --oneline -2

cd ..
mkdir lab08-stash
cd lab08-stash
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '*.cache\n' > .gitignore
printf 'Line: base\n' > state.txt
git add .gitignore state.txt
git commit -m "docs: establish stash baseline"
printf 'Line: staged\n' > state.txt
git add state.txt
printf 'Line: working\n' > state.txt
printf 'Untracked plan\n' > draft.txt
printf 'Disposable cache\n' > build.cache
git stash push -u -m "lesson draft with staged boundary"
git stash list
git stash show --stat --include-untracked 'stash@{0}'
git status --short
cat build.cache

git stash apply --index 'stash@{0}'
git show :state.txt
cat state.txt
cat draft.txt
git status --short
git stash list
git stash drop 'stash@{0}'

git show :state.txt | grep -q "Line: staged"
grep -q "Line: working" state.txt
test -f draft.txt

git stash push -u -m "local plan before upstream change"
printf 'Line: upstream\n' > state.txt
git add state.txt
git commit -m "docs: record another accepted wording"
if git stash pop 'stash@{0}'; then exit 91; fi
git status --short
git ls-files -u
git stash list

test -n "$(git ls-files -u)"
test -n "$(git stash list)"

printf 'Line: combined after review\n' > state.txt
git add state.txt draft.txt
git diff --cached --check
git diff --cached
git ls-files -u
git commit -m "docs: reconcile current wording and saved plan"
git stash drop 'stash@{0}'
git stash list
git status --short

cd ..
mkdir lab08-rescue
cd lab08-rescue
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Recovery baseline\n' > README.md
git add README.md
git commit -m "docs: establish recovery baseline"
git switch -c task
printf 'Recover this committed plan\n' > plan.txt
git add plan.txt
git commit -m "docs: record recoverable plan"
git switch main
git branch -D task
git reflog --oneline HEAD

RESCUE08=$(git rev-parse 'HEAD@{1}')
git show --stat "$RESCUE08"
git branch rescued "$RESCUE08"
git show rescued:plan.txt
git log --oneline main..rescued
git status --short

test "$(git branch --show-current)" = main
git show rescued:plan.txt | grep -q 'Recover this committed plan'
test ! -e plan.txt
test -z "$(git status --porcelain)"
cd ../lab08-reset-source
test "$(git rev-parse HEAD)" = "$(git rev-parse reset-tip)"
test -z "$(git status --porcelain)"
cd ../lab08-soft
test "$(git rev-parse HEAD)" = "$(git rev-parse reset-base)"
git show :state.txt | grep -q 'Version: C'
grep -q 'Version: D' state.txt
cd ../lab08-mixed
test "$(git rev-parse HEAD)" = "$(git rev-parse reset-base)"
git show :state.txt | grep -q 'Version: A'
grep -q 'Version: D' state.txt
git show :obstacle.txt | grep -q 'Original tracked content'
test ! -e obstacle.txt
cd ../lab08-hard
test "$(git rev-parse HEAD)" = "$(git rev-parse reset-base)"
git show :state.txt | grep -q 'Version: A'
grep -q 'Version: A' state.txt
grep -q 'Original tracked content' obstacle.txt
grep -q 'Unrelated untracked draft' scratch.txt
grep -q 'Temporary untracked note' ../obstacle08-saved.txt
grep -q 'Version: D' ../draft08-saved.txt
cd ../lab08
git merge-base --is-ancestor mistake08 HEAD
grep -q 'Room: A101' room.txt
cd ../lab08-merge
test -f feature.txt && test -f schedule.txt
git diff --exit-code HEAD merged08
git merge-base --is-ancestor topic HEAD
if git cat-file -e undone08:feature.txt; then exit 92; fi
cd ../lab08-amend
test "$(git rev-parse 'before-amend^')" = "$(git rev-parse 'HEAD^')"
test "$(git rev-parse before-amend)" != "$(git rev-parse HEAD)"
test -f lesson.txt && test -f exercise.txt
cd ../lab08-stash
test -z "$(git stash list)"
test -z "$(git status --porcelain)"
test -z "$(git ls-files -u)"
grep -q 'Line: combined after review' state.txt
grep -q 'Untracked plan' draft.txt
grep -q 'Disposable cache' build.cache
