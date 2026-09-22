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
# book_fix: an optional per-slug repair stage for code listings whose source
# text layer is baked-in OCR damage (see $FIXAWK below). It is a plain `cat` for
# every book that sets no $FIXAWK, so the other 31 books are untouched.
# mutool_furniture: strip Engineering a Compiler's page header (mutool -F txt
# emits one page per form feed). Each page opens with a running head and a bare
# folio, in either order: recto "<N.M> <Section>" then the folio, verso the folio
# then "CHAPTER <N> <Title>" (appendices use "APPENDIX <A> <Title>"). They are the
# only furniture and sit at the very top, so drop a line only while still in the
# first two non-empty lines of a page AND it looks like a folio (a bare arabic or
# roman numeral) or one of those running heads. The first real content line ends
# the scan, so nothing below the header is ever touched. Plain cat unless a slug
# turns it on via $EXTRACT.
mutool_furniture() {
  if [ "$EXTRACT" != mutool ]; then cat; return; fi
  # $CHTITLE (set in emit) is the section being written; front matter and the
  # preface number their pages in roman and carry camel-cased running heads that
  # mutool's reading order drops mid-flow rather than at the page top, so those
  # two files get an extra, file-scoped drop of a bare roman folio / a known
  # running-head word anywhere in the file. Every file also drops the Elsevier
  # per-chapter-opening footer (a DOI line, the copyright line, and the bare
  # folio that trails them), which mutool linearises into the body mid-sentence.
  awk -v ch="$CHTITLE" '
    BEGIN { RS="\f"; ORS=""; fm = (ch=="Front Matter" || ch=="Preface") }
    {
      n=split($0, L, "\n"); seen=0
      for (i=1;i<=n;i++) {
        line=L[i]; t=line; gsub(/^[ \t]+|[ \t]+$/,"",t)
        if (t=="") { print line "\n"; continue }
        # Elsevier opening-page footer, anywhere it linearised to:
        if (t ~ /^Engineering a Compiler\. https:\/\/doi\.org\//) { drop_folio=1; continue }
        if (t ~ /^Copyright .* Elsevier Inc\. All rights reserved\.$/) { drop_folio=1; continue }
        if (drop_folio && t ~ /^[0-9]+$/) { drop_folio=0; continue }
        drop_folio=0
        # page-top running head + folio (either order):
        if (seen<2 && (t ~ /^[0-9]+$/ || t ~ /^[ivxlcdm]+$/ \
            || t ~ /^CHAPTER [0-9]+ / || t ~ /^APPENDIX [A-Z] / \
            || t ~ /^[0-9]+\.[0-9]+ [A-Za-z]/)) { seen++; continue }
        # front-matter/preface: camel-cased running head or a bare roman folio
        # that leaked into the body (never content in those two files):
        if (fm && (t ~ /^[ivxlcdm]+$/ || t=="Preface" || t=="ChapterNotes" \
            || t=="Contents" || t=="Acknowledgments")) { continue }
        seen=2; print line "\n"
      }
      print "\f"
    }'
}
book_fix() {
  # chtitle carries the current chapter/appendix running-head string (its title
  # with the "N " / "Appendix X " prefix stripped); only amd_apm_fix.awk reads it,
  # every other per-slug fix ignores the extra -v.
  if [ -n "$FIXAWK" ] && [ -f "$FIXAWK" ]; then awk -v chtitle="$CHTITLE" -f "$FIXAWK"; else cat; fi
}
# pre_fix runs on the RAW pdftotext output, before the control-byte tr, for a
# book whose defect is font bytes with no ToUnicode map (see $SSAFIX). Plain
# cat unless $SSAFIX is set, so every other book is untouched.
pre_fix() {
  if [ -n "$SSAFIX" ] && [ -f "$SSAFIX" ]; then awk -f "$SSAFIX"; else cat; fi
}
# caption_fix: pdftotext -layout preserves each line's absolute x-position, so a
# figure/listing/table caption that is centred (or set in a page column) in the
# source lands with a wide, page-position-dependent run of leading spaces
# ("                    Listing 1.102: GCC 4.8.1"). Prose and code already sit at
# the left margin, so these floating captions are the one visible formatting
# inconsistency. Left-align them. The trigger is deliberately narrow to protect
# prose: the line, once trimmed, must OPEN with "Listing|Figure|Table|Algorithm|
# Example <number>:" - a figure number followed by a COLON. That colon is what
# separates a real caption from an inline reference that merely begins a wrapped
# line. Captions come in two punctuations - "Listing 1.102: GCC 4.8.1" (colon)
# and "Table 4. Instruction interface signals" (dot) - so after the figure
# number an optional ":" or "." may appear, then the TITLE. The title must start
# with an upper-case letter, a digit or "(": that is what tells a caption from an
# inline reference that opens a wrapped line, because a reference continues in
# lower case ("Table 5.3 shows the sections", "Table 2-19 summarizes ..."). Body
# text and code never open this way, so every other line passes through unchanged.
caption_fix() {
  awk '{ t=$0; sub(/^[ \t]+/,"",t)
         if (t ~ /^(Listing|Figure|Table|Algorithm|Example) [0-9][-0-9A-Za-z.,\/]*[:.]?[ ]+[A-Z0-9(]/) print t
         else print $0 }'
}
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
  # The AMD64 APM prints the current chapter/appendix title as a running footer
  # ("<Title> ... <page>"); CHTITLE is that title (the emit title minus its
  # "N " or "Appendix X " number prefix) so amd_apm_fix.awk can drop the footer
  # that folio.awk misses in the manual's short sections. Empty / ignored for
  # every other book.
  CHTITLE=$(printf '%s' "$3" | sed -E 's/^[0-9]+ //; s/^Appendix [A-Z] //')
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
  # A few books (Engineering a Compiler) set their mathematical notation - angle
  # brackets, the not-equal sign, epsilon, arrows - in subsetted math fonts that
  # carry no ToUnicode map AND reuse the same byte code for different glyphs
  # across fonts (byte 0x02 is angbracketleft in one font, epsilon in another),
  # so pdftotext emits a raw control byte the pipeline can only turn into "?" and
  # no byte->glyph map can be right. mutool resolves each glyph through its own
  # font's /Differences, so for those books we extract with mutool instead and
  # strip the running head/folio with mutool_furniture (folio.awk keys on the
  # -layout column positions mutool does not emit). $EXTRACT selects it per slug.
  if [ "$EXTRACT" = mutool ]; then
    mutool draw -F txt -o - "$PDF" "$1-$2" 2>/dev/null \
      | mutool_furniture \
      | book_fix \
      | caption_fix \
      | cat -s > "$OUT/$n $f.txt"
    return
  fi
  pdftotext -layout -f "$1" -l "$2" "$PDF" - 2>/dev/null \
    | pre_fix \
    | sed "$CTLX$CTL" | tr '\000-\010\013\015-\037' '[?*]' | sed "$LIG" \
    | awk -v book="$MODE" -v furn="$FURN" -v keys="$OUT/.folio.keys" -v first_page="$1" -f "$AWKF" \
    | cut_anchor "$4" "$5" \
    | book_fix \
    | caption_fix \
    | cat -s > "$OUT/$n $f.txt"
}
# Book mode ($4=book): pick chapter/part/appendix boundaries from the outline by
# TITLE pattern at any depth (the printed TOC), so chapters nested under Parts
# are kept (top-level-only dropped them). Strip a "[Trial version]"/bracket tag
# some PDF tools stamp on every bookmark. Spec PDFs (C/C++/DWARF/ABI/... which
# have bare numbered clauses, no Chapter/Part) keep the depth heuristic below.
SLUG=$(basename "$OUT")
# Per-slug page furniture: a whole line, repeated on every page, that carries no
# content and that the shared filter above does not catch. Keyed by slug below
# (FURN), each pattern validated against its own book to match only running
# heads and never a body line.
CTLX=
case "$SLUG" in
  # Memory Consistency Primer: byte 0x16 is the mu of "μhb"/"μspec" (CCICheck),
  # only ever mid-line; without this the tr turns it into a stray "?".
  a-primer-on-memory-consistency-and-cache-coherence)
    CTLX="s/$(printf '\026')/μ/g
