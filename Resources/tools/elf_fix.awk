# elf_fix.awk - drop the ELF specification's running-footer furniture.
#
# The TIS ELF spec prints a running footer on every body page in two alternating
# forms:
#   odd/even A:  "<page>   Book I: ELF (Executable and Linking Format)"
#                (a "N-M" page tag, a run of spaces, then the Book's full title)
#   odd/even B:  "PROGRAM LOADING AND DYNAMIC LINKING            2-5"
#                (the section title in ALL CAPS, a run of spaces, a "N-M" page tag)
# folio.awk's page-edge vote removes one parity and leaves the other, so this
# filter drops both forms to normalize the frozen .txt. Each rule is anchored on
# the "N-M" page tag AND (form A) the literal "Book <roman>:" or (form B) an
# all-uppercase title, with two or more spaces between the two fields, so it
# matches only a running footer - never a body line, and never a table-of-
# contents entry (those carry dotted leaders and mixed-case titles).

# Form A: page tag, gap, "Book I/II/III:" then the book title.
/^[0-9A]+-[0-9]+[ \t]{2,}Book (I|II|III):[ \t]/ { next }

# Form B: an all-caps section title (letters, spaces, &), gap, page tag, EOL.
# The [A-Z] start and [A-Z &]+ body exclude mixed-case TOC lines, and the
# required "N-M$" tail excludes ordinary all-caps prose.
/^[A-Z][A-Z &]+[ \t]{2,}[0-9A]+-[0-9]+[ \t]*$/ { next }

{ print }
