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
rm -f "$OUT"/*.txt "$OUT"/.complete "$OUT"/.folio.keys "$OUT"/.titles
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
idx=0; prev_p=""; prev_t=""; prev_a=""
# Some PDFs (LaTeX-set ones such as The Algorithm Design Manual) carry the
# ff/fi/fl/ffi/ffl ligatures as the single code points U+FB00 to U+FB04, which
# pdftotext passes through, so a search for "file" or "buffer" misses them.
# Map just those five to plain letters (the NFKC form of each); written as
# UTF-8 byte sequences so the sed works in any locale.
LIG="s/$(printf '\357\254\200')/ff/g; s/$(printf '\357\254\201')/fi/g; s/$(printf '\357\254\202')/fl/g; s/$(printf '\357\254\203')/ffi/g; s/$(printf '\357\254\204')/ffl/g"
# Control bytes. pdftotext writes the raw byte when a font's glyph has no
# Unicode mapping, and the `tr` in the pipeline below turns every one of them
# into "?", which then FUSES to the next word: "?Target Audience", "? ummary",
# "?Negative (sign) flag".
# The fix is positional, not a blanket remap, because the same byte means
# different things in different books. A control byte that OPENS a line (only
# whitespace or the page's form feed before it) is always a decoration - an
# Apress heading dingbat, a bullet - so blank it to a space, keeping the column
# so -layout alignment is untouched. A control byte in the MIDDLE of a line is
# left alone on purpose: in the LaTeX-set books those are real mathematics
# (0x06 is the "!=" sign in The Algorithm Design Manual, 0x04 is "!=" in
# SSA-based Compiler Design, 0x08 is a floor bracket in Algorithm Design), and
# blanking them would silently turn "n1 != n2" into "n1  = n2", which is worse
# than a visible "?". $CTLX below adds the one mid-line exception, per book.
CC=$(printf '\001\002\003\004\005\006\007\010\013\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037')
CTL=":a
s/^\([ $(printf '\t\014')]*\)[$CC]/\1 /
ta"
# The line filter itself lives in folio.awk next to this script, because it is a
# two-pass page-aware program and no longer fits on one line. Locating it is
# awkward on purpose: docs.lua reads THIS FILE'S TEXT and runs it under
# `sh -c "<text>" pdf ...`, so at runtime $0 is the literal tag "pdf" and there
# is no script path to work from. Try $0's directory when $0 really is a path,
# then the committed tools directory under the nvim config root (the same
# stdpath("config")/Resources/tools that docs.lua read this file from), and fail
# loudly rather than quietly building books with no folio filter at all.
AWKF=
case "$0" in
  */*) [ -f "${0%/*}/folio.awk" ] && AWKF="${0%/*}/folio.awk" ;;
esac
if [ -z "$AWKF" ]; then
  C="${XDG_CONFIG_HOME:-$HOME/.config}/${NVIM_APPNAME:-nvim}/Resources/tools/folio.awk"
  [ -f "$C" ] && AWKF="$C"
fi
if [ -z "$AWKF" ]; then
  echo "pdf_build: folio.awk not found next to pdf_build.sh" >&2; exit 1