" ;;
  # Hacker's Delight sets a few math signs in a font with no ToUnicode map, so
  # pdftotext emits a raw control byte the tr below would turn into "?": 0x10 is
  # the minus sign (14x, "base -2", "-1/0"), 0x05 the universal quantifier and
  # 0x07 the existential (in the predicate formulas). Map them to the real glyphs
  # while they are still distinct. (0x02 is a one-off on the Safari ad page and
  # is left to the tr.)
  hackers-delight)
    CTLX="s/$(printf '\020')/−/g
s/$(printf '\005')/∀/g
s/$(printf '\007')/∃/g
" ;;
esac
FURN=
case "$SLUG" in
  learn-programming-with-ocaml) FURN='^([0-9]+ +(Chapter [0-9]+[.].*|BIBLIOGRAPHY|INDEX)|[0-9]+[.][0-9]+[.] .+ [0-9]+|(BIBLIOGRAPHY|INDEX) +[0-9]+)$' ;;
  # Books whose per-page running head is "<section-number> <Title>  <folio>"
  # (section head on one edge, folio right-aligned) and which folio.awk's learn
  # pass does not attest (its folio does not march in a simple offset, or the head
  # lands mid-column under -layout). The pattern is deliberately narrow: a
  # dotted-decimal section number, a Title with NO period in it (so a table-of
  # -contents dot-leader "9.9 X ... 132" and any prose sentence are excluded), then
  # at least three spaces (the right-aligned folio gap, never an inline number) and
  # a trailing page number. Validated per book to match only running heads.
  computer-organization-and-design|\
  modern-processor-design|mastering-stm32)
    FURN='^[0-9]+[.][0-9]+[.]?[ ]+[A-Z][^.]*[ ][ ][ ]+[0-9]{1,4}[ ]*$' ;;
  # GC Handbook: same section-head form, plus the Taylor & Francis blank-page
  # production stamp that leaks at some chapter ends (a standalone line; the
  # acknowledgments sentence that names the publisher wraps and never matches ^$).
  the-garbage-collection-handbook)
    FURN='^([0-9]+[.][0-9]+[.]?[ ]+[A-Z][^.]*[ ][ ][ ]+[0-9]{1,4}|Taylor & Francis( Group)?)[ ]*$' ;;
  # H&P separates its running head from the folio with a box-drawing bullet (the
  # same U+25A0 it uses as a list marker at line START). Its folios are arabic OR
  # letter-dashed ("D-45"). Verso: "<folio> ■ Appendix X / Chapter N <title>";
  # recto: "<N.N|X.N> <title> ■ <folio>". Both require the ■ to be preceded by a
  # folio/section number, so a "■ text" list item (■ at line start) never matches.
  computer-architecture-a-quantitative-approach)
    FURN='^ *([0-9]{1,4}|[A-M]-[0-9]+) +■ +(Appendix [A-M]|Chapter [0-9]+)|^ *([0-9]+[.][0-9]+|[A-M][.][0-9]+) .* +■ +([0-9]{1,4}|[A-M]-[0-9]+) *$' ;;
