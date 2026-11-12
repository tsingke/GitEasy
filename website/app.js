/* No network service, analytics, or account is required for learning. */
(() => {
  'use strict';
  const $ = (s, root = document) => root.querySelector(s);
  const $$ = (s, root = document) => [...root.querySelectorAll(s)];
  const prefix = document.body.dataset.prefix;
  const store = {get(k, fallback) {try {return JSON.parse(localStorage.getItem(k)) ?? fallback;} catch {return fallback;}}, set(k, v) {try {localStorage.setItem(k, JSON.stringify(v));} catch {}}};
  const escape = s => String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  let toastTimer;
  function toast(text) {$('#toast').textContent = text; $('#toast').classList.add('visible'); clearTimeout(toastTimer); toastTimer=setTimeout(() => $('#toast').classList.remove('visible'), 2300);}
  const themeButton = $('#theme-toggle');
  function setTheme(value) {document.documentElement.dataset.theme=value;themeButton.setAttribute('aria-label',value==='dark'?'切换浅色模式':'切换深色模式');themeButton.setAttribute('aria-pressed',String(value==='dark'));}
  setTheme(store.get('giteasy-theme',matchMedia('(prefers-color-scheme:dark)').matches?'dark':'light'));
  themeButton.addEventListener('click',()=>{const value=document.documentElement.dataset.theme==='dark'?'light':'dark';setTheme(value);store.set('giteasy-theme',value);});
  const menu=$('#menu-toggle'),sidebar=$('.sidebar'),backdrop=$('.sidebar-backdrop');
  function closeMenu(){sidebar.classList.remove('open');backdrop.hidden=true;menu.setAttribute('aria-expanded','false');menu.setAttribute('aria-label','打开章节导航');}
  menu.addEventListener('click',()=>{const open=sidebar.classList.toggle('open');backdrop.hidden=!open;menu.setAttribute('aria-expanded',String(open));menu.setAttribute('aria-label',open?'关闭章节导航':'打开章节导航');});
  backdrop.addEventListener('click',closeMenu);
  addEventListener('keydown',e=>{if(e.key==='Escape')closeMenu();});
  const storedCompleted=store.get('giteasy-completed',[]);
  const completed=(Array.isArray(storedCompleted)?storedCompleted:[]).filter(n=>Number.isInteger(n)&&n>=1&&n<=17);
  function updateProgress() {$('#progress-count').textContent=`${completed.length} / 17`;$('#chapter-progress').value=completed.length;$$('.chapter-link').forEach(a=>{a.classList.toggle('completed',completed.includes(Number(a.dataset.chapter)));if(a.classList.contains('active'))a.setAttribute('aria-current','page');});const button=$('#complete-chapter');if(button){const done=completed.includes(Number(button.dataset.number));button.textContent=done?'✓ 本章已学 · 点击撤销':'标记本章已学';button.setAttribute('aria-pressed',String(done));}}
  updateProgress();
  $('#complete-chapter')?.addEventListener('click',e=>{const n=Number(e.currentTarget.dataset.number),i=completed.indexOf(n);if(i<0)completed.push(n);else completed.splice(i,1);store.set('giteasy-completed',completed);updateProgress();toast(i<0?'已记录，继续下一章吧。':'已撤销本章完成标记。');});
  if(/^\d+$/.test(document.body.dataset.page))store.set('giteasy-last-chapter',Number(document.body.dataset.page));
  const last=store.get('giteasy-last-chapter',1);if($('#resume-learning'))$('#resume-learning').href=`chapters/${String(last).padStart(2,'0')}.html`;
  let pending=false;
  function scrollProgress(){const height=document.documentElement.scrollHeight-innerHeight;$('.reading-progress').style.width=(height>0?Math.min(100,scrollY/height*100):0)+'%';pending=false;}
  addEventListener('scroll',()=>{if(!pending){pending=true;requestAnimationFrame(scrollProgress);}},{passive:true});scrollProgress();
  if('IntersectionObserver' in window){const observer=new IntersectionObserver(entries=>{for(const entry of entries){if(!entry.isIntersecting)continue;$$('.page-toc a').forEach(a=>a.classList.toggle('current',decodeURIComponent(a.hash.slice(1))===entry.target.id));}},{rootMargin:'-90px 0px -65% 0px'});$$('main h2[id],main section[id]').forEach(h=>observer.observe(h));}
  async function copyText(text){if(navigator.clipboard&&isSecureContext){await navigator.clipboard.writeText(text);return;}const area=document.createElement('textarea');area.value=text;area.style.position='fixed';area.style.opacity='0';document.body.append(area);area.select();const ok=document.execCommand('copy');area.remove();if(!ok)throw new Error('copy unavailable');}
  $$('.copy-code').forEach(button=>button.addEventListener('click',async()=>{const text=$('pre',button.closest('.code-block')).textContent;try{await copyText(text);button.textContent='已复制';setTimeout(()=>button.textContent='复制',1800);toast('命令已复制；执行前请确认实验目录与前置状态。');}catch{toast('未能自动复制，请选中代码手动复制。');}}));
  const imageDialog=$('#image-dialog');
  $$('.zoom-image').forEach(button=>button.addEventListener('click',()=>{const original=$('img',button);$('img',imageDialog).src=original.src;$('img',imageDialog).alt=original.alt;$('p',imageDialog).textContent=original.alt;imageDialog.showModal();}));
  $$('dialog .close-dialog').forEach(button=>button.addEventListener('click',()=>button.closest('dialog').close()));
  $$('dialog').forEach(d=>d.addEventListener('click',e=>{if(e.target===d){const rect=d.getBoundingClientRect();if(e.clientX<rect.left||e.clientX>rect.right||e.clientY<rect.top||e.clientY>rect.bottom)d.close();}}));
  const searchDialog=$('#search-dialog'),input=$('#global-search'),results=$('#search-results');
  function openSearch(){if(!searchDialog.open)searchDialog.showModal();input.focus();}
  $('.search-trigger').addEventListener('click',openSearch);
  addEventListener('keydown',e=>{if((e.metaKey||e.ctrlKey)&&e.key.toLowerCase()==='k'){e.preventDefault();openSearch();}});
  const searchRows=(window.GITEASY_SEARCH||[]).map(row=>({...row,normalized:(row.title+' '+row.chapter+' '+row.text).toLowerCase()}));
  function highlighted(text,tokens){const safe=escape(text);const escaped=tokens.map(t=>escape(t).replace(/[.*+?^${}()|[\]\\]/g,'\\$&')).filter(Boolean);if(!escaped.length)return safe;return safe.replace(new RegExp(escaped.join('|'),'gi'),m=>`<mark>${m}</mark>`);}
  input.addEventListener('input',()=>{const q=input.value.trim().toLowerCase();if(!q){results.innerHTML='<p>输入关键词，查找概念、实验与命令。</p>';return;}const tokens=q.split(/\s+/).filter(Boolean);const matches=searchRows.filter(r=>tokens.every(t=>r.normalized.includes(t))).map(r=>({...r,score:tokens.reduce((score,t)=>score+(r.title.toLowerCase().includes(t)?10:0)+(r.chapter.toLowerCase().includes(t)?3:0),0)})).sort((a,b)=>b.score-a.score);if(!matches.length){results.innerHTML='<p>没有找到相关内容。试试更短的术语，如“索引”或“reset”。</p>';return;}results.innerHTML=`<p>找到 ${matches.length} 个相关小节，显示前 ${Math.min(30,matches.length)} 项</p>`+matches.slice(0,30).map(row=>{const i=Math.max(0,row.text.toLowerCase().indexOf(tokens[0])-35);return `<a class="search-result" href="${prefix}${escape(row.url)}"><small>${escape(row.chapter)}</small><strong>${highlighted(row.title,tokens)}</strong><p>${highlighted(row.text.slice(i,i+155),tokens)}…</p></a>`;}).join('');});
  const filter=$('#command-filter');if(filter){const rows=$$('.command-table tbody tr');function update(){const query=filter.value.trim().toLowerCase();let count=0;rows.forEach(row=>{row.hidden=!row.textContent.toLowerCase().includes(query);if(!row.hidden)count++;});$$('.command-group').forEach(group=>group.hidden=!$$('tbody tr',group).some(row=>!row.hidden));$('#command-count').textContent=`${count} / ${rows.length} 项用法`;}filter.addEventListener('input',update);update();}
  let work=['line 1'],index=['line 1'],head=['line 1'];
  function renderState(text){$('#state-worktree').textContent=work.join('\n');$('#state-index').textContent=index.join('\n');$('#state-head').textContent=head.join('\n');$('#state-explanation').textContent=text;}
  $$('[data-state-action]').forEach(button=>button.addEventListener('click',()=>{switch(button.dataset.stateAction){case 'edit':if(work.length>=8){renderState('已追加到8行。可以暂存、提交，或重新开始实验。');break;}work.push('line '+(work.length+1));renderState('编辑只改变工作文件。索引与HEAD仍保留原来的内容，Git不会自动把后续编辑加入候选。');break;case 'add':index=[...work];renderState('git add记录当前工作文件的内容，更新索引候选；已经提交的HEAD快照保持不变。现在可以继续编辑再提交。');break;case 'commit':if(head.join('\n')===index.join('\n')){renderState('索引与当前提交相同，没有新的候选变化可提交。工作文件即使改变，也需先选择暂存。');break;}head=[...index];renderState('提交根据索引创建新快照，更新当前分支。工作文件保留原样；暂存后新增的行依然没有进入本次提交。本模型只展示一个文件的内容。');break;case 'reset':work=['line 1'];index=['line 1'];head=['line 1'];renderState('先追加一行，再暂存；暂存后继续编辑，最后提交。看看哪一行进入了历史。');}}));
})();
