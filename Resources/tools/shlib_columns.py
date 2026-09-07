#!/usr/bin/env python3
"""Two-column extractor for "How To Write Shared Libraries" (Ulrich Drepper).

pdf_build.sh always runs `pdftotext -layout`, which is correct for the repo's
single-column books but INTERLEAVES a two-column paper: it prints the left and
right columns side by side on one physical line, so every prose line splices an
unrelated right-column sentence onto a left-column one. dsohowto.pdf is such a
two-column paper (US Letter, 612x792pt), so it gets its own extractor.

Per page, text is pulled column by column with `pdftotext -layout` crop boxes
(LEFT x0 W300, RIGHT x308 W304), left then right, so reading order is restored
while -layout keeps the code listings' indentation. Page geometry is not
uniform, so pages are classified:

  page 1        full-width title/author/abstract (y0..270), then two columns
  pages 2-41    two-column body
  pages 42-44   full-width single column (appendix A/B scripts)
  pages 45-46   two-column index
  page 47       full-width references + revision history

The footer ("N  Version 4.0  How To Write Shared Libraries") sits below y760 and
is dropped by the body crop height. Output matches the NNN-Title.txt + .complete
shape of the other frozen PDF books.

Usage:  shlib_columns.py <dsohowto.pdf> <out-dir>
"""
import subprocess, sys, os

PDF, OUT = sys.argv[1], sys.argv[2]

def pt(page, x, y, w, h):
    return subprocess.run(
        ["pdftotext", "-layout", "-x", str(x), "-y", str(y), "-W", str(w), "-H", str(h),
         "-f", str(page), "-l", str(page), PDF, "-"],
        capture_output=True, text=True).stdout

HDR, BODY_H = 270, 760

def page_text(p):
    if p == 1:
        return pt(1, 0, 0, 612, HDR) + pt(1, 0, HDR, 300, BODY_H - HDR) + pt(1, 308, HDR, 304, BODY_H - HDR)
    if p in (42, 43, 44, 47):
        return pt(p, 0, 0, 612, BODY_H)
    return pt(p, 0, 0, 300, BODY_H) + pt(p, 308, 0, 304, BODY_H)

def clean(t):
    out, blank = [], 0
    for ln in t.split("\n"):
        ln = ln.replace("\x0c", "").rstrip()
        if ln.strip() == "":
            blank += 1
            if blank > 1:
                continue
        else:
            blank = 0
        out.append(ln)
    return "\n".join(out).strip() + "\n"

CHAPTERS = [
    ("001 1 Preface", 1, 14),
    ("002 2 Optimizations for DSOs", 15, 33),
    ("003 3 Maintaining APIs and ABIs", 34, 41),
    ("004 A Counting Relocations", 42, 43),
    ("005 B Automatic Handler of Arrays of String Pointers", 44, 44),
    ("006 C Index", 45, 46),
    ("007 References and Revision History", 47, 47),
]

os.makedirs(OUT, exist_ok=True)
for name, a, b in CHAPTERS:
    txt = "".join(page_text(p) for p in range(a, b + 1))
    open(os.path.join(OUT, name + ".txt"), "w").write(clean(txt))
open(os.path.join(OUT, ".complete"), "w").write("")
