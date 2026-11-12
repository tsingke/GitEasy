#!/usr/bin/env python3
"""Export the authored LaTeX manuscript into a self-contained, buildless study site.
Author-only: requires the sibling manuscript, its compiled PDF/aux, pandoc,
PyMuPDF, Pillow and BeautifulSoup. CI validates the checked-in static output.
"""
import sys
sys.dont_write_bytecode=True
import argparse, collections, hashlib, html, json, re, shutil, subprocess
from pathlib import Path
import fitz
from bs4 import BeautifulSoup
from PIL import Image
R=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser();parser.add_argument('--book',type=Path,default=R.parent.parent/'6-GitBook修订稿');parser.add_argument('--reuse-images',action='store_true',help='UI-only rebuild: reuse existing figure images; do not use after content or image changes');args=parser.parse_args()
B=args.book.resolve(); W=R/'website'; A=W/'assets'; A.mkdir(parents=True,exist_ok=True)
T=R/'tools/site_templates'; E=html.escape
manifest=json.loads((B/'docs/editorial/chapter-manifest.json').read_text())
questions=json.loads((B/'docs/editorial/exercise-details.json').read_text())
commands=json.loads((B/'docs/editorial/command-atlas.json').read_text())
labels={}; pages=json.loads((B/'quality/reports/compiled-label-pages.json').read_text())['labels']
for p in (B/'build/cache/Git全解-ocean').rglob('*.aux'):
 for key,num,page,title,target in re.findall(r'\\newlabel\{([^{}]+)\}\{\{([^{}]*)\}\{([^{}]*)\}\{([^{}]*)\}\{([^{}]*)\}',p.read_text()):
  labels[key]={'number':num,'page':pages.get(key),'title':title,'target':target}
assert labels and all(f'ch:lookup-{n:02}' in labels for n in range(1,18)), 'Build full manuscript first'
pdf=fitz.open(B/'build/pdf/Git全解-ocean.pdf')
lookup={}; records=[]; blocks=[]; search=[]; current=0; dependencies={}
parts=['基础篇','核心篇','进阶篇','实践篇']
def part(n):return 0 if n<=4 else 1 if n<=8 else 2 if n<=12 else 3

def group(text,pos):
 assert text[pos]=='{',text[pos:pos+50]
 start=pos+1;depth=1;pos+=1
 while pos<len(text):
  if text[pos]=='\\':pos+=2;continue
  if text[pos]=='{':depth+=1
  if text[pos]=='}':
   depth-=1
   if depth==0:return text[start:pos],pos+1
  pos+=1
 raise ValueError('Unbalanced TeX group')
def macro(text,name,handler):
 pattern=re.compile(r'\\'+re.escape(name)+r'(?![A-Za-z])\s*\{');out=[];start=0
 for_match=pattern.search(text)
 while for_match:
  out.append(text[start:for_match.start()]);value,end=group(text,for_match.end()-1);out.append(handler(value));start=end;for_match=pattern.search(text,start)
 return ''.join(out)+text[start:]
def plain(s):
 s=s.replace(r'\_','_').replace(r'\%','%').replace(r'\&','&').replace('~',' ')
 s=re.sub(r'\\(?:code|texttt|textbf|emph)\{([^{}]*)\}',r'\1',s)
 return re.sub(r'\\[A-Za-z]+\*?(?:\[[^\]]*\])?','',s).replace('{','').replace('}','').strip()
def raw(value):
 token=f'WEBRAWPLACEHOLDER{len(blocks):05}END';blocks.append(value);return '\n\n'+token+'\n\n'
def optimize(source,dest,width=1500):
 
 if args.reuse_images and dest.exists():return
 im=Image.open(source).convert('RGB');im.thumbnail((width,2000));im.save(dest,'WEBP',quality=90,method=6)

