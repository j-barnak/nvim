#!/usr/bin/env python3
"""Regenerate Resources/docs/BOOKS.md: every title the :Docs Books menu offers.

    python3 Resources/tools/books_inventory.py

Reads the BOOKS and WEB_BOOKS tables out of lua/config/docs.lua (the menu is
built from exactly those two), counts what is on disk for each entry, and
writes one table per group.  Decisions from the keep/remove pass live in
Resources/docs/books_decisions.tsv (`<slug-or-key>\\t<keep|remove>\\t<note>`),
so the Keep column reflects them and an entry that was removed from docs.lua
but is still marked there is reported on stderr.  Run it after every change
to either table so the committed list never drifts from the menu.
"""
import glob, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
CFG = os.path.normpath(os.path.join(HERE, "..", ".."))
LUA = os.path.join(CFG, "lua", "config", "docs.lua")
DOCS = os.path.join(CFG, "Resources", "docs")
OUT = os.path.join(DOCS, "BOOKS.md")
DECISIONS = os.path.join(DOCS, "books_decisions.tsv")


def slugify(t):
    return re.sub(r"[^0-9A-Za-z]+", "-", t.lower()).strip("-")


def decisions():
    d = {}
    if os.path.isfile(DECISIONS):
        with open(DECISIONS, encoding="utf-8") as fh:
            for line in fh:
                if line.startswith("#") or not line.strip():
                    continue
                cols = line.rstrip("\n").split("\t")
                d[cols[0]] = (cols[1], cols[2] if len(cols) > 2 else "")
    return d


def chapter_books(src):
    body = src[src.index("local BOOKS = {"):src.index("local function book_slug")]
    mods = re.findall(r'\{ module = "([^"]+)", key = "([^"]+)", items = \{(.*?)\n\t\} \}', body, re.S)
    for mname, mkey, items in mods:
        rows = []
        for m in re.finditer(r'\{ title = "([^"]+)", fmt = "(\w+)"(?:, slug = "([^"]+)")?(?:, url = "([^"]+)")?', items):
            title, fmt, slug, url = m.groups()
            if fmt == "mdbook":
                d = os.path.join(DOCS, "rust", url.rsplit("/", 1)[1], "src")
                n = len(glob.glob(os.path.join(d, "**", "*.md"), recursive=True))
                ident = "rust/" + url.rsplit("/", 1)[1]
            else:
                ident = slug or slugify(title)
                d = os.path.join(DOCS, "books", mkey, ident)
                n = len([x for x in os.listdir(d) if x[0].isdigit()]) if os.path.isdir(d) else 0
            rows.append((title, fmt, ident, n))
        yield mname, mkey, rows


def web_books(src):
    body = src[src.index("local WEB_BOOKS = {"):src.index("-- All books under one entry")]
    for m in re.finditer(r'\{ title = "([^"]+)", key = "([^"]+)"', body):
        title, key = m.groups()
        idx = os.path.join(DOCS, key, "index.tsv")
        lines, hosts = [], []
        if os.path.isfile(idx):
            with open(idx, encoding="utf-8", errors="replace") as fh:
                lines = fh.read().splitlines()
            hosts = sorted({re.sub(r"^https?://(www\.)?([^/]+).*$", r"\2", l.split("\t")[-1]) for l in lines})
        yield title, key, len(lines), hosts


def main():
    with open(LUA, encoding="utf-8") as fh:
        src = fh.read()
    dec = decisions()
    used = set()

    def keep(ident):
        used.add(ident)
        if ident not in dec:
            return ""
        verdict, note = dec[ident]
        return verdict + (" — " + note if note else "")

    out = []
    w = out.append
    w("# :Docs Books\n")
    w("Every title the `:Docs` → Books menu offers (RISC-V included for completeness;")
    w("those 25 sit behind the top-level \"RISC-V (manuals)\" entry instead). Generated")
    w("by `Resources/tools/books_inventory.py` from the `BOOKS` and `WEB_BOOKS` tables")
    w("in `lua/config/docs.lua`; the Keep column comes from `books_decisions.tsv`.\n")
    w("Two kinds of book:\n")
    w("- **Chapter books**: an epub/pdf or a markdown repo converted once into numbered")
    w("  chapter files under `Resources/docs/books/<module>/<slug>/` (the four rust-lang")
    w("  mdBooks under `Resources/docs/rust/<repo>/src`). Browsed with fd/find.")
    w("- **Web books**: a frozen site or article series, `Resources/docs/<key>/index.tsv`")
    w("  (`title<TAB>url` rows) whose pages are `Resources/docs/.webcache/<sha256(url)>.txt`,")
    w("  shared between books.\n")

    chapters = list(chapter_books(src))
    webs = list(web_books(src))
    n_ch = sum(len(r) for _, _, r in chapters)
    w("## Chapter books (epub / pdf / markdown repo) — %d\n" % n_ch)
    i = 0
    for mname, mkey, rows in chapters:
        w("### %s (`%s`)\n" % (mname, mkey))
        w("| # | Title | Fmt | Slug | Chapters | Keep? |")
        w("|---|---|---|---|---|---|")
        for title, fmt, ident, n in rows:
            i += 1
            w("| %d | %s | %s | `%s` | %s | %s |" % (i, title, fmt, ident, n or "MISSING", keep(ident)))
        w("")
    w("## Frozen web books (`WEB_BOOKS`) — %d\n" % len(webs))
    w("| # | Title | Key | Entries | Source | Keep? |")
    w("|---|---|---|---|---|---|")
    for i, (title, key, n, hosts) in enumerate(webs, 1):
        h = ", ".join(hosts[:3]) + (" …" if len(hosts) > 3 else "")
        w("| %d | %s | `%s` | %s | %s | %s |" % (i, title, key, n or "MISSING", h, keep(key)))
    w("")
    # A `remove` row whose entry is gone from docs.lua is the normal end state
    # of a removal, and is what the last table is built from; a `keep` row in
    # that state is a mistake worth flagging.
    gone = sorted(set(dec) - used)
    removed = [(i, dec[i][1]) for i in gone if dec[i][0] == "remove"]
    if removed:
        w("## Removed from Books — %d\n" % len(removed))
        w("| Slug / key | Note |")
        w("|---|---|")
        for ident, note in removed:
            w("| `%s` | %s |" % (ident, note))
        w("")
    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write("\n".join(out))
    for ident in gone:
        if dec[ident][0] != "remove":
            print("books_decisions.tsv: %r is marked %s but is not in docs.lua" % (ident, dec[ident][0]), file=sys.stderr)
    print("wrote %s: %d chapter books, %d web books" % (os.path.relpath(OUT, CFG), n_ch, len(webs)))


if __name__ == "__main__":
    main()