fi
# cut_anchor: the one piece of LINE granularity in an otherwise page-granular
# builder. $1 is the text of the printed heading this chapter opens on and $2
# the text of the next chapter's heading; either may be empty. It reads the
# filtered page range on stdin and passes through only the lines from the first
# occurrence of $1 up to (not including) the first later occurrence of $2,
# comparing on the trimmed, whitespace-collapsed line so a centred or indented
# heading keys the same as a flush-left one.
# Only a caller that puts a third (anchor) column in .ch.tsv reaches the awk;
# with no anchors this is a plain `cat` and the page range is emitted exactly as
# before, which is why the other 31 books rebuild byte for byte.
# It runs AFTER folio.awk on purpose: folio.awk judges a line by its position on
# its physical page, so it must see whole pages. Cutting afterwards cannot change
# any of its verdicts, and matching on text rather than a line number means the
# lines it removed do not shift the anchor.
cut_anchor() {
  if [ -z "$1" ] && [ -z "$2" ]; then cat; return; fi
  awk -v s="$1" -v e="$2" '
    function sq(x){ gsub(/[ \t]+/, " ", x); sub(/^ /, "", x); sub(/ $/, "", x); return x }
    BEGIN { on = (s == "") }
    { t = sq($0)
      if (!on) { if (t == s) on = 1; else next }
      else if (e != "" && t == e) exit
      print }'
}
# emit <first page> <last page> <title> [start anchor] [end anchor]
emit() {
  idx=$((idx+1)); n=$(printf '%03d' "$idx")
  # Chapter file name: full title, cut at a word boundary near 140 chars (the
  # old hard cut -c1-80 chopped 11 Beautiful C++ guideline titles mid-word).
  f=$(printf '%s' "$3" | tr '/' '-' | awk '{ if (length($0) > 140) { s = substr($0, 1, 140); sub(/ [^ ]*$/, "", s); print s } else print }')
  # Line filter (folio.awk): strip the bracket tag some PDF tools stamp on
  # bookmarks, drop page folios, converter banners, and (book mode) two more
  # pieces of page furniture that are whole lines on their own: the "Page N"
  # footer of CHM-converted books (Unix Network Programming) and the print
  # edition's "Click here to view code image" link line (OpenGL SuperBible,
  # Beautiful C++). $FURN adds the per-book banner a few PDFs stamp on every
  # single page (see below); it is empty for every other book, so nothing else
  # changes. Control characters are mapped to "?" as before -- except the form
  # feed (\014), which is now KEPT through the tr so folio.awk can see where
  # each physical page starts, and is stripped there instead.
  # A folio is only dropped when it sits at the top or bottom of its physical
  # page AND its value tracks the printed page-number sequence, so first_page
  # must be the real PDF page this range opens on, and the offsets it is checked
  # against come from the whole-book learn pass below ($OUT/.folio.keys). The
  # same file carries the book's running-head keys, which folio.awk applies to
  # the edge blocks of each physical page; $FURN survives for the four books
  # whose furniture is not a running head at all (a watermark, a licence notice,
  # an OCR-mangled head that no page-position rule can key).
  pdftotext -layout -f "$1" -l "$2" "$PDF" - 2>/dev/null \
    | sed "$CTLX$CTL" | tr '\000-\010\013\015-\037' '[?*]' | sed "$LIG" \
    | awk -v book="$MODE" -v furn="$FURN" -v keys="$OUT/.folio.keys" -v first_page="$1" -f "$AWKF" \
    | cut_anchor "$4" "$5" \
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
#   disarming-code: the running head of a scanned book, on 499 of its 545 pages.
#   Even pages carry "<printed page number>   Disarming Code" and odd pages
#   "Chapter N: Title   <printed page number>" (or "Appendix A: ..."), and the
#   OCR sprinkles stray spaces through both, so the pattern tolerates a space
#   after any letter of the two fixed words and a space or a question mark
#   inside the page number ("11 2", "3?4"). Requiring the title to start with a
#   capital, a digit or a colon keeps body lines such as "Appendix B of this
#   work provides ." out of it. The tail allows 200 characters rather than 100
#   because the OCR leaves a very wide gap before the page number on two heads
#   (page 207's "Chapter 6: ..." and page 415's "Chapter 11 : ..."), which were
#   the only two the shorter bound missed; 200 matches those two and not one
#   line more anywhere in the book.
#   Its chapter opener pages carry no running head, only the bare printed page
#   number. That used to need a per-slug $LEADNUM switch, which turned the old
#   blank-line-triggered digit rule on for the first non-empty line of a chapter
#   file; it is gone, because folio.awk sees physical pages and an opener folio
#   is simply the top line of one.
#   learn-programming-with-ocaml: the running head of a LaTeX book, on 430 of
#   its 462 pages. Even pages carry "<printed page number>   Chapter N. Title"
#   (or BIBLIOGRAPHY / INDEX) and odd pages "N.M. Section Title   <printed page
#   number>". Every line the pattern matches in the whole book is the first
#   line of its page, and the pages it leaves alone are the ones that open a
#   part, a chapter or the end matter (those carry no running head).
# Per-slug mid-line control byte. Only two books have one that is unambiguous,
# and in both it is 0x08 heading a table-of-contents dot leader on every entry,
# so it renders as "Preface?xv" / "Who This Book is For?  3" - the second of
# which reads as a question the book never asks. Every 0x08 in these two books
# is that leader (199 of 199 and 121 of 121). It is NOT global because 0x08 is
# a floor bracket in The Algorithm Design Manual.
CTLX=
case "$SLUG" in
  modern-x86-assembly-language-programming|fuzzing-against-the-machine)
    CTLX="s/$(printf '\010')/ /g
