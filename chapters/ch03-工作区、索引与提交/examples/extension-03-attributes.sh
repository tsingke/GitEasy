#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir attributes03
cd attributes03
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '*.txt text eol=lf\n' > .gitattributes
python3 - <<'PY'
from pathlib import Path
Path('note.txt').write_bytes(b'alpha\r\nbeta\r\n')
PY
git check-attr text eol -- note.txt
git add .gitattributes note.txt
python3 - <<'PY'
import subprocess
staged = subprocess.run(['git','show',':note.txt'],capture_output=True,check=True).stdout
assert staged == b'alpha\nbeta\n'
PY
git commit -m "chore: define the text normalization rule"

printf 'alpha\nbeta\ngamma\n' > note.txt
git add --renormalize .
git diff --cached --check
git diff --cached --stat
git commit -m "docs: extend the normalized note"
test -z "$(git status --porcelain)"
