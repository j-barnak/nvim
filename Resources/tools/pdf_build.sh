set -e
# MODE is optional: the PDF spec providers pass only three arguments.
PDF="$1"; OUT="$2"; URL="$3"; MODE="${4:-}"
# Refuse an empty or root-ish out-dir: the cleanup below globs outside the
# quotes, so "" or "/" would expand to "rm -f /*.txt". Normalise first, so
# "///", "/.", "/.." and a trailing slash cannot slip through, then require at
# least two real path components.
OUTN=$(printf %s "$OUT" | sed 's#//*#/#g; s#/*$##')
if [ "$(printf %s "${OUTN#/}" | tr / '\n' | grep -vc '^\.\{0,2\}$')" -lt 2 ]; then
  echo "pdf_build: refusing out-dir '$OUT'" >&2; exit 1
fi
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
# A pipeline hides its failures from set -e, so a missing pdfinfo or an
# unreadable PDF would otherwise surface as arithmetic errors much later.
[ -n "$TOTAL" ] || { echo "pdf_build: pdfinfo gave no page count for $PDF" >&2; exit 1; }
idx=0; prev_p=""; prev_t=""
# Some PDFs (LaTeX-set ones such as The Algorithm Design Manual) carry the
# ff/fi/fl/ffi/ffl ligatures as the single code points U+FB00 to U+FB04, which
# pdftotext passes through, so a search for "file" or "buffer" misses them.
# Map just those five to plain letters (the NFKC form of each); written as
# UTF-8 byte sequences so the sed works in any locale.
LIG="s/$(printf '\357\254\200')/ff/g; s/$(printf '\357\254\201')/fi/g; s/$(printf '\357\254\202')/fl/g; s/$(printf '\357\254\203')/ffi/g; s/$(printf '\357\254\204')/ffl/g"
emit() {
  idx=$((idx+1)); n=$(printf '%03d' "$idx")
  # Chapter file name: full title, cut at a word boundary near 140 chars (the
  # old hard cut -c1-80 chopped 11 Beautiful C++ guideline titles mid-word).
  f=$(printf '%s' "$3" | tr '/' '-' | awk '{ if (length($0) > 140) { s = substr($0, 1, 140); sub(/ [^ ]*$/, "", s); print s } else print }')
  # Line filter: strip the bracket tag some PDF tools stamp on bookmarks, drop
  # lines that are only a page number (an isolated digit line after a blank),
  # converter banners, and (book mode) two more pieces of page furniture that
  # are whole lines on their own: the "Page N" footer of CHM-converted books
  # (Unix Network Programming) and the print edition's "Click here to view
  # code image" link line (OpenGL SuperBible, Beautiful C++). $FURN adds the
  # per-book banner a few PDFs stamp on every single page (see below); it is
  # empty for every other book, so nothing else changes. Control characters
  # are mapped to "?" as before.
  pdftotext -layout -f "$1" -l "$2" "$PDF" - 2>/dev/null \
    | sed 's/\f//g' | tr '\000-\010\013-\037' '[?*]' | sed "$LIG" \
    | awk -v book="$MODE" -v furn="$FURN" '{o=$0; gsub(/\[Trial version\]/,""); t=$0; gsub(/^[ \t]+|[ \t]+$/,"",t); pb=prevblank; prevblank=(t=="")} o!=$0 && t==""{next} book!="book" && t ~ /^ISO\/IEC [0-9]/{next} book!="book" && t ~ /^© ISO\/IEC/{next} t ~ /^[0-9]{1,4}$/ && pb{next} t ~ /ABC Amber|Team LiB|processtext\.com/{next} book=="book" && t ~ /^Page [0-9]+$/{next} book=="book" && t=="Click here to view code image"{next} furn!="" && t ~ furn{next} {print}' \
    | cat -s > "$OUT/$n $f.txt"
}
# Book mode ($4=book): pick chapter/part/appendix boundaries from the outline by
# TITLE pattern at any depth (the printed TOC), so chapters nested under Parts
# are kept (top-level-only dropped them). Strip a "[Trial version]"/bracket tag
# some PDF tools stamp on every bookmark. Spec PDFs (C/C++/DWARF/ABI/... which
# have bare numbered clauses, no Chapter/Part) keep the depth heuristic below.
SLUG=$(basename "$OUT")
# Per-slug page furniture: a whole line, repeated on every page, that carries no
# content. Two books need it and no other book has one, so it is keyed by slug
# rather than added to the shared filter above.
#   c-concurrency-in-action: a distributor watermark on all 592 pages.
#   talking-compilers-with-chatgpt: a two-line licence/contact notice at the top
#   of all 916 pages (its first page words the second line differently).
#   disarming-code: the running head of a scanned book, on 497 of its 545 pages.
#   Even pages carry "<printed page number>   Disarming Code" and odd pages
#   "Chapter N: Title   <printed page number>" (or "Appendix A: ..."), and the
#   OCR sprinkles stray spaces through both, so the pattern tolerates a space
#   after any letter of the two fixed words and a space or a question mark
#   inside the page number ("11 2", "3?4"). Requiring the title to start with a
#   capital, a digit or a colon keeps body lines such as "Appendix B of this
#   work provides ." out of it.
FURN=
case "$SLUG" in
  c-concurrency-in-action) FURN='^https://avxhm\.se/' ;;
  talking-compilers-with-chatgpt) FURN='^(This material is freely available|For typos or suggestions, please contact Fernando|Send comments, typos and suggestions to)' ;;
  disarming-code) FURN='^([0-9?][0-9? ]{0,4} +D ?i ?s ?a ?r ?m ?i ?n ?g +C ?o ?d ?e$|(C ?h ?a ?p ?t ?e ?r|A ?p ?p ?e ?n ?d ?i ?x) ?[0-9AB]{1,2} ?([:.] ?[A-Za-z0-9/]|[A-Z0-9/]).{0,100}$)' ;;
