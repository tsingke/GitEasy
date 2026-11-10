#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir package12
cd package12
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
mkdir docs
printf '# Course package\n' > README.md
printf 'Environment: Git and Python 3.\n' > docs/environment.txt
git add README.md docs/environment.txt
git commit -m "docs: prepare the first course package"
git tag -a course-v1.0.0 -m "Course materials for the first delivery"
RELEASE12=$(git rev-parse 'course-v1.0.0^{commit}')
git archive --format=zip --prefix=course-v1.0.0/ \
  --output=../course-v1.0.0.zip course-v1.0.0
printf 'Environment: Git, Python 3, and an editor.\n' > docs/environment.txt
git add docs/environment.txt
git commit -m "docs: clarify the editor requirement"

test "$(git rev-parse 'course-v1.0.0^{commit}')" = "$RELEASE12"
test "$(git rev-parse HEAD)" != "$RELEASE12"
test "$(git cat-file -t course-v1.0.0)" = tag
git show course-v1.0.0:docs/environment.txt
git show HEAD:docs/environment.txt
python3 - <<'PY'
import zipfile
with zipfile.ZipFile('../course-v1.0.0.zip') as package:
    names = package.namelist()
    assert 'course-v1.0.0/README.md' in names
    assert not any('/.git/' in name for name in names)
    text = package.read('course-v1.0.0/docs/environment.txt').decode()
    assert text == 'Environment: Git and Python 3.\n'
PY
