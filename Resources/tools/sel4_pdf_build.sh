#!/usr/bin/env bash
# Freeze the seL4 whitepaper, reference manual, and publications list into the
# :Docs frozen cache used by the "seL4" picker:
#   Whitepaper   -> one page,  cache key = the whitepaper PDF url
#   Manual       -> per-chapter subpicker (split by the PDF's top-level
#                   bookmarks): Resources/docs/sel4-manual/index.tsv +
#                   cache key = <manual url>#<chapter-slug>
#   Publications -> one page,  cache key = the publications HTML url
# Whitepaper/manual come from PDFs (pdftotext); publications from HTML.
# Usage: sel4_pdf_build.sh   (needs curl, pdftotext, pandoc, python3)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
MAN_OUT="$CFG/Resources/docs/sel4-manual"
WP_URL="https://sel4.systems/About/seL4-whitepaper.pdf"
MAN_URL="https://sel4.systems/Info/Docs/seL4-manual-latest.pdf"
PUB_URL="https://sel4.systems/Research/publications.html"
mkdir -p "$MAN_OUT" "$CACHE"
sha() { printf '%s' "$1" | sha256sum | awk '{print $1}'; }

echo "==> whitepaper"
curl -fsSL --max-time 60 "$WP_URL" -o /tmp/sel4_wp.pdf
{ echo "# seL4 Whitepaper"; echo; pdftotext -nopgbrk /tmp/sel4_wp.pdf - 2>/dev/null; } > "$CACHE/$(sha "$WP_URL").txt"
echo "   $(wc -l < "$CACHE/$(sha "$WP_URL").txt") lines"

echo "==> publications"
curl -fsSL --compressed --max-time 60 "$PUB_URL" \
  | python3 "$WE" content 'main#page-top' "$PUB_URL" abs 2>/dev/null \
  | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
  | python3 "$WE" clean "" "" 2>/dev/null > "$CACHE/$(sha "$PUB_URL").txt"
echo "   $(wc -l < "$CACHE/$(sha "$PUB_URL").txt") lines"

echo "==> manual (split by top-level bookmarks)"
curl -fsSL --max-time 60 "$MAN_URL" -o /tmp/sel4_man.pdf
# title <TAB> first-page <TAB> last-page, from the PDF outline (last page of a
# chapter = first page of the next, minus one; final chapter runs to the end).
CH=$(python3 - /tmp/sel4_man.pdf <<'PY'
import sys
from pypdf import PdfReader
r=PdfReader(sys.argv[1]); n=len(r.pages)
tops=[]
for o in r.outline:
    if isinstance(o, list): continue
    try: pg=r.get_destination_page_number(o)+1
    except Exception: continue
    tops.append((pg, o.title.strip()))
tops.sort()
# keep the real chapters (drop the two "List of ..." front-matter entries)
tops=[(p,t) for p,t in tops if not t.lower().startswith("list of")]
for i,(p,t) in enumerate(tops):
    last = (tops[i+1][0]-1) if i+1 < len(tops) else n
    print(f"{t}\t{p}\t{last}")
PY
)
: > "$MAN_OUT/index.tsv"; mok=0
while IFS=$'\t' read -r title first last; do
  [ -z "$title" ] && continue
  slug=$(printf '%s' "$title" | tr 'A-Z ' 'a-z-' | tr -cd 'a-z0-9-')
  url="$MAN_URL#$slug"
  { echo "# $title"; echo; pdftotext -nopgbrk -f "$first" -l "$last" /tmp/sel4_man.pdf - 2>/dev/null; } \
    > "$CACHE/$(sha "$url").txt"
  printf '%s\t%s\n' "$title" "$url" >> "$MAN_OUT/index.tsv"; mok=$((mok+1))
done <<< "$CH"
echo "   manual chapters: $mok, index rows: $(wc -l < "$MAN_OUT/index.tsv")"
