# ssa_fix.awk -- recover the math glyphs that pdftotext cannot map in the
# digital PDF "SSA-based Compiler Design" (Rastello & Bouchez Tichadou,
# Springer 2022).
#
# WHY THIS EXISTS
#   The book is a normal digital LaTeX PDF (not a scan): pdftotext extracts its
#   prose and code correctly EXCEPT for two math glyphs whose subsetted fonts
#   carry no ToUnicode map, so pdftotext emits the raw font byte for them:
#
#     byte 0x02  glyph "triangleright" (font MSAM10, /Differences [2 /triangleright])
#                = the right-margin comment marker in the numbered algorithm
#                  listings.  Adobe Glyph List: triangleright -> U+22B3 (the->) .
#
#     byte 0x04  glyph "negationslash" (font MTSYN) = the combining "not" slash
#                that overlays the following relation.  In this book it only ever
#                negates four symbols:
#                    0x04 '='      -> U+2260  the!=      (not equal)
#                    0x04 U+2208   -> U+2209  the-notin  (not an element of)
#                    0x04 U+2203   -> U+2204  the-nexist (there does not exist)
#                    0x04 U+2287   -> U+2289  the-notsupseteq
#
#   pdf_build.sh runs `tr` over the extraction and turns every unmapped control
#   byte into a literal '?', which fuses these into "?=", "?the-in", a bare "?"
#   comment marker, etc.  Because the book also contains 73 genuine '?'
#   characters, the damage CANNOT be repaired after that `tr`: a post-tr '?' is
#   ambiguous.  So this filter runs on the RAW `pdftotext -layout` output,
#   BEFORE pdf_build.sh's control-byte `tr`, where 0x02 and 0x04 are still
#   distinct bytes and the fix is exact, not a guess.
#
#   A third defect is pure layout, not a byte: the not-member relation is
#   sometimes typeset as an ordinary U+2208 (in) with a SEPARATE '/' slash glyph,
#   and `pdftotext -layout` places that slash either right after the symbol
#   ("the-in/") or, when the slash sits a hair lower, on the NEXT physical line
#   ("... if Y the-in" / "        / Defs(v) then").  Both forms are the negated
#   membership U+2209 (notin); this filter rejoins the wrapped form and collapses
#   the inline form.  Exactly three '^\s*/ ' continuation lines and one inline
#   "the-in/" exist in the whole book, so the patterns are unambiguous.
#
# SCOPE / SAFETY
#   Only the two byte glyphs above and the not-member slash are touched.  Every
#   other unmapped control byte (0x03, 0x05..0x08, 0x0f, 0x18, ...) is left for
#   pdf_build.sh's `tr` to render as '?' exactly as before, because those stand
#   for other mathematics whose intended glyph is not certain from the byte
#   alone.  A trailing/standalone 0x04 with no relation after it (one 2-D math
#   artifact) is likewise left alone.  Genuine '?' text is never seen here.
#
# PIPELINE POSITION (in pdf_build.sh emit(), per-slug guard on this book):
#     pdftotext -layout -f P -l Q "$PDF" - | awk -f ssa_fix.awk | sed "$CTLX$CTL" | tr ...
#   i.e. immediately after pdftotext and before the control-byte sed/tr.  It is a
#   no-op for every other book (only the ssa-based-compiler-design slug wires it
#   in), so nothing else changes.

BEGIN {
  NEG = sprintf("%c", 4)   # negationslash
  TRI = sprintf("%c", 2)   # triangleright (algorithm comment marker)
  have = 0
}

function fixchars(s,   t) {
  t = s
  # comment marker 0x02 -> the-> (U+22B3)
  gsub(TRI, "\342\212\263", t)
  # negationslash 0x04 + relation -> negated relation
  gsub(NEG "=",             "\342\211\240", t)   # != U+2260
  gsub(NEG "\342\210\210",  "\342\210\211", t)   # notin U+2209 (from in U+2208)
  gsub(NEG "\342\212\207",  "\342\212\211", t)   # notsupseteq U+2289 (from U+2287)
  gsub(NEG " \342\210\203", "\342\210\204", t)   # nexists U+2204 (0x04 SPACE exists)
  gsub(NEG "\342\210\203",  "\342\210\204", t)   # nexists (adjacent, safety)
  # inline not-member typeset as U+2208 followed by a literal slash
  gsub("\342\210\210/",     "\342\210\211", t)   # in/ -> notin
  return t
}

{
  cur = fixchars($0)
  # Rejoin a not-member split across two physical lines by -layout:
  #   buffered line ends in U+2208 (in);  this line is "   / <rest>".
  if (have && buf ~ /\342\210\210[ \t]*$/ && cur ~ /^[ \t]*\/[ \t]/) {
    sub(/\342\210\210[ \t]*$/, "\342\210\211", buf)   # in -> notin
    rest = cur
    sub(/^[ \t]*\/[ \t]*/, "", rest)
    buf = buf " " rest
    print buf
    have = 0
    next
  }
  if (have) print buf
  buf = cur
  have = 1
}

END { if (have) print buf }
