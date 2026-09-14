#!/usr/bin/env python3
# Align GFM pipe tables for monospaced viewing: pad every cell in a column to
# that column's width so the pipes line up in the editor. Column width = the
# widest cell in the column, capped at MAX_COL so one giant cell (e.g. cpuid's
# multi-hundred-char Intel descriptions) can't pad an entire column to that
# width; cells longer than the cap simply overflow (they are almost always the
# last column, where overflow costs nothing). Only contiguous runs of table
# rows are touched; everything else is passed through unchanged.
#
# This is the felixcloutier x86 counterpart to compact_tables.py: the x86 pages
# are read as reference tables, so aligned columns beat single-space compaction.
import re, sys

MAX_COL = 100  # per-column pad cap (chars)


def is_row(l):
    s = l.strip()
    return s.startswith("|") and s.endswith("|") and s.count("|") >= 2


def is_sep(l):
    return bool(re.match(r'^\s*\|[\s:|-]+\|\s*$', l)) and '-' in l


def cells(l):
    s = l.strip()
    return [c.strip() for c in s[1:-1].split("|")]


def align(text):
    lines = text.split("\n")
    out, i, n = [], 0, len(lines)
    while i < n:
        if is_row(lines[i]):
            j = i
            while j < n and is_row(lines[j]):
                j += 1
            block = lines[i:j]
            rows = [cells(b) for b in block]
            ncol = max(len(r) for r in rows)
            width = [3] * ncol
            for r in rows:
                for c in range(len(r)):
                    if not is_sep_cells(r):
                        width[c] = max(width[c], min(len(r[c]), MAX_COL))
            for b, r in zip(block, rows):
                r = r + [""] * (ncol - len(r))
                if is_sep(b):
                    out.append("| " + " | ".join("-" * width[c] for c in range(ncol)) + " |")
                else:
                    out.append("| " + " | ".join(r[c].ljust(width[c]) for c in range(ncol)) + " |")
            i = j
        else:
            out.append(lines[i])
            i += 1
    return "\n".join(out)


def is_sep_cells(r):
    return all(re.fullmatch(r':?-+:?', c or "-") for c in r) and any("-" in c for c in r)


if __name__ == "__main__":
    changed = 0
    for p in sys.argv[1:]:
        t = open(p, encoding="utf-8").read()
        a = align(t)
        if a != t:
            open(p, "w", encoding="utf-8").write(a)
            changed += 1
    print("aligned:", changed)
