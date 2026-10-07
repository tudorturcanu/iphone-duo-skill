#!/usr/bin/env python3
"""Check the Apple pages behind references/shipping.md and the launch-status and SDK lines in SKILL.md.

The facts the skill states about dates, store requirements, asset sizes, and Xcode status come from pages that
change without notice. This compares a few small facts (numbers and one-word statuses, never Apple's text) with the
live pages and exits 1 when one differs, so shipping.md and SKILL.md get re-checked. Run weekly by hig-drift.yml.
"""
import html, re, sys, urllib.request
import xml.etree.ElementTree as ET

DEV = "https://developer.apple.com/"
SIZE = re.compile(r"(\d{3,4})\s*[×x]\s*(\d{3,4})")


def get(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "iphone-duo-skill-check"}), timeout=30) as r:
        return r.read().decode("utf-8", "replace")


def text(page):
    page = re.sub(r"<script.*?</script>|<style.*?</style>", " ", page, flags=re.S)
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", page))).replace("\xa0", " ")


def duo_sizes(page):
    """Sizes printed within 600 characters after a 'Duo' label on an App Store Connect spec page."""
    t = text(page)
    found = set()
    for m in re.finditer("Duo", t):
        found |= {f"{a}x{b}" for a, b in SIZE.findall(t[m.start():m.start() + 600])}
    return found


def main():
    problems = []

    # 1. Launch news post: dates and the screenshot requirement.
    news = text(get(DEV + "news/?id=kkphp5qo"))
    for fact in ("October 23, 2026", "April 2027", "Xcode 27.1"):
        if fact not in news:
            problems.append(f"news post kkphp5qo no longer says '{fact}': re-check references/shipping.md and SKILL.md")

    # 2. New iPhone Duo news posts since this skill was last updated.
    known = {"vn8abkxx", "rfb1rooi", "nyuppv9r", "kkphp5qo", "gv788oj6"}
    for it in ET.fromstring(get(DEV + "news/rss/news.rss")).iter("item"):
        guid = (it.findtext("guid") or "").split("=")[-1]
        body = (it.findtext("title") or "") + html.unescape(it.findtext("description") or "")
        if "Duo" in body.replace("\xa0", " ") and guid not in known:
            problems.append(f"new iPhone Duo news post {guid}: {(it.findtext('title') or '').strip()} (add its id to `known` after reading it)")

    # 3. Screenshot and preview specs: Duo sizes unchanged; the specs page starts mentioning the 2027 deadline.
    base = DEV + "help/app-store-connect/reference/app-information/"
    shots = get(base + "screenshot-specifications")
    want = {"1398x2034", "2007x2853", "2034x1398", "2853x2007"}
    if not want <= duo_sizes(shots):
        problems.append(f"screenshot sizes for iPhone Duo changed (missing {sorted(want - duo_sizes(shots))}): re-check references/shipping.md")
    if "2027" in text(shots):
        problems.append("screenshot specifications page now mentions 2027: update the 'page lags the news post' note in references/shipping.md")
    previews = get(base + "app-preview-specifications")
    pt = text(previews)
    for size in ("886 x 1920", "1920 x 886", "2034 × 1398", "2853 × 2007"):
        if size not in pt:
            problems.append(f"app preview page no longer lists {size}: re-check references/shipping.md")

    # 4. Xcode 27.1 status (the skill says 'release candidate').
    import json
    meta = json.loads(get(DEV + "tutorials/data/documentation/xcode-release-notes/xcode-27_1-release-notes.json"))["metadata"]
    if "RC" not in meta.get("title", ""):
        problems.append(f"Xcode 27.1 release notes are now titled '{meta.get('title')}': update 'RC' wording in SKILL.md and references/")

    # 5. Apple's "Three steps" page: SDK tiers, Apple's own resizability skill, and the testing tools the skill names.
    prepare = text(get(DEV + "iphone-duo/prepare/"))
    for fact in ("iOS 26 SDK", "iOS 27.1 SDK", "xcrun agent skills export", "iPhone Mirroring", "resizable simulator",
                 "featuring nomination"):
        if fact not in prepare:
            problems.append(f"prepare page no longer says '{fact}': re-check SKILL.md, the reference (section 5), and references/shipping.md")

    for p in problems:
        print("::warning::" + p)
    print("Apple launch sources unchanged" if not problems else f"{len(problems)} change(s) to review")
    sys.exit(1 if problems else 0)


if __name__ == "__main__":
    main()