esac
# Per-slug code-listing repair (book_fix above): one awk filter per book that
# needs it, kept next to pdf_build.sh and resolved from folio.awk's directory
# ($AWKF is already located above); a no-op for every other book.
FIXAWK=
case "$SLUG" in
  # OpenGL SuperBible: long C/C++/GLSL statements are hard-wrapped in the PDF's
  # own narrow code frame. superbible_fix.awk rejoins a continuation line only
  # when the pending line is syntactically incomplete (ends in a binary
  # operator/opener, or a comma inside unclosed brackets); author breaks pass.
  opengl-superbible) FIXAWK="${AWKF%/*}/superbible_fix.awk" ;;
  # ELF spec: folio.awk's page-edge vote strips the even-page running footers but
  # leaves the odd-page ones (the two footer forms alternate: a page number then
  # the Book title, or an all-caps section title then the page number).
  # elf_fix.awk drops both forms symmetrically; it is anchored on the "N-M" page
  # tag and the all-caps title so it never touches a body line or a TOC entry.
  elf-specification) FIXAWK="${AWKF%/*}/elf_fix.awk" ;;
  # Retrocomputing with Clash: folio.awk leaves 145 running heads (verso
  # "<folio> Chapter N <title>", recto "<n.m> <section> <folio>"); retroclash_fix
  # drops both, page-top only, keeping TOC dot-leaders. Every match is the first
  # non-blank line of its page, so no body/code line is touched.
  retrocomputing-with-clash) FIXAWK="${AWKF%/*}/retroclash_fix.awk" ;;
  # Memory Consistency Primer: 174 running heads folio.awk misses (even
  # "<folio> <n>. TITLE", odd "<n.m>. TITLE <folio>"), all-caps-title keyed.
  a-primer-on-memory-consistency-and-cache-coherence) FIXAWK="${AWKF%/*}/primer_fix.awk" ;;
  # RISC-V specs (ISA manual + SBI/AIA/IOMMU/... the whole books-riscv set): the
  # asciidoc toolchain prints a "<Section Title> | Page <N>" footer on every
  # page; folio.awk strips only bare page numbers, so ~800 survive. riscv_fix
  # drops the footer lines (body-safe: only a footer ends in "| Page N").
  riscv-* | the-risc-v-instruction-set-manual) FIXAWK="${AWKF%/*}/riscv_fix.awk" ;;
  # Fluent Python: O'Reilly running head "<section> | <page>" / "<page> |
  # <chapter>" on every body page, using section headings folio.awk's outline
  # list does not know, so ~260 survive mid-listing. fluent_python_fix drops the
  # bar-and-bare-page-number line (body-safe: prose/Python never look like that).
  fluent-python) FIXAWK="${AWKF%/*}/fluent_python_fix.awk" ;;
  # SAT/SMT by Example: Yurichev's listings package prints a wrapped code line
  # with a continuation hook whose font glyph ToUnicode-maps to U+00C7 (Ç), so
  # every wrapped listing line opens with a spurious "Ç ". satsmt_fix remaps the
  # leading "Ç " to the conventional hook "↪ " (588 lines, Ç is never a real
  # letter in this book), pairing it with the ⤦ that ends the line above.
  sat-smt-by-example) FIXAWK="${AWKF%/*}/satsmt_fix.awk" ;;
  # AMD64 APM (both volumes): the running footer "<chapter title> ... <page>"
  # (and its even-page mirror "<page> ... <chapter title>") leaks in the
  # manual's short sections, where folio.awk has too few pages to key its
  # running-head vote. amd_apm_fix drops it, keyed on the exact chapter/appendix
  # title passed in via $CHTITLE, so it can never touch a body or table line.
  amd-apm-vol1 | amd-apm-vol2) FIXAWK="${AWKF%/*}/amd_apm_fix.awk" ;;
  hackers-delight) FIXAWK="${AWKF%/*}/hackers_delight_fix.awk" ;;
