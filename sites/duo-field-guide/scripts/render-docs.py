"""Render the self-contained content snapshots into the buildless site's dist/."""
from pathlib import Path
import re
import html
import markdown

ROOT = Path(__file__).resolve().parents[1]
ORIGIN = 'https://duo-field-guide-tudor.scopeworker-2245.chatgpt.site'


def rewrite_link(match, reference=False):
    target = match[1]
    if '://' in target or target.startswith('#'):
        return match[0]
    path, separator, anchor = target.partition('#')
    if path.endswith('README.md'):
        path = 'https://github.com/tudorturcanu/iphone-duo-skill#-quick-install' if anchor else 'https://github.com/tudorturcanu/iphone-duo-skill'
        return '](' + path + ')'
    if path.endswith('SKILL.md'):
        path = ('../' if reference else '') + 'references/skill.html'
    elif '/references/' in path:
        path = ('../' if reference else '') + 'references/' + Path(path).stem + '.html'
    elif path.endswith('.md'):
        path = Path(path).stem + '.html'
    return '](' + path + (separator + anchor if separator else '') + ')'


def render(source, destination, title, reference=False):
    text = source.read_text()
    text = re.sub(r'^---\n.*?\n---\n', '', text, flags=re.S)
    text = re.sub(r'\]\(([^)]+)\)', lambda m: rewrite_link(m, reference), text)
    body = markdown.markdown(text, extensions=['fenced_code', 'tables', 'toc', 'sane_lists'])
    body = re.sub(r'<table>(.*?)</table>', r'<div class="table-scroll"><table>\1</table></div>', body, flags=re.S)
    prefix = '../' if reference else ''
    document = f'''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>{html.escape(title)} — Duo Field Guide</title><link rel="stylesheet" href="{prefix}palette.css?v=9"><link rel="stylesheet" href="{prefix}styles.css?v=9"><link rel="stylesheet" href="{prefix}refinement.css?v=9"><link rel="stylesheet" href="{prefix}guide-nav.css?v=9"><script src="{prefix}navigation.js" defer></script></head>
<body><a class="skip-link" href="#article">Skip to article</a><header class="site-header"><div class="header-inner"><a class="brand" href="{prefix}index.html"><span class="brand-mark" aria-hidden="true"><i></i><i></i></span><strong>duo</strong><span class="brand-divider"></span><span>Developer guide</span></a><a class="header-link" href="{prefix}index.html#explore">Back to the explorer ↗</a></div></header>
<main class="article-shell" id="article"><p class="article-kicker">THE DEVELOPER EDITION / REVIEWED 26 OCT 2026</p>{body}</main>
<footer class="site-footer section-shell"><span>Independent developer guide · Not affiliated with Apple</span><a href="{prefix}sources.html">Sources & methodology ↗</a></footer></body></html>'''
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(document)
    if source.name == 'tutorial.md':
        download = re.sub(r'\]\((?!https?://|#)([^)]+)\)', lambda m: '](' + ORIGIN + '/' + m[1] + ')', text)
        (ROOT / 'dist/tutorial.md').write_text(download)


render(ROOT / 'content/tutorial.md', ROOT / 'dist/tutorial.html', 'Your first iPhone Duo audit')
render(ROOT / 'content/sources.md', ROOT / 'dist/sources.html', 'Sources & methodology')
for source in (ROOT / 'content/references').glob('*.md'):
    render(source, ROOT / 'dist/references' / (source.stem + '.html'), source.stem.replace('-', ' ').capitalize(), True)
