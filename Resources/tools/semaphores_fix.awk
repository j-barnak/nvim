# semaphores_fix.awk - drop the running heads folio.awk leaves in The Little
# Book of Semaphores (book_fix / $FIXAWK stage).
#
# folio.awk drops only BARE folios (a page number alone); this book's running
# heads carry the title too, so they survive into the body. They come in four
# shapes, each matched structurally AND title-anchored so no body/code/TOC line
# is hit:
#
#   verso footer   "<folio>  <Title>"                (folio left, title right)
#   recto header   "<Title>  <folio>"                (title left, folio right)
#   recto header   "<n.m[.k]> <Section Title>  <folio>"   (numbered section)
#   lone folio     "<roman>"                         (front-matter page number)
#
# Anchors that keep it body-safe:
#  - the title forms require the title to be EXACTLY one of the known running-head
#    titles (12 chapter titles + CONTENTS + BIBLIOGRAPHY, and Preface for the
#    verso form only). "Preface" is left OUT of the title-FIRST set on purpose:
#    the only "Preface  <folio>" line that is title-first is the printed Table of
#    Contents' own first entry ("Preface ... i"), which must be kept - every real
#    Preface running head is folio-first ("ii  Preface").
#  - the numbered-section form requires a trailing folio AND forbids a dot-leader
#    run (". ."), so the printed Table of Contents (entries "<n.m> Title . . . N")
#    and a real body heading (no trailing folio) are preserved. The section label
#    allows an appendix letter ("A.3", "B.4"), not just digits.
#  - ONLY lone ROMAN folios are dropped. Downey numbers every listing line,
#    including blank ones, so a lone ARABIC number is a code line number and is
#    left exactly as it is.
# Line-drop only.

function trim(s){ sub(/^[ \t]+/,"",s); sub(/[ \t]+$/,"",s); return s }
BEGIN{
  # chapter titles shared by both forms
  n=split("Introduction|Semaphores|Basic synchronization patterns|" \
          "Classical synchronization problems|Less classical synchronization problems|" \
          "Not-so-classical problems|Not remotely classical problems|" \
          "Synchronization in Python|Synchronization in C|" \
          "Cleaning up Python threads|Cleaning up POSIX threads|" \
          "CONTENTS|BIBLIOGRAPHY", A, "|")
  for(i=1;i<=n;i++){ VERSO[A[i]]=1; RECTO[A[i]]=1 }
  VERSO["Preface"]=1          # verso ("ii Preface") only; NOT recto (that is the TOC entry)
  FOLIO="([0-9]{1,3}|[ivxlcdm]{1,7})"
}
{ line=trim($0)
  # verso footer: "<folio>  <Title>"
  if (match(line, "^" FOLIO "[ \t][ \t]+")) {
    if (substr(line, RLENGTH+1) in VERSO) next
  }
  # trailing "<2+ spaces><folio>" -> recto header (title-form or numbered-section)
  if (match(line, "[ \t][ \t]+" FOLIO "$")) {
    head=trim(substr(line, 1, RSTART-1))
    if (head in RECTO) next                                        # title-form
    if (head ~ /^[A-Z0-9]{1,2}\.[0-9]{1,2}(\.[0-9]{1,2})? / \
        && head !~ /\. \./ && head !~ /\.\.+/) next                # numbered-section form
  }
  # lone roman folio (front-matter page number); never a code line number
  if (line ~ /^[ivxlcdm]{1,7}$/) next
  print
}
