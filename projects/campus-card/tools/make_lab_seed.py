#!/usr/bin/env python3
"""Create a NEW, explicitly incomplete baseline for the staged textbook exercise."""
from pathlib import Path
import shutil,sys
source=Path(__file__).resolve().parents[1]
if len(sys.argv)!=2:raise SystemExit('usage: python3 make_lab_seed.py NEW_DIRECTORY')
target=Path(sys.argv[1]).resolve()
if target.exists():raise SystemExit('Target already exists; choose a new directory')
shutil.copytree(source,target,ignore=shutil.ignore_patterns('.git','build*','__pycache__','*.pyc'))
(target/'gui/main.cpp').unlink()
src=target/'src/card_service.cpp';s=src.read_text();s=s.replace('id_.find_first_not_of(" \\t\\r\\n")==std::string::npos || name_.find_first_not_of(" \\t\\r\\n")==std::string::npos','id_.empty() || name_.empty()');src.write_text(s)
test=target/'tests/test_card_service.cpp';test.write_text(test.read_text().replace('    rejects([&]{service.openStaff("T3","x","   ");},"blank holder name");\n',''))
(target/'docs/demo-policy.md').write_text('Service desk: pending\n')
cmake=target/'CMakeLists.txt';cmake.write_text(cmake.read_text().replace('VERSION 0.1.1','VERSION 0.1.0'))
src=target/'src/card_service.cpp';s=src.read_text().replace('balance_after,day,currency\\n','balance_after,day\\n').replace('<<\",CNY\\n\";', "<<'\\n';")
src.write_text(s)
test=target/'tests/test_card_service.cpp';test.write_text(test.read_text().replace('    check(service.exportCsv().find(\",CNY\\n\")!=std::string::npos,\"CSV currency\");\n',''))
(target/'BASELINE.md').write_text('# Teaching baseline\n\nThe seed initially omitted GUI implementation, currency export and the whitespace-only-name regression. Later tasks add them. This file records initial exercise conditions, not the status of the current revision.\n')
print(target)
