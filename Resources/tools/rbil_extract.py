#!/usr/bin/env python3
# Extract one Ralf Brown's Interrupt List page (ctyme.com/intr/int-XX.htm) into
# readable text. The page's real content (the interrupt's function entries) sits
# in the <body> between four navigation <table>s; there are no <pre> blocks, so
# line structure comes from <br>. Reads HTML on stdin, writes the cleaned text to
# stdout. (Titles come from a static well-known-interrupt map in rbil_build.sh; a
# derived "dominant category" was tried and rejected as misleading, since a vendor
# product with many sub-functions outweighs the interrupt's actual purpose.)
import sys, re
from bs4 import BeautifulSoup

s = BeautifulSoup(sys.stdin.read(), "lxml")
for t in s.find_all(["table", "script", "style", "form"]):
    t.decompose()
for h in s.find_all(["h1", "h2"]):
    h.decompose()
body = s.find("body") or s
for br in body.find_all("br"):
    br.replace_with("\n")
txt = body.get_text("\n")
# collapse runs of blank lines, trim trailing spaces
txt = "\n".join(line.rstrip() for line in txt.splitlines())
txt = re.sub(r"\n{3,}", "\n\n", txt).strip()
sys.stdout.write(txt + "\n")
