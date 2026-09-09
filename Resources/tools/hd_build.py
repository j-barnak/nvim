#!/usr/bin/env python3
# hd_build.py - build the frozen chapter text for Hacker's Delight (Henry S.
# Warren). The book's math notation is set in a font whose ToUnicode map is
# wrong: pdftotext renders every math glyph as a plausible WRONG letter (<= as
# "d", >= as "t", the assignment arrow as a letter, and ~30 more), silently
# corrupting the formulas, and mutool renders them all as U+FFFD (conflated).
# pdfminer.six is the only extractor that exposes the true font code, as
# "(cid:N)"; HD_CID below maps each code to its real Unicode glyph. The map was
# built by rendering the pages and reading the glyphs visually (every code with
# >= 5 occurrences verified on 3+ pages), so it is exact and, because one font
# code is exactly one glyph, globally consistent.
#
# Usage: hd_build.py <hackers-delight.pdf> <out-dir>
# Requires pdfminer.six (build-time only; the committed .txt is what ships).
import sys, os, re
from pdfminer.high_level import extract_text

HD_CID = {
    100:"≤",116:"≥",109:"←",134:"⊕",152:"·",123:"≡",159:"⇒",122:"≠",99:"′",
    71:"δ",83:"π",166:"∑",124:"≈",111:"→",150:"∏",84:"θ",72:"ε",102:"∞",
    16:"−",80:"μ",79:"λ",39:"Δ",156:"⇔",7:"∃",179:"∫",5:"∀",
    # extensible big-delimiter pieces: the hooks stand in for the whole bracket,
    # the vertical extensions collapse away (they only stack a taller delimiter).
    167:"(",168:"",169:"(",183:")",184:"",185:")",173:"{",174:"",175:"{",176:"",
}
LIG = {"ﬀ":"ff","ﬁ":"fi","ﬂ":"fl","ﬃ":"ffi","ﬄ":"ffl"}

# (first_page, title) depth-0 boundaries; Cover..Contents fold into Front Matter
# (the driver auto-emits it before the first boundary). "Answers to Exercises"
# is a real 48-page section the outline lists but pdftotext book-mode dropped.
BOUNDS = [
    (14,"Foreword"),(16,"Preface"),
    (18,"1 Introduction"),(28,"2 Basics"),(76,"3 Power-of-2 Boundaries"),
    (84,"4 Arithmetic Bounds"),(98,"5 Counting Bits"),(134,"6 Searching Words"),
    (146,"7 Rearranging Bits and Bytes"),(188,"8 Multiplication"),
    (198,"9 Integer Division"),(222,"10 Integer Division by Constants"),
    (296,"11 Some Elementary Functions"),(316,"12 Unusual Bases for Number Systems"),
    (328,"13 Gray Code"),(336,"14 Cyclic Redundancy Check"),
    (348,"15 Error-Correcting Codes"),(372,"16 Hilbert's Curve"),
    (392,"17 Floating-Point"),(408,"18 Formulas for Primes"),
    (422,"Answers to Exercises"),
    (470,"Appendix A. Arithmetic Tables for a 4-Bit Machine"),
    (474,"Appendix B. Newton's Method"),
    (476,"Appendix C. A Gallery of Graphs of Discrete Functions"),
    (488,"Bibliography"),(498,"Index"),
]
TOTAL = 513

def sub_cids(s):
    return re.sub(r"\(cid:(\d+)\)", lambda m: HD_CID.get(int(m.group(1)), m.group(0)), s)

def fix_ligs(s):
    for k,v in LIG.items(): s=s.replace(k,v)
    return s

ALLCAPS = re.compile(r"^[A-Z0-9][-A-Z0-9 ,.'’()/&]*[A-Z][-A-Z0-9 ,.'’()/&]*$")
SECNUM  = re.compile(r"^[0-9]+–[0-9]+$")      # en-dash section number, e.g. 2–1
FOLIO   = re.compile(r"^[0-9]+$")

# front-matter running heads that pdfminer linearises mid-flow (not just at the
# page top), plus the roman-numeral folios the front matter uses.
FM_HEAD = re.compile(r"^(CONTENTS|FOREWORD|PREFACE|INDEX|BIBLIOGRAPHY)$")
ROMAN = re.compile(r"^[ivxlcdm]+$")

def strip_furniture(page, frontmatter=False):
    # Per page: the top holds the running head - a folio or an en-dash section
    # number, plus an ALL-CAPS section/chapter title, on separate lines. Drop the
    # first up-to-2 non-empty lines when they are that furniture, then stop at the
    # first real content line. The "ptg########" per-page watermark is dropped
    # wherever it sits (bottom of every page). In the front matter (roman-numbered
    # pages: TOC, Foreword, Preface), pdfminer puts the running head + folio in the
    # MIDDLE of the linearised text, so there also drop a bare roman-numeral folio
    # or a CONTENTS/FOREWORD/PREFACE running head anywhere on the page - neither is
    # ever real body content in those sections. (The body uses arabic folios, which
    # the top-of-page rule already handles, so this stays front-matter-only.)
    out, seen = [], 0
    for line in page.split("\n"):
        t = line.strip()
        if re.match(r"^ptg\d+$", t):        # DRM watermark, every page
            continue
        if frontmatter and t and (ROMAN.match(t) or FM_HEAD.match(t)):
            continue
        if seen < 2 and t and (FOLIO.match(t) or SECNUM.match(t) or ALLCAPS.match(t)):
            seen += 1
            continue
        if t:
            seen = 2
        out.append(line)
    return "\n".join(out)

def extract(pdf, fp, lp):
    pages = list(range(fp-1, lp))          # pdfminer is 0-indexed
    fm = lp < 18                           # front matter: everything before chapter 1 (page 18)
    txt = extract_text(pdf, page_numbers=pages)
    parts = [strip_furniture(sub_cids(fix_ligs(p)), fm) for p in txt.split("\f")]
    body = "\n".join(parts)
    return re.sub(r"\n{3,}", "\n\n", body).strip("\n") + "\n"

def main():
    pdf, out = sys.argv[1], sys.argv[2]
    os.makedirs(out, exist_ok=True)
    for f in os.listdir(out):
        if f.endswith(".txt"): os.remove(os.path.join(out, f))
    ranges = []
    first = BOUNDS[0][0]
    if first > 1: ranges.append((1, first-1, "Front Matter"))
    for i,(p,title) in enumerate(BOUNDS):
        lp = BOUNDS[i+1][0]-1 if i+1 < len(BOUNDS) else TOTAL
        ranges.append((p, lp, title))
    for idx,(fp,lp,title) in enumerate(ranges, 1):
        name = "%03d %s.txt" % (idx, title.replace("/","-"))
        text = extract(pdf, fp, lp)
        with open(os.path.join(out, name), "w") as fh:
            fh.write(text)
        print("%s  (p%d-%d, %d bytes)" % (name, fp, lp, len(text)))
    open(os.path.join(out, ".complete"), "w").close()

if __name__ == "__main__":
    main()
