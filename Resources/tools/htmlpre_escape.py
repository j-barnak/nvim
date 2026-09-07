#!/usr/bin/env python3
# htmlpre_escape.py - repair unescaped code brackets inside <pre> blocks.
#
# Some sites (LazyFoo's SDL tutorials) emit C++ listings where the angle
# brackets of template arguments are written INTO the HTML two different ways,
# both invalid, inside a <pre> that carries no real nested tags:
#   * a bare numeric entity with no trailing ";"  -> "static_cast&#060float&#062"
#   * a literal, unescaped angle bracket           -> "static_cast<float>"
# A standard HTML parser then treats "<float>" (or the decoded "<") as an opening
# tag and DELETES it, so "static_cast<float>(x)" becomes the uncompilable
# "static_cast(x)". This filter runs on the raw HTML BEFORE the parser: within
# every <pre>...</pre> region it turns both forms into the proper &lt; / &gt;
# entities, which the parser then decodes back to real "<"/">" as TEXT. Because
# these <pre> blocks contain no intended child tags, escaping every literal
# "<"/">" in them is safe. Content outside <pre> is passed through untouched, so
# a page's real markup (including its <pre ...> tags themselves) is preserved.
import sys, re

_PRE = re.compile(r"(<pre\b[^>]*>)(.*?)(</pre>)", re.S | re.I)

def fix(content):
    # bare numeric entities missing their ";" -> proper entities
    content = re.sub(r"&#0*60(?![0-9;])", "&lt;", content)
    content = re.sub(r"&#0*62(?![0-9;])", "&gt;", content)
    # literal angle brackets (real code, not markup) -> entities
    content = content.replace("<", "&lt;").replace(">", "&gt;")
    return content

def main():
    html = sys.stdin.read()
    sys.stdout.write(_PRE.sub(lambda m: m.group(1) + fix(m.group(2)) + m.group(3), html))

if __name__ == "__main__":
    main()