" ;;
esac
FURN=
case "$SLUG" in
  c-concurrency-in-action) FURN='^https://avxhm\.se/' ;;
  talking-compilers-with-chatgpt) FURN='^(This material is freely available|For typos or suggestions, please contact Fernando|Send comments, typos and suggestions to)' ;;
  disarming-code) FURN='^([0-9?][0-9? ]{0,4} +D ?i ?s ?a ?r ?m ?i ?n ?g +C ?o ?d ?e$|(C ?h ?a ?p ?t ?e ?r|A ?p ?p ?e ?n ?d ?i ?x) ?[0-9AB]{1,2} ?([:.] ?[A-Za-z0-9/]|[A-Z0-9/]).{0,200}$)' ;;
  learn-programming-with-ocaml) FURN='^([0-9]+ +(Chapter [0-9]+[.].*|BIBLIOGRAPHY|INDEX)|[0-9]+[.][0-9]+[.] .+ [0-9]+|(BIBLIOGRAPHY|INDEX) +[0-9]+)$' ;;
esac
# Furniture learn pass: read the WHOLE book once and record which page-number
# offsets its page ends attest, and which page-edge lines are running heads (see
# folio.awk). emit() then applies those keys per chapter, which a chapter could
# not derive for itself: a two-page Part divider or a short Bibliography has
# nowhere near the five pages the vote needs, and a running head has to be
# recognised against the whole book's page sequence and title list. $FURN must
# already be set, because a stripped watermark changes which line is the top or
# bottom of its page.
# The title list is the outline dump this script already took, plus the PDF's
# own Title, and is what lets a running head that carries no page number at all
# ("Chapter 4 <U+25A0> AVX Programming", "Getting to know .git") be recognised as a
# repeat of one of the book's OWN headings rather than by bare repetition.
{ cut -f3 "$OUT/.all.tsv"; pdfinfo "$PDF" 2>/dev/null | sed -n 's/^Title: *//p'; } > "$OUT/.titles"
pdftotext -layout "$PDF" - 2>/dev/null \
  | sed "$CTLX$CTL" | tr '\000-\010\013\015-\037' '[?*]' | sed "$LIG" \
  | awk -v book="$MODE" -v furn="$FURN" -v titles="$OUT/.titles" -v mode=learn -f "$AWKF" > "$OUT/.folio.keys"
# A book may legitimately attest no offsets (its folios are fused into a running
# head, so no line is ever a bare number), but reading no text at all means
# pdftotext failed and every folio would silently survive.
[ "$(awk '/^#lines /{print $2; exit}' "$OUT/.folio.keys")" -gt 0 ] 2>/dev/null \
  || { echo "pdf_build: folio learn pass read no text from $PDF" >&2; exit 1; }
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
elif [ "$4" = book ] && [ "$SLUG" = learn-programming-with-ocaml ]; then
  # Chapters are the outline's depth-1 nodes (the depth fallback further down
  # finds the same set), but this book's end matter cannot be taken from the
  # outline: its single "Index" bookmark resolves seven pages early, which cut
  # chapter 13 off in the middle of its exercises and swallowed the whole
  # bibliography, and the bibliography has no bookmark of its own. Take the
  # chapters from the outline and the two end-matter boundaries from the page
  # that prints the heading, searching only the pages after the last chapter
  # starts so a table-of-contents line cannot be mistaken for the heading.
  awk -F'\t' '$1==1 && tolower($3) !~ /^(index|bibliography)$/ { t=$3; sub(/^[ \t]+/,"",t); sub(/[ \t]+$/,"",t); print $2"\t"t }' "$OUT/.all.tsv" > "$OUT/.ch.tsv"
  LASTP=$(tail -1 "$OUT/.ch.tsv" | cut -f1)
  pdftotext -layout -f "${LASTP:-1}" "$PDF" - 2>/dev/null \
    | awk -v off="${LASTP:-1}" 'BEGIN{RS="\f"} { n=split($0,L,"\n"); h=""; for(i=1;i<=n;i++){ h=L[i]; gsub(/^[ \t]+|[ \t]+$/,"",h); if(h!="") break } if (h=="Bibliography" || h=="Index") print (NR+off-1)"\t"h }' \
    >> "$OUT/.ch.tsv"
  sort -t"$(printf '\t')" -k1,1n -s -o "$OUT/.ch.tsv" "$OUT/.ch.tsv"
