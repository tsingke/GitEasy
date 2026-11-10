#!/usr/bin/env python3
"""Run chapter labs in disposable directories and preserve evidence outside Git repositories."""
import argparse
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import tempfile
import time

ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser(description=__doc__)
choice=parser.add_mutually_exclusive_group(required=True)
choice.add_argument('--chapter',type=int,choices=range(1,17))
choice.add_argument('--all',action='store_true')
parser.add_argument('--list',action='store_true',help='show selected routes without executing')
parser.add_argument('--output',type=Path,help='write logs and result JSON to this NEW directory')
args=parser.parse_args()
manifest=json.loads((ROOT/'chapter-manifest.json').read_text())
routes=[]
for chapter in manifest:
    if args.all or args.chapter==chapter['chapter']:
        routes.extend(sorted((ROOT/'chapters'/chapter['folder']/'examples').glob('*.sh')))
if args.list:
    for route in routes:print(route.relative_to(ROOT))
    if not routes:print('No executable route: this chapter is conceptual.')
    sys.exit(0)
for tool in ['git','bash','python3']:
    if not shutil.which(tool):parser.error(f'required executable not found: {tool}')
out=args.output.resolve() if args.output else Path(tempfile.mkdtemp(prefix='giteasy-evidence-'))
if args.output:
    try:out.mkdir(parents=True,exist_ok=False)
    except FileExistsError:parser.error('--output must be a new directory; existing evidence is never overwritten')
results=[]
for route in routes:
    name=route.parent.parent.name.split('-')[0]+'-'+route.stem
    with tempfile.TemporaryDirectory(prefix=f'giteasy-{name}-') as sandbox:
        sandbox=str(Path(sandbox).resolve())
        env=os.environ.copy()
        env.update(GIT_CONFIG_NOSYSTEM='1',GIT_CONFIG_GLOBAL=os.devnull,GIT_TERMINAL_PROMPT='0',
                   GIT_EDITOR='true',GIT_MERGE_AUTOEDIT='no',LC_ALL='C',
                   GITEASY_LAB_SANDBOX=sandbox,GITEASY_COURSE=str(ROOT/'course'))
        start=time.monotonic()
        try:
            result=subprocess.run([shutil.which('bash'),'-e',str(route)],cwd=sandbox,env=env,
                                  text=True,capture_output=True,timeout=240)
            passed=result.returncode==0
            log=result.stdout+'\n'+result.stderr
            code=result.returncode
        except subprocess.TimeoutExpired as error:
            passed=False;code='timeout';log=str(error)
    (out/f'{name}.log').write_text(log)
    row={'route':str(route.relative_to(ROOT)),'passed':passed,'exit_code':code,
         'seconds':round(time.monotonic()-start,2)}
    results.append(row)
    print(('PASS' if passed else 'FAIL')+' '+row['route'],flush=True)
    if not passed:print(log[-2500:],file=sys.stderr)
report={'platform':platform.platform(),'python':platform.python_version(),
        'git':subprocess.run(['git','--version'],capture_output=True,text=True,check=True).stdout.strip(),
        'scope':'offline teaching routes only; no platform authentication, PR review, LFS or production credentials',
        'results':results}
(out/'results.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(f'Evidence: {out}')
sys.exit(0 if all(row['passed'] for row in results) else 1)
