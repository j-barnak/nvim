#!/usr/bin/env python3
# strip_line_gutters.py - remove leaked line-number gutters from frozen docs.
#
# Some sites (VuePress div.line-numbers-wrapper and similar) render a code
# block's line numbers as a separate column. When such a page is scraped into
# a Markdown cache without dropping that column, the numbers survive as a run
# of bare-integer lines "1, 2, 3, ..., N" inside a fenced code block. Two
# shapes occur:
#
#   A (interleaved): the run sits between the ``` opener and the real code, all
#                    in one fence. Fix: drop the run, keep the fence + code.
#   B (detached):    the run is a whole fenced block of only digits, followed by
#                    a separate real code fence. Fix: delete the numbers-only
#                    block entirely (plus one trailing blank line).
#
# The run is only stripped when it is >= 3 lines and is exactly 1..N, so a code
# block that legitimately starts with a non-1 number, or a short 1-2 line run,
# is never touched. Deterministic and idempotent: re-running changes nothing.
#
# Usage: strip_line_gutters.py FILE [FILE ...]
#        strip_line_gutters.py --check FILE [FILE ...]   (report only, exit 1 if any gutters)
import re
import sys

FENCE = re.compile(r"^\s*```")
INTLINE = re.compile(r"^\s*\d+\s*$")


def strip_gutters(lines):
    """Return (new_lines, blocks_removed)."""
    out, i, removed, n = [], 0, 0, len(lines)
    while i < n:
        ln = lines[i]
        if FENCE.match(ln):
            j = i + 1
            run = []
            while j < n and INTLINE.match(lines[j]):
                run.append(int(lines[j].strip()))
                j += 1
            is_gutter = len(run) >= 3 and run == list(range(1, len(run) + 1))
            if is_gutter:
                removed += 1
                if j < n and FENCE.match(lines[j]):
                    # Shape B: numbers-only fenced block -> drop opener..closer
                    i = j + 1
                    if i < n and lines[i].strip() == "":  # collapse one blank
                        i += 1
                    continue
                # Shape A: keep the opener, drop the digit run only
                out.append(ln)
                i = j
                continue
        out.append(ln)
        i += 1
    return out, removed


def main(argv):
    check = False
    files = []
    for a in argv:
        if a == "--check":
            check = True
        else:
            files.append(a)
    total, touched = 0, 0
    for path in files:
        with open(path, encoding="utf-8") as fh:
            lines = fh.read().split("\n")
        new, removed = strip_gutters(lines)
        if removed:
            total += removed
            touched += 1
            if check:
                print("%s: %d gutter block(s)" % (path, removed))
            else:
                with open(path, "w", encoding="utf-8") as fh:
                    fh.write("\n".join(new))
                print("%s: stripped %d gutter block(s)" % (path, removed))
    if check:
        print("total: %d gutter block(s) in %d file(s)" % (total, touched))
        return 1 if total else 0
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
