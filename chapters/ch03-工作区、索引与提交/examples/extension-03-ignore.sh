#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir ignore03
cd ignore03
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
mkdir build
cat > .gitignore <<'EOF'
/build/*
!/build/README.md
*.tmp
EOF
printf '# Build output directory\n' > build/README.md
printf 'generated data\n' > build/result.bin
printf 'temporary notes\n' > scratch.tmp
git check-ignore -v build/result.bin scratch.tmp
if git check-ignore -q build/README.md; then exit 1; fi
git status --short --untracked-files=all

git add .gitignore build/README.md
git commit -m "chore: document and filter generated output"
git ls-files
test "$(git ls-files | wc -l | tr -d ' ')" = 2
test -z "$(git status --porcelain)"
test -f build/result.bin