esac
# Per-slug text extractor. "mutool" routes emit() through mutool draw -F txt +
# mutool_furniture instead of pdftotext -layout, for books whose math notation is
# in ToUnicode-less, font-code-reusing math fonts (see mutool_furniture).
EXTRACT=
case "$SLUG" in
  *) ;; # none at the moment (was engineering-a-compiler)
esac
# pre_fix (SSAFIX): a per-slug filter on the RAW pdftotext output, BEFORE the
# control-byte tr, for a book whose math fonts carry no ToUnicode map (the tr
# would turn the raw font bytes into "?" for good). No-op unless set.
SSAFIX=
case "$SLUG" in
  *) ;; # none at the moment (was ssa-based-compiler-design -> ssa_fix.awk)
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
if [ "$4" = book ] && [ "$SLUG" = elf-specification ]; then
  # The ELF spec's outline repeats "1. Object Files" under each of Books I, II
  # and III, so the outline/depth split produces three indistinguishable
  # chapters. Its real divisions are the Books' numbered sections; name them with
  # a Book prefix so every title is distinct. Each Book's own Contents / List of
  # Figures pages fold into that Book's first chapter, and the front matter and
  # Index bracket the three Books. Boundaries are the printed page starts.
  { printf '1\tFront Matter\n'
    printf '9\tBook I: Object Files\n'
    printf '39\tBook I: Program Loading and Dynamic Linking\n'
    printf '45\tBook I: Reserved Names\n'
    printf '49\tBook II: Object Files (Intel Architecture)\n'
    printf '59\tBook III: Object Files\n'
    printf '71\tBook III: Program Loading and Dynamic Linking\n'
    printf '89\tBook III: Intel Architecture and System V R4 Dependencies\n'
    printf '103\tIndex\n'; } > "$OUT/.ch.tsv"
