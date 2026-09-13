#!/usr/bin/env python3
# Compact pandoc's column-aligned GFM pipe tables (padded to the widest cell,
# often 200+ chars wide and unreadable in a text viewer) to single-space cells.
# Only touches contiguous runs of table rows; leaves everything else untouched.
import re, sys

def is_row(l):
    s = l.strip()
    return s.startswith("|") and s.endswith("|") and s.count("|") >= 2

def is_sep(l):
    return bool(re.match(r'^\s*\|[\s:|-]+\|\s*$', l)) and '-' in l

def cells(l):
    s = l.strip()
    return [c.strip() for c in s[1:-1].split("|")]

def compact(text):
    lines = text.split("\n")
    out, i, n = [], 0, len(lines)
    while i < n:
        if is_row(lines[i]):
            j = i
            while j < n and is_row(lines[j]):
                j += 1
            block = lines[i:j]
            ncol = max(len(cells(b)) for b in block)
            for b in block:
                if is_sep(b):
                    out.append("|" + "|".join([" --- "] * ncol) + "|")
                else:
                    c = cells(b)
                    c += [""] * (ncol - len(c))
                    out.append("| " + " | ".join(c) + " |")
            i = j
        else:
            out.append(lines[i]); i += 1
    return "\n".join(out)

if __name__ == "__main__":
    changed = 0
    for p in sys.argv[1:]:
        t = open(p, encoding="utf-8").read()
        c = compact(t)
        if c != t:
            open(p, "w", encoding="utf-8").write(c)
            changed += 1
            print("compacted:", p.split("/")[-1])
    print("changed:", changed)
