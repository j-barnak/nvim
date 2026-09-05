set -e
PDF="$1"; OUT="$2"; URL="$3"; MODE="$4"
if [ ! -f "$PDF" ]; then mkdir -p "$(dirname "$PDF")"; curl -fsSL "$URL" -o "$PDF"; fi
mkdir -p "$OUT"
# Clean slate; ".complete" (written only on full success) gates reuse, so a
# build killed midway is retried rather than treated as done.
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
idx=0; prev_p=""; prev_t=""
emit() {
  idx=$((idx+1)); n=$(printf '%03d' "$idx")
  # Chapter file name: full title, cut at a word boundary near 140 chars (the
  # old hard cut -c1-80 chopped 11 Beautiful C++ guideline titles mid-word).
  f=$(printf '%s' "$3" | tr '/' '-' | awk '{ if (length($0) > 140) { s = substr($0, 1, 140); sub(/ [^ ]*$/, "", s); print s } else print }')
  pdftotext -layout -f "$1" -l "$2" "$PDF" - 2>/dev/null \
    | sed 's/\f//g' | tr '\000-\010\013-\037' '[?*]' \
    | awk -v book="$MODE" '{o=$0; gsub(/\[Trial version\]/,""); t=$0; gsub(/^[ \t]+|[ \t]+$/,"",t); pb=prevblank; prevblank=(t=="")} o!=$0 && t==""{next} book!="book" && t ~ /^ISO\/IEC [0-9]/{next} book!="book" && t ~ /^© ISO\/IEC/{next} t ~ /^[0-9]{1,4}$/ && pb{next} t ~ /ABC Amber|Team LiB|processtext\.com/{next} {print}' \
    | cat -s > "$OUT/$n $f.txt"
}
# Book mode ($4=book): pick chapter/part/appendix boundaries from the outline by
# TITLE pattern at any depth (the printed TOC), so chapters nested under Parts
# are kept (top-level-only dropped them). Strip a "[Trial version]"/bracket tag
# some PDF tools stamp on every bookmark. Spec PDFs (C/C++/DWARF/ABI/... which
# have bare numbered clauses, no Chapter/Part) keep the depth heuristic below.
SLUG=$(basename "$OUT")
if [ "$4" = book ] && [ "$SLUG" = operating-systems-three-easy-pieces ]; then
  # OSTEP's chapters are topic-titled (no Chapter N / number / Part keyword), so
  # no title pattern can find them; its real chapters are the outline's depth-1
  # nodes. Take depth 0 too: the depth-0 dialogues/chapter headings are real
  # boundaries, and without them the text between a chapter heading and its
  # first subsection (e.g. Chapter 2's opening pages) was silently dropped.
  awk -F'\t' '$1<=1{print $2"\t"$3}' "$OUT/.all.tsv" > "$OUT/.ch.tsv"
elif [ "$4" = book ]; then
  # Match on a lowercased copy so No Starch's "APPENDIX: ..." / "GLOSSARY" count;
  # accept letter-numbered appendices ("A. The One-Definition Rule") once a
  # chapter has been seen, at outline depth <= 1 (deeper lettered items are
  # sub-sections).
  awk -F'\t' '
    { t=$3; sub(/^[ \t]+/,"",t); sub(/^\[[A-Za-z0-9 ._-]*\][ \t]*/,"",t); sub(/[ \t]+$/,"",t); lt=tolower(t); ty=0 }
    lt ~ /^part [ivxlc0-9]/ || lt ~ /^section [0-9]+[ :.]/ || lt ~ /^chapter [0-9]+.*[a-z]/ \
      || t ~ /^[0-9]+\. [^(]/ || t ~ /^[0-9]+ [A-Z]/ || lt ~ /^appendix[: ]/ { ty=1; seen=1 }
    seen && $1 <= 1 && lt ~ /^[a-h]\. [a-z]/ { ty=1 }
    lt ~ /^(preface|foreword|epilogue|afterword)([ .:]|$)/ || lt ~ /^introduction[ ]*$/ { ty=1 }
    seen && lt ~ /^(bibliography|index|references|glossary)[ ]*$/ { ty=1 }
    ty { print $2"\t"t }
  ' "$OUT/.all.tsv" | sort -t"$(printf '\t')" -k1,1n -s \
    | awk -F'\t' '$1!=lastp{print} {lastp=$1}' > "$OUT/.ch.tsv"
  [ "$(wc -l < "$OUT/.ch.tsv")" -ge 5 ] || : > "$OUT/.ch.tsv"
fi
# Fallback / spec mode: split at the shallowest outline depth with >= 5 entries.
if [ ! -s "$OUT/.ch.tsv" ]; then
  D=$(awk -F'\t' '{c[$1]++} END{for(d=0;d<8;d++) if(c[d]>=5){print d; exit}}' "$OUT/.all.tsv")
  [ -n "$D" ] && awk -F'\t' -v D="$D" '$1==D{print $2"\t"$3}' "$OUT/.all.tsv" > "$OUT/.ch.tsv"
fi
if [ -s "$OUT/.ch.tsv" ]; then
  # Pages before the first outline boundary (a preface, foreword, or an
  # unbookmarked introduction) used to be dropped entirely; emit them as a
  # Front Matter chapter so no text is lost.
  first_p=$(head -1 "$OUT/.ch.tsv" | cut -f1)
  [ "${first_p:-1}" -gt 1 ] && emit 1 $((first_p-1)) "Front Matter"
  while IFS="$(printf '\t')" read -r p t; do
    [ -n "$prev_p" ] && emit "$prev_p" $((p-1)) "$prev_t"
    prev_p="$p"; prev_t="$t"
  done < "$OUT/.ch.tsv"
  [ -n "$prev_p" ] && emit "$prev_p" "$TOTAL" "$prev_t"
else
  p=1
  while [ "$p" -le "$TOTAL" ]; do e=$((p+39)); [ "$e" -gt "$TOTAL" ] && e="$TOTAL"; emit "$p" "$e" "pages $p-$e"; p=$((e+1)); done
fi
rm -f "$JS" "$OUT/.all.tsv" "$OUT/.ch.tsv"
# Drop blank chapter files (cover / back-cover / title pages that are image-only
# in the PDF and text-extract to nothing) so they are not dead picker entries.
for t in "$OUT"/*.txt; do
  [ -e "$t" ] && [ "$(tr -d '[:space:]\f' < "$t" | wc -c)" -lt 3 ] && rm -f "$t"
done
touch "$OUT/.complete"
