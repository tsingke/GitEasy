#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir patch11
cd patch11
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Room: A101\n' > room.txt
git add room.txt
git commit -m "docs: establish the patch baseline"
printf 'Room: B202\n' > room.txt
git diff --binary > ../room11.patch
git restore -- room.txt
git apply --stat ../room11.patch
git apply --check ../room11.patch
git apply ../room11.patch

grep -q 'Room: B202' room.txt
test "$(git rev-list --count HEAD)" = 1
test -z "$(git diff --cached)"
git diff -- room.txt
git add room.txt
git commit -m "fix: apply the corrected room patch"

git branch receive-base
git switch -c mail-topic
printf 'Inspect the patch before applying it.\n' > review.txt
git add review.txt
git commit -m "docs: add a patch review reminder"
SOURCE11=$(git rev-parse HEAD)
git format-patch -1 --stdout HEAD > ../lesson11.mbox
git switch -c mail-receiver receive-base
git am ../lesson11.mbox
git show HEAD:review.txt
git log -1 --format='%an <%ae>%n%s'
test -z "$(git diff mail-topic mail-receiver)"
test -z "$(git status --porcelain)"
