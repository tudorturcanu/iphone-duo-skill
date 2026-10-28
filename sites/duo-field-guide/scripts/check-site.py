"""Check local asset links and reference anchors in the static guide."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import unquote, urlsplit
import re

ROOT = Path(__file__).resolve().parents[1] / 'dist'
INTRO_ROUTES = {'meet', 'resize', 'regions', 'bars', 'state', 'build', 'explore', 'updates', 'ship'}
EXAMPLE_ROUTES = {'mail', 'notes', 'media', 'layout'}

class Page(HTMLParser):
    def __init__(self, source):
        super().__init__()
        self.links, self.ids = [], set()
        self.feed(source)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'id' in attrs:
            self.ids.add(attrs['id'])
        self.links.extend(attrs[key] for key in ('href', 'src') if key in attrs)

pages = {path: Page(path.read_text()) for path in ROOT.rglob('*.html')}
errors = []

def check(path, value):
    url = urlsplit(value)
    if url.scheme or url.netloc:
        return
    target = (path.parent / unquote(url.path)).resolve() if url.path else path
    if not target.exists():
        errors.append(f'{path.name}: missing {value}')
    elif url.fragment and target in pages and url.fragment not in pages[target].ids:
        if target.name == 'index.html' and url.fragment in INTRO_ROUTES:
            return
        if target.name == 'examples.html' and url.fragment in EXAMPLE_ROUTES:
            return
        errors.append(f'{path.name}: missing anchor {value}')

for path, page in pages.items():
    for link in page.links:
        check(path, link)
for name in ('intro.js', 'navigation.js'):
    source = (ROOT / name).read_text()
    for match in re.finditer(r"references/[^'\"`\s<>]+\.html(?:#[^'\"`\s<>]+)?", source):
        check(ROOT / name, match[0])
if errors:
    raise SystemExit('\n'.join(errors))
print(f'PASS: {len(pages)} pages, local assets, and JavaScript reference targets resolve.')
