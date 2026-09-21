#!/usr/bin/env bash
# Freeze "Algorithms, 4th Edition" (Sedgewick & Wayne, algs4.cs.princeton.edu)
# into the :Docs frozen web-book layout used by the "Algorithms (Sedgewick)"
# picker:
#   Resources/docs/algs4/index.tsv              "<title>\t<url>" in book order
#   Resources/docs/.webcache/<sha256(url)>.txt    the rendered chapter/section
#
# The site is one page per chapter/section, numbered by URL: /N0.../ is a chapter
# (1 Fundamentals ...) and /NM.../ (M != 0) is section N.M (1.1 Programming Model
# ...). Body is div#content; Java code is in <pre>. Titles come from each page's
# own numbered heading; indentation (2 spaces) nests sections under chapters.
# Usage: algs4_build.sh   (needs curl, python3+bs4+lxml, pandoc)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/algs4"
BASE="https://algs4.cs.princeton.edu"
mkdir -p "$OUT" "$CACHE"

SLUGS="10fundamentals 11model 12oop 13stacks 14analysis 15uf \
20sorting 21elementary 22mergesort 23quicksort 24pq 25applications \
30searching 31elementary 32bst 33balanced 34hash 35applications \
40graphs 41graph 42digraph 43mst 44sp \
50strings 51radix 52trie 53substring 54regexp 55compression \
60context 61event 62btree 63suffix 64maxflow 65reductions 66intractability"

: > "$OUT/index.tsv"; ok=0; fail=0
for slug in $SLUGS; do
  url="$BASE/$slug/"
  html=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null)
  [ -z "$html" ] && { echo "FAIL fetch $url" >&2; fail=$((fail+1)); continue; }
  # title from the page's own numbered heading (h1); fallback to <title>
  title=$(printf '%s' "$html" | python3 -c "
import sys, re
from bs4 import BeautifulSoup
s=BeautifulSoup(sys.stdin.read(),'lxml')
c=s.select_one('div#content') or s
h=c.find(['h1','h2'])
t=re.sub(r'\s+',' ', h.get_text(' ',strip=True)).strip() if h else ((s.title.string or '').strip() if s.title else '')
print(t)")
  [ -z "$title" ] && title="$slug"
  # chapter slug ends in 0 (10,20,...): top level; else a section, indent it.
  case "$slug" in
    ?0*) indent="" ;;
    *)   indent="  " ;;
  esac
  body=$(printf '%s' "$html" \
    | python3 "$WE" content div#content "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null)
  if [ "$(printf '%s' "$body" | wc -c)" -lt 200 ]; then
    echo "FAIL empty $url" >&2; fail=$((fail+1)); continue
  fi
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  printf '%s\n' "$body" > "$cf"
  printf '%s%s\t%s\n' "$indent" "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.3
done
echo "==> algs4: $ok pages, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
