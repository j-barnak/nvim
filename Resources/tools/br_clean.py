#!/usr/bin/env python3
# beautifulracket.com sprinkles invisible soft hyphens (U+00AD) through its prose
# for typographic line-breaking, and every page body opens with a breadcrumb
# heading ("### [Beautiful Racket](..) / [section](..)"). Strip both so the
# frozen page reads cleanly. Everything else is left intact.
import re, sys

CRUMB = re.compile(r'^#{1,6}\s*\[[^\]]*Racket\].*/')
PUA = re.compile(r'[-]')             # icon-font glyphs (anchors, etc.)

# Pandoc's gfm writer backslash-escapes markdown punctuation in PROSE (\#, \[, \],
# \*, \|, \<, \>, \$, \`, \_, braces/parens ...). That is correct for a markdown
# parser but the :Docs viewer shows the raw markdown, so those escapes appear as
# literal backslashes all over the page. Remove them - but ONLY in prose: leave
# fenced code, inline `code`, and table rows alone, where a backslash before a
# letter/quote is real Racket content ("\n", "\"", "\\") and \| separates cells.
_PUNCT = set("#[]<>*|$`_{}()+.!~-\\")
_PUNCT_NOPIPE = _PUNCT - {"|"}

def _deesc(s, punct):
    out, i, n = [], 0, len(s)
    while i < n:
        if s[i] == "\\" and i + 1 < n and s[i + 1] in punct:
            out.append(s[i + 1]); i += 2
        else:
            out.append(s[i]); i += 1
    return "".join(out)

def _deescape(text):
    out, in_fence = [], False
    for ln in text.split("\n"):
        st = ln.lstrip()
        if st.startswith("```") or st.startswith("~~~"):
            in_fence = not in_fence; out.append(ln); continue
        if in_fence:
            out.append(ln); continue
        is_table = bool(re.match(r'^\s*\|', ln)) or (bool(re.match(r'^\s*:?-{2,}', ln)) and "|" in ln)
        punct = _PUNCT_NOPIPE if is_table else _PUNCT
        parts = re.split(r'(`[^`]*`)', ln)   # protect inline code spans
        for k in range(0, len(parts), 2):
            parts[k] = _deesc(parts[k], punct)
        out.append("".join(parts))
    return "\n".join(out)

def run(text):
    text = text.replace("­", "")            # soft hyphens
    text = PUA.sub("", text)                      # decorative icon glyphs
    text = _deescape(text)                        # drop pandoc's prose backslash-escapes
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
