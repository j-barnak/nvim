# riscv_fix.awk - drop the asciidoc running footer the RISC-V spec PDFs carry
# (book_fix / $FIXAWK stage). Every page prints a footer "<Section Title> | Page
# <N>" (or just "| Page <N>" on a titleless page); folio.awk strips only bare
# page numbers, so ~800 of these survive across the RISC-V manuals, several
# landing mid-listing/mid-table.
#
# The footer is always its OWN line and is the ONLY place a line ENDS in
# "| Page <number>". RISC-V content uses "|" freely but always mid-line - the
# bitwise-OR examples ("( a | b )", "(|) represents bitwise logical OR"), BNF
# alternatives ("| <number>") and instruction syntax ("l{b|h|w|d}") - never at
# end of line before a page number. So this is body-safe. Line-drop only.
/\| Page [0-9]+[ \t]*$/ { next }
{ print }
