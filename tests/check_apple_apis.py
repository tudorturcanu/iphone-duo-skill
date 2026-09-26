#!/usr/bin/env python3
"""Check that every Apple API the skill names still exists with the recorded availability.

Reads tests/apple-apis.tsv (doc path, iOS introduced, iOS deprecated, beta) and compares each entry with
Apple's DocC JSON. Exits 1 on any change so the skill gets re-checked. `--update` rewrites the file from
the live docs. Only availability metadata is stored, never Apple's text.
"""
import json, sys, urllib.request, urllib.error
from concurrent.futures import ThreadPoolExecutor

BASE = "https://developer.apple.com/tutorials/data/documentation/"
FILE = "tests/apple-apis.tsv"


def fetch(path):
    try:
        with urllib.request.urlopen(BASE + path + ".json", timeout=30) as r:
            meta = json.load(r)["metadata"]
    except urllib.error.HTTPError as e:
        return path, None, f"HTTP {e.code}"
    except Exception as e:  # network trouble: report, don't mistake for a removal
        return path, None, f"error: {e}"
    ios = next((p for p in meta.get("platforms", []) if p.get("name") == "iOS"), {})
    return path, (ios.get("introducedAt", "-"), ios.get("deprecatedAt", "-"), "beta" if ios.get("beta") else "-"), None


def main():
    rows = [l.rstrip("\n").split("\t") for l in open(FILE) if l.strip() and not l.startswith("#")]
    with ThreadPoolExecutor(8) as pool:
        live = list(pool.map(fetch, [r[0] for r in rows]))
    if "--update" in sys.argv:
        with open(FILE, "w") as f:
            f.write("# doc path (under /documentation/)\tiOS introduced\tiOS deprecated\tbeta\n")
            for path, cur, err in live:
                if err:
                    sys.exit(f"{path}: {err}")
                f.write("\t".join([path, *cur]) + "\n")
        print(f"Updated {len(live)} entries")
        return
    problems = []
    for row, (path, cur, err) in zip(rows, live):
        if err:
            problems.append(f"{path}: {err}")
        elif tuple(row[1:4]) != cur:
            problems.append(f"{path}: recorded {'/'.join(row[1:4])}, now {'/'.join(cur)}")
    for p in problems:
        print("::warning::" + p)
    print(f"{len(rows) - len(problems)}/{len(rows)} Apple APIs unchanged")
    if problems:
        print("Review SKILL.md and references/ for each change, then run: python3 tests/check_apple_apis.py --update")
        sys.exit(1)


if __name__ == "__main__":
    main()