esac
if [ "$4" = book ] && { [ "$SLUG" = talking-compilers-with-chatgpt ] || [ "$SLUG" = introduction-to-static-analysis ] || [ "$SLUG" = is-parallel-programming-hard ]; }; then
  # Three books whose printed table of contents is exactly the outline's depth-0
  # nodes, so they leave .ch.tsv unwritten and let the depth fallback split there.
  #   talking-compilers-with-chatgpt: these lecture notes are transcribed ChatGPT
  #   sessions, and every numbered item of every answer ("1. Front-End (Language
  #   Independence)") is bookmarked, so the title patterns below matched 240 of
  #   them and shredded the book. Its 25 chapters are the depth-0 nodes (plus the
  #   title and contents pages).
  #   introduction-to-static-analysis and is-parallel-programming-hard: both
  #   number their appendices as a bare letter and a title ("A Reference for
  #   Mathematical Notions", "E Answers to Quick Quizzes"), which no title
  #   pattern below can tell from an ordinary section, so the appendices ended up
  #   inside the last numbered chapter. Their depth-0 nodes are the chapters, the
  #   appendices and the end matter, in printed order.
  :
elif [ "$4" = book ] && [ "$SLUG" = operating-systems-three-easy-pieces ]; then
  # OSTEP's chapters are topic-titled (no Chapter N / number / Part keyword), so
  # no title pattern can find them; the split follows the outline's shape.
  # Depth-0 nodes are the preface pieces, the two opening chapters and the
  # three Parts. A Part is a depth-0 node whose subtree reaches depth 2 (its
  # depth-1 children are chapters, which have depth-2 sections); chapter 2's
  # depth-1 children are its own sections and stay inside the chapter (taking
  # every depth-1 node exploded that chapter into ten files cut mid-page).
  # The six preface bookmarks all resolve to the Preface's first page (broken
  # anchors) and Contents / List of Figures have no bookmark at all, so the
  # front-matter sections are found by the heading printed at the top of the
  # page, and outline entries landing inside that front matter are treated as
  # its subsection bookmarks. Chapters are numbered 1..51 (the dialogues are
  # numbered chapters in this book) and parts I..III as on the contents page;
  # the index sections at the end stay unnumbered.
  FP=$(awk -F'\t' '$1==0{tp=$2} $1>=2{print tp; exit}' "$OUT/.all.tsv")
  pdftotext -layout -f 1 -l $((FP-1)) "$PDF" - 2>/dev/null \
    | awk 'BEGIN{RS="\f"} { n=split($0,L,"\n"); h=""; for(i=1;i<=n;i++){ h=L[i]; gsub(/^[ \t]+|[ \t]+$/,"",h); if(h!="") break } if (h ~ /^(Preface|Contents|List of Figures)$/) print NR"\t"h }' \
    > "$OUT/.fm.tsv"
  FML=$(tail -1 "$OUT/.fm.tsv" | cut -f1)
  { cat "$OUT/.fm.tsv"; awk -F'\t' -v fml="${FML:-0}" '
      { d[NR]=$1; p[NR]=$2; t[NR]=$3 }
      END {
        for (i=1;i<=NR;i++) { if (d[i]==0) top=i; else if (d[i]>=2) part[top]=1 }
        split("I II III IV V", R, " "); n=0; np=0
        for (i=1;i<=NR;i++) {
          if (d[i]==0) top=i
          if (p[i] <= fml) continue
          if (d[i]==0 && part[i]) { np++; print p[i]"\tPart "R[np]": "t[i]; continue }
          if (d[i]==0 || (d[i]==1 && part[top])) {
            if (tolower(t[i]) ~ /^(general index|index|asides|tips|cruces)$/) print p[i]"\t"t[i]
            else { n++; print p[i]"\t"n". "t[i] }
          }
        }
      }' "$OUT/.all.tsv"; } | sort -t"$(printf '\t')" -k1,1n -s > "$OUT/.ch.tsv"
  rm -f "$OUT/.fm.tsv"
elif [ "$4" = book ] && [ "$SLUG" = programming-with-posix-threads ]; then
  # This PDF is a Word conversion and carries no outline at all, so the only
  # structure left is the printed page text. Each of chapters 1 to 9 opens with
  # its heading as the first line of its page ("1    Introduction": the number,
  # a run of spaces, then the title), and the Preface opens the same way, so a
  # page whose first line has that shape starts a chapter. Chapter 10 is the one
  # exception: it starts halfway down page 188, where the heading is the tail of
  # a body line, and it is picked up by a line ending in a chapter number and a
  # short capitalised title. That second pattern matches exactly one line in the
  # whole 202-page book, so nothing else is cut; chapter 10's file does open
  # with the last few entries of the mini-reference that share its page.
  pdftotext -layout "$PDF" - 2>/dev/null \
    | awk 'BEGIN{RS="\f"}
      {
        n=split($0,L,"\n"); h=""
        for(i=1;i<=n;i++){ h=L[i]; gsub(/^[ \t]+|[ \t]+$/,"",h); if(h!="") break }
        if (h ~ /^[0-9]{1,2}[ \t]{2,}[^ \t]/) { num=h; sub(/[ \t].*$/,"",num); ttl=h; sub(/^[0-9]+[ \t]+/,"",ttl); print NR"\t"num". "ttl }
        else if (h ~ /^Preface[ \t]*$/) { print NR"\tPreface" }
        else { for(i=1;i<=n;i++) if (L[i] ~ /(^|[.] )[0-9]{1,2} [A-Z][a-z]+([ ][a-z]+){0,3}[ \t]*$/) { s=L[i]; sub(/^.*[.] /,"",s); gsub(/^[ \t]+|[ \t]+$/,"",s); num=s; sub(/[ \t].*$/,"",num); ttl=s; sub(/^[0-9]+[ \t]+/,"",ttl); print NR"\t"num". "ttl; break } }
      }' > "$OUT/.ch.tsv"
elif [ "$4" = book ] && [ "$SLUG" = disarming-code ]; then
  # A 545-page scan whose text layer is Acrobat Paper Capture OCR. It has no
  # outline, and no reliable heading shape either (the display titles are set as
  # artwork and come back mangled), so the boundaries below are the printed
  # table of contents, written out here because there is nothing in the file to
  # derive them from. Every page in the map was checked against the scan: a
  # chapter opens on a page whose first line is the bare printed page number,
  # with the chapter title on the next line, and all sixteen land on such a
  # page. The closing note that follows appendix B carries no printed heading,
  # so it stays at the end of appendix B rather than becoming its own chapter.
  cat > "$OUT/.ch.tsv" <<'EOF3'
17	1. An ARM Assembly Primer
75	2. Compilation & Linking
99	3. Binary Formats
141	4. The Process Lifecycle
167	5. Memory - I - The System View
191	6. Memory - II - The Process View
249	7. MultiThreading
285	8. I/O & IPC
329	9. Profiling
359	10. Hooking & Injecting
387	11. Runtimes
423	12. Post Mortem
445	13. Beyond User Mode
491	14. Reverse Engineering
521	A. disarm(j) - The Missing Manual Page
535	B. jtrace(j) - The Missing Manual Page
EOF3
elif [ "$4" = book ]; then
  # Match on a lowercased copy so No Starch's "APPENDIX: ..." / "GLOSSARY" count;
  # accept letter-numbered appendices ("A. The One-Definition Rule") once a
  # chapter has been seen, at outline depth <= 1 (deeper lettered items are
  # sub-sections). A bare "Introduction" is a chapter only at depth 0 or as a
  # direct child of a Part; nested deeper it is a section (the Preface's
  # "Introduction" subsection in Unix Network Programming split the preface
  # body off into its own file and left a stub Preface).
  awk -F'\t' '
    { t=$3; sub(/^[ \t]+/,"",t); sub(/^\[[A-Za-z0-9 ._-]*\][ \t]*/,"",t); sub(/[ \t]+$/,"",t); lt=tolower(t); ty=0 }
    $1 == 0 { partop = (lt ~ /^part [ivxlc0-9]/ || lt ~ /^section [0-9]+[ :.]/) }
    lt ~ /^part [ivxlc0-9]/ || lt ~ /^section [0-9]+[ :.]/ || lt ~ /^chapter [0-9]+.*[a-z]/ \
      || t ~ /^[0-9]+\. [^(]/ || t ~ /^[0-9]+ [A-Z]/ || lt ~ /^appendix[: ]/ { ty=1; seen=1 }
    seen && $1 <= 1 && lt ~ /^[a-h]\. [a-z]/ { ty=1 }
    lt ~ /^(preface|foreword|epilogue|afterword)([ .:]|$)/ { ty=1 }
    lt ~ /^introduction[ ]*$/ && ($1 == 0 || ($1 == 1 && partop)) { ty=1 }
    seen && lt ~ /^(bibliography|index|references|glossary)[ ]*$/ { ty=1 }
    ty { print $2"\t"t }
  ' "$OUT/.all.tsv" | sort -t"$(printf '\t')" -k1,1n -s \
    | awk -F'\t' '$1!=lastp{print} {lastp=$1}' > "$OUT/.ch.tsv"
  [ "$(wc -l < "$OUT/.ch.tsv")" -ge 5 ] || : > "$OUT/.ch.tsv"
fi
# Fallback / spec mode: split at the shallowest outline depth with >= 5 entries.
# Trim the title the way the book branch above already does: some outlines pad
# every entry with a trailing space, which would end up in the file name as
# "003 Introduction .txt".
if [ ! -s "$OUT/.ch.tsv" ]; then
  D=$(awk -F'\t' '{c[$1]++} END{for(d=0;d<8;d++) if(c[d]>=5){print d; exit}}' "$OUT/.all.tsv")
  [ -n "$D" ] && awk -F'\t' -v D="$D" '$1==D{t=$3; sub(/^[ \t]+/,"",t); sub(/[ \t]+$/,"",t); print $2"\t"t}' "$OUT/.all.tsv" > "$OUT/.ch.tsv"
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
