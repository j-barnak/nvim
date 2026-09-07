# mdx2html.py - reconstruct the one Gatsby-SPA chapter of bootloader-articles.
# joe-bergeron.com is a client-only Gatsby SPA: curl and every Wayback snapshot
# return an empty shell. The article body lives in Gatsby's page-data JSON as a
# compiled-MDX tree; this converts that tree to HTML wrapped in <div id="mdx">,
# which then runs the ordinary 'content div#mdx <url> abs' pipeline. One-off for
# that chapter (its frozen cache is committed as an artifact).
"""Convert a Gatsby-plugin-mdx compiled `node.body` into plain HTML.

joe-bergeron.com is a client-only Gatsby SPA: curl gets an empty shell and no
Wayback snapshot ever captured server-rendered HTML. The article text lives
only in the site's GraphQL page-data JSON, as a compiled MDX module whose whole
body is a regular tree of  mdx("tag", propsOrNull, ...children)  calls (the same
category as the emulator book's GitBook ch 8, whose cache is the underlying
content, not the SPA shell). This walks that call tree and emits the HTML the
article would have rendered to, wrapped in <div id="mdx">, so the ordinary
`webextract content div#mdx <url> abs` stage can freeze it like any static page.

Reads the compiled body on stdin, writes HTML on stdout. No JS is executed:
this is a parser for the mdx()-call subset only, not an evaluator.
"""
import html
import sys

src = sys.stdin.read()
i = src.find("MDXContent")
i = src.find("return", i)
i = src.find("mdx(", i)

VOID = {"br", "hr", "img"}
# tags MDX emits that map onto a different HTML element
REMAP = {"tt": "code", "inlineCode": "code"}


class P:
    def __init__(self, s, pos):
        self.s = s
        self.p = pos

    def ws(self):
        while self.p < len(self.s) and self.s[self.p] in " \t\r\n":
            self.p += 1

    def value(self):
        self.ws()
        c = self.s[self.p]
        if c == '"':
            return ("str", self.string())
        if c == "{":
            return ("obj", self.obj())
        if c == "[":
            return ("arr", self.arr())
        # identifier / keyword / number, optionally a call
        j = self.p
        while self.p < len(self.s) and (self.s[self.p].isalnum()
                                        or self.s[self.p] in "_$."):
            self.p += 1
        name = self.s[j:self.p]
        self.ws()
        if self.p < len(self.s) and self.s[self.p] == "(":
            args = self.args()
            if name == "mdx":
                return ("el", self.element(args))
            return ("call", None)          # _extends(...) etc: opaque
        return ("lit", name)               # null / true / number

    def string(self):
        assert self.s[self.p] == '"'
        self.p += 1
        out = []
        while True:
            c = self.s[self.p]
            if c == "\\":
                nx = self.s[self.p + 1]
                out.append({"n": "\n", "t": "\t", "r": "\r", '"': '"',
                            "\\": "\\", "/": "/", "b": "\b", "f": "\f"}.get(nx, nx))
                self.p += 2
                if nx == "u":
                    # \uXXXX already consumed 'u'; take 4 hex
                    hexs = self.s[self.p:self.p + 4]
                    out[-1] = chr(int(hexs, 16))
                    self.p += 4
                continue
            if c == '"':
                self.p += 1
                return "".join(out)
            out.append(c)
            self.p += 1

    def obj(self):
        assert self.s[self.p] == "{"
        self.p += 1
        d = {}
        while True:
            self.ws()
            if self.s[self.p] == "}":
                self.p += 1
                return d
            # key: bare ident or "quoted"
            if self.s[self.p] == '"':
                key = self.string()
            else:
                j = self.p
                while self.s[self.p] not in " \t\r\n:":
                    self.p += 1
                key = self.s[j:self.p]
            self.ws()
            assert self.s[self.p] == ":"
            self.p += 1
            val = self.value()
            d[key] = val[1] if val[0] == "str" else val
            self.ws()
            if self.s[self.p] == ",":
                self.p += 1

    def arr(self):
        self.p += 1
        out = []
        while True:
            self.ws()
            if self.s[self.p] == "]":
                self.p += 1
                return out
            out.append(self.value())
            self.ws()
            if self.s[self.p] == ",":
                self.p += 1

    def args(self):
        assert self.s[self.p] == "("
        self.p += 1
        out = []
        while True:
            self.ws()
            if self.s[self.p] == ")":
                self.p += 1
                return out
            out.append(self.value())
            self.ws()
            if self.s[self.p] == ",":
                self.p += 1

    def element(self, args):
        tag = args[0][1] if args[0][0] == "str" else None   # MDXLayout ident
        props = args[1][1] if len(args) > 1 and args[1][0] == "obj" else {}
        children = args[2:] if len(args) > 2 else []
        return {"tag": tag, "props": props, "children": children}


def render(node, out):
    kind, val = node
    if kind == "str":
        out.append(html.escape(val))
        return
    if kind != "el":
        return                       # lit / call / obj / arr: nothing to render
    el = val
    tag = el["tag"]
    if tag is None:                  # MDXLayout wrapper: unwrap
        for ch in el["children"]:
            render(ch, out)
        return
    tag = REMAP.get(tag, tag)
    attrs = ""
    for k, v in el["props"].items():
        if k in ("parentName", "mdxType"):
            continue
        if isinstance(v, tuple):     # non-string prop value: skip
            continue
        name = "class" if k == "className" else k
        attrs += ' %s="%s"' % (name, html.escape(str(v), quote=True))
    if tag in VOID:
        out.append("<%s%s/>" % (tag, attrs))
        return
    out.append("<%s%s>" % (tag, attrs))
    for ch in el["children"]:
        render(ch, out)
    out.append("</%s>" % tag)


p = P(src, i)
p.p += len("mdx")
root_args = p.args()
root = ("el", p.element(root_args))
out = ['<div id="mdx">']
render(root, out)
out.append("</div>")
sys.stdout.write("".join(out))
