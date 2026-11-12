#!/usr/bin/env python3
"""Browser smoke/regression checks. Run with a local server and Playwright installed.
Usage: python tools/test_site_browser.py --url http://127.0.0.1:8873 --output /tmp/giteasy-qa
"""
import argparse,json
from pathlib import Path
from playwright.sync_api import sync_playwright
parser=argparse.ArgumentParser();parser.add_argument('--url',default='http://127.0.0.1:8873');parser.add_argument('--output',type=Path,default=Path('/tmp/giteasy-site-qa'));a=parser.parse_args();a.output.mkdir(parents=True,exist_ok=True)
checks=[];errors=[]
def passed(name):checks.append(name)
with sync_playwright() as p:
 browser=p.chromium.launch(headless=True)
 context=browser.new_context(viewport={'width':1512,'height':1050},device_scale_factor=1,color_scheme='light',permissions=['clipboard-read','clipboard-write'])
 page=context.new_page();page.on('pageerror',lambda e:errors.append(str(e)))
 page.goto(a.url);page.wait_for_load_state('networkidle');assert page.title().startswith('GitEasy')
 page.screenshot(path=str(a.output/'desktop-home.png'),full_page=True)
 page.screenshot(path=str(a.output/'desktop-first-screen.png'))
 assert page.locator('main .curriculum-rows a').count()==17
 passed('Homepage and all 17 chapter entries')
 page.locator('[data-state-action=edit]').click();page.locator('[data-state-action=add]').click();page.locator('[data-state-action=edit]').click();page.locator('[data-state-action=commit]').click()
 assert page.locator('#state-head').inner_text()=='line 1\nline 2'
 assert page.locator('#state-worktree').inner_text()=='line 1\nline 2\nline 3'
 passed('Simulator: post-staging edits remain outside the commit')
 page.locator('[data-state-action=reset]').click();page.locator('[data-state-action=commit]').click();assert '没有新的候选变化' in page.locator('#state-explanation').inner_text()
 passed('Simulator: identical candidate does not create a simulated commit')
 page.keyboard.press('Control+k');page.locator('#global-search').fill('索引');page.wait_for_selector('.search-result');assert page.locator('.search-result').count()>0
 page.locator('.search-result').first.click();page.wait_for_load_state('networkidle');assert page.url.split('#')[-1]
 passed('Keyboard search and section navigation')
 page.locator('.search-trigger').click();page.locator('#global-search').fill('[');assert page.locator('#search-dialog').is_visible();page.keyboard.press('Escape')
 passed('Search handles punctuation and Escape')
 page.goto(a.url+'/chapters/03.html');page.wait_for_load_state('networkidle')
 assert page.locator('table').count()==4, 'Chapter 3 comparison tables must be semantic HTML'
 assert 'diff --git a/notes.txt' in page.locator('article').inner_text()
 assert page.locator('pre code').filter(has_text='diff --git').inner_text().splitlines()[1]=='--- a/notes.txt'
 passed('Native chapter tables and literal diff output')
 code=page.locator('.code-block').first;expected=code.locator('pre').inner_text();code.locator('.copy-code').click();assert page.evaluate('navigator.clipboard.readText()')==expected
 passed('Code clipboard preserves source characters and line breaks')
 exercise=page.locator('details.exercise').first;exercise.locator('summary').click();assert exercise.locator('.answer').is_visible()
 passed('Exercise answer disclosure')
 page.locator('.zoom-image').first.click();assert page.locator('#image-dialog').is_visible();assert page.locator('#image-dialog img').get_attribute('src');page.keyboard.press('Escape')
 passed('High-resolution figure dialog')
 page.locator('#complete-chapter').click();page.reload();assert page.locator('#progress-count').inner_text()=='1 / 17';assert '本章已学' in page.locator('#complete-chapter').inner_text()
 passed('Reading completion persists after reload')
 page.locator('#theme-toggle').click();page.reload();assert page.locator('html').get_attribute('data-theme')=='dark'
 page.screenshot(path=str(a.output/'desktop-dark-chapter.png'));page.locator('#theme-toggle').click()
 passed('Theme preference persists')
 page.goto(a.url+'/reference/commands.html');page.wait_for_load_state('networkidle');page.locator('#command-filter').fill('worktree');visible=page.locator('.command-table tbody tr:visible');assert visible.count()>0;assert visible.count()<124
 passed('Command reference filters by real command content')
 for n in range(1,18):
  page.goto(a.url+f'/chapters/{n:02}.html');page.wait_for_load_state('networkidle')
  assert page.locator('h1').count()==1
  assert page.locator('details.exercise').count()>=10
  assert page.locator('figure[id]').count()>0
  assert page.evaluate('document.documentElement.scrollWidth <= innerWidth'),f'desktop overflow chapter {n}'
 passed('All 17 chapters render without desktop horizontal overflow')
 page.goto(a.url+'/chapters/03.html');page.wait_for_load_state('networkidle');page.screenshot(path=str(a.output/'desktop-chapter.png'))
 page.set_viewport_size({'width':390,'height':844});page.goto(a.url);page.wait_for_load_state('networkidle');page.screenshot(path=str(a.output/'mobile-home.png'),full_page=True)
 assert page.evaluate('document.documentElement.scrollWidth <= innerWidth')
 page.locator('#menu-toggle').click();assert page.locator('.sidebar').is_visible();assert page.locator('#menu-toggle').get_attribute('aria-expanded')=='true'
 page.locator('.sidebar a[data-chapter="3"]').click();page.wait_for_load_state('networkidle');assert '/03.html' in page.url;assert page.locator('#menu-toggle').get_attribute('aria-expanded')=='false'
 assert page.evaluate('document.documentElement.scrollWidth <= innerWidth')
 page.screenshot(path=str(a.output/'mobile-chapter.png'),full_page=True)
 passed('Mobile menu, navigation and chapter layout')
 page.goto(a.url+'/reference/commands.html');page.wait_for_load_state('networkidle');assert page.evaluate('document.documentElement.scrollWidth <= innerWidth')
 passed('Mobile command table scrolls within its container')
 # No server required: data is loaded by local scripts, not fetch requests.
 local=Path(__file__).resolve().parents[1]/'website/index.html';page.goto(local.as_uri());page.wait_for_load_state('load');page.locator('.search-trigger').click();page.locator('#global-search').fill('合并');page.wait_for_selector('.search-result')
 passed('Direct file:// opening supports full-text search')
 assert not errors,errors
 browser.close()
report={'passed':True,'checks':checks,'javascript_errors':errors,'viewports':[{'width':1512,'height':1050},{'width':390,'height':844}],'scope':'Chromium interactions, desktop/mobile layout, source-preserving copy, search, navigation, local persistence and direct-file loading. Other browser engines not executed.'}
(a.output/'browser-report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n');print(json.dumps(report,ensure_ascii=False))
