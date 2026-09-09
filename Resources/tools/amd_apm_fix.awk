# amd_apm_fix.awk - drop the AMD64 APM running footer (book_fix / $FIXAWK stage).
# Every body page of the AMD64 Architecture Programmer's Manual prints the
# current chapter/appendix title as a footer, alternating left/right by parity:
#   odd  page: "<Chapter Title>                         <printed page number>"
#   even page: "<printed page number>                         <Chapter Title>"
# folio.awk strips these across the long chapters (its running-head vote has the
# pages it needs), but the manual's short sections - the front matter, the five
# appendices, the index - have too few pages for the vote, so dozens of footers
# survive there, several landing mid-table.
#
# The footer text is ALWAYS the exact running-head string of the section being
# emitted, handed in as $CHTITLE (the chapter/appendix title with its "N " or
# "Appendix X " number prefix already stripped). The front matter file spans the
# Contents/Figures/Tables/Revision History pages, whose footers carry those four
# fixed titles, so they are added to the set as well. Forms A and B drop a line
# only when its whitespace-collapsed form is EXACTLY "<title> <page>" or "<page>
# <title>" for one of those titles - a full, exact title match with nothing but
# a page number beside it. The page number is arabic in the body and a lowercase
# roman numeral in the front matter (i, ix, xv, lxiii, ...). No body sentence,
# register table row or bit-field diagram is ever exactly a chapter title plus a
# bare number, so forms A/B cannot touch content anywhere.
#
# Form C drops a line that is JUST a page folio (a bare roman/arabic numeral on
# its own line), which the front matter also carries. It is gated to the front
# matter and preface only (where the folios are roman and standalone numerals are
# never content), so a lone "x", "i" or "v" table cell / loop index in a body
# chapter is never removed. Body-safe, line-drop only.
BEGIN {
  n = split("Contents\nFigures\nTables\nRevision History", FM, "\n")
  for (i = 1; i <= n; i++) T[FM[i]] = 1
  if (chtitle != "") T[chtitle] = 1
  frontmatter = (chtitle == "Front Matter" || chtitle == "Preface")
}
# a page number: 1-4 arabic digits, or a lowercase roman numeral
function isnum(s) { return (s ~ /^[0-9][0-9]?[0-9]?[0-9]?$/ || s ~ /^[ivxlc]+$/) }
{
  c = $0; gsub(/[ \t]+/, " ", c); sub(/^ /, "", c); sub(/ $/, "", c)
  # form A: "<title> <page>"
  if (c ~ / [0-9ivxlc]+$/) { t = c; sub(/ [0-9ivxlc]+$/, "", t); p = c; sub(/^.* /, "", p); if (isnum(p) && (t in T)) next }
  # form B: "<page> <title>"
  if (c ~ /^[0-9ivxlc]+ /) { t = c; sub(/^[0-9ivxlc]+ /, "", t); p = c; sub(/ .*$/, "", p); if (isnum(p) && (t in T)) next }
  # form C: standalone folio, front matter / preface only. ROMAN only: the front
  # matter numbers its pages in roman (i, ix, xv, lxiii), so a bare roman numeral
  # on its own line is a folio, but a bare ARABIC number there is content (a
  # revision-history year like 2022, a "see page 706" cross-reference) and is kept.
  if (frontmatter && c ~ /^[ivxlc]+$/) next
  print
}
