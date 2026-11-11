#!/usr/bin/env python3
"""Apply the explicit regression test or implementation fix used by the textbook lab."""
from pathlib import Path
import argparse
p=argparse.ArgumentParser();p.add_argument('--tests-only',action='store_true');p.add_argument('--implementation-only',action='store_true');a=p.parse_args()
root=Path.cwd()
if not a.implementation_only:
    path=root/'tests/test_card_service.cpp';s=path.read_text()
    line='    rejects([&]{service.openStaff("T3","x","   ");},"blank holder name");\n'
    if line not in s:
        token='    rejects([&]{service.card("missing");}'
        assert token in s;path.write_text(s.replace(token,line+token))
if not a.tests_only:
    path=root/'src/card_service.cpp';s=path.read_text();old='id_.empty() || name_.empty()'
    new='id_.find_first_not_of(" \\t\\r\\n")==std::string::npos || name_.find_first_not_of(" \\t\\r\\n")==std::string::npos'
    assert old in s or new in s;path.write_text(s.replace(old,new))
