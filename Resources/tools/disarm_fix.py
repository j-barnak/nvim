#!/usr/bin/env python3
"""disarm_fix.py -- targeted OCR-repair for the frozen "DisARMing Code" book.

The source PDF (DisARMing Code, 545p) is a scan whose text layer was produced by
Adobe Acrobat 9.0's Paper Capture (OCR) plug-in. pdftotext -layout reproduces the
OCR's wrong glyphs verbatim (confirmed on the source pages), so the corruption
lives in the source text layer and a rebuild through pdf_build.sh cannot recover
it -- the repair has to be applied to the frozen chapter .txt files.

This script performs ONLY a closed, mechanical set of corrections where the
intended token is 100% unambiguous, per a strict scope:
  * ARM instruction mnemonics in the mnemonic / operand tables:
        AORP -> ADRP,  LOP -> LDP,  LOR -> LDR   (D mis-read as O)
  * the bitwise/logical-OR operator '|' mis-read as the letter 'I', only inside
    verified code/asm/shell contexts (a shell pipe, an ORR-result comment, and
    two condition-code flag expressions)
  * 'greg' -> 'grep' in a shell command line
  * the split register name 'SCTLR_E L2' -> 'SCTLR_EL2'
  * one wrong condition-code value: the HI row reads 0xB but HI is 0x8 (the OCR
    duplicated the 0xB that legitimately belongs to the LT row on the next line)
  * one merged figure listing (Figure 6-4): the C source of f3/f2/f1 is set in
    the figure's right column and pdftotext -layout interleaves the diagram's
    left-column labels ("Stack Frame of f2 ()", "Stack Frame of f 3 ( )") between
    its statements. The two columns are separated by position so the code reads
    as one contiguous block and the two labels follow it. No word is added or
    dropped; only the interleaving order is undone.

Deliberately NOT touched (prose, or ambiguous / outside the sanctioned set, so
left source-limited): general hex-literal OCR (0xl for 0x1, 0xla4, ...), array
indices (apple[l]), the C name fl (should be f1) in the figure, mangled hostnames
(eMlnent), garbled program output ((consumed), executable_eath), the EO/EQ
mnemonic slip, and the book-wide code corruption in chapters 3 and 11.

Every edit is guarded: the exact corrupt text must be present (with the expected
occurrence count) before it is replaced, and the script is idempotent -- run
again after a successful pass and it reports each edit as already applied and
changes nothing. It refuses to write a file whose word count changed or that
gained a U+FFFD or a C0 control byte.

Usage:
    python3 disarm_fix.py [FROZEN_DIR]
FROZEN_DIR defaults to the committed book directory.
"""
import os
import re
import sys

DEFAULT_DIR = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "..", "docs", "books", "books-asm", "disarming-code",
)

PRIMER = "002 1. An ARM Assembly Primer.txt"
MEMORY = "007 6. Memory - II - The Process View.txt"

# (old, new) substring edits, each expected exactly once in its file. The
# surrounding context in every `old` makes the match unique and unambiguous.
SUBSTR_EDITS = {
    PRIMER: [
        # ARM mnemonic table: D mis-OCR'd as O
        ("AORP           Load ADdRess of Page",
         "ADRP           Load ADdRess of Page"),
        ("LOP                      Loa D Pa ir of register",
         "LDP                      Loa D Pa ir of register"),
        ("LOR                         Loa D Reg ister from memory",
         "LDR                         Loa D Reg ister from memory"),
        # operand-types table: same mnemonic, ADRP with a literal operand
        ("Literal                   AORP X4 , #4440",
         "Literal                   ADRP X4 , #4440"),
        # shell command line: greg -> grep and the pipe I -> |
        ("disarm -v 0x12345678 I greg -a",
         "disarm -v 0x12345678 | grep -a"),
        # ORR-result comment: X0 = X0 | 0x1000
        ("X0 I 0x1000", "X0 | 0x1000"),
        # split register name in the MSR operand
        ("SCTLR_E L2, X0", "SCTLR_EL2, X0"),
        # condition-code table: HI is 0x8, not 0xB (0xB is the LT row's value)
        ("0xB              HI                     Unsigned higher",
         "0x8              HI                     Unsigned higher"),
        # condition-code flag expressions: OR operator I -> |
        ("( ! C I Z)", "( ! C | Z)"),
        ("Z I (N ! = V)", "Z | (N ! = V)"),
    ],
}

CONTROL_RE = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f]")


