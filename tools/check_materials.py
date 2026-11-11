#!/usr/bin/env python3
"""Check chapter naming, resource links and absence of author-specific paths."""
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[1]
chapters=json.loads((ROOT/'chapter-manifest.json').read_text())
assert [x['chapter'] for x in chapters]==list(range(1,18))
for ch in chapters:
    base=ROOT/'chapters'/ch['folder']
    assert (base/'README.md').is_file(),base
    assert (base/'exercises.md').is_file(),base
errors=[]
for p in ROOT.rglob('*'):
    if '.git' in p.parts or not p.is_file() or p.suffix not in {'.md','.py','.sh','.json','.yml'}:continue
    text=p.read_text()
    if p.suffix=='.sh' and ('/Users/' in text or '/path/to/' in text):errors.append(f'{p}: nonportable path')
    if p.suffix=='.md':
        for link in re.findall(r'!?\[[^\]]*\]\(([^)]+)\)',text):
            if '://' in link or link.startswith('#'):continue
            target=(p.parent/link.split('#')[0]).resolve()
            if not target.exists():errors.append(f'{p.relative_to(ROOT)}: missing {link}')
assert not errors,'\n'.join(errors)
print(f'{len(chapters)} chapter folders and relative Markdown links passed')
