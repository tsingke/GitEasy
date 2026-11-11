#!/usr/bin/env bash
# From the textbook lab17.tex command blocks.
set -e
: "${GITEASY_LAB_SANDBOX:?Use tools/run_enterprise_lab.py}"
test "$PWD" = "$GITEASY_LAB_SANDBOX"
python3 "$GITEASY_CAMPUS/tools/make_lab_seed.py" seed
git init --bare -b main center.git
git clone center.git team-a
cp -R seed/. team-a/
cd team-a
git config user.name 'Developer A'
git config user.email 'a@example.invalid'
git add .
git diff --cached --stat
git commit -m 'build: establish campus card core baseline'
git push -u origin main
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --clean-first --parallel 2
ctest --test-dir build --output-on-failure
cd ..

git clone center.git team-b
cd team-b
git config user.name 'Developer B'
git config user.email 'b@example.invalid'
git status --short
git log --oneline -1
cd ..

cd team-a
git switch -c feature/csv-currency
python3 - <<'PY'
from pathlib import Path
p=Path('src/card_service.cpp');s=p.read_text()
s=s.replace('balance_after,day\\n','balance_after,day,currency\\n')
s=s.replace("<<','<<item.day<<'\\n';", "<<','<<item.day<<\",CNY\\n\";")
p.write_text(s)
p=Path('tests/test_card_service.cpp');s=p.read_text()
token='    const auto before=service.history().size();'
s=s.replace(token,'    check(service.exportCsv().find(",CNY\\n")!=std::string::npos,"CSV currency");\n'+token)
p.write_text(s)
PY
cmake --build build --clean-first --parallel 2
ctest --test-dir build --output-on-failure
git add src/card_service.cpp tests/test_card_service.cpp
git diff --cached --stat
git commit -m 'feat: include currency in exported transactions'
git push -u origin feature/csv-currency
cd ..

cd team-b
git switch -c feature/qt-console
mkdir -p gui
cp "$GITEASY_CAMPUS/gui/main.cpp" gui/main.cpp
printf '\nQt console is enabled with CAMPUS_BUILD_GUI=ON.\n' >> README.md
git add gui/main.cpp README.md
git diff --cached --stat
git commit -m 'feat: add Qt campus card service console'
git push -u origin feature/qt-console
cd ..

cd team-a
git switch main
git merge --no-ff feature/csv-currency -m 'merge: deliver CSV currency'
git push origin main
cd ..

cd team-b
git switch main
git merge --no-ff feature/qt-console -m 'merge: deliver Qt console'
if git push origin main; then exit 1; fi
git fetch origin
git log --oneline --left-right main...origin/main
git merge origin/main -m 'merge: integrate parallel deliveries'
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --clean-first --parallel 2
ctest --test-dir build --output-on-failure
git push origin main
cd ..

cd team-a
git fetch origin
git merge --ff-only origin/main
git switch -c feature/desk-north
printf 'Service desk: north campus\n' > docs/demo-policy.md
git add docs/demo-policy.md
git commit -m 'docs: propose north campus service desk'
git switch main
git merge --no-ff feature/desk-north -m 'merge: record north desk proposal'
git push origin main
cd ..

cd team-b
git switch -c feature/desk-south
printf 'Service desk: south campus\n' > docs/demo-policy.md
git add docs/demo-policy.md
git commit -m 'docs: propose south campus service desk'
git switch main
git merge --no-ff feature/desk-south -m 'merge: record south desk proposal'
git fetch origin
if git merge origin/main; then exit 1; fi
git status --short
git ls-files -u -- docs/demo-policy.md

printf 'Service desks: north and south campuses\n' > docs/demo-policy.md
git add docs/demo-policy.md
git diff --cached --check
git commit -m 'merge: support both campus service desks'
git push origin main
git rev-list --parents -n 1 HEAD
cd ..

cd team-a
git fetch origin
git merge --ff-only origin/main
git tag -a campus-v0.1.0 -m 'Campus core and Qt source teaching baseline'
git push origin campus-v0.1.0
git switch -c fix/nonblank-holder
python3 "$GITEASY_CAMPUS/tools/name_validation_patch.py" --tests-only
cmake --build build --clean-first --parallel 2
if ctest --test-dir build --output-on-failure > build/regression-before.log 2>&1; then exit 1; fi
cat build/regression-before.log
grep -q 'FAIL blank holder name' build/regression-before.log

