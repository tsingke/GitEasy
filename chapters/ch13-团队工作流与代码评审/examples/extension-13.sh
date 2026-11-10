#!/usr/bin/env bash
# Generated from the textbook's verified command route; run via tools/run_lab.py.
set -e
: "${GITEASY_LAB_SANDBOX:?Run this lab with tools/run_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
mkdir review13
cd review13
git init -b main
git config user.name "Git Learner"
git config user.email "learner@example.invalid"
printf '# Course guide\n' > README.md
git add README.md
git commit -m "docs: establish the course guide"
git switch -c docs/submission
mkdir docs
cat > docs/submission.md <<'EOF'
# Report submission

- Location: reports/student-id/
- File name: lab-number.md
- Deadline: Friday 18:00, Asia/Shanghai.
- Required sections: method, evidence, and explanation.
EOF
git add docs/submission.md
git commit -m "docs: define the report submission contract"
git diff --check main...HEAD
git diff --stat main...HEAD
git log --oneline main..HEAD

cat > ../review13-summary.md <<'EOF'
# Submission contract

Problem: students need one unambiguous report location.
Change: define location, file naming, deadline, and report sections.
Validation: inspect the new guide and run git diff --check.
Follow-up: the instructor confirms the deadline before merging.
EOF
test "$(git diff --name-only main...HEAD)" = docs/submission.md
grep -q 'Asia/Shanghai' docs/submission.md
test -z "$(git status --porcelain)"
