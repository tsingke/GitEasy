#!/usr/bin/env python3
"""Publish the actual route results to the native Actions job summary."""
from pathlib import Path
import json,os,sys
path=Path(sys.argv[1]) if len(sys.argv)>1 else Path('lab-results/results.json')
if path.exists():
 report=json.loads(path.read_text());rows=report['results'];passed=sum(row['passed'] for row in rows)
 text=f'## Offline teaching routes\n\n{passed} / {len(rows)} passed.\n\n| Route | Result |\n|---|---|\n'
 text+=''.join('| '+row['route']+' | '+('PASS' if row['passed'] else 'FAIL')+' |\n' for row in rows)
 text+='\nScope: local repositories and build checks; no real platform review or credentials.\n'
else:text='## Offline teaching routes\n\nNo completed route report was produced. Check the failing preparation step.\n'
print(text)
if os.environ.get('GITHUB_STEP_SUMMARY'):
 with open(os.environ['GITHUB_STEP_SUMMARY'],'a') as stream:stream.write(text)
