# hackers_delight_fix.awk - drop Hacker's Delight's running head (book_fix stage).
# Recto pages print "<N-M> <SECTION TITLE> <folio>", verso pages "<folio>
# <CHAPTER TITLE> <N-M>", where N-M is the chapter-section number set with an
# en-dash (U+2013, e.g. "2-1 MANIPULATING RIGHTMOST BITS 13" / "14 BASICS 2-1").
# folio.awk misses them: the section titles are not outline nodes and the N-M
# shape is unusual. The en-dash section number appears ONLY in these heads and
# the title is all-caps (body text never is), so keying on the en-dash number at
# one end, an all-caps title, and a bare folio at the other end is body-safe.
# Line-drop only.
/^[0-9]+–[0-9]+ [A-Z][-A-Z0-9 ,.'’()]* [0-9]+$/ { next }
/^[0-9]+ [A-Z][-A-Z0-9 ,.'’()]* [0-9]+–[0-9]+$/ { next }
{ print }
