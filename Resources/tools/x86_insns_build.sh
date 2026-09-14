#!/usr/bin/env bash
# Freeze (or update) the Felix Cloutier x86/amd64 instruction reference
# (felixcloutier.com/x86) into the :Docs frozen web-book layout used by the
# "x86 Instruction Reference" picker:
#   Resources/docs/x86-insns/index.tsv         "[<Category> Instruction] MNEM - summary" rows
#   Resources/docs/.webcache/<sha256(url)>.txt  the rendered pages
#
# Each instruction page is a chapter. Categories come from the index <h2>
# sections (Core / SGX / SMX / VMX / Xeon Phi). Tables are the point: fc_tables.py
# expands rowspan/colspan and lifts full-width sub-headers BEFORE extraction, and
# compact_tables.py narrows the widths AFTER, so the opcode/operand/Intel tables
# render as readable markdown with no collapsed columns.
# Usage: x86_insns_build.sh   (needs curl, python3+bs4+lxml, pandoc)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
FCT="$CFG/Resources/tools/fc_tables.py"
CT="$CFG/Resources/tools/compact_tables.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/x86-insns"
BASE="https://www.felixcloutier.com/x86"
mkdir -p "$OUT" "$CACHE"

echo "==> fetching the instruction index"
curl -fsSL --compressed "$BASE/" -o /tmp/fc_index.html

# Parse the index with bs4: each <h2> category section is followed by a <table>
# of instruction rows (first <td> = mnemonic link, last <td> = summary). Emit
# "[<Category> Instruction] MNEM - summary<TAB>url" rows in site order. Some
# mnemonics share a page (the 3 MOV forms, the gather pairs); every mnemonic
# still gets its own index row so it is findable.
python3 - > "$OUT/index.tsv" 2>/tmp/fc_idx.err <<'PY'
import sys
from bs4 import BeautifulSoup
h=open('/tmp/fc_index.html').read()
soup=BeautifulSoup(h,"lxml")
CAT={"Core Instructions":"Core Instruction","SGX Instructions":"SGX Instruction",
     "SMX Instructions":"SMX Instruction","VMX Instructions":"VMX Instruction",
     "Xeon Phi™ Instructions":"Xeon Phi Instruction"}
rows=[]; seen=set()
for h2 in soup.find_all("h2"):
    cat=CAT.get(h2.get_text(strip=True))
    if not cat: continue
    tbl=h2.find_next("table")
    if not tbl: continue
    for tr in tbl.find_all("tr"):
        tds=tr.find_all("td")
        if len(tds)<2: continue
        a=tds[0].find("a", href=True)
        if not a: continue
        href=a["href"]
        if "no-longer-updated" in href or not href.startswith("/x86/"): continue
        mnem=tds[0].get_text(" ",strip=True); summ=tds[-1].get_text(" ",strip=True)
        url="https://www.felixcloutier.com"+href
        key=(cat,url,mnem)
        if key in seen: continue
        seen.add(key)
        disp=f"[{cat}] {mnem}" + (f" — {summ}" if summ else "")
        rows.append(f"{disp}\t{url}")
sys.stdout.write("\n".join(rows)+"\n")
sys.stderr.write(f"index rows: {len(rows)}\n")
PY
cat /tmp/fc_idx.err >&2
idxrows=$(wc -l < "$OUT/index.tsv")

ok=0; fail=0; n=0
: > /tmp/fc_built.list
# unique URLs only (several mnemonics map to one page)
cut -f2 "$OUT/index.tsv" | awk 'NF' | sort -u > /tmp/fc_urls.txt
total=$(wc -l < /tmp/fc_urls.txt)
echo "==> $total unique pages to fetch"
while IFS= read -r url; do
  [ -z "$url" ] && continue; n=$((n+1))
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  html=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null)
  [ -z "$html" ] && { echo "FAIL fetch $url" >&2; fail=$((fail+1)); continue; }
  body=$(printf '%s' "$html" \
    | python3 "$FCT" 2>/dev/null \
    | python3 "$WE" content body "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null)
  [ "$(printf '%s' "$body" | wc -c)" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  printf '%s' "$body" > "$cf"
  echo "$cf" >> /tmp/fc_built.list
  ok=$((ok+1))
  [ $((n % 100)) -eq 0 ] && printf '  [%d/%d]\n' "$n" "$total"
  sleep 0.25
done < /tmp/fc_urls.txt

echo "==> compacting tables in $ok cached pages"
# compact_tables.py rewrites files in place; feed it the built list in batches.
xargs -a /tmp/fc_built.list -n 200 python3 "$CT" >/dev/null 2>&1 || true
echo "==> x86 insns: $ok/$total pages ok, $fail failed, index rows: $idxrows"
