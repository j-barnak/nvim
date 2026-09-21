#!/usr/bin/env python3
# Pre-process a MaskRay blog page before the webextract/pandoc pipeline.
# MaskRay's code blocks are Rouge "table" highlights:
#   <figure class="highlight"><table><tr>
#     <td class="gutter"><pre><span class="line">1</span><br>...</pre></td>
#     <td class="code"><pre><span class="line">code</span><br>...</pre></td>
#   </tr></table></figure>
# pandoc renders the <table> as a mangled table and the <br>-separated lines
# collapse onto one line, then the raw HTML is stripped - losing all code. Replace
# each such figure with a clean <pre><code> holding the code column with real
# newlines, so pandoc emits a fenced block. Reads HTML on stdin, writes on stdout.
import sys
from bs4 import BeautifulSoup

s = BeautifulSoup(sys.stdin.read(), "lxml")
for fig in s.select("figure.highlight"):
    codepre = fig.select_one("td.code pre")
    if codepre is None:
        pres = fig.find_all("pre")
        codepre = pres[-1] if pres else None
    if codepre is None:
        continue
    for br in codepre.find_all("br"):
        br.replace_with("\n")
    text = codepre.get_text().strip("\n")
    pre = s.new_tag("pre")
    code = s.new_tag("code")
    code.string = "\n" + text + "\n"
    pre.append(code)
    fig.replace_with(pre)
sys.stdout.write(str(s))
