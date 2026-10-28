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


DESCRIPTIONS = {
    'tutorial.html': 'Audit and adapt a SwiftUI app for iPhone Duo with a practical walkthrough, code examples, and testing guidance.',
    'sources.html': 'Explore the Apple documentation and methodology behind the independent iPhone Duo Field Guide.',
    'references/skill.html': 'Use the iPhone Duo design skill to audit and adapt SwiftUI and UIKit apps for foldable displays.',
    'references/system-behaviors.html': 'Learn how iPhone Duo system behaviors affect app layout, navigation, state, and transitions.',
    'references/apple-hig-designing-for-iphone-duo.html': 'Explore iPhone Duo design guidance, SwiftUI patterns, adaptive layouts, reserved regions, and API availability.',
    'references/shipping.html': 'Prepare an iPhone Duo app for release with guidance on testing, SDK compatibility, screenshots, and submission.',
    'references/cameras-and-scene-accessories.html': 'Design iPhone Duo camera experiences and scene accessories for changing device arrangements.',
}


def render(source, destination, title, reference=False):
    text = source.read_text()
    text = re.sub(r'^---\n.*?\n---\n', '', text, flags=re.S)
    text = re.sub(r'\]\(([^)]+)\)', lambda m: rewrite_link(m, reference), text)
    body = markdown.markdown(text, extensions=['fenced_code', 'tables', 'toc', 'sane_lists'])
    body = re.sub(r'<table>(.*?)</table>', r'<div class="table-scroll"><table>\1</table></div>', body, flags=re.S)
    prefix = '../' if reference else ''
    page_title = title + ' — Duo Field Guide'
    description = DESCRIPTIONS[destination.relative_to(ROOT / 'dist').as_posix()]
    seo = (f'<meta name="description" content="{html.escape(description, quote=True)}">'
           f'<meta property="og:type" content="website"><meta property="og:site_name" content="Duo Field Guide">'
           f'<meta property="og:title" content="{html.escape(page_title, quote=True)}">'
           f'<meta property="og:description" content="{html.escape(description, quote=True)}">'
           '<meta name="twitter:card" content="summary">')
    document = f'''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>{html.escape(page_title)}</title>{seo}<link rel="stylesheet" href="{prefix}palette.css?v=9"><link rel="stylesheet" href="{prefix}styles.css?v=9"><link rel="stylesheet" href="{prefix}refinement.css?v=9"><link rel="stylesheet" href="{prefix}guide-nav.css?v=9"><script src="{prefix}navigation.js" defer></script></head>
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
REFERENCE_TITLES = {
    'skill': 'iPhone Duo design skill',
    'system-behaviors': 'iPhone Duo system behaviors',
    'apple-hig-designing-for-iphone-duo': 'iPhone Duo design and API reference',
    'shipping': 'Shipping an iPhone Duo app',
    'cameras-and-scene-accessories': 'iPhone Duo cameras and scene accessories',
}
for source in (ROOT / 'content/references').glob('*.md'):
    render(source, ROOT / 'dist/references' / (source.stem + '.html'), REFERENCE_TITLES[source.stem], True)