python3 "$GITEASY_CAMPUS/tools/name_validation_patch.py" --implementation-only
cmake --build build --clean-first --parallel 2
ctest --test-dir build --output-on-failure
git add src/card_service.cpp tests/test_card_service.cpp
git diff --cached --check
git commit -m 'fix: reject whitespace-only holder identity'
fix_commit=$(git rev-parse HEAD)
git switch main
git merge --no-ff fix/nonblank-holder -m 'merge: validate nonblank holder identity'
git push origin main
cd ..

git clone center.git maintainer
cd maintainer
git config user.name 'Release Maintainer'
git config user.email 'maintainer@example.invalid'
git switch -c maintenance/0.1 campus-v0.1.0
git cherry-pick "$fix_commit"
git diff --name-only campus-v0.1.0..HEAD
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --clean-first --parallel 2
ctest --test-dir build --output-on-failure
python3 - <<'PYVERSION'
from pathlib import Path
p=Path('CMakeLists.txt');p.write_text(p.read_text().replace('VERSION 0.1.0','VERSION 0.1.1'))
PYVERSION
git add CMakeLists.txt
git commit -m 'build: identify maintenance release 0.1.1'
git tag -a campus-v0.1.1 -m 'Maintenance fix for nonblank holder identity'
git push -u origin maintenance/0.1
git push origin campus-v0.1.1
cd ..

cd team-a
git switch -c feature/upgrade-guide
printf '# Upgrade guide\n' > docs/upgrade.md
git add docs/upgrade.md
git commit -m 'docs: describe campus card upgrade'
printf '\nRun the core tests before deployment.\n' >> docs/upgrade.md
git add docs/upgrade.md
git commit --fixup HEAD
GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash HEAD~2
git rev-list --count main..HEAD
git show --stat HEAD
git switch main
cd ..

cd team-a
git switch -c drill/lost-card-regression
good_commit=$(git rev-parse HEAD)
printf 'Investigation starts from a known passing baseline.\n' > docs/investigation.md
git add docs/investigation.md
git commit -m 'docs: record investigation baseline'
python3 - <<'PY'
from pathlib import Path
p=Path('src/card_service.cpp');s=p.read_text()
assert 'if(target.state!=CardState::Active)' in s
p.write_text(s.replace('if(target.state!=CardState::Active)','if(false)'))
PY
git add src/card_service.cpp
git commit -m 'test: inject lost-card regression for bisect drill'
bad_commit=$(git rev-parse HEAD)
printf 'Keep evidence for each tested revision.\n' >> docs/investigation.md
git add docs/investigation.md
git commit -m 'docs: explain investigation evidence'

git bisect start HEAD "$good_commit"
git bisect run python3 "$GITEASY_CAMPUS/tools/bisect_check.py"
test "$(git rev-parse refs/bisect/bad)" = "$bad_commit"
git bisect log
git bisect reset
git switch main
cd ..

cd team-a
python3 - <<'PY'
from pathlib import Path
p=Path('src/card_service.cpp');p.write_text(p.read_text().replace('if(target.state!=CardState::Active)','if(false)'))
PY
git add src/card_service.cpp
git restore --source=HEAD --worktree -- src/card_service.cpp
git status --short
cmake --build build --clean-first --parallel 2
ctest --test-dir build --output-on-failure
if python3 tools/check_candidate.py; then exit 1; fi

git restore --staged -- src/card_service.cpp
python3 tools/check_candidate.py
git status --short
cd ..

cd team-a
git fetch origin --tags
git archive --format=zip --output=../campus-v0.1.1-source.zip campus-v0.1.1
git bundle create ../campus-history.bundle --all
git bundle verify ../campus-history.bundle
cd ..
git clone campus-history.bundle restored
cd restored
git switch -c verify/release campus-v0.1.1
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --clean-first --parallel 2
ctest --test-dir build --output-on-failure
git describe --tags --exact-match
git status --short
cd ..

cd team-a
git worktree add -b verify/maintenance ../maintenance-tree campus-v0.1.1
git worktree list
cmake -S ../maintenance-tree -B ../maintenance-build -DCMAKE_BUILD_TYPE=Release
cmake --build ../maintenance-build --parallel 2
ctest --test-dir ../maintenance-build --output-on-failure
git worktree remove ../maintenance-tree
cd ..

test -f team-a/gui/main.cpp
grep -q 'currency' team-a/src/card_service.cpp
grep -q 'north and south' team-a/docs/demo-policy.md
test "$(git -C team-a rev-list --count main..feature/upgrade-guide)" = 1
test -z "$(git -C team-a status --porcelain)"
test -f campus-v0.1.1-source.zip
test -f campus-history.bundle
test "$(git -C restored describe --tags --exact-match)" = campus-v0.1.1
