# tlpi_fix.awk - repair two furniture/glyph defects in The Linux Programming
# Interface (book_fix / $FIXAWK stage).
#
# 1. Bullet dingbat -> letter 'z'. The book's itemized-list bullet is a dingbat
#    font glyph with no Unicode map, so pdftotext emits the raw font byte for the
#    letter 'z'; every bulleted item opens with a standalone "z" followed by the
#    list indent. 1,827 of them across 71 of 74 files. A leading standalone "z"
#    (line start, only whitespace before it, two or more spaces after it) is
#    ALWAYS this bullet - no English sentence starts with a bare "z  " token, so
#    the substitution has zero false positives. Map it back to a real bullet.
#
# 2. Even-page footer leak. folio.awk's vote leaves 9 even-page footers of the
#    form "<page>   Chapter N" / "<page>   Appendix X"; the anchored shape never
#    occurs in a list or code line, so drop the whole line.
#
# The odd-page footers (a letter-spaced chapter/section title then a page number,
# e.g. "M e m or y A l l oc a t io n   145", ~28 of them) are deliberately NOT
# touched: every safe automated match either eats figure/diagram rows ("fd 1
# 86", "0  39  70") or the front-matter TOC's own letter-spaced part titles, so
# they are left as a documented cosmetic residual (all in prose, none in code).
#
# Line-drop / single-glyph substitution only; nothing else is rewritten.

/^[ \t]*[0-9]{1,4}[ \t]{2,}(Chapter [0-9]+|Appendix [A-F])[ \t]*$/ { next }
{ if ($0 ~ /^[ \t]*z[ \t][ \t]+/) sub(/z/, "•"); print }
