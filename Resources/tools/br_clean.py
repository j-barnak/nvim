#!/usr/bin/env python3
# beautifulracket.com sprinkles invisible soft hyphens (U+00AD) through its prose
# for typographic line-breaking, and every page body opens with a breadcrumb
# heading ("### [Beautiful Racket](..) / [section](..)"). Strip both so the
# frozen page reads cleanly. Everything else is left intact.
import re, sys

CRUMB = re.compile(r'^#{1,6}\s*\[[^\]]*Racket\].*/')
PUA = re.compile(r'[-]')             # icon-font glyphs (anchors, etc.)

def run(text):
    text = text.replace("­", "")            # soft hyphens
    text = PUA.sub("", text)                      # decorative icon glyphs
    lines = [ln.rstrip() for ln in text.split("\n")]
    # drop leading blank lines and a leading breadcrumb heading so the page
    # starts at its own H1.
    i = 0
    while i < len(lines) and (lines[i].strip() == "" or CRUMB.match(lines[i])):
        i += 1
    lines = lines[i:]
    # collapse the blank-line runs the stripped glyphs left behind (max 1 blank).
    out = []
    for ln in lines:
        if ln == "" and out and out[-1] == "":
            continue
        out.append(ln)
    while out and out[-1] == "":
        out.pop()
    return "\n".join(out)

if __name__ == "__main__":
    sys.stdout.write(run(sys.stdin.read()))
