#!/usr/bin/env python3
"""Index one ns-3 release's published Doxygen for the :Docs ns-3 provider.

    python3 ns3_api_idx.py <release> <outdir>      e.g.  3.48  ~/.local/share/nvim/docs/ns3/ns-3.48

Writes <outdir>/api-topics/index.tsv and <outdir>/api-classes/index.tsv, each
a "title<TAB>url" list the frozen_web_provider reads; the pages themselves are
fetched on demand when opened (hybrid live mode) and cached under .webcache.

Sources, under https://www.nsnam.org/docs/release/<release>/doxygen/:
  topics.html     Doxygen >= 1.10 "Topics" (module groups).  Rows nest by their
                  id ("row_0_", "row_0_3_"), so a child is titled "Parent / Child"
                  and fzf matches on either.  Older releases only have
                  modules.html; it is tried second with the same parser.
  annotated.html  every class/struct, "ns3::Name — one-line description".

A release with no doxygen published (3.11-3.14, and anything before 3.1) exits
2 with a one-line reason on stderr so the caller can say so instead of showing
an empty list.  Standard library only, like the other builders.
"""
import html, os, re, sys, urllib.error, urllib.request
from html.parser import HTMLParser

UA = "Mozilla/5.0 (personal-docs-archive)"


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read().decode("utf-8", "replace")


class Rows(HTMLParser):
    """Collect Doxygen directory-table rows: (row id, first a.el text, href, td.desc text)."""

    def __init__(self):
        super().__init__()
        self.rows, self.row, self.field = [], None, None

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "tr" and a.get("id", "").startswith("row_"):
            self.row = {"id": a["id"], "title": "", "href": "", "desc": ""}
        elif self.row is not None and tag == "a" and "el" in (a.get("class") or "").split() and not self.row["href"]:
            self.row["href"] = a.get("href", "")
            self.field = "title"
        elif self.row is not None and tag == "td" and "desc" in (a.get("class") or "").split():
            self.field = "desc"

    def handle_endtag(self, tag):
        if self.row is not None:
            if tag == "a" and self.field == "title":
                self.field = None
            elif tag == "td" and self.field == "desc":
                self.field = None
            elif tag == "tr":
                if self.row["href"]:
                    self.rows.append(self.row)
                self.row, self.field = None, None

    def handle_data(self, data):
        if self.row is not None and self.field:
            self.row[self.field] += data


def parse(page):
    p = Rows()
    p.feed(page)
    out = []
    for r in p.rows:
        r["title"] = re.sub(r"\s+", " ", html.unescape(r["title"])).strip()
        r["desc"] = re.sub(r"\s+", " ", html.unescape(r["desc"])).strip()
        r["depth"] = r["id"].count("_") - 2  # "row_0_" -> 0, "row_0_3_" -> 1
        out.append(r)
    return out


def write(path, lines):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("".join(l + "\n" for l in lines))


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    rel, out = sys.argv[1], sys.argv[2]
    base = "https://www.nsnam.org/docs/release/%s/doxygen/" % rel
    try:
        fetch(base + "index.html")
    except urllib.error.HTTPError as e:
        print("ns-3 %s: no published Doxygen at %s (HTTP %d)" % (rel, base, e.code), file=sys.stderr)
        sys.exit(2)

    topics = None
    for name in ("topics.html", "modules.html"):
        try:
            topics = parse(fetch(base + name))
            break
        except urllib.error.HTTPError:
            continue
    if not topics:
        print("ns-3 %s: neither topics.html nor modules.html found" % rel, file=sys.stderr)
        sys.exit(2)
    lines, chain = [], []
    for r in topics:
        chain = chain[: r["depth"]] + [r["title"]]
        lines.append("%s\t%s" % (" / ".join(chain), base + r["href"]))
    write(os.path.join(out, "api-topics", "index.tsv"), lines)

    classes = parse(fetch(base + "annotated.html"))
    lines, chain = [], []
    for r in classes:
        chain = chain[: r["depth"]] + [r["title"]]
        # Namespace rows have no class page of their own worth listing; keep the
        # leaf entries (classes/structs/unions), qualified by their namespace.
        if r["href"].startswith("namespace"):
            continue
        name = "::".join(chain)
        lines.append("%s\t%s" % (name + (" — " + r["desc"] if r["desc"] else ""), base + r["href"]))
    write(os.path.join(out, "api-classes", "index.tsv"), lines)
    print("ns-3 %s: %d topics, %d classes" % (rel, len(topics), len(lines)))


if __name__ == "__main__":
    main()
