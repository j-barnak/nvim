# satsmt_fix.awk - repair the code line-continuation marker in SAT/SMT by Example
# (book_fix / $FIXAWK stage). Yurichev sets the book with the LaTeX listings
# package and breaklines on: a wrapped code line prints the pre-break glyph U+2936
# (⤦) at the end and a matching hook at the start of the continuation line. The
# continuation hook is a font glyph whose ToUnicode maps it to U+00C7 (Ç), so
# pdftotext emits a spurious "Ç " at the head of every wrapped listing line.
#
# Ç occurs in this book ONLY as that marker: 588 of them, and every one is the
# first non-space character of its line, opening a code continuation (SMT-LIB, C,
# Python). The book has no French words or names, so no Ç is ever a real letter
# and none appears mid-line. Remap the leading "Ç " to the conventional
# continuation hook "↪ ", keeping the indentation, so the wrapped line pairs with
# the ⤦ that ends the line above it. Anchored to the leading position, so a body
# line could never be touched even if a stray Ç appeared elsewhere.
{ if ($0 ~ /^[ \t]*Ç /) sub(/Ç /, "↪ "); print }