def load(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def check_clean(text, path):
    if "�" in text:
        raise SystemExit("refusing %s: contains U+FFFD" % path)
    if CONTROL_RE.search(text):
        raise SystemExit("refusing %s: contains a C0 control byte" % path)


def apply_substr_edits(text, edits, label):
    changed = 0
    expected_delta = 0  # intended change in whitespace-token count
    for old, new in edits:
        n = text.count(old)
        if n == 0:
            if text.count(new) >= 1:
                print("  [skip] already applied: %r" % old[:40])
                continue
            raise SystemExit(
                "  [FAIL] %s: expected corrupt text absent and fix absent: %r"
                % (label, old[:40]))
        if n != 1:
            raise SystemExit(
                "  [FAIL] %s: %r occurs %d times (expected 1)" % (label, old[:40], n))
        text = text.replace(old, new)
        # Each `old`/`new` is space-delimited on both sides, so its internal word
        # count composes with the surrounding text; the only intended delta is the
        # SCTLR_E L2 -> SCTLR_EL2 join (2 tokens -> 1).
        expected_delta += len(new.split()) - len(old.split())
        changed += 1
        print("  [fix ] %r -> %r" % (old[:38], new[:38]))
    return text, changed, expected_delta


def demerge_figure(text):
    """Un-interleave Figure 6-4's C listing from the diagram's left-column labels.

    The block, as pdftotext -layout linearises it, is:
        <84>void f3 () {
        <blank>
        <84>}
        <blank>
        <84>void f2 () {
        <blank>
        <33>Stack Frame of f2 ()            <94>f3 ();
        <84>}
        <blank>
        <84>void fl () {
        <94>f2 () ;
        <33>Stack Frame of f 3 ( )          <84>}
    The two mixed lines carry a left label (col 33) and a right code token
    (col >= 84); everything at col >= 80 is code. Rebuild the code as one block,
    then place the two labels after it. `fl` is left as-is (out of scope).
    """
    sp84, sp94, sp33 = " " * 84, " " * 94, " " * 33
    lines = text.split("\n")
    # The interleaved marker: a single physical line carrying BOTH the left-column
    # label and the right-column code token. Its absence means the block is either
    # already de-merged or was never in the expected shape.
    interleaved = [i for i, ln in enumerate(lines)
                   if "Stack Frame of f2 ()" in ln and "f3 ();" in ln]
    if not interleaved:
        contiguous = (
            sp84 + "void f2 () {\n" + sp94 + "f3 ();\n" + sp84 + "}") in text
        labels_after = (sp33 + "Stack Frame of f2 ()\n"
                        + sp33 + "Stack Frame of f 3 ( )") in text
        if contiguous and labels_after:
            print("  [skip] figure already de-merged")
            return text, 0
        raise SystemExit(
            "  [FAIL] figure: interleaved line absent and not in de-merged form")
    if len(interleaved) != 1:
        raise SystemExit(
            "  [FAIL] figure: interleaved line occurs %d times" % len(interleaved))
    head = sp84 + "void f3 () {"
    starts = [i for i, ln in enumerate(lines) if ln == head]
    if len(starts) != 1:
        raise SystemExit("  [FAIL] figure: head line occurs %d times" % len(starts))
    i0 = starts[0]
    block = lines[i0:i0 + 12]
    # Structural asserts on the two interleaved lines.
    line_f2lbl = block[6]   # Stack Frame of f2 ()   ...   f3 ();
    line_f3lbl = block[11]  # Stack Frame of f 3 ( )  ...   }
    if "Stack Frame of f2 ()" not in line_f2lbl or "f3 ();" not in line_f2lbl:
        raise SystemExit("  [FAIL] figure: unexpected f2 label/code line")
    if "Stack Frame of f 3 ( )" not in line_f3lbl or "}" not in line_f3lbl:
        raise SystemExit("  [FAIL] figure: unexpected f3 label/code line")
    if block[9] != sp84 + "void fl () {" or block[10] != sp94 + "f2 () ;":
        raise SystemExit("  [FAIL] figure: unexpected f1 body")

    label_f2 = line_f2lbl[:80].rstrip()          # <33>Stack Frame of f2 ()
    label_f3 = line_f3lbl[:80].rstrip()          # <33>Stack Frame of f 3 ( )
    f3_body = line_f2lbl[80:].strip()            # "f3 ();"

    new_block = [
        sp84 + "void f3 () {",
        "",
        sp84 + "}",
        "",
        sp84 + "void f2 () {",
        sp94 + f3_body,
        sp84 + "}",
        "",
        sp84 + "void fl () {",
        sp94 + "f2 () ;",
        sp84 + "}",
        "",
        label_f2,
        label_f3,
    ]
    lines[i0:i0 + 12] = new_block
    print("  [fix ] Figure 6-4 listing de-interleaved from stack-frame labels")
    return "\n".join(lines), 1


def words(text):
    return len(text.split())


def process(directory):
    total = 0
    # --- substring edits ---
    for fname, edits in SUBSTR_EDITS.items():
        path = os.path.join(directory, fname)
        print("== %s ==" % fname)
        before = load(path)
        wbefore = words(before)
        after, n, expected_delta = apply_substr_edits(before, edits, fname)
        check_clean(after, path)
        if words(after) != wbefore + expected_delta:
            raise SystemExit(
                "  [FAIL] %s: word count changed %d -> %d (expected delta %d)"
                % (fname, wbefore, words(after), expected_delta))
        if expected_delta:
            print("  [note] word count %d -> %d (intended join of a split token)"
                  % (wbefore, words(after)))
        if after != before:
            with open(path, "w", encoding="utf-8") as fh:
                fh.write(after)
        total += n

    # --- merged figure ---
    path = os.path.join(directory, MEMORY)
    print("== %s ==" % MEMORY)
    before = load(path)
    wbefore = words(before)
    after, n = demerge_figure(before)
    check_clean(after, path)
    if words(after) != wbefore:
        raise SystemExit(
            "  [FAIL] %s: word count changed %d -> %d (de-merge must preserve words)"
            % (MEMORY, wbefore, words(after)))
    if after != before:
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(after)
    total += n

    print("done: %d edits applied (0 means everything was already fixed)" % total)


if __name__ == "__main__":
    directory = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_DIR
    process(os.path.abspath(directory))
