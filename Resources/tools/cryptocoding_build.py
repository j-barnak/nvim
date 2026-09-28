#!/usr/bin/env python3
"""Freeze veorq/cryptocoding (the "Cryptocoding" rules for crypto software) as a
:Docs top-level chapter set, one chapter per rule, in the README's own order.

    python3 Resources/tools/cryptocoding_build.py

The whole guide is one README.md whose table of contents lists the ten rules
("Compare secret strings in constant time", ...), each a "## " section with
Problem / Solution subsections. The chapters are those sections, split at the
"## " headings, in document order (which is the ToC order); the preamble above
the first rule (minus the ToC itself, which the picker replaces) becomes the
"Introduction" chapter. Each chapter's url is the README's own anchor, taken
from the ToC so it is exactly what GitHub renders, and the page is the section's
Markdown verbatim (no pandoc: it is already Markdown).

Writes Resources/docs/cryptocoding/index.tsv ("title\\turl") and
Resources/docs/.webcache/<sha256(url)>.txt. Standard library only.
"""
import hashlib, os, re, sys, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
DOCS = os.path.join(HERE, "..", "docs")
RAW = "https://raw.githubusercontent.com/veorq/cryptocoding/master/README.md"
PAGE = "https://github.com/veorq/cryptocoding"


def main():
    req = urllib.request.Request(RAW, headers={"User-Agent": "Mozilla/5.0 (personal-docs-archive)"})
    with urllib.request.urlopen(req, timeout=60) as r:
        text = r.read().decode("utf-8")
    lines = text.split("\n")

    # ToC rows: "   * [Title](#anchor)" -> anchor by title, in ToC order.
    anchors = {}
    for l in lines:
        m = re.match(r"^\s*[*-] \[(.+?)\]\(#([^)]+)\)\s*$", l)
        if m:
            anchors.setdefault(m.group(1), m.group(2))

    # Split at "## " headings (top-level rules); everything before is the preamble.
    heads = [i for i, l in enumerate(lines) if l.startswith("## ")]
    if not heads:
        sys.exit("no '## ' sections found")
    chapters = []
    pre = lines[: heads[0]]
    # Drop the ToC list from the preamble (the picker is the ToC now).
    pre = [l for l in pre if not re.match(r"^\s*[*-] \[.+?\]\(#[^)]+\)\s*$", l)]
    # ... and the ToC's own "Table of Contents" heading, written setext-style
    # (a title line followed by a line of "="), so drop both lines of the pair.
    cleaned, skip = [], False
    for l in pre:
        if re.match(r"^\s*table of contents\s*$", l, re.I):
            skip = True
            continue
        if skip and re.match(r"^[=-]+\s*$", l):
            skip = False
            continue
        skip = False
        cleaned.append(l)
    pre = cleaned
    chapters.append(("Introduction", PAGE + "#cryptocoding", pre))
    for n, start in enumerate(heads):
        end = heads[n + 1] if n + 1 < len(heads) else len(lines)
        title = lines[start][3:].strip()
        anchor = anchors.get(title) or re.sub(r"[^\w\- ]", "", title.lower()).replace(" ", "-")
        body = ["# " + title] + lines[start + 1 : end]
        chapters.append((title, PAGE + "#" + anchor, body))

    out = os.path.join(DOCS, "cryptocoding")
    cache = os.path.join(DOCS, ".webcache")
    os.makedirs(out, exist_ok=True)
    os.makedirs(cache, exist_ok=True)
    with open(os.path.join(out, "index.tsv"), "w", encoding="utf-8") as idx:
        for title, url, body in chapters:
            content = "\n".join(body).strip("\n") + "\n"
            with open(os.path.join(cache, hashlib.sha256(url.encode()).hexdigest() + ".txt"), "w", encoding="utf-8") as fh:
                fh.write(content)
            idx.write("%s\t%s\n" % (title, url))
    print("cryptocoding: %d chapters" % len(chapters))


if __name__ == "__main__":
    main()
