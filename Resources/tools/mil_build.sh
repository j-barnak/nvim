#!/usr/bin/env bash
# Freeze "Mathematics in Lean" (leanprover-community.github.io/mathematics_in_lean)
# into the :Docs frozen web-book layout used by the "Mathematics in Lean" picker:
#   Resources/docs/mathematics-in-lean/index.tsv    "<title>\t<url>" in ToC order
#   Resources/docs/.webcache/<sha256(url)>.txt        the rendered chapter/section
#
# The book is a Sphinx site: 13 chapter pages (C01_.. C13_..), each wrapping its
# content in nested <section id="..."> blocks. One cache per ToC line: a chapter
# keeps only its own intro (nested <section>s removed), a numbered section keeps
# its own body. Indentation (2 spaces per level) reproduces the chapter/section
# tree. Lean code (<pre>) survives pandoc as fenced blocks.
# Usage: mil_build.sh   (needs curl, python3+bs4+lxml, pandoc)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/mathematics-in-lean"
BASE="https://leanprover-community.github.io/mathematics_in_lean"
mkdir -p "$OUT" "$CACHE"

CHAPTERS="C01_Introduction C02_Basics C03_Logic C04_Sets_and_Functions \
C05_Elementary_Number_Theory C06_Discrete_Mathematics C07_Structures \
C08_Hierarchies C09_Groups_and_Rings C10_Linear_Algebra C11_Topology \
C12_Differential_Calculus C13_Integration_and_Measure_Theory"

echo "==> fetching 13 chapter pages"
for c in $CHAPTERS; do
  curl -fsSL --compressed --max-time 40 "$BASE/$c.html" -o "/tmp/mil_$c.html"
done

WE="$WE" CACHE="$CACHE" OUT="$OUT" BASE="$BASE" CHAPTERS="$CHAPTERS" python3 - <<'PY'
import os, re, hashlib, subprocess
from urllib.parse import urljoin
from bs4 import BeautifulSoup

WE, CACHE, OUT, BASE = os.environ["WE"], os.environ["CACHE"], os.environ["OUT"], os.environ["BASE"]
chapters = os.environ["CHAPTERS"].split()

def absolutize(node, page_url):
    for a in node.find_all("a", href=True):
        if not a["href"].startswith(("http", "#", "mailto")):
            a["href"] = urljoin(page_url, a["href"])
    for im in node.find_all("img", src=True):
        if not im["src"].startswith("http"):
            im["src"] = urljoin(page_url, im["src"])

def render(html_str):
    p1 = subprocess.run(["pandoc", "-f", "html", "-t", "gfm-raw_html", "--wrap=none",
                         "--preserve-tabs"], input=html_str, capture_output=True, text=True)
    p2 = subprocess.run(["python3", WE, "clean", "", ""], input=p1.stdout,
                        capture_output=True, text=True)
    return p2.stdout.strip()

def write(title, url, html_str):
    body = render(html_str)
    if len(body) < 20:
        print("  EMPTY", title); return False
    cf = os.path.join(CACHE, hashlib.sha256(url.encode()).hexdigest() + ".txt")
    open(cf, "w", encoding="utf-8").write(body + "\n")
    rows.append("%s\t%s" % (title, url))
    return True

rows = []
for c in chapters:
    page_url = "%s/%s.html" % (BASE, c)
    s = BeautifulSoup(open("/tmp/mil_%s.html" % c, encoding="utf-8", errors="replace").read(), "lxml")
    main = s.find("div", attrs={"role": "main"}) or s.find("div", class_="body") or s
    # the chapter is the single top-level <section id> under main
    chap = main.find("section", id=True)
    if not chap:
        print("  no chapter section in", c); continue
    absolutize(chap, page_url)
    # drop the ¶ headerlinks so they do not leak into titles
    for hl in chap.find_all("a", class_="headerlink"):
        hl.decompose()
    subsecs = chap.find_all("section", id=True, recursive=False)

    def title_of(node, fallback):
        h = node.find(["h1", "h2", "h3"])
        return re.sub(r"\s+", " ", h.get_text(" ", strip=True)).strip() if h else fallback

    ctitle = title_of(chap, c)
    # chapter cache = chapter with nested sections removed (intro only). Some
    # chapters (Introduction) open straight into their first section with no
    # intro; those become a non-clickable header row instead of an empty cache.
    from copy import copy
    chap_intro = copy(chap)
    for sub in chap_intro.find_all("section", id=True):
        sub.decompose()
    if not write(ctitle, page_url, str(chap_intro)):
        rows.append(ctitle)  # header-only row (no url)
    # each numbered section = its own body
    for sub in subsecs:
        surl = "%s#%s" % (page_url, sub.get("id"))
        write("  " + title_of(sub, sub.get("id")), surl, str(sub))

open(os.path.join(OUT, "index.tsv"), "w", encoding="utf-8").write("\n".join(rows) + "\n")
print("==> Mathematics in Lean: %d rows" % len(rows))
PY
rm -f /tmp/mil_C*.html
echo "index rows: $(wc -l < "$OUT/index.tsv")"
