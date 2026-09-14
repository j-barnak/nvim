#!/usr/bin/env python3
# o1-labs.github.io/ocamlbyexample stores its prose as LITERAL markdown text in
# the HTML (the site never renders **bold**/`code`/[links]), so pandoc -f html
# escapes those markers (\*\*match\*\*, \`match\`). Un-escape that markdown
# punctuation OUTSIDE fenced code blocks so the reader renders the intended
# emphasis / inline code / links. Code fences are left byte-intact.
import re, sys

# markers the site uses as markdown and pandoc escaped: emphasis, inline code,
# links. Deliberately NOT '-' '.' '+' '#' at line starts (would forge lists/
# headings out of prose).
UNESC = re.compile(r'\\([`*_\[\]()~])')

# the site appends a "next: [..](..)" / "previous: [..](..)" footer nav line to
# every chapter body: navigation chrome, dropped.
FOOTER = re.compile(r'^\s*(next|previous):\s', re.I)

def run(text):
    out, fence = [], False
    for ln in text.split("\n"):
        s = ln.lstrip()
        if s.startswith("```") or s.startswith("~~~"):
            fence = not fence
            out.append(ln)
            continue
        if not fence and FOOTER.match(ln):
            continue
        out.append(ln if fence else UNESC.sub(r"\1", ln))
    # drop any trailing blank lines left by removing the footer
    while out and out[-1].strip() == "":
        out.pop()
    return "\n".join(out)

if __name__ == "__main__":
    sys.stdout.write(run(sys.stdin.read()))
