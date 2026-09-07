#!/usr/bin/env python3
"""Column de-interleaver for The Algorithm Design Manual (Skiena, 3rd ed).

pdf_build.sh runs `pdftotext -layout`, which is right for this book's single-
column body but WRONG for the handful of code/pseudocode figures the book sets
in two or three side-by-side columns. -layout prints those columns onto shared
physical lines, so two unrelated C functions (or three pseudocode listings)
splice together and neither reads as sequential code. One page also floats a
figure (the parent matrix, Figure 10.6) to the top of the page, so -layout
linearises it INTO the middle of reconstruct_path(), between the MATCH-branch
recursive call and match_out().

Unlike shlib_columns.py (a whole two-column paper, so every page is cropped),
here only a few sub-page BLOCKS are multi-column while the rest of each page is
ordinary single-column prose. So this tool does not re-extract whole chapters:
it re-extracts just the affected blocks with per-column `pdftotext -layout` crop
boxes (measured from the PDF's own word geometry, page size 504.567x666.142pt),
stacks the columns in reading order with indentation preserved, and splices each
corrected block into the committed frozen chapter .txt in place of the merged
one. Every surrounding byte of the chapter is left exactly as pdf_build.sh
produced it, so the rebuild is a pure reorder (word-for-word parity).

Blocks handled:
  006 Chapter 3 Data Structures     p103  Sort1()/Sort2()/Sort3()  (3 columns)
                                          + "!=" glyph (0x07) restored
  013 Chapter 10 Dynamic Programming p335 row_init()/column_init() (2 columns)
                                     p335 match()/indel()          (2 columns)
                                     p336 insert_out()+delete_out()/match_out()
                                     p334 Figure 10.6 moved out of reconstruct_path()

Usage:  tadm_columns.py <The-Algorithm-Design-Manual.pdf> <book-dir>
        book-dir is the frozen ".../the-algorithm-design-manual" directory.
"""
import subprocess, sys, os, re

PDF, BOOK = sys.argv[1], sys.argv[2]


def crop(page, x, y, w, h):
    """One -layout crop box, form feed stripped, trailing blank lines dropped."""
    out = subprocess.run(
        ["pdftotext", "-layout", "-f", str(page), "-l", str(page),
         "-x", str(x), "-y", str(y), "-W", str(w), "-H", str(h), PDF, "-"],
        capture_output=True, text=True).stdout
    lines = out.replace("\x0c", "").split("\n")
    while lines and lines[-1].strip() == "":
        lines.pop()
    # 0x07 is the not-equal glyph in this book's pseudocode font; -layout
    # passes it through and pdf_build.sh's tr later shows it as "?=".
    return [ln.replace("\x07", "!") for ln in lines]


def indent(lines, base):
    """Prefix `base` spaces to every non-blank line, keeping internal indent."""
    return [(" " * base + ln) if ln.strip() else "" for ln in lines]


def stack(base, *cols):
    """Stack column line-lists in reading order, one blank line between each."""
    out = []
    for i, c in enumerate(cols):
        if i:
            out.append("")
        out.extend(indent(c, base))
    return out


# --- Re-extracted, de-interleaved blocks (built from the source PDF) ----------

# p103: three-column pseudocode. Headers are cropped in a separate band from the
# bodies because Sort2's widest body line and Sort3's centred header overlap in
# x; split at the wide header gaps, then bodies at the clean body gap (x=288).
def sort_listings():
    h1 = crop(103, 0, 376, 140, 14)      # Sort1()
    h2 = crop(103, 140, 376, 115, 14)    # Sort2()
    h3 = crop(103, 255, 376, 257, 14)    # Sort3()
    b1 = crop(103, 0, 391, 172, 101)     # Sort1 body
    b2 = crop(103, 172, 391, 116, 101)   # Sort2 body
    b3 = crop(103, 288, 391, 224, 101)   # Sort3 body
    # header at base 6, body at base 10 (matches the book's listing indent).
    def one(h, b):
        return indent(h, 6) + indent(b, 10)
    return one(h1, b1) + [""] + one(h2, b2) + [""] + one(h3, b3)


# p335 row_init | column_init  (two columns, boundary x=242)
def row_column_init():
    left = crop(335, 0, 188, 242, 100)
    right = crop(335, 242, 188, 270, 100)
    return stack(5, left, right)


# p335 int match | int indel  (two columns, boundary x=242)
def match_indel():
    left = crop(335, 0, 388, 242, 66)
    right = crop(335, 242, 388, 270, 66)
    return stack(5, left, right)


