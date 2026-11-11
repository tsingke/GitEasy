#!/usr/bin/env bash
set -e
: "${GITEASY_LAB_SANDBOX:?Use tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir layout09
cd layout09
git init -b main --object-format=sha1 --ref-format=files
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf 'Repository layout\n' > notes.txt
git add notes.txt
git commit -m "docs: establish a layout observation baseline"
git tag -a layout-v1 -m "Layout observation baseline"

git rev-parse --git-dir
git rev-parse --git-common-dir
git rev-parse --git-path HEAD
git rev-parse --git-path index
cat "$(git rev-parse --git-path HEAD)"
git ls-files --stage
git cat-file -p HEAD

INDEX_BLOB=$(git rev-parse :notes.txt)
printf 'Unstaged detail\n' >> notes.txt
test "$(git rev-parse :notes.txt)" = "$INDEX_BLOB"
git diff -- notes.txt
git show :notes.txt
git restore --worktree -- notes.txt

LAYOUT_TIP=$(git rev-parse main)
git pack-refs --all
git show-ref --verify refs/heads/main
test "$(git rev-parse main)" = "$LAYOUT_TIP"
git for-each-ref --format='%(refname) %(objectname)' refs/heads refs/tags

git worktree add -b inspect-layout ../layout09-linked
cat ../layout09-linked/.git
git -C ../layout09-linked rev-parse --git-dir
git -C ../layout09-linked rev-parse --git-common-dir
git -C ../layout09-linked rev-parse --git-path index
git worktree remove ../layout09-linked
test -z "$(git status --porcelain)"
cd ..

test "$(git -C layout09 rev-list --count main)" = 1
test "$(git -C layout09 rev-parse main)" = "$(git -C layout09 rev-parse layout-v1^{commit})"
test -z "$(git -C layout09 status --porcelain)"
python3 - <<'PYCHECK'
from pathlib import Path
assert Path('layout09/.git/index').read_bytes().startswith(b'DIRC')
assert Path('layout09/.git/packed-refs').is_file()
assert not Path('layout09-linked').exists()
PYCHECK