elif [ "$4" = book ] && [ "$SLUG" = a-primer-on-memory-consistency-and-cache-coherence ]; then
  # The depth-0 fallback breaks here: the outline nodes are not in page order and
  # a stray "Blank Page" bookmark (page 2) would swallow the whole body. Take the
  # depth-0 nodes, drop "Blank Page", and sort by page; front matter is
  # auto-emitted before the first boundary.
  awk -F'\t' '$1==0 && $3!="Blank Page"{t=$3; sub(/^[ \t]+/,"",t); sub(/[ \t]+$/,"",t); print $2"\t"t}' "$OUT/.all.tsv" \
    | sort -t"$(printf '\t')" -k1,1n -s > "$OUT/.ch.tsv"
elif [ "$4" = book ] && { [ "$SLUG" = amd-apm-vol1 ] || [ "$SLUG" = amd-apm-vol2 ]; }; then
  # AMD64 APM (FrameMaker PDFs): the depth-0 outline nodes are the front matter
  # (Contents/Figures/Tables/Revision History), the Preface, the numbered
  # chapters, the lettered appendices (vol 2) and the Index. Two vol-1 chapters
  # are titled "5 64-Bit Media Programming" and "6 x87 Floating-Point
  # Programming" - a digit / a lowercase letter right after the chapter number -
  # which the generic book pattern (^N <Capital>) misses, so it folded 5 and 6
  # into chapter 4. Take the boundaries straight from the depth-0 outline
  # instead. Vol 2's outline opens with three cover-page nodes that all resolve
  # to page 1 (the title block); drop page <= 1 so they do not each become a
  # chapter. Contents..Revision History are dropped as boundaries so they fold
  # into the auto-emitted Front Matter (the first real boundary is the Preface),
  # matching every other book in this library. Dedupe by page in case two nodes
  # resolve to the same page.
  awk -F'\t' '$1==0 {
        t=$3; sub(/^[ \t]+/,"",t); sub(/[ \t]+$/,"",t); lt=tolower(t)
        if ($2+0 <= 1) next
        if (lt ~ /^(contents|figures|tables|revision history)$/) next
        print $2"\t"t
      }' "$OUT/.all.tsv" | sort -t"$(printf '\t')" -k1,1n -s \
    | awk -F'\t' '$1!=lastp{print} {lastp=$1}' > "$OUT/.ch.tsv"
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
elif [ "$4" = book ] && [ "$SLUG" = computer-architecture-a-quantitative-approach ]; then
  # H&P 6e's outline is broken: Appendix I is absent, L/M are mis-placed, and the
  # References nodes are out of order, so the generic split truncated appendices J
  # and M mid-section and leaked the next appendix's contents page into each one.
  # Each chapter/appendix opens on a page whose first line is the bare number/
  # letter then the title; those verified opener pages are the boundaries here.
  # Front matter (pages 1-18) is auto-emitted before the first boundary.
  # Each chapter/appendix opens with a mini-contents page (e.g. p32 lists "1.1
  # Introduction, 1.2 ..."), THEN the numbered title page. Start each boundary at
  # that mini-contents page (opener - 1) so the section list travels with its own
  # chapter instead of leaking onto the end of the previous one. Front matter
  # (cover, the whole-book Contents, and the Preface, pages 1-31) is auto-emitted
  # as one chapter before the first boundary.
  { printf '32\t1 Fundamentals of Quantitative Design and Analysis\n'
    printf '108\t2 Memory Hierarchy Design\n'
    printf '198\t3 Instruction-Level Parallelism and Its Exploitation\n'
    printf '312\t4 Data-Level Parallelism in Vector, SIMD, and GPU Architectures\n'
    printf '398\t5 Thread-Level Parallelism\n'
    printf '496\t6 Warehouse-Scale Computers to Exploit Request-Level and Data-Level Parallelism\n'
    printf '570\t7 Domain-Specific Architectures\n'
    printf '650\tA Instruction Set Principles\n'
    printf '706\tB Review of Memory Hierarchy\n'
    printf '774\tC Pipelining: Basic and Intermediate Concepts\n'
    printf '853\tD Storage Systems\n'
    printf '921\tE Embedded Systems\n'
    printf '948\tF Interconnection Networks\n'
    printf '1067\tG Vector Processors in More Depth\n'
    printf '1102\tH Hardware and Software for VLIW and EPIC\n'
    printf '1147\tI Large-Scale Multiprocessors and Scientific Applications\n'
    printf '1195\tJ Computer Arithmetic\n'
    printf '1269\tK Survey of Instruction Set Architectures\n'
    printf '1345\tL Advanced Concepts on Address Translation\n'
    printf '1347\tM Historical Perspectives and References\n'
    printf '1441\tReferences\n'
    printf '1477\tIndex\n'; } > "$OUT/.ch.tsv"