elif [ "$4" = book ] && [ "$SLUG" = writing-a-bootloader-from-scratch-cmu-15-410 ]; then
  # A 20-page course handout with 12 sections, so most sections begin MID-PAGE
  # and a page-granular split cannot separate them: eleven of the twelve
  # chapters opened inside their predecessor ("Bootloader: Overview" opened at
  # "2.4 Real Mode Interrupts"), and sections 3 and 8 shared a page with their
  # neighbour on both sides, so they came out as empty files, were dropped, and
  # their bodies were left filed under the following section's title.
  # This is the one book split at LINE granularity: the boundary is the printed
  # section heading, and cut_anchor above does the cutting.
  # The headings are not TRUSTED, they are CONFIRMED. The expected set is the
  # PDF's own outline (its twelve depth-0 nodes, in order); a line starts a
  # chapter only when its collapsed text is exactly "<n> <that node's title>"
  # for the next n still wanted, so the sequence can only be consumed in order
  # and a heading-shaped body line cannot start a spurious chapter (page 11
  # prints "1 MB of memory. However, ..." flush left, which any "number then
  # title" regex would have taken). Every heading must be found and must land on
  # the page its own bookmark resolves to, or the map is abandoned and the
  # generic fallback below splits by outline page as before.
  # The title carries the printed section number ("1 Introduction"), which the
  # outline titles omit and which the file order otherwise disagrees with once
  # Front Matter takes 001. Front Matter is the three-line title block above
  # section 1 on page 1, and is written into the map here (rather than left to
  # the driver's first_p > 1 rule) because it does not start on a page of its
  # own; it is emitted only when some text really does precede the heading.
  awk -F'\t' '$1==0{t=$3; sub(/^[ \t]+/,"",t); sub(/[ \t]+$/,"",t); print $2"\t"t}' "$OUT/.all.tsv" > "$OUT/.d0.tsv"
  pdftotext -layout "$PDF" - 2>/dev/null | awk -v d0="$OUT/.d0.tsv" '
    function sq(x){ gsub(/[ \t]+/, " ", x); sub(/^ /, "", x); sub(/ $/, "", x); return x }
    BEGIN { N=0; while ((getline l < d0) > 0) { split(l, F, "\t"); N++; OP[N]=F[1]+0; OT[N]=F[2] } close(d0)
            want=1; page=1 }
    { line=$0; page += gsub(/\014/, "", line); t=sq(line)
      if (want <= N && t == want " " OT[want]) { HP[want]=page; HT[want]=t; if (page != OP[want]) bad=bad " " want; want++; next }
      if (want == 1 && t != "") pre=1 }
    END { if (want <= N) { printf "pdf_build: heading %d (%s) not found in the page text\n", want, OT[want] > "/dev/stderr"; exit 1 }
          if (bad != "") { print "pdf_build: heading(s)" bad " not on the page their bookmark resolves to" > "/dev/stderr"; exit 1 }
          if (pre) print HP[1] "\tFront Matter\t"
          for (i = 1; i <= N; i++) print HP[i] "\t" HT[i] "\t" HT[i] }' > "$OUT/.ch.tsv" \
    || : > "$OUT/.ch.tsv"
  rm -f "$OUT/.d0.tsv"
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
  # Every title below was re-checked against two independent places in the book
  # that name the chapter: the heading on its own opening page, and the running
  # head repeated on the rest of its pages ("Chapter N: Title"). Three titles
  # had been shortened to a topic word and are written out in full here: 9 was
  # "Profiling" and is "System-Wide Tracing, Profiling & Auditing" (the printed
  # contents page agrees), 11 was "Runtimes" and is "Runtimes & Higher-Level
  # Languages", and 12 was "Post Mortem" and is "Exceptions, Crashes & Other
  # Fatalities" (its opening page sets the same title as "Exceptions, Crashes
  # and other Fatalities"; the running head's title case is used, as it is what
  # the other fifteen entries follow). The appendix titles keep "disarm(j)" and
  # "jtrace(j)": the front matter explains that the author specifies all of his
  # own tools as living in manual section (j), so that is deliberate notation
  # and not OCR damage.
  cat > "$OUT/.ch.tsv" <<'EOF3'
