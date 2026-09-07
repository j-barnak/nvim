# cmove_fix.awk -- per-slug code-listing repair for the book
#   c-move-semantics-the-complete-guide  (C++ Move Semantics, Josuttis 2022).
#
# WHY: This LaTeX-set PDF prints a running head on every body page, and a
# handful of them survive folio.awk's page-edge vote and linearise INTO the
# text -- four of them land in the MIDDLE of a C++ code listing (splitting an
# #include block, a class body, and two contiguous snippets). The head has two
# alternating forms:
#     odd  page:  "N.M  Section Title" <wide gap> <printed folio>
#     even page:  <printed folio> <wide gap> "Chapter N: Chapter Title"
# Both are pure page furniture (no book content) and are dropped here. The
# builder runs this AFTER folio.awk, so it only ever sees the stragglers folio
# already missed; every line it removes is one of those heads.
#
# NOT the table of contents: the printed TOC entries are the same "N.M Title
# ... folio" shape but are INDENTED (they never start in column 0) and carry a
# dot-leader run (" . . ."); both guards below keep every TOC and index line.
# A real section heading printed in the body carries no trailing folio, so the
# "<gap><folio>$" requirement leaves body headings untouched too.
#
# Line-drop only: no line is merged, reordered or rewritten, so the surrounding
# blank lines collapse under the builder's trailing `cat -s` and each repaired
# code block reads as one contiguous listing. A no-op for every book but this
# one (it is wired by slug in pdf_build.sh's FIXAWK case).
#
# Test standalone:   awk -f cmove_fix.awk CHAPTER.txt | cat -s
# Hook (pdf_build.sh, FIXAWK case):
#   c-move-semantics-the-complete-guide) FIXAWK="${AWKF%/*}/cmove_fix.awk" ;;

# odd-page running head: "N.M  Title <wide gap> folio", column 0, no dot leader.
/^[0-9]+\.[0-9]+ [^ ]/ && /[^ ]   *[0-9]+$/ && !/ \. \./ { next }

# even-page running head: "folio <wide gap> Chapter N: Title", column 0.
/^[0-9]+ {2,}Chapter [0-9]+:/ { next }

{ print }
