#!/usr/bin/env bash
# Freeze (or update) the Rust std reference (doc.rust-lang.org/std) into the
# :Docs frozen web-book layout used by pick_rust_std:
#   Resources/docs/rust-std/index.tsv        all item pages (searchable)
#   Resources/docs/rust-std/{modules,primitives,macros,keywords}.tsv
#   Resources/docs/.webcache/<sha256(url)>.txt   the rendered pages
#
# rustdoc is autodoc, so we scrape the BUILT site (never the rust repo source).
# Re-run any time to update to the current stable std. Polite: ~0.4s/page.
# Usage: rust_std_build.sh   (run from the nvim config root, or it will cd there)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/rust-std"
SEL='section#main-content'
BASE="https://doc.rust-lang.org/std/"
mkdir -p "$OUT" "$CACHE"

echo "==> enumerating std pages"
curl -fsSL --compressed "$BASE/index.html" -o /tmp/rstd_landing.html
curl -fsSL --compressed "$BASE/all.html"   -o /tmp/rstd_all.html
python3 - "$OUT" <<'PY'
import re, sys, os
B="https://doc.rust-lang.org/std/"
OUT=sys.argv[1]
land=open('/tmp/rstd_landing.html').read(); allh=open('/tmp/rstd_all.html').read()
def section(html,sid):
    m=re.search(r'id="'+sid+r'"[^>]*>.*?</h2>(.*?)(?:<h2 |$)', html, re.S); return m.group(1) if m else ""
def links(block,pat):
    return [(l.strip(), B+h) for h,l in re.findall(r'href="('+pat+r')"[^>]*>([^<]+)</a>', block)]
cats={
 'modules':    [(f"std::{l}",u) for l,u in links(section(land,'modules'), r'[a-z_]+/index\.html')],
 'primitives': links(section(land,'primitives'), r'primitive\.[a-z0-9_]+\.html'),
 'macros':     [(l+"!",u) for l,u in links(section(land,'macros'), r'macro\.[a-z0-9_]+\.html')],
 'keywords':   links(section(land,'keywords'), r'keyword\.[a-z0-9_]+\.html'),
}
items=set(B+h for h in re.findall(r'href="([a-z0-9_./]+/(?:struct|enum|trait|fn|macro|primitive|type|constant|union|derive|keyword)\.[^"]+\.html)"', allh))
pages=set([B+"index.html", B+"all.html"]) | items
for rows in cats.values():
    for _,u in rows: pages.add(u)
for cr in ("alloc","core","proc_macro","std_detect","test"):
    pages.add(f"https://doc.rust-lang.org/{cr}/index.html")
open('/tmp/rstd_urls.txt','w').write("\n".join(sorted(pages))+"\n")
for name,rows in cats.items():
    open(os.path.join(OUT,name+".tsv"),'w').write("\n".join(f"{t}\t{u}" for t,u in rows)+"\n")
print("pages:",len(pages),"| modules",len(cats['modules']),"primitives",len(cats['primitives']),
      "macros",len(cats['macros']),"keywords",len(cats['keywords']))
PY

echo "==> scraping (this takes a while)"
: > "$OUT/.rows"; ok=0; fail=0; n=0; total=$(wc -l < /tmp/rstd_urls.txt)
while IFS= read -r url; do
  [ -z "$url" ] && continue; n=$((n+1))
  html=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null)
  [ -z "$html" ] && { echo "FAIL $url" >&2; fail=$((fail+1)); continue; }
  body=$(printf '%s' "$html" | python3 "$WE" content "$SEL" "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null)
  [ "$(printf '%s' "$body" | wc -c)" -lt 50 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  title=$(printf '%s' "$body" | grep -m1 -E '^#+ ' | sed -E 's/^#+[[:space:]]*//' | tr -s ' ' | sed -E 's/^ +| +$//g')
  [ -z "$title" ] && title=$(printf '%s' "$url" | sed -E 's#.*/([^/]+)\.html#\1#')
  printf '%s' "$body" > "$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/.rows"; ok=$((ok+1))
  [ $((n % 100)) -eq 0 ] && printf '  [%d/%d]\n' "$n" "$total"
  sleep 0.4
done < /tmp/rstd_urls.txt
sort -u "$OUT/.rows" > "$OUT/index.tsv"; rm -f "$OUT/.rows"
echo "==> done: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
