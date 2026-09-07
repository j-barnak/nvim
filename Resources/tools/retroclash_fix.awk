# retroclash_fix.awk -- drop the running-head furniture that folio.awk leaves in
#   retrocomputing-with-clash  (Retrocomputing with Clash, Gergo Erdi, 2022).
#
# This LaTeX/pandoc PDF prints a running head on every body page in two
# alternating forms:
#   verso (even printed page):  "<folio>   Chapter <n>   <chapter title>"
#   recto (odd printed page):   "<n.m>   <section title>   <folio>"
# folio.awk removes the verso head only for the long chapters (its H2 title vote
# needs >= 4 dense even pages, so the short chapters keep it), and it never
# removes a recto head at all: each head carries its own section number, so a
# given stem ("2.3 Our first circuit #") runs on only the two or three pages of
# that section and never reaches the vote's page threshold. 145 heads survive.
#
# Both forms are ALWAYS the first non-blank line of their physical page: of 495
# lines matching these shapes across the whole book, every one is page-top and
# none is mid-page, so the exact shapes below never touch a body or code line.
# The builder runs this AFTER folio.awk, so it only sees the stragglers folio
# missed.
#
# NOT the table of contents: the printed TOC (front matter) uses the same
# "N.M Title ... folio" shape but carries a dot-leader run (" . . . "); the guard
# below keeps every TOC and index line. A real body section heading carries no
# trailing folio, so the "<gap><folio>$" requirement leaves body headings alone.
#
# Line-drop only: nothing is merged, reordered or rewritten.
#
# Test standalone:   awk -f retroclash_fix.awk CHAPTER.txt | cat -s
# Hook (pdf_build.sh, FIXAWK case):
#   retrocomputing-with-clash) FIXAWK="${AWKF%/*}/retroclash_fix.awk" ;;

/\. *\. *\./ { print; next }                                       # keep TOC dot leaders

# verso: leading folio, gap, "Chapter <n>", gap, then the chapter title.
/^[ \t]*[0-9]{1,3}[ \t]{2,}Chapter[ \t]+[0-9]{1,2}[ \t]{2,}[^ \t]/ { next }

# recto: "N.M" at line start, the section title, a wide gap, a trailing folio.
/^[ \t]*[0-9]+\.[0-9]+[ \t]+[^ \t]/ && /[^ \t][ \t]{2,}[0-9]{1,3}[ \t]*$/ { next }

{ print }
