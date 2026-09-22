#!/usr/bin/env python3
"""List (or delete) frozen web-cache files nothing can reach any more.

    python3 Resources/tools/webcache_orphans.py            # report
    python3 Resources/tools/webcache_orphans.py --delete   # remove them

Every frozen web provider is an index (Resources/docs/<key>/*.tsv, URL in the
last column) whose pages live as Resources/docs/.webcache/<sha256(url)>.txt.
A page is reachable when an index cites its URL, when a string literal in
lua/config/docs.lua does (the seL4 whitepaper, the Nyx paper, the rust-std
landing pages), or when a reachable page links to it: `gd` in the viewer
follows an absolute link to its frozen copy, which is how the ~1100 angr API
module pages and the rust-std item pages are read, with no index row of their
own.  One cache file can also be shared by several indexes (a syzkaller
article is in the LWN index and the kernel-security index too).  Removing a
book must therefore drop only what the remaining indexes can no longer reach,
so the check is a transitive walk from every index, not a per-book listing.
A URL is hashed both as written and with its #fragment stripped, the two
forms the Lua side uses.
"""
import hashlib, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..", "docs")
LUA = os.path.join(HERE, "..", "..", "lua", "config", "docs.lua")
CACHE = os.path.join(ROOT, ".webcache")
LINK = re.compile(r'https?://[^\s)\]"\'<>]+')


def sha(u):
    return hashlib.sha256(u.encode("utf-8")).hexdigest()


def roots():
    urls = set()
    for d in os.listdir(ROOT):
        p = os.path.join(ROOT, d)
        if not os.path.isdir(p) or d.startswith("."):
            continue
        for f in os.listdir(p):
            if f.endswith(".tsv"):
                with open(os.path.join(p, f), encoding="utf-8", errors="replace") as fh:
                    for line in fh:
                        cols = line.rstrip("\n").split("\t")
                        if len(cols) >= 2 and cols[-1].startswith("http"):
                            urls.add(cols[-1])
    with open(LUA, encoding="utf-8") as fh:
        urls.update(re.findall(r'"(https?://[^"\s]+)"', fh.read()))
    return urls


def reachable(urls):
    seen, queue = set(), list(urls)
    while queue:
        u = queue.pop()
        for cand in (u, u.split("#", 1)[0]):
            h = sha(cand)
            if h in seen:
                continue
            p = os.path.join(CACHE, h + ".txt")
            if not os.path.isfile(p):
                continue
            seen.add(h)
            with open(p, encoding="utf-8", errors="replace") as fh:
                queue.extend(l.rstrip(".,;:") for l in LINK.findall(fh.read()))
    return seen


def main():
    delete = "--delete" in sys.argv
    urls = roots()
    seen = reachable(urls)
    files = sorted(f for f in os.listdir(CACHE) if f.endswith(".txt"))
    orphans = [f for f in files if f[:-4] not in seen]
    print("%d index/literal URLs, %d cache files reachable, %d orphan(s)" % (len(urls), len(seen), len(orphans)))
    for f in orphans:
        with open(os.path.join(CACHE, f), encoding="utf-8", errors="replace") as fh:
            title = fh.readline().strip()[:60]
        print("%s %s  %s" % ("deleted" if delete else "orphan ", f, title))
        if delete:
            os.remove(os.path.join(CACHE, f))


if __name__ == "__main__":
    main()
