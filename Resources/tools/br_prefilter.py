#!/usr/bin/env python3
# Pre-process a beautifulracket.com page before the webextract/pandoc pipeline.
# Each code sample is a <div class="highlight-container"> holding: a Pygments
# table (a line-number gutter <div class="linenodiv"><pre>..</pre></div> beside a
# code <pre> whose identifiers are <a class="docs"> links to the Racket
# reference), a duplicate plain-text copy (the clipboard source), and a
# <div class="copy-button"> with a download.svg icon. pandoc can't put links in a
# code block, so it renders the whole thing as escaped prose - and the gutter,
# duplicate copy and copy icon all leak in. Replace each highlight-container with
# a single clean <pre><code> built from the code column's text (its get_text
# keeps real newlines and indentation), so pandoc emits one fenced code block.
# Reads HTML on stdin, writes on stdout.
import sys
from bs4 import BeautifulSoup

s = BeautifulSoup(sys.stdin.read(), "lxml")
doc = s.select_one("div#doc") or s

def code_text(container):
    # prefer the non-gutter <pre> (the code column); else the container text.
    for pre in container.find_all("pre"):
        par = pre.parent
        if par is not None and "linenodiv" in (par.get("class") or []):
            continue
        t = pre.get_text().rstrip("\n")
        if t.strip():
            return t
    return container.get_text().rstrip("\n")

# Inline asides are tooltips: <span class="tooltip"> + <span class="tooltip-inner">
# NOTE</span></span>. Frozen, both the " + " toggle marker and the note text land
# mid-paragraph ("...arguments.  + Being able to..."). Lift each note out of its
# paragraph into a blockquote right after it, and drop the " + " toggle.
for tip in doc.select("span.tooltip"):
    inner = tip.select_one(".tooltip-inner")
    note = inner.get_text(" ", strip=True) if inner else ""
    par = tip.find_parent(["p", "li", "div"])
    tip.decompose()
    if note and par is not None:
        bq = s.new_tag("blockquote")
        np = s.new_tag("p")
        np.string = note
        bq.append(np)
        par.insert_after(bq)

for cont in doc.select("div.highlight-container"):
    text = code_text(cont)
    if not text.strip():
        cont.decompose(); continue
    newpre = s.new_tag("pre")
    code = s.new_tag("code")
    code.string = text
    newpre.append(code)
    cont.replace_with(newpre)

# Defensive: any leftover line-number gutters or copy buttons outside a container.
for g in doc.select("div.linenodiv"):
    g.decompose()
for b in doc.select("div.copy-button"):
    b.decompose()

sys.stdout.write(str(s))