17	1. An ARM Assembly Primer
75	2. Compilation & Linking
99	3. Binary Formats
141	4. The Process Lifecycle
167	5. Memory - I - The System View
191	6. Memory - II - The Process View
249	7. MultiThreading
285	8. I/O & IPC
329	9. System-Wide Tracing, Profiling & Auditing
359	10. Hooking & Injecting
387	11. Runtimes & Higher-Level Languages
423	12. Exceptions, Crashes & Other Fatalities
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
# Per-slug boundary correction, applied to whichever branch above wrote the map.
#   zero-to-production-in-rust: every chapter bookmark is a hyperref anchor set
#   before the \clearpage that ends the previous chapter, so it resolves to the
#   printed page number rather than the PDF page and lands one page early. All
#   eleven chapters opened with the last page of their predecessor ("Telemetry"
#   with chapter 3's "3.11 Summary", and so on), so shift them on by one page.
#   The Foreword and Preface anchors are on their own opening page already and
#   are left where they are.
#   The shipped chapters were rebuilt with this shift, so the book reads
#   correctly today only because the shift is here. Drop it and eleven of the
#   fourteen files open mid-sentence again ("004 Getting Started" would start
#   "had built reading The Rust Book ...", the tail of the Preface). Checking
#   the shipped files alone therefore proves nothing about whether the rule is
#   still needed; rebuild without it to see the seams break.
if [ "$4" = book ] && [ "$SLUG" = zero-to-production-in-rust ] && [ -s "$OUT/.ch.tsv" ]; then
  awk -F'\t' 'BEGIN{OFS="\t"} $2=="Foreword" || $2=="Preface" {print; next} {print $1+1, $2}' \
    "$OUT/.ch.tsv" > "$OUT/.ch.shift" && mv "$OUT/.ch.shift" "$OUT/.ch.tsv"
fi
# Far-side bound for the last chapter. It is normally the last page of the PDF,
# but a scan can carry pages after the book ends.
#   disarming-code: the scan runs to source page 545 and the book's body ends at
#   541. Pages 542-545 are the back-cover blurb and then the scanning service's
#   customer consent form, which carries a real person's name and a signature
#   line. That is not book content and must not ship, so appendix B stops at 541.
END_PAGE="$TOTAL"
if [ "$4" = book ] && [ "$SLUG" = disarming-code ]; then END_PAGE=541; fi
if [ -s "$OUT/.ch.tsv" ]; then
  # Pages before the first outline boundary (a preface, foreword, or an
  # unbookmarked introduction) used to be dropped entirely; emit them as a
  # Front Matter chapter so no text is lost.
  first_p=$(head -1 "$OUT/.ch.tsv" | cut -f1)
  [ "${first_p:-1}" -gt 1 ] && emit 1 $((first_p-1)) "Front Matter"
  # A map may carry a third column: the printed heading the chapter opens on
  # (see cut_anchor). Only the CMU bootloader handout writes one, and every
  # other map leaves the field empty, so `a` is empty, the range still ends at
  # the page BEFORE the next chapter's, and cut_anchor is a plain cat. When the
  # next chapter DOES have an anchor its heading is somewhere inside page $p, so
  # this chapter must be given that page too and let the anchor make the cut.
  while IFS="$(printf '\t')" read -r p t a; do
    if [ -n "$prev_p" ]; then
      if [ -n "$a" ]; then emit "$prev_p" "$p" "$prev_t" "$prev_a" "$a"
      else emit "$prev_p" $((p-1)) "$prev_t" "$prev_a" ""; fi
    fi
    prev_p="$p"; prev_t="$t"; prev_a="$a"
  done < "$OUT/.ch.tsv"
  [ -n "$prev_p" ] && emit "$prev_p" "$END_PAGE" "$prev_t" "$prev_a" ""
else
  p=1
  while [ "$p" -le "$TOTAL" ]; do e=$((p+39)); [ "$e" -gt "$TOTAL" ] && e="$TOTAL"; emit "$p" "$e" "pages $p-$e"; p=$((e+1)); done
fi
rm -f "$JS" "$OUT/.all.tsv" "$OUT/.ch.tsv" "$OUT/.folio.keys" "$OUT/.titles"
# Drop blank chapter files (cover / back-cover / title pages that are image-only
# in the PDF and text-extract to nothing) so they are not dead picker entries.
for t in "$OUT"/*.txt; do
  [ -e "$t" ] && [ "$(tr -d '[:space:]\f' < "$t" | wc -c)" -lt 3 ] && rm -f "$t"
done
touch "$OUT/.complete"