# p336 insert_out + delete_out (left) | match_out (right), boundary x=285
def out_functions():
    left = crop(336, 0, 104, 285, 112)     # insert_out then delete_out
    right = crop(336, 285, 104, 227, 112)  # match_out
    # left already carries a blank line between insert_out and delete_out;
    # keep that, and separate the two columns with one blank line.
    return indent(left, 6) + [""] + indent(right, 6)


# --- Splice helpers -----------------------------------------------------------

def read_lines(path):
    with open(path) as f:
        return f.read().split("\n")


def write_lines(path, lines):
    with open(path, "w") as f:
        f.write("\n".join(lines))


def replace_range(lines, first_pred, last_pred, new_block):
    """Replace the inclusive span from the first line matching first_pred to the
    next line matching last_pred. The two-column code blocks are NOT blank-
    delimited (the closing-brace line is glued to the next prose bullet), so the
    span must be pinned by its own first and last lines, not by surrounding
    blanks. Exactly one first-line match is required."""
    starts = [i for i, l in enumerate(lines) if first_pred(l)]
    if len(starts) != 1:
        raise SystemExit(f"expected 1 block start, got {len(starts)}")
    s = starts[0]
    e = next((i for i in range(s, len(lines)) if last_pred(lines[i])), None)
    if e is None:
        raise SystemExit("block end not found")
    return lines[:s] + new_block + lines[e + 1:]


# --- Chapter 3 ----------------------------------------------------------------

def fix_chapter3():
    path = os.path.join(BOOK, "006 Chapter 3 Data Structures.txt")
    lines = read_lines(path)
    lines = replace_range(
        lines,
        lambda l: "Sort1()" in l and "Sort2()" in l and "Sort3()" in l,
        lambda l: "y = Minimum(t)" in l and "Delete" not in l and l.count("=") == 1
                  and "Successor" not in l,
        sort_listings())
    write_lines(path, lines)
    return path


# --- Chapter 10 ---------------------------------------------------------------

def fix_chapter10():
    path = os.path.join(BOOK, "013 Chapter 10 Dynamic Programming.txt")
    lines = read_lines(path)

    # 1) Move Figure 10.6 out of the MATCH branch of reconstruct_path().
    #    It sits as two non-blank runs (matrix table, then caption) between the
    #    "reconstruct_path(s, t, i-1, j-1, m);" call and "match_out(s, t, i, j);".
    call_re = re.compile(r"reconstruct_path\(s, t, i-1, j-1, m\);")
    call_i = next(i for i, l in enumerate(lines) if call_re.search(l))
    mout_i = next(i for i in range(call_i + 1, len(lines))
                  if "match_out(s, t, i, j);" in lines[i])
    # figure = the lines strictly between the call and match_out, trimmed of the
    # blank lines that hug it on either side.
    seg_s, seg_e = call_i + 1, mout_i
    fs = seg_s
    while fs < seg_e and lines[fs].strip() == "":
        fs += 1
    fe = seg_e
    while fe > fs and lines[fe - 1].strip() == "":
        fe -= 1
    figure = lines[fs:fe]
    if not any("Figure 10.6" in l for l in figure):
        raise SystemExit("Figure 10.6 block not located inside reconstruct_path")
    # excise: leave exactly one blank line between the call and match_out.
    lines = lines[:call_i + 1] + [""] + lines[mout_i:]

    # find the function's closing brace: the lone "}" after match_out, then
    # re-insert the figure after it (before the "For many problems" paragraph).
    mout_i = next(i for i, l in enumerate(lines) if "match_out(s, t, i, j);" in l)
    close_i = next(i for i in range(mout_i + 1, len(lines))
                   if lines[i].rstrip() == "}")
    lines = (lines[:close_i + 1] + [""] + figure + [""] + lines[close_i + 1:])

    # 2) De-interleave the three two-column code figures.
    lines = replace_range(
        lines,
        lambda l: re.match(r"\s*row_init\(int i\)\s+column_init\(int i\)", l),
        lambda l: re.fullmatch(r"\}\s+\}", l.strip()) is not None,
        row_column_init())
    lines = replace_range(
        lines,
        lambda l: re.match(r"\s*int match\(char c, char d\)\s+int indel\(char c\)", l),
        lambda l: l.strip() == "}",
        match_indel())
    lines = replace_range(
        lines,
        lambda l: re.match(r"\s*insert_out\(char \*t, int j\)\s+match_out", l),
        lambda l: l.strip() == "}",
        out_functions())

    write_lines(path, lines)
    return path


def main():
    if not os.path.isdir(BOOK):
        raise SystemExit(f"book dir not found: {BOOK}")
    p3 = fix_chapter3()
    p10 = fix_chapter10()
    open(os.path.join(BOOK, ".complete"), "w").write("")
    print("rewrote:", p3)
    print("rewrote:", p10)


if __name__ == "__main__":
    main()
