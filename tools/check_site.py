#!/usr/bin/env python3
"""Validate the self-contained Pages artifact using the Python standard library."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit,unquote
import json,re
R=Path(__file__).resolve().parents[1];W=R/'website'
class Page(HTMLParser):
 def __init__(self,path):
  super().__init__(convert_charrefs=True);self.ids=set();self.links=[];self.images=[];self.duplicate=[];self.h1=0;self.details=0;self.figures=0;self.codes=0;self.feed(path.read_text())
 def handle_starttag(self,tag,attrs):
  a=dict(attrs)
  if 'id' in a:
   if a['id'] in self.ids:self.duplicate.append(a['id'])
   self.ids.add(a['id'])
  if tag=='a' and a.get('href'):self.links.append(a['href'])
  if tag in ['img','script','link']:
   src=a.get('src') if tag in ['img','script'] else a.get('href')
   if src:self.images.append(src)
   if tag=='img' and src:assert a.get('alt'),('Missing alternative text',a)
  if tag=='h1':self.h1+=1
  if tag=='details' and a.get('class')=='exercise':self.details+=1
  if tag=='figure' and a.get('id','').startswith(('fig:','figure:')):self.figures+=1
  if tag=='div' and a.get('class')=='code-block':self.codes+=1
pages={p:Page(p) for p in W.rglob('*.html')};errors=[]
for p,page in pages.items():
 text=p.read_text()
 if 'WEBRAWPLACEHOLDER' in text or '{{CONTENT}}' in text:errors.append(f'{p.name}: unrendered source')
 if page.duplicate:errors.append(f'{p.name}: duplicate ids {page.duplicate}')
 if page.h1!=1:errors.append(f'{p.name}: expected one h1, found {page.h1}')
 for value in page.links+page.images:
  url=urlsplit(value)
  if url.scheme or url.netloc:continue
  if value.startswith('/'):errors.append(f'{p.name}: root-relative link incompatible with project Pages: {value}');continue
  target=(p.parent/unquote(url.path)).resolve() if url.path else p
  if not target.is_relative_to(W.resolve()):errors.append(f'{p.name}: non-self-contained {value}')
  elif not target.exists():errors.append(f'{p.name}: missing {value}')
  elif url.fragment and target.suffix=='.html' and unquote(url.fragment) not in pages[target].ids:errors.append(f'{p.name}: missing anchor {value}')
manifest=json.loads((W/'build-manifest.json').read_text())
chapters=[p for p in pages if p.parent.name=='chapters'];assert len(chapters)==manifest['chapters']==17
assert sum(pages[p].details for p in chapters)==manifest['questions']==218
assert sum(pages[p].figures for p in chapters)==manifest['figures']==251
assert sum(pages[p].codes for p in chapters)>100
assert (W/'.nojekyll').is_file()
assert not errors,'\n'.join(errors)
print(json.dumps({'html_pages':len(pages),'chapters':17,'questions':218,'figures':251,'command_entries':manifest['command_entries'],'local_links_and_anchors':'passed','artifact':'self-contained; no root-relative paths'},ensure_ascii=False))
