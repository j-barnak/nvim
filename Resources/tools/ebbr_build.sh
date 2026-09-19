#!/usr/bin/env bash
# Freeze the EBBR (Embedded Base Boot Requirements) specification into the :Docs
# frozen web-book layout used by the "EBBR" picker:
#   Resources/docs/ebbr/index.tsv           "<title>\t<url#section>" in spec order
#   Resources/docs/.webcache/<sha256(url)>.txt   the rendered section
#
# EBBR is a single-page Sphinx document; each top-level <section> (About / UEFI /
# Privileged or Secure Firmware / Firmware Storage / EFI Variable file format /
# Bibliography) is one chapter. The cache key is sha256 of the page URL plus the
# section's "#anchor", so every section gets its own cache file. Source:
# https://arm-software.github.io/ebbr/
# Usage: ebbr_build.sh   (needs curl, python3+bs4+lxml, pandoc)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/ebbr"
URL="https://arm-software.github.io/ebbr/"
mkdir -p "$OUT" "$CACHE"

echo "==> fetching EBBR"
curl -fsSL --compressed --max-time 60 "$URL" -o /tmp/ebbr.html

# Emit "title<TAB>anchor-id" for each top-level section, in document order.
python3 - > /tmp/ebbr_secs.tsv 2>/tmp/ebbr.err <<'PY'
import sys, re
from bs4 import BeautifulSoup
h = open('/tmp/ebbr.html', encoding='utf-8', errors='replace').read()
soup = BeautifulSoup(h, "lxml")
main = soup.find("div", attrs={"role": "main"}) or soup.find("div", class_="body") or soup
# The h1 wraps the whole doc; its direct child <section>s are the chapters.
top = None
h1 = main.find("h1")
if h1:
    top = h1.find_parent("section") or h1.find_parent("div", class_="section")
scope = top or main
rows = []
for sec in scope.find_all(["section"], recursive=True):
    hd = sec.find(["h2"], recursive=False)
    if not hd:
        # some themes nest the heading one level down
        hd = sec.find(["h2"])
        if hd is None or hd.find_parent("section") is not sec:
            continue
    sid = sec.get("id") or ""
    if not sid:
        continue
    title = hd.get_text(" ", strip=True).rstrip("¶").strip()
    title = re.sub(r"^\s*\d+\.\s*", "", title).strip()  # drop the "2." section number prefix
    rows.append(f"{title}\t{sid}")
sys.stdout.write("\n".join(rows) + "\n")
sys.stderr.write(f"sections: {len(rows)}\n")
PY
cat /tmp/ebbr.err >&2

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r title sid; do
  [ -z "$sid" ] && continue
  securl="$URL#$sid"
  body=$(python3 "$WE" content "section#$sid" "$URL" sphinx,abs < /tmp/ebbr.html 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null)
  if [ "$(printf '%s' "$body" | wc -c)" -lt 40 ]; then
    echo "FAIL empty section#$sid" >&2; fail=$((fail+1)); continue
  fi
  cf="$CACHE/$(printf '%s' "$securl" | sha256sum | awk '{print $1}').txt"
  { printf '# %s\n\n' "$title"; printf '%s\n' "$body"; } > "$cf"
  printf '%s\t%s\n' "$title" "$securl" >> "$OUT/index.tsv"; ok=$((ok+1))
done < /tmp/ebbr_secs.tsv
echo "==> EBBR: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
