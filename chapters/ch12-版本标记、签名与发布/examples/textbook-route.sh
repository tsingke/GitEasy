#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir lab12-release
cd lab12-release
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Course\n\nInitial reading material.\n' > README.md
git add README.md
git commit -m "docs: establish release material"
git tag checkpoint-1
git tag -a course-v1.0.0 -m "First stable course material"
git cat-file -t checkpoint-1
git cat-file -t course-v1.0.0
git cat-file -p course-v1.0.0
git rev-parse 'course-v1.0.0^{commit}'

RELEASE12=$(git rev-parse 'course-v1.0.0^{commit}')
printf '\nCorrect the reading order.\n' >> README.md
git add README.md
git commit -m "docs: clarify reading order"
git show course-v1.0.0:README.md
git diff course-v1.0.0 HEAD -- README.md
git describe --tags --long
git rev-parse 'course-v1.0.0^{commit}'

cd ..
git init --bare --initial-branch=main release-center.git
cd lab12-release
git remote add origin ../release-center.git
git push origin main
git push origin refs/tags/course-v1.0.0
git ls-remote --tags origin
git clone ../release-center.git ../release-reader
git -C ../release-reader rev-parse 'course-v1.0.0^{commit}'

cd ..
mkdir lab12-signing
cd lab12-signing
mkdir keys
ssh-keygen -q -t ed25519 -N '' -C 'gitbook-demo' -f keys/demo
printf 'learner@example.invalid %s\n' "$(cat keys/demo.pub)" > keys/allowed_signers
mkdir project
cd project
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
git config gpg.format ssh
git config user.signingkey "$(pwd)/../keys/demo"
git config gpg.ssh.allowedSignersFile "$(pwd)/../keys/allowed_signers"
printf '# Signed course\n' > README.md
git add README.md
git commit -S -m "docs: establish signed practice"
git tag -s signed-v1 -m "Signed practice release"

git verify-commit HEAD
git verify-tag signed-v1
git log -1 --show-signature
git cat-file -p HEAD

cp ../keys/allowed_signers ../keys/allowed_signers.saved
: > ../keys/allowed_signers
if git verify-commit HEAD; then exit 91; fi

mv ../keys/allowed_signers.saved ../keys/allowed_signers
git verify-commit HEAD
git verify-tag signed-v1
git status --short

test -z "$(git status --porcelain)"
git cat-file -p HEAD | grep -q 'BEGIN SSH SIGNATURE'
git -C ../../lab12-release cat-file -t course-v1.0.0 | grep -qx tag
git -C ../../lab12-release cat-file -t checkpoint-1 | grep -qx commit
test "$RELEASE12" = "$(git -C ../../release-reader rev-parse 'course-v1.0.0^{commit}')"
test "$RELEASE12" = "$(git -C ../../lab12-release rev-parse HEAD^)"
test -z "$(git -C ../../lab12-release ls-remote origin refs/tags/checkpoint-1)"
