#!/usr/bin/env bash
# Freeze Emmanuel Goossaert's "Coding for SSDs" 6-part series (codecapsule.com)
# into the :Docs frozen web-book layout used by the "Coding for SSDs" picker:
#   Resources/docs/coding-for-ssds/index.tsv     "<title>\t<url>" in part order
#   Resources/docs/.webcache/<sha256(url)>.txt     the rendered part
#
# Each part is one chapter; the post body is div.post-content (comments excluded).
# Usage: coding_for_ssds_build.sh   (needs curl, python3+bs4+lxml, pandoc)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/coding-for-ssds"
B="http://codecapsule.com/2014/02/12"
mkdir -p "$OUT" "$CACHE"

ROWS=$(cat <<'TOC'
Part 1: Introduction and Table of Contents	coding-for-ssds-part-1-introduction-and-table-of-contents
Part 2: Architecture of an SSD and Benchmarking	coding-for-ssds-part-2-architecture-of-an-ssd-and-benchmarking
Part 3: Pages, Blocks, and the Flash Translation Layer	coding-for-ssds-part-3-pages-blocks-and-the-flash-translation-layer
Part 4: Advanced Functionalities and Internal Parallelism	coding-for-ssds-part-4-advanced-functionalities-and-internal-parallelism
Part 5: Access Patterns and System Optimizations	coding-for-ssds-part-5-access-patterns-and-system-optimizations
Part 6: A Summary - What every programmer should know about SSDs	coding-for-ssds-part-6-a-summary-what-every-programmer-should-know-about-solid-state-drives
TOC
)

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r title slug; do
  [ -z "$slug" ] && continue
  url="$B/$slug/"
  body=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null \
    | python3 "$WE" content div.post-content "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null)
  if [ "$(printf '%s' "$body" | wc -c)" -lt 200 ]; then
    echo "FAIL $url" >&2; fail=$((fail+1)); continue
  fi
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  { printf '# %s\n\n' "$title"; printf '%s\n' "$body"; } > "$cf"
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.3
done <<< "$ROWS"
echo "==> Coding for SSDs: $ok parts, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
