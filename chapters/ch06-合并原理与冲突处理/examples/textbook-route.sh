#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab06-shapes
cd lab06-shapes
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Course materials\n' > README.md
git add README.md
git commit -m "docs: establish course baseline"
git tag shape-base
git switch -c lesson
printf 'Task: inspect a merge\n' > lesson.txt
git add lesson.txt
git commit -m "docs: add merge lesson"
git switch main
git merge --ff-only lesson
git rev-parse main lesson
git rev-list --count main
git switch -c preserve shape-base
git merge --no-ff lesson -m "merge: integrate lesson with a boundary"
git rev-list --parents -n 1 HEAD
git diff main preserve
git log --graph --oneline --all
git switch -c left shape-base
printf 'Left task\n' > left.txt
git add left.txt
git commit -m "docs: add left task"
git switch -c right shape-base
printf 'Right task\n' > right.txt
git add right.txt
git commit -m "docs: add right task"
git switch left
if git merge --ff-only right; then echo "Expected failure 1 did not occur" >&2; exit 91; fi
git merge --no-ff --no-commit right
git status
git rev-parse HEAD MERGE_HEAD
git diff --cached --stat
git diff --cached
git commit -m "merge: integrate right after inspection"
git rev-list --parents -n 1 HEAD
git merge right
cd ..
mkdir lab06
cd lab06
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
git config merge.conflictStyle diff3
printf 'Meeting: Monday\n' > course.txt
git add course.txt
git commit -m "docs: baseline meeting"
git switch -c proposal
printf 'Meeting: Tuesday\n' > course.txt
git add course.txt
git commit -m "docs: propose Tuesday"
git switch main
printf 'Meeting: Wednesday\n' > course.txt
git add course.txt
git commit -m "docs: choose Wednesday"
if git merge proposal; then echo "Expected failure 2 did not occur" >&2; exit 91; fi
git show HEAD:course.txt
git show MERGE_HEAD:course.txt
git show HEAD~1:course.txt
git ls-files -u
git show :1:course.txt
git show :2:course.txt
git show :3:course.txt
printf 'Meeting: Wednesday\nOffice hours: Tuesday\n' > course.txt
git add course.txt
git diff --cached
git ls-files -u
git commit -m "docs: combine meeting and office hours"
git rev-list --parents -n 1 HEAD
git status --short
cd ..
mkdir lab06-cases
cd lab06-cases
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Policy: initial\n' > policy.txt
git add policy.txt
git commit -m "docs: add initial policy"
git tag case-base
git switch -c remove-policy
git rm policy.txt
git commit -m "docs: retire policy file"
git switch -c revise-policy case-base
printf 'Policy: revise before archiving\n' > policy.txt
git add policy.txt
git commit -m "docs: revise existing policy"
if git merge remove-policy; then echo "Expected failure 3 did not occur" >&2; exit 91; fi
git status --short
git ls-files -u
git show :1:policy.txt
git show :2:policy.txt
if git show :3:policy.txt; then echo "Expected failure 4 did not occur" >&2; exit 91; fi
printf 'Policy: archived after review\n' > policy.txt
git add policy.txt
git diff --cached --check
git diff --cached
git ls-files -u
git commit -m "merge: retain an explicit policy archive notice"
git switch -c add-students case-base
printf 'Audience: students\n' > handbook.txt
git add handbook.txt
git commit -m "docs: add student handbook"
git switch -c add-tutors case-base
printf 'Audience: tutors\n' > handbook.txt
git add handbook.txt
git commit -m "docs: add tutor handbook"
if git merge add-students; then echo "Expected failure 5 did not occur" >&2; exit 91; fi
git ls-files -u
git show :2:handbook.txt
git show :3:handbook.txt
if git show :1:handbook.txt; then echo "Expected failure 6 did not occur" >&2; exit 91; fi
git merge --abort
git status --short
cat handbook.txt
git branch --show-current
test -z "$(git status --porcelain)"
grep -q '^Audience: tutors$' handbook.txt
if git merge add-students; then echo "Expected failure 7 did not occur" >&2; exit 91; fi
git merge --quit
git status --short
git ls-files -u
if git rev-parse --verify MERGE_HEAD; then echo "Expected failure 8 did not occur" >&2; exit 91; fi
test -n "$(git ls-files -u)"
git restore --source=HEAD --staged --worktree -- handbook.txt
git status --short
cat handbook.txt
cd ..
mkdir lab06-semantic
cd lab06-semantic
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '__pycache__/\n' > .gitignore
printf 'discount = 10\n' > config.py
cat > price.py <<'PY'
from config import discount

def final_price(amount):
    return amount * (100 - discount) / 100
PY
git add .gitignore config.py price.py
git commit -m "feat: calculate discount in percentage points"
git tag semantic-base
python3 -c "from price import final_price; print(final_price(100))"
git switch -c fractional-discount
printf 'discount = 0.1\n' > config.py
cat > price.py <<'PY'
from config import discount

def final_price(amount):
    return amount * (1 - discount)
PY
git add config.py price.py
git commit -m "refactor: express discount as a fraction"
python3 -c "from price import final_price; assert final_price(100) == 90"
git switch -c receipt semantic-base
cat > receipt.py <<'PY'
from config import discount

def receipt_total(amount):
    return amount * (100 - discount) / 100
PY
git add receipt.py
git commit -m "feat: calculate receipt total"
python3 -c "from receipt import receipt_total; assert receipt_total(100) == 90"
git merge --no-ff fractional-discount -m "merge: integrate fractional discount"
python3 -c "from price import final_price; from receipt import receipt_total; print(final_price(100), receipt_total(100))"
if python3 -c "from receipt import receipt_total; assert receipt_total(100) == 90"; then echo "Expected failure 9 did not occur" >&2; exit 91; fi
cat > receipt.py <<'PY'
from price import final_price

def receipt_total(amount):
    return final_price(amount)
PY
python3 -c "from price import final_price; from receipt import receipt_total; assert final_price(100) == receipt_total(100) == 90"
git add receipt.py
git commit -m "fix: reuse the shared discount calculation"
git status --short
test -z "$(git status --porcelain)"
python3 -c "from price import final_price; from receipt import receipt_total; assert final_price(100) == receipt_total(100) == 90"
cd ../lab06-shapes
test "$(git branch --show-current)" = left
test -f left.txt && test -f right.txt
test "$(git rev-parse main)" = "$(git rev-parse lesson)"
test "$(git rev-list --count main)" = 2
test "$(git rev-list --parents -n 1 preserve | wc -w | tr -d ' ')" = 3
test "$(git rev-list --parents -n 1 left | wc -w | tr -d ' ')" = 3
git diff --exit-code main preserve
cd ../lab06
test "$(git rev-list --parents -n 1 HEAD | wc -w | tr -d ' ')" = 3
grep -q 'Office hours: Tuesday' course.txt
test -z "$(git status --porcelain)"
cd ../lab06-cases
test "$(git branch --show-current)" = add-tutors
test -z "$(git status --porcelain)"
git show revise-policy:policy.txt | grep -q 'Policy: archived after review'
