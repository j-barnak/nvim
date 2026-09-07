# essentials_fix.awk - remove the running heads folio.awk leaves in the short
# sections of Essentials of Compilation (book_fix / $FIXAWK stage).
#
# folio.awk's page vote needs >= 4 dense pages, so it strips every running head
# in the long chapters but leaks 11 in the four short sections (ch6 = 8pp, the
# 2-page Appendix, References, Index). Two head shapes:
#   even page:  "<folio>   <Chapter N | Appendix A | References | Index>"
#   odd  page:  "<section title>   <folio>"
#
# Gotcha this guards: the odd head "References   211" / "Index   217" is shape-
# identical to the front-matter TABLE OF CONTENTS entries "References   209" /
# "Index   217". book_fix runs per chapter and Front Matter is itself a chapter,
# so a stateless rule would delete those TOC lines. Instead buffer the whole
# chapter and fire the References/Index odd-form rule ONLY inside that section's
# own chapter (its first non-blank line equals the word), so the TOC survives.
# The even form and ch6's unique title are collision-free and dropped always.
# Line-drop only; nothing merged or rewritten.

{ buf[NR] = $0 }
END {
  first = ""
  for (i = 1; i <= NR; i++) { t = buf[i]; gsub(/^[ \t]+|[ \t]+$/, "", t); if (t != "") { first = t; break } }
  refchap = (first == "References"); idxchap = (first == "Index")
  for (i = 1; i <= NR; i++) {
    line = buf[i]; t = line; gsub(/^[ \t]+|[ \t]+$/, "", t)
    if (t ~ /^[0-9][0-9]?[0-9]?[ \t][ \t]+(Chapter [0-9]+|Appendix A|References|Index)$/) continue
    if (t ~ /^Loops and Dataflow Analysis[ \t][ \t]+[0-9][0-9]?[0-9]?$/) continue
    if (refchap && t ~ /^References[ \t][ \t]+[0-9][0-9]?[0-9]?$/) continue
    if (idxchap && t ~ /^Index[ \t][ \t]+[0-9][0-9]?[0-9]?$/) continue
    print line
  }
}