elif [ "$4" = book ] && [ "$SLUG" = embedded-systems-arm-cortex-m-zhu ]; then
  # Chapters are titled "ChN: Title" (abbreviated), which the generic book
  # pattern (Chapter/Part/Appendix at line start) misses, so it folded all 24
  # into the front matter and split only on the "Appendix X:" nodes. The depth-0
  # outline nodes are exactly the chapters, appendices, Bibliography and Index in
  # page order; take them straight. Front matter (before Ch1) folds into the
  # auto-emitted first block, like every other book.
  awk -F'\t' '$1==0 {t=$3; sub(/^[ \t]+/,"",t); sub(/[ \t]+$/,"",t); print $2"\t"t}' "$OUT/.all.tsv" \
    | sort -t"$(printf '\t')" -k1,1n -s > "$OUT/.ch.tsv"
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
# SMBIOS (DMTF DSP0134): a spec whose PDF bookmark tree is FLAT - depth 0 mixes
# the seven real clauses ("1 Scope" .. "7 Structure definitions") with the whole
# page-1 metadata block, every abbreviation from clause 4 (AC, ACPI, AGP, ...)
# and every "Table N - ..." from clause 7, all as siblings. The generic depth
# heuristic below would take all ~300 of them and produce a wall of one-line
# abbreviation/table "chapters" plus duplicate page-1 front matter. Keep only the
# real boundaries: the numbered clauses, the informative ANNEXes and the
# Bibliography. Front matter (pages before clause 1) is auto-emitted as usual.
# Guarded on the slug and on spec mode, so no other document is affected.
if [ "$4" != book ] && [ "$SLUG" = smbios ]; then
  awk -F'\t' '$1==0 {
      t=$3; sub(/^[ \t]+/,"",t); sub(/[ \t]+$/,"",t)
      if (t ~ /^[0-9]+ / || t ~ /^ANNEX [A-Z]/ || t=="Bibliography") print $2"\t"t
    }' "$OUT/.all.tsv" | sort -t"$(printf '\t')" -k1,1n -s \
    | awk -F'\t' '$1!=lastp{print} {lastp=$1}' > "$OUT/.ch.tsv"
fi
# Fallback / spec mode: split at the shallowest outline depth with >= 5 entries.
# Trim the title the way the book branch above already does: some outlines pad
# every entry with a trailing space, which would end up in the file name as
# "003 Introduction .txt".
if [ ! -s "$OUT/.ch.tsv" ]; then
  D=$(awk -F'\t' '{c[$1]++} END{for(d=0;d<8;d++) if(c[d]>=5){print d; exit}}' "$OUT/.all.tsv")
  [ -n "$D" ] && awk -F'\t' -v D="$D" '$1==D{t=$3; sub(/^[ \t]+/,"",t); sub(/[ \t]+$/,"",t); print $2"\t"t}' "$OUT/.all.tsv" > "$OUT/.ch.tsv"
fi
# Far-side bound for the last chapter. It is normally the last page of the PDF,
# but a scan can carry pages after the book ends.
END_PAGE="$TOTAL"
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
