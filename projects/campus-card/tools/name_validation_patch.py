#!/usr/bin/env python3
"""Apply the explicit regression test or implementation fix for the staged lab."""
from pathlib import Path
import argparse
from lab_scenario import identity,identity_test
p=argparse.ArgumentParser();p.add_argument('--tests-only',action='store_true');p.add_argument('--implementation-only',action='store_true');a=p.parse_args()
assert not(a.tests_only and a.implementation_only),'Choose one phase or neither'
root=Path.cwd()
if not a.implementation_only:identity_test(root)
if not a.tests_only:identity(root)
