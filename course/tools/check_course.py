#!/usr/bin/env python3
"""Check the working files OR index of a course repository (Python 3.9+)."""
import argparse
from pathlib import Path
import re
import subprocess

REQUIRED = ('README.md', 'docs/syllabus.md', 'lessons/lab01.md',
            'lessons/lab02.md', 'CHANGELOG.md')
MARKER = re.compile(r'^(?:<{7}|={7}|>{7})(?:\s|$)', re.MULTILINE)

def run_git(root, *args):
    return subprocess.run(['git', '-C', str(root), *args], check=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout

def check(root, index=False):
    failures = []
    if index:
        try:
            if run_git(root, 'ls-files', '-u'):
                failures.append('Index contains unmerged entries.')
        except subprocess.CalledProcessError:
            return ['Cannot read Git index; verify the repository path.']
    for name in REQUIRED:
        try:
            raw = run_git(root, 'show', ':' + name) if index else (root / name).read_bytes()
            text = raw.decode('utf-8')
        except (OSError, UnicodeError, subprocess.CalledProcessError):
            failures.append(f'{name}: missing or not readable UTF-8 text.')
            continue
        if not text.startswith('# '):
            failures.append(f'{name}: first line must be a level-one Markdown title.')
        if MARKER.search(text):
            failures.append(f'{name}: possible unresolved conflict marker.')
        if not text.endswith('\n'):
            failures.append(f'{name}: missing final newline.')
    return failures

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path('.'))
    parser.add_argument('--index', action='store_true', help='read staged blobs, not working files')
    args = parser.parse_args()
    failures = check(args.repo.resolve(), args.index)
    scope = 'index' if args.index else 'working tree'
    if failures:
        print(f'FAIL ({scope})')
        for failure in failures:
            print('- ' + failure)
        return 1
    print(f'PASS ({scope}): {len(REQUIRED)} required documents checked.')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