def figure(m):
 source=m.group();lm=re.search(r'\\label\{([^}]+)\}',source);cm=re.search(r'\\caption(?:\[[^]]*\])?\s*\{',source)
 assert lm and cm,source[:100]
 label=lm[1];caption=plain(group(source,cm.end()-1)[0]);row=labels[label];number=row['number'];page=pdf[row['page']-1];cap=page.search_for('图'+number)
 direct=re.search(r'\\(?:includegraphics|BookConceptGraphic|BookDetailGraphic)(?:\[([^\]]*)\])?\{([^}]+)\}',source)
 if direct and r'\begin{tikzpicture}' not in source:
  matches=list(re.finditer(r'\\(?:includegraphics|BookConceptGraphic|BookDetailGraphic)(?:\[([^\]]*)\])?\{([^}]+)\}',source))
  images=[];originals=[];fractions=[]
  for item in matches:
   original=B/item[2]
   if not original.suffix:original=original.with_suffix('.pdf')
   originals.append(str(original.relative_to(B)))
   if original.suffix.lower()=='.pdf':
    image_pdf=fitz.open(original);pix=image_pdf[0].get_pixmap(matrix=fitz.Matrix(2.5,2.5),alpha=False);im=Image.frombytes('RGB',[pix.width,pix.height],pix.samples)
   else:im=Image.open(original).convert('RGB')
   trim=re.search(r'trim=([0-9.]+)bp ([0-9.]+)bp ([0-9.]+)bp ([0-9.]+)bp',item[1] or '')
   if trim:
    left,bottom,right,top=map(float,trim.groups());im=im.crop((int(left),int(top),im.width-int(right),im.height-int(bottom)))
   images.append(im);fraction=re.search(r'width=([.0-9]+)\\linewidth',item[1] or '');fractions.append(float(fraction[1]) if fraction else 1)
  if len(images)>1:
   scaled=[]
   for im,fraction in zip(images,fractions):
    width=round(1700*fraction/max(fractions));scaled.append(im.resize((width,round(im.height*width/im.width)),Image.Resampling.LANCZOS))
   im=Image.new('RGB',(1700,sum(i.height for i in scaled)+20*(len(scaled)-1)),'white');y=0
   for image in scaled:im.paste(image,((1700-image.width)//2,y));y+=image.height+20
  else:im=images[0];im.thumbnail((1700,2200))
  filename='figure-'+number.replace('.','-')+'.webp'
  if len(images)>1 or not (args.reuse_images and (A/filename).exists()):im.save(A/filename,'WEBP',quality=93,method=6)
  lookup[label]=f'chapters/{current:02}.html#{label}'
  records.append({'label':label,'number':number,'caption':caption,'page':row['page'],'sources':originals,'image':filename})
  return raw(f'<figure id="{E(label)}"><button class="zoom-image" aria-label="放大图{E(number)}：{E(caption)}"><img src="../assets/{filename}" alt="图{E(number)} {E(caption)}" loading="lazy" width="{im.width}" height="{im.height}"></button><figcaption><b>图 {E(number)}</b> {E(caption)}</figcaption></figure>')

 # PDF text uses separate spans for the caption prefix; select its actual line.
 caplines=[]
 for block in page.get_text('dict')['blocks']:
  for line in block.get('lines',[]):
   text=''.join(s['text'] for s in line['spans'])
   if re.match(r'^图\s*'+re.escape(number)+r'(?![\d.])',text.strip()) and any('Bold' in s['font'] and abs(s['size']-9)<.2 for s in line['spans']):caplines.append(fitz.Rect(line['bbox']))
 assert caplines,(label,number,row['page'])
 c=caplines[-1]
 geom=[fitz.Rect(d['rect']) for d in page.get_drawings() if d['rect'].y0>52 and d['rect'].y1<c.y0+1 and (d['rect'].width>2 or d['rect'].height>2)]
 geom += [fitz.Rect(im['bbox']) for im in page.get_image_info() if im['bbox'][1]>52 and im['bbox'][3]<c.y0+2]
 assert geom,(label,'No artwork')
 # Narrative is 10.5 pt Song text, unlike the diagram labels. Use its latest
 # non-overlapping line as a boundary; previous captions are boundaries too.
 boundary=53.0
 for block in page.get_text('dict')['blocks']:
  for line in block.get('lines',[]):
   box=fitz.Rect(line['bbox']); spans=line['spans'];txt=''.join(s['text'] for s in spans)
   if box.y1>=c.y0-2:continue
   body=any(abs(s['size']-10.5)<.1 and 'FandolSong' in s['font'] and len(s['text'])>12 for s in spans)
   priorcap=bool(re.match(r'^[图表]\s*\d+\.\d+',txt.strip()))
   if (body or priorcap) and not any(box.intersects(g) for g in geom):boundary=max(boundary,box.y1)
 selected=[g for g in geom if g.y0>=boundary-1 and g.y1<=c.y0+1]
 assert selected,(label,boundary)
 clip=fitz.Rect()
 for box in selected:clip|=box
 # Include loose diagram labels and arrow annotations within the artwork band.
 top=clip.y0
 for block in page.get_text('dict')['blocks']:
  for line in block.get('lines',[]):
   box=fitz.Rect(line['bbox'])
   if box.y0>=max(boundary+1,top-17) and box.y1<c.y0-1:clip|=box
 clip+=(-9,-8,9,6);clip&=page.rect
 filename='figure-'+number.replace('.','-')+'.webp'
 if args.reuse_images and (A/filename).exists():
  im=Image.open(A/filename);width,height=im.size
 else:
  pix=page.get_pixmap(matrix=fitz.Matrix(3,3),clip=clip,alpha=False);width,height=pix.width,pix.height
  im=Image.frombytes('RGB',[width,height],pix.samples);im.save(A/filename,'WEBP',quality=93,method=6)
 lookup[label]=f'chapters/{current:02}.html#{label}'
 records.append({'label':label,'number':number,'caption':caption,'page':row['page'],'clip':list(clip),'image':filename})
 return raw(f'<figure id="{E(label)}"><button class="zoom-image" aria-label="放大图{E(number)}：{E(caption)}"><img src="../assets/{filename}" alt="图{E(number)} {E(caption)}" loading="lazy" width="{width}" height="{height}"></button><figcaption><b>图 {E(number)}</b> {E(caption)}</figcaption></figure>')

def expand(path,seen=()):
 assert path not in seen,('recursive input',path)
 data=path.read_text();dependencies[str(path.relative_to(B))]=hashlib.sha256(data.encode()).hexdigest()
 # Protect verbatim command bodies before resolving TeX comments or inputs.
 def code(m):
  content=m[1];p=0
  if content.startswith('['):p=content.index(']')+1
  while p<len(content) and content[p].isspace():p+=1
  title,p=group(content,p)
  code=content[p:].strip('\n');code=re.sub(r'^\\label\{[^}]+\}\s*','',code)
  return raw(f'<div class="code-block"><div class="code-bar"><span>{E(plain(title))}</span><button class="copy-code" aria-label="复制命令">复制</button></div><pre><code>{E(code)}</code></pre></div>')
 data=re.sub(r'\\begin\{cmdbox\}(.*?)\\end\{cmdbox\}',code,data,flags=re.S)
 for env in ['outbox','filebox','verbatim','lstlisting']:
  def literal_block(m):
   value=m[1];title='终端输出' if env=='outbox' else '文件内容';label=''
   if value.startswith('['):
    end=value.index(']');opt=value[1:end];lm=re.search(r'label=([^,]+)',opt);label=lm[1] if lm else '';value=value[end+1:]
   if label:lookup[label]=f'chapters/{current:02}.html#{label}'
   if env=='filebox':
    title,end=group(value,0);value=value[end:]
   return raw(f'<div class="code-block" id="{E(label)}"><div class="code-bar"><span>{E(title)}</span><button class="copy-code">复制</button></div><pre><code>{E(value.strip(chr(10)))}</code></pre></div>')
  data=re.sub(r'\\begin\{'+env+r'\}(.*?)\\end\{'+env+r'\}',literal_block,data,flags=re.S)
 data=re.sub(r'(?<!\\)%[^\n]*','',data)
 data=re.sub(r'\\input\s*\{([^}]+)\}',lambda m:expand(B/(m[1]+('' if m[1].endswith('.tex') else '.tex')),(*seen,path)),data)
 return data

def prepare(data):
 data=re.split(r'\\BookExercises',data)[0]
 data=re.sub(r'\\begin\{figure\}.*?\\end\{figure\}',figure,data,flags=re.S)
 def listing(m):
  options=m[1];p=(B/m[2]).resolve();lines=p.read_text().splitlines();first=re.search(r'firstline=(\d+)',options);last=re.search(r'lastline=(\d+)',options);caption=re.search(r'caption=\{([^}]+)\}',options);lab=re.search(r'label=\{([^}]+)\}',options)
  label=lab[1] if lab else '';lookup[label]=f'chapters/{current:02}.html#{label}'
  return raw(f'<div class="code-block" id="{E(label)}"><div class="code-bar"><span>{E(caption[1] if caption else p.name)}</span><button class="copy-code">复制</button></div><pre><code>{E(chr(10).join(lines[int(first[1])-1 if first else 0:int(last[1]) if last else len(lines)]))}</code></pre></div>')
 # Expand the one authored macro wrapping the clock listing.
 data=re.sub(r'\\newcommand\{\\BookCampusClockListing\}\{(\\lstinputlisting[^\n]+)\}',lambda m:'',data)
 data=data.replace(r'\BookCampusClockListing',r'\lstinputlisting[firstline=6,lastline=13,caption={注入业务日期并检验充值重试},label={lst:campus-clock}]{../2-GitHub项目/GitEasy/projects/campus-card/tests/test_service_clock.cpp}')
 data=re.sub(r'\\lstinputlisting\[([^\]]+)\]\{([^}]+)\}',listing,data)
 def table(m):
  source=m.group();cap=re.search(r'\\caption(?:\[[^]]*\])?\s*\{',source);lab=re.search(r'\\label\{([^}]+)\}',source)
  caption=plain(group(source,cap.end()-1)[0]) if cap else ''
  label=lab[1] if lab else '';number=labels.get(label,{}).get('number','')
  if label:lookup[label]=f'chapters/{current:02}.html#{label}'
  start=re.search(r'\\begin\{tabularx?\}',source)
  assert start,source[:100]
  _,pos=group(source,start.end())
  if start.group().endswith('tabularx}'):
   while source[pos].isspace():pos+=1
   _,pos=group(source,pos)
  body=re.split(r'\\end\{tabularx?\}',source[pos:])[0]
  body=re.sub(r'\\(?:toprule|midrule|bottomrule|hline)\b','',body)
  body=re.sub(r'\\rowcolor\{[^}]*\}','',body)
  rows=[]
  for line in re.split(r'\\\\(?:\[[^\]]*\])?',body):
   if not line.strip():continue
   cells=[]
   for cell in re.split(r'(?<!\\)&',line):
    span=1;cell=cell.strip()
    if cell.startswith(r'\multicolumn'):
     count,j=group(cell,len(r'\multicolumn'));_,j=group(cell,j);cell,j=group(cell,j);span=int(count)
    cell=macro(cell,'ref',lambda x:raw(f'<a class="book-ref" data-label="{E(x)}">{E(labels.get(x,{}).get("number",x))}</a>').strip())
    cells.append((span,inline(cell)))
   rows.append(cells)
  out=f'<div class="table-scroll" tabindex="0" id="{E(label)}"><table><caption><b>表 {E(number)}</b> {E(caption)}</caption>'
  for i,cells in enumerate(rows):
   tag='th' if i==0 else 'td';out+='<tr>'+''.join(f'<{tag} colspan="{span}">{cell}</{tag}>' for span,cell in cells)+'</tr>'
  return raw(out+'</table></div>')
 data=re.sub(r'\\begin\{table\}.*?\\end\{table\}',table,data,flags=re.S)
 data=macro(data,'code',lambda x:r'\texttt{'+x+'}')
 data=macro(data,'index',lambda x:'')
 data=macro(data,'label',lambda x:raw(f'<span id="{E(x)}"></span>') if not lookup.setdefault(x,f'chapters/{current:02}.html#{x}') is None else '')
 data=macro(data,'ref',lambda x:raw(f'<a class="book-ref" data-label="{E(x)}">{E(labels.get(x,{}).get("number",x))}</a>').strip())
 for env in ['chapterintro','roadmap','remarkbox','proofbox','personbox']:
  data=data.replace('\\begin{'+env+'}', '\n').replace('\\end{'+env+'}', '\n')
 data=re.sub(r'\\(?:clearpage|cleardoublepage|newpage|noindent|indent|smallskip|medskip|bigskip|centering|small|scriptsize|footnotesize|begingroup|endgroup)\b','',data)
 data=re.sub(r'\\(?:setlength|renewcommand)\{[^}]*\}\{[^}]*\}','',data)
 data=re.sub(r'\\rowcolor\{[^}]*\}','',data)
 return data

def convert(data):
 result=subprocess.run(['pandoc','-f','latex','-t','html5','--math-method=mathml','--wrap=none',*(['--citeproc','--bibliography='+str(B/'refs/refs.bib')] if r'\cite' in data else [])],input=data,text=True,capture_output=True,check=True)
 if result.stderr:print(result.stderr[:300],file=sys.stderr)
 out=result.stdout
 for i,value in enumerate(blocks):out=out.replace('<p>WEBRAWPLACEHOLDER'+f'{i:05}'+'END</p>',value).replace('WEBRAWPLACEHOLDER'+f'{i:05}'+'END',value)
 return out

def inline(text):
 return convert(macro(text,'code',lambda x:r'\texttt{'+x+'}')).strip().removeprefix('<p>').removesuffix('</p>')

# Shared hero and project assets; full-quality original sources remain elsewhere.
for source,name,width in [('assets/book-cover.png','book-cover.webp',700),('assets/campus-qt.png','campus-qt.webp',1500),('assets/campus-architecture.png','campus-architecture.webp',1500),('assets/illustrations/ch03-gpt.png','three-states.webp',1400)]:optimize(R/source,A/name,width)
for n in range(1,18):optimize(R/f'assets/mindmaps/ch{n:02}.png',A/f'mindmap-{n:02}.webp',1500)

articles=[]
for row,exercise in zip(manifest,questions):
 current=row['chapter'];data=prepare(expand(B/row['source']));out=convert(data)
 soup=BeautifulSoup(out,'html.parser');heading=soup.find('h1')
 if heading:heading.decompose()
 for level in ['h2','h3','h4']:
  for i,h in enumerate(soup.find_all(level)):h['id']=f'{level}-{i+1}'
 for table in soup.find_all('table'):
  wrapper=soup.new_tag('div',attrs={'class':'table-scroll','tabindex':'0'});table.wrap(wrapper)
 for a in soup.select('span[id]'):lookup.setdefault(a['id'],f'chapters/{current:02}.html#{a["id"]}')
 out=str(soup)
 out+='<section class="exercises" id="exercises"><div class="section-kicker">LEARN · PRACTISE · REFLECT</div><h2>本章习题与解析</h2><p>先独立作答，再展开解析核对思路。答案与教材同源，知识点随题列出。</p>'
 for q in exercise['questions']:
  out+=f'<details class="exercise" id="ex:{q["number"]}"><summary><span class="difficulty">{E(q["difficulty"])}</span><b>{E(q["number"])}</b><span>{inline(q["question"])}</span><span class="disclosure" aria-hidden="true">＋</span></summary><div class="answer"><p class="knowledge">考查知识点 · {E(" / ".join(q["knowledge_points"]))}</p>'+''.join('<p>'+E(a)+'</p>' for a in q['answer_paragraphs'])+'</div></details>'
  lookup['ex:'+q['number']]=f'chapters/{current:02}.html#ex:{q["number"]}'
 out+=f'</section><section id="mindmap"><h2>本章知识结构</h2><p>按六个模块回顾本章，在概念、操作与验证之间建立联系。</p><figure><button class="zoom-image" aria-label="放大第{current}章复习导图"><img src="../assets/mindmap-{current:02}.webp" alt="第{current}章完整复习导图" loading="lazy" class="mindmap"></button></figure></section>'
 articles.append((row,out))
 print(f'Exported chapter {current:02}: {len(out):,} HTML chars',flush=True)

# Resolve cross-chapter anchors only after discovering every chapter's labels.
for row,out in articles:
 for key,href in lookup.items():
  out=out.replace(f'data-label="{E(key)}"',f'href="../{E(href)}"')
 # Appendix references point to the actual corresponding web appendix.
 out=re.sub(r'<a class="book-ref" data-label="([^"]+)">([^<]+)</a>',r'<span class="book-ref" title="教材交叉引用">\2</span>',out)
 row['html']=out

layout=(T/'layout.html').read_text()
def navigation(prefix,active):
 out=f'<a class="nav-home {"active" if active=="home" else ""}" href="{prefix}index.html">学习总览<span>↗</span></a>'
 for i,name in enumerate(parts):
  out+=f'<div class="nav-group"><span>0{i+1}</span>{name}</div>'
  for r in manifest:
   n=r['chapter']
   if part(n)!=i:continue
   out+=f'<a class="chapter-link {"active" if active==n else ""}" data-chapter="{n}" href="{prefix}chapters/{n:02}.html"><span class="nav-num">{n:02}</span><span>{E(r["title"])}</span><i class="completion-dot" aria-hidden="true"></i></a>'
 out+=f'<div class="nav-group">学习工具</div><a href="{prefix}reference/commands.html">⌘ &nbsp; Git命令速查</a><a href="{prefix}reference/preface.html">序 &nbsp; 前言与阅读说明</a><a href="{prefix}reference/resources.html">↗ &nbsp; 实训与参考资料</a>'
 out+=''.join(f'<a href="{prefix}reference/appendix-{letter}.html">{letter.upper()} &nbsp; {title}</a>' for letter,title in [('b','配置与检查模板'),('c','常见故障排查'),('d','术语中英对照'),('e','综合诊断与评价')])
 return out

def write(path,title,content,active='home',toc='',description='从零理解Git的版本控制思想，学习分支协作、对象原理与工程实践。'):
 prefix='../' if '/' in path else './'
 values={'TITLE':E(title),'DESCRIPTION':E(description),'PREFIX':prefix,'NAV':navigation(prefix,active),'CONTENT':content,'TOC':toc,'PAGE':str(active)}
 result=layout
 for key,value in values.items():result=result.replace('{{'+key+'}}',value)
 result=result.replace(' id=""','')
 target=W/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_text(result)
 soup=BeautifulSoup(content,'html.parser')
 for h in soup.find_all(['h2','h3']):
  texts=[]
  for sib in h.next_siblings:
   if getattr(sib,'name',None) in ['h2','h3']:break
   texts.append(sib.get_text(' ',strip=True) if hasattr(sib,'get_text') else str(sib))
  search.append({'title':h.get_text(' ',strip=True),'chapter':title,'url':path+'#'+h.get('id',''),'text':' '.join(texts)})

for row,_ in articles:
 n=row['chapter'];out=row['html'];soup=BeautifulSoup(out,'html.parser');heads=soup.find_all('h2');chars=len(soup.get_text())
 for i,h in enumerate(heads):
  if not h.get('id'):h['id']=f'review-{i+1}'
 out=str(soup)
 toc='<div class="toc-label">本章目录</div>'+''.join(f'<a href="#{h["id"]}">{E(h.get_text())}</a>' for h in heads)
 head=f'<div class="breadcrumb"><a href="../index.html">学习总览</a><span>/</span>{parts[part(n)]}<span>/</span>第{n:02}章</div><header class="chapter-header"><div class="section-kicker">CHAPTER {n:02} · {parts[part(n)]}</div><h1>{E(row["title"])}</h1><div class="chapter-meta"><span>张庆科 编著</span><span>约 {max(1,round(chars/400))} 分钟</span><span>{len(questions[n-1]["questions"])} 道分层习题</span></div></header>'
 footer=f'<div class="lesson-actions"><button id="complete-chapter" data-number="{n}">标记本章已学</button><span>学习记录仅保存在本浏览器</span></div><nav class="lesson-pager" aria-label="相邻章节">'
 if n>1:footer+=f'<a href="{n-1:02}.html"><small>← 上一章</small>{E(manifest[n-2]["title"])}</a>'
 if n<17:footer+=f'<a href="{n+1:02}.html"><small>下一章 →</small>{E(manifest[n]["title"])}</a>'
 footer+='</nav>'
 write(f'chapters/{n:02}.html',row['title'],head+'<article class="prose">'+out+'</article>'+footer,n,toc)

# Homepage template includes a working three-state teaching simulator.
home=(T/'home.html').read_text()
chapters=''
for i,name in enumerate(parts):
 chapters+=f'<section class="curriculum-part" id="part-{i+1}"><header><span>0{i+1}</span><div><h3>{name}</h3><p>{["建立版本控制思维，完成第一次提交。","沿着分支、合并与远程交换，理解协作。","进入对象、引用与历史，解释命令的机制。","把知识带入团队，完成真实的工程交付。"][i]}</p></div></header><div class="curriculum-rows">'
 for r in manifest:
  n=r['chapter']
  if part(n)==i:chapters+=f'<a href="chapters/{n:02}.html"><span>{n:02}</span><h4>{E(r["title"])}</h4><span>{len(questions[n-1]["questions"])}题</span><b>↗</b></a>'
 chapters+='</div></section>'
home=home.replace('{{CHAPTERS}}',chapters)
write('index.html','GitEasy · Git版本控制原理与实践',home,toc='<div class="toc-label">探索教材</div><a href="#learning-path">全书学习路径</a><a href="#state-lab">三份状态实验室</a><a href="#campus">校园一卡通实训</a><a href="#start">开始学习</a>')

content='<header class="chapter-header"><div class="section-kicker">REFERENCE / 01</div><h1>Git命令速查</h1><p>按任务找到命令，结合场景确认前提与影响范围。占位符需要替换，表格中的不同形式不能整行当作脚本执行。</p></header><div class="command-tools"><label for="command-filter">筛选命令、场景或选项</label><input id="command-filter" type="search" placeholder="试试 diff、恢复、worktree…"><span id="command-count"></span></div><article class="prose">'
for i,(name,rows) in enumerate(__import__('itertools').groupby(commands,key=lambda c:c['group'])):
 content+=f'<section class="command-group" id="group-{i+1}"><h2>{E(name)}</h2><div class="table-scroll"><table class="command-table"><thead><tr><th>命令</th><th>用法</th><th>场景与边界</th></tr></thead><tbody>'
 for c in rows:content+=f'<tr><td><code>git {E(c["name"])}</code></td><td><code>{E(c["usage"])}</code></td><td>{E(c["example"])}<small>{E(c["boundary"])}</small></td></tr>'
 content+='</tbody></table></div></section>'
content+='</article>';write('reference/commands.html','Git命令速查',content,'commands')
# Front matter and resources remain readable without LaTeX or a network dependency.
preface=convert(prepare(expand(B/'chapters/preface.tex')))
write('reference/preface.html','前言与阅读说明','<article class="prose">'+preface+'</article>','preface')
for letter,title in [('b','配置、别名与检查模板'),('c','常见故障排查'),('d','术语中英对照'),('e','综合诊断与学习评价')]:
 current=0
 source=expand(B/f'chapters/appendix_{letter}.tex')
 if letter=='d':
  start=re.search(r'\\begin\{longtable\}',source);_,pos=group(source,start.end());end=source.index(r'\end{longtable}',pos)
  body=source[pos:end];body=re.sub(r'\\endfirsthead.*?\\endhead','',body,flags=re.S);body=re.sub(r'\\caption\{([^}]+)\}\\label\{([^}]+)\}\\\\',r'\\caption{\1}\\label{\2}',body)
  source=source[:start.start()]+r'\begin{table}\begin{tabular}{lll}'+body+r'\end{tabular}\end{table}'+source[end+len(r'\end{longtable}'):]
 out=convert(prepare(source));soup=BeautifulSoup(out,'html.parser');h1=soup.find('h1')
 if h1:h1.decompose()
 for i,h in enumerate(soup.find_all(['h2','h3'])):h['id']=f'appendix-section-{i+1}'
 # Appendix-local references have their own route; other links use source labels.
 for anchor in soup.select('[id]'):
  if anchor['id']:lookup[anchor['id']]=f'reference/appendix-{letter}.html#{anchor["id"]}'
 for a in soup.select('[data-label]'):
  key=a['data-label'];target=lookup.get(key)
  if target:a['href']='../'+target
  else:a.unwrap()
  a.attrs.pop('data-label',None)
 toc='<div class="toc-label">附录目录</div>'+''.join(f'<a href="#{h["id"]}">{E(h.get_text())}</a>' for h in soup.find_all('h2'))
 write(f'reference/appendix-{letter}.html',title,f'<header class="chapter-header"><div class="section-kicker">APPENDIX {letter.upper()}</div><h1>{title}</h1></header><article class="prose">'+str(soup)+'</article>',f'appendix-{letter}',toc)
resources=(T/'resources.html').read_text();write('reference/resources.html','实训与参考资料',resources,'resources')
(W/'search-data.js').write_text('window.GITEASY_SEARCH='+json.dumps(search,ensure_ascii=False).replace('</','<\\/')+';\n')
(W/'.nojekyll').touch()
report={'book_pdf_sha256':hashlib.sha256((B/'build/pdf/Git全解-ocean.pdf').read_bytes()).hexdigest(),'chapters':17,'questions':sum(len(x['questions']) for x in questions),'figures':len(records),'command_entries':len(commands),'search_sections':len(search),'source_files':dependencies,'figure_crops':records,'scope':'Complete chapter prose and authored command blocks; diagram images exported from verified manuscript PDF; exercise answers and command reference from source data. Figures retain book numbering. Web layout is independent of print pagination.'}
(W/'build-manifest.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
import xml.etree.ElementTree as ET
namespace='http://www.sitemaps.org/schemas/sitemap/0.9';ET.register_namespace('',namespace);sitemap=ET.Element('{'+namespace+'}urlset')
for page in sorted(W.rglob('*.html')):
 url=ET.SubElement(sitemap,'{'+namespace+'}url');ET.SubElement(url,'{'+namespace+'}loc').text='https://tsingke.github.io/GitEasy/'+page.relative_to(W).as_posix()
ET.ElementTree(sitemap).write(W/'sitemap.xml',encoding='utf-8',xml_declaration=True)
(W/'robots.txt').write_text('User-agent: *\nAllow: /GitEasy/\nSitemap: https://tsingke.github.io/GitEasy/sitemap.xml\n')
print(f'Website ready: 17 chapters, {len(records)} diagrams, {len(search)} searchable sections')
