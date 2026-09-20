#!/usr/bin/env bash
# Freeze "Programming Z3" (theory.stanford.edu/~nikolaj/programmingz3.html) into
# the :Docs frozen web-book layout used by the "Programming Z3" picker:
#   Resources/docs/programming-z3/index.tsv     "<title>\t<url>" in ToC order
#   Resources/docs/.webcache/<sha256(url)>.txt    the rendered section
#
# The book is a SINGLE Madoko page: headings (h2/h3/h4/h5) and content (p, div,
# pre, ...) are flat siblings inside div.madoko, with no section wrappers. One
# cache per ToC line (h2/h3/h4 with an id): each entry gets its own prose, sliced
# from its heading up to the next h2/h3/h4 (h5 sub-headings fold into their
# parent, since the ToC stops at three levels). Indentation (2 spaces per level)
# reproduces the tree. Code (<pre>) survives pandoc as code blocks.
# Usage: z3_build.sh   (needs curl, python3+bs4+lxml, pandoc)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/programming-z3"
URL="https://theory.stanford.edu/~nikolaj/programmingz3.html"
mkdir -p "$OUT" "$CACHE"

echo "==> fetching Programming Z3"
curl -fsSL --compressed --max-time 60 "$URL" -o /tmp/z3.html

WE="$WE" CACHE="$CACHE" OUT="$OUT" URL="$URL" python3 - <<'PY'
import os, re, hashlib, subprocess
from urllib.parse import urljoin
from bs4 import BeautifulSoup

WE, CACHE, OUT, URL = os.environ["WE"], os.environ["CACHE"], os.environ["OUT"], os.environ["URL"]
s = BeautifulSoup(open("/tmp/z3.html", encoding="utf-8", errors="replace").read(), "lxml")
mad = s.find("div", class_="madoko") or s.find("body")

# absolutize links/images once
for a in mad.find_all("a", href=True):
    if not a["href"].startswith(("http", "#", "mailto")):
        a["href"] = urljoin(URL, a["href"])
for im in mad.find_all("img", src=True):
    if not im["src"].startswith("http"):
        im["src"] = urljoin(URL, im["src"])

TOC = {"h2", "h3", "h4"}   # ToC-entry heading levels (h5 folds into its parent)
entries, cur = [], None
for child in list(mad.children):
    name = getattr(child, "name", None)
    if name in TOC and child.get("id"):
        cur = {"level": int(name[1]), "id": child["id"], "heading": child, "nodes": [child]}
        entries.append(cur)
    elif cur is not None and name is not None:
        cur["nodes"].append(child)
    # (nodes before the first ToC heading are the page banner/nav; ignored)

def render(html_str):
    p1 = subprocess.run(["pandoc", "-f", "html", "-t", "gfm-raw_html", "--wrap=none",
                         "--preserve-tabs"], input=html_str, capture_output=True, text=True)
    p2 = subprocess.run(["python3", WE, "clean", "", ""], input=p1.stdout,
                        capture_output=True, text=True)
    return p2.stdout.strip()

def clean_title(h):
    for hl in h.find_all("a", class_=lambda c: c and "header" in " ".join(c).lower()):
        hl.decompose()
    t = re.sub(r"\s+", " ", h.get_text(" ", strip=True)).strip()
    t = re.sub(r"^([\d.]+)\s*\.\s+", r"\1. ", t)   # "1.1 . Resources" -> "1.1. Resources"
    return t

rows = []
for e in entries:
    title = clean_title(e["heading"])
    indent = "  " * (e["level"] - 2)
    url = "%s#%s" % (URL, e["id"])
    body = render("".join(str(n) for n in e["nodes"]))
    if len(body) < 20:
        print("  EMPTY", title); continue
    cf = os.path.join(CACHE, hashlib.sha256(url.encode()).hexdigest() + ".txt")
    open(cf, "w", encoding="utf-8").write(body + "\n")
    rows.append("%s%s\t%s" % (indent, title, url))

open(os.path.join(OUT, "index.tsv"), "w", encoding="utf-8").write("\n".join(rows) + "\n")
print("==> Programming Z3: %d rows" % len(rows))
PY
rm -f /tmp/z3.html
echo "index rows: $(wc -l < "$OUT/index.tsv")"
