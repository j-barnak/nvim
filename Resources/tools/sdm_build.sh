set -e
PDF="$1"; OUT="$2"; URL="$3"; PY="$4"
if [ ! -f "$PDF" ]; then
  mkdir -p "$(dirname "$PDF")"
  curl -fsSL "$URL" -o "$PDF"
fi
mkdir -p "$OUT"
# Clean slate; ".complete" is written only after the whole split succeeds, so a
# build killed midway is retried rather than treated as done (glob-of-*.txt is
# not kill-atomic). set -e aborts before the sentinel on any error.
rm -f "$OUT"/*.txt "$OUT"/.complete
JS="$OUT/.ol.js"
cat > "$JS" <<EOF2
var doc = Document.openDocument("$PDF");
function pageof(it){ try { var l = doc.resolveLink(it.uri); return (typeof l==="number")?l:(l&&l.page); } catch(e){ return -1; } }
function walk(items,d){ for(var i=0;i<items.length;i++){ var it=items[i]; print(d+"\t"+(pageof(it)+1)+"\t"+it.title.replace(/\s+/g," ")); if(it.down) walk(it.down,d+1); } }
walk(doc.loadOutline(),0);
EOF2
mutool run "$JS" > "$OUT/.all.tsv" 2>/dev/null
TOTAL=$(pdfinfo "$PDF" | awk '/^Pages:/{print $2}')
# Split at the shallowest outline depth with >= 5 entries (volumes differ).
D=$(awk -F'\t' '{c[$1]++} END{for(d=0;d<8;d++) if(c[d]>=5){print d; exit}}' "$OUT/.all.tsv")
idx=0; prev_p=""; prev_t=""
emit() {
  idx=$((idx+1)); n=$(printf '%03d' "$idx")
  f=$(printf '%s' "$3" | tr '/' '-' | cut -c1-80)
  hdr=$(printf '%s' "$3" | sed -E 's/^(Chapter|Appendix) [0-9A-Z]+ *//' | tr '[:lower:]' '[:upper:]')
  pdftotext -layout -f "$1" -l "$2" "$PDF" - 2>/dev/null \
    | sed 's/\f//g' \
    | awk -v h="$hdr" '{t=$0; gsub(/^[ \t]+|[ \t]+$/,"",t)} t ~ /^Vol\. [0-9A-D]+ +[0-9A-Z]+-[0-9]+$/{next} t ~ /^[0-9A-Z]+-[0-9]+ +Vol\. [0-9A-D]+$/{next} h!="" && toupper(t)==h{next} {print}' \
    | cat -s > "$OUT/$n $f.txt"
}
if [ -n "$D" ]; then
  awk -F'\t' -v D="$D" '$1==D{print $2"\t"$3}' "$OUT/.all.tsv" > "$OUT/.ch.tsv"
  while IFS="$(printf '\t')" read -r p t; do
    [ -n "$prev_p" ] && emit "$prev_p" $((p-1)) "$prev_t"
    prev_p="$p"; prev_t="$t"
  done < "$OUT/.ch.tsv"
  [ -n "$prev_p" ] && emit "$prev_p" "$TOTAL" "$prev_t"
else
  # No usable outline (e.g. Vol 4): fixed 40-page chunks.
  p=1
  while [ "$p" -le "$TOTAL" ]; do
    e=$((p+39)); [ "$e" -gt "$TOTAL" ] && e="$TOTAL"
    emit "$p" "$e" "pages $p-$e"
    p=$((e+1))
  done
fi
rm -f "$JS" "$OUT/.all.tsv" "$OUT/.ch.tsv"
# Extract figures as tight PNGs (diagrams are vector, so rasterize regions).
if [ -n "$PY" ] && command -v python3 >/dev/null 2>&1 \
   && command -v pdftoppm >/dev/null 2>&1 && command -v convert >/dev/null 2>&1; then
  python3 "$PY" "$PDF" "$OUT/figures" >/dev/null 2>&1 || true
fi
touch "$OUT/.complete"
