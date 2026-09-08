# fluent_python_fix.awk - drop the O'Reilly running head Fluent Python prints on
# every body page. Odd pages carry "<section title>   |   <page number>" and
# even pages "<page number>   |   <chapter/part title>", right/left justified by
# pdftotext -layout so they land mid-listing and mid-paragraph. folio.awk keys a
# running head to the book's OUTLINE titles, but these heads use the current
# SECTION heading (e.g. "A Pythonic Card Deck", "The super() Function"), which is
# not an outline node, so 260-odd of them survive.
#
# The head is always its OWN line: a single vertical bar with TWO OR MORE spaces
# on each side, a bare page number on one side, and no other bar on the line.
# Body prose and Python never look like that - "a | b" and set/dict unions use
# single spaces, and a pdftotext table row keeps its leading "|" and multiple
# bars - so this is body-safe. Line-drop only.
/^[ \t]*[^|]*[^| \t][ \t][ \t]+\|[ \t][ \t]+[0-9]+[ \t]*$/ { next }
/^[ \t]*[0-9]+[ \t][ \t]+\|[ \t][ \t]+[^|]*[^| \t][ \t]*$/ { next }
{ print }
