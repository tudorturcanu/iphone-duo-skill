#!/usr/bin/env python3
"""Check Apple's HIG article "Designing for iPhone Duo" for changes, section by section.

tests/hig-duo.sha256 holds one hash for the whole article and one per section, so a change report names the
sections to re-read instead of only saying "something changed". Exits 1 on any change so references/ and SKILL.md
get re-checked. `--update` rewrites the file from the live article. Only hashes and section headings are stored,
never Apple's text.
"""
import hashlib, re, sys, urllib.request

URL = "https://developer.apple.com/tutorials/data/design/human-interface-guidelines/designing-for-iphone-duo.md"
FILE = "tests/hig-duo.sha256"
WHOLE = "(whole article)"


def sha(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def sections(article):
    """[(name, hash)]: the whole article first, then each `##` / `###` section in order."""
    body = article.split("\nCopyright", 1)[0] + "\n"  # the footer carries a year, not guidance
    out, name, lines, seen = [(WHOLE, sha(body))], "(intro)", [], {}
    for line in body.splitlines():
        m = re.match(r"#{2,3} (.+)", line)
        if m:
            out.append((name, sha("\n".join(lines))))
            name, lines = m.group(1).strip(), []
            seen[name] = seen.get(name, 0) + 1
            if seen[name] > 1:
                name = f"{name} ({seen[name]})"
        lines.append(line)
    out.append((name, sha("\n".join(lines))))
    return out


def main():
    with urllib.request.urlopen(urllib.request.Request(URL, headers={"User-Agent": "iphone-duo-skill-check"}), timeout=30) as r:
        live = sections(r.read().decode("utf-8"))
    if "--update" in sys.argv:
        with open(FILE, "w") as f:
            f.write("# sha256\tsection of the HIG article (hashes only, never Apple's text)\n")
            f.writelines(f"{h}\t{name}\n" for name, h in live)
        print(f"Updated {len(live) - 1} section hashes")
        return
    known = {}
    for line in open(FILE):
        if line.strip() and not line.startswith("#"):
            h, _, name = line.rstrip("\n").partition("\t")
            known[name or WHOLE] = h  # a bare hash is the pre-1.3.1 whole-article format
    now = dict(live)
    if known.get(WHOLE) == now[WHOLE]:
        print(f"HIG article unchanged ({now[WHOLE]})")
        return
    changed = [n for n, h in live[1:] if n in known and known[n] != h]
    added = [n for n, _ in live[1:] if n not in known]
    removed = [n for n in known if n not in now]
    if len(known) == 1:
        print("::warning::The HIG article changed (no section hashes recorded yet, so re-read all of it).")
    for label, names in (("changed", changed), ("new", added), ("removed", removed)):
        if names and len(known) > 1:
            print(f"::warning::HIG sections {label}: {', '.join(names)}")
    print("Review those sections, update references/ and SKILL.md, then run: python3 tests/check_hig.py --update")
    sys.exit(1)


if __name__ == "__main__":
    main()
