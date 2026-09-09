#!/usr/bin/env python3
# dso_recut.py - fix the chapter boundaries of "How To Write Shared Libraries"
# (Ulrich Drepper, dsohowto.pdf).
#
# The book is a two-column paper. Its committed chapter text is correct and
# clean (extracted per-column with `pdftotext -layout` cropped to each column,
# then footer-stripped - that is why the prose is hyphenated single-column and
# the "<folio> Version 4.0 How To Write Shared Libraries" page footer is gone),
# but it was originally split at PDF *page* boundaries. Every section starts
# partway down a page, so each chapter file opened with the TAIL of the previous
# section (e.g. "003 3 Maintaining APIs and ABIs" began with section 2.7's
# DL_CALL_FCT paragraph) and its own tail was stranded at the top of the next
# file.
#
# Because the page-boundary cuts are arbitrary points in one continuous stream,
# concatenating the seven committed chapter files in order losslessly rebuilds
# the whole document; this script does that and RE-SPLITS at the printed section
# headings instead, so each chapter is exactly its own section (heading -> next
# heading) with nothing dropped and no bleed. It is idempotent: re-running it on
# already-corrected files reproduces them, because it concatenates first.
#
# Usage: dso_recut.py <book-dir>
import sys, os, re

# (output filename, heading line as it renders in the text). The first chapter
# has no start anchor: it begins at the top of the document (title page +
# abstract precede the "1 Preface" heading and belong with the Preface).
CHAPTERS = [
    ("001 1 Preface.txt", None),
    ("002 2 Optimizations for DSOs.txt", "2 Optimizations for DSOs"),
    ("003 3 Maintaining APIs and ABIs.txt", "3 Maintaining APIs and ABIs"),
    ("004 A Counting Relocations.txt", "A Counting Relocations"),
    ("005 B Automatic Handler of Arrays of String Pointers.txt",
     "B Automatic Handler of Arrays of String Pointers"),
    ("006 C Index.txt", "C Index"),
    ("007 References and Revision History.txt", "D References"),
]

def collapse(s):
    return re.sub(r"\s+", " ", s).strip()

def main():
    d = sys.argv[1]
    # concatenate the existing chapters in numeric order (the frozen artifact)
    files = sorted(f for f in os.listdir(d) if re.match(r"\d{3} ", f) and f.endswith(".txt"))
    lines = []
    for f in files:
        lines += open(os.path.join(d, f)).read().split("\n")
    # locate each anchor: exactly one line must collapse-equal it
    cuts = [0]
    for _, anchor in CHAPTERS[1:]:
        hits = [i for i, l in enumerate(lines) if collapse(l) == anchor]
        if len(hits) != 1:
            sys.exit("anchor %r matched %d lines (expected 1): %s" % (anchor, len(hits), hits))
        cuts.append(hits[0])
    cuts.append(len(lines))
    # remove the old files, write the re-split ones
    for f in files:
        os.remove(os.path.join(d, f))
    for i, (name, _) in enumerate(CHAPTERS):
        body = "\n".join(lines[cuts[i]:cuts[i + 1]]).strip("\n")
        body = re.sub(r"\n{3,}", "\n\n", body) + "\n"
        open(os.path.join(d, name), "w").write(body)
        print("%-52s %5d lines" % (name, body.count("\n")))
    open(os.path.join(d, ".complete"), "w").close()

if __name__ == "__main__":
    main()
