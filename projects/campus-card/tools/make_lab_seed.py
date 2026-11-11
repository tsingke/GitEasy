#!/usr/bin/env python3
"""Create a NEW baseline with explicit, later-delivered teaching changes."""
from pathlib import Path
import shutil,sys
from lab_scenario import identity,identity_test,currency
source=Path(__file__).resolve().parents[1]
if len(sys.argv)!=2:raise SystemExit('usage: python3 make_lab_seed.py NEW_DIRECTORY')
target=Path(sys.argv[1]).resolve()
if target.exists():raise SystemExit('Target already exists; choose a new directory')
shutil.copytree(source,target,ignore=shutil.ignore_patterns('.git','build*','__pycache__','*.pyc'))
shutil.rmtree(target/'gui')
identity(target,False)
identity_test(target,False)
currency(target,False)
(target/'docs/demo-policy.md').write_text('Service desk: pending\n')
p=target/'CMakeLists.txt';p.write_text(p.read_text().replace('VERSION 0.1.1','VERSION 0.1.0'))
(target/'BASELINE.md').write_text('# Teaching baseline\n\nThe multi-file core is present. GUI files, currency export and the nonblank-name regression are deliberately delivered in later tasks. This note describes the initial exercise, not current completeness.\n')
print(target)
