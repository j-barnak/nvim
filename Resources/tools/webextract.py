"""Extract the article body from a saved web page, for the frozen doc cache.

The build pipeline is not otherwise recorded anywhere in this repository, and
an audit has already been burned once by "rebuild with the current tool" being
ambiguous while this file had uncommitted changes, so the exact commands that
produced Resources/docs/.webcache live here, next to the tool that runs them.
Every book goes through the same three stages,

    curl -fsSL --compressed <url>
      | python3 webextract.py <mode> <selector> <page-url> <opts>
      | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs
      | python3 webextract.py clean "" "" <clean-opts>

    cache file = Resources/docs/.webcache/<sha256 of the index.tsv URL>.txt

and differ only in <mode> <selector> <opts>. --preserve-tabs is not optional
(see the note at the end of this docstring).

    osdev            mediawiki "" https://wiki.osdev.org      clean opts: listsep
    browser-eng      content body <url> wbe,abs
    learncpp         content div.entry-content <url> abs
    learnopengl      content div#content <url> abs,logl
    revers-hyper     content div.page-contents <url> reveng,abs
    rayanfam         content div.post-content
    rust-atomics     content article "" guesslang
    herd7            content body
    kernel-labs      content 'div[itemprop=articleBody]' "" sphinx
    kernel-internals content article.md-content__inner <url> mkdocs,abs
    packer           content div.page-html-padded <url> ftl,abs
    snapshot-fuzzer  content div.post-content <url> abs                  (ch 1-6, 8-13)
                     content div.entry-content <url> doare,abs           (ch 7)
    astra            content div.post-content <url> chroma,abs           (ch 1)
                     content div.post-body <url> abs                     (ch 4-7)
                     ch 2 and 3 are .txt whitepapers, wrapped in a bare fence,
                     with no HTML stage at all
    kernel-ctf       content section.article-content <url> abs           (ch 1-2)
                     content div.content <url> chroma,abs                (ch 3-5)
                     content article <url> latexml,abs                   (ch 6)
                     content div.post-text <url> duasynt,abs             (ch 7)
                     content div.article-prose <url> chroma,abs          (ch 8)
                     content div.post-content <url> chroma,abs           (ch 9)
                     content div.post-body <url> gist=<dir>,abs          (ch 10)
    slub             content div.framed <url> phrack,abs                 (ch 1)
                     content div.entry-content <url> brush,jetpack,abs   (ch 2)
                     content article.post <url> abs                      (ch 3)
                     content div.post-content <url> brush,unescape,abs   (ch 5-8)
                     content div.ArticleText <url> lwn,abs               (ch 9)
                     content div.post-body <url> abs                     (ch 10)
                     content article.md-content__inner <url> mkdocs,abs  (ch 11)
                     content div.post-content <url> chroma,abs           (ch 12)
                     content div.content <url> abs                       (ch 13)
                     ch 4 and 14 are PDFs and have no HTML stage: both go
                     through pdf_build.sh's byte filters (control bytes,
                     ligatures) into one text file, the slide deck with
                     "pdftotext -layout" and its xairy.io watermark dropped,
                     the two-column paper through a recursive XY-cut of each
                     page (a "pdftotext -layout" per column and per full-width
                     block, in reading order), because plain reading-order mode
                     flattens every listing to the left margin and loses the
                     line-number gutter its captions refer to, while a whole-page
                     -layout interleaves the two columns.
    kernel-exploitation (the dojo) is 77 chapters from many different sites, so
                     the selector/opts vary per chapter; only the ones that
                     needed a repair beyond a plain "content <sel> <url> abs"
                     are recorded here (the rest are ordinary content extracts):
                     content article.post-article <url> ec,starlight,abs
                                                 (r1ru.github.io: ch 1,17/64,21,
                                                  23,26,29,31 - Expressive Code)
                     content div.post-body <url> shiki,abs   (kylebot: ch 52)
                     content div.post-body <url> vscode,abs  (willsroot: ch
                                                  18/32, one shared cache)
                     content div.entry-content <url> abs   clean opts: nbsp
                                                 (exodusintel: ch 7, ch 58)
                     content div.content <url> chroma,lazyimg,abs (itaybel: ch24)
                     content div.bpp-post-content <url> lazyimg,abs (ctfiot: ch77)
                     ch 8 (0xten.gitbook.io) is a React SPA curl cannot render;
                     its cache is GitBook markdown, fixed in place by the gitbook
                     clean opt ({% embed %} -> bare autolink).

The <opts> are a comma-separated set. Each one exists because a real source in
this library needs it; each is named after the generator that emits the markup,
and every one is documented at the point it runs:

    abs        resolve relative href/src/srcset/poster against the page URL
    sphinx     Sphinx / sphinx_rtd_theme: lexer on the grandparent div, the
               <span class="pre"> shrapnel inside inline <code>
    chroma     Hugo's <pre class="chroma"><code class="language-c">
    brush      WordPress SyntaxHighlighter's <pre class="brush: cpp; ...">
    latexml    arXiv LaTeXML \\lstlisting, rebuilt from its own base64 payload
    gist=DIR   Blogger's <script src="gist.github.com/...js"> embeds, inlined
               from files fetched into DIR and named after the gist's ?file=
    ftl        fasterthanli.me's <figure class="code-block"> listings, its
               <picture>/<video>, and its two-speaker asides
    mkdocs     mkdocs-material's site nav, sidebars and headerlinks
    unescape   undo a doubly-escaped entity inside <pre> (blogs.oracle.com)
    phrack     phrack.org's issue index table, and its one 80-column <pre>
    lwn        LWN's reader-comment form and keyword index
    jetpack    WordPress.com's "Share this" / "Related" block
    doare      doar-e.github.io's date strip and its language-less Pygments blocks
    duasynt    duasynt.com's section headings, drawn as <div class="post-section">
    guesslang  label an attribute-less <pre> from its own text (rust-atomics)
    wbe        browser.engineering's <header> social links, print-edition
               <aside class="ad">, Substack <div id="signup">, and <footer>
               (its custom pandoc template has no article wrapper)
    logl       learnopengl.com's hidden <h1 id="content-url"> URL-path heading
    reveng     revers.engineering's author box, Digiprove seal and license table
    ec         Astro Expressive Code's <div class="ec-line"> per-line code, and
               its "Terminal window" / file-name code-frame <figcaption>
    shiki      Shiki / hexo <span class="line"> per-line code (welded by <br>)
    starlight  Astro Starlight's bare admonition label (<p class="aside-title">)
    vscode     VS Code "Copy With Syntax Highlighting" pasted into a bare <p>
               of hljs / white-space:pre spans, with no <pre> (willsroot)
    lazyimg    promote an <img>'s data-src/data-srcset over a lazy-load
               placeholder (a spinner SVG, a shared 1x1), dropping the leftover
    nbsp       (clean opt) normalise U+00A0 in PROSE too, for a WordPress page
               that sprinkles it as an extraction artifact (exodusintel)
    gitbook    (clean opt) unwrap GitBook's {% embed url="<U>" %} to bare <U>

Some rules are unconditional because the markup they repair is never anything
but damage: Cloudflare's data-cfemail obfuscation (which eats real text such as
`cargo add enumflags2@0.6` and `change_number@got.plt`), the deprecated <xmp>
element (which pandoc reads as prose, running a 10-line SQL listing together),
a permalink glyph anchor (Sphinx's 580 pilcrows), and a header row whose cells
are <td> inside <thead> (which pandoc demotes to a body row and then prints a
blank header above - the ELF relocation tables lost the "Calculation" column
that makes "S + A - P" mean anything). epub_build.sh's flatten_tables already
folds thead the same way; the two are deliberately consistent.

--preserve-tabs is not optional. Without it pandoc expands a tab inside <code>
to the next tab stop computed from the character's ABSOLUTE COLUMN in the input,
and this tool writes the whole document as a single line, so every tab-indented
listing is indented by an amount that depends on how much text happens to
precede it in the file. Deleting one icon-only anchor in a heading re-indented
19 code lines two files away. With --preserve-tabs the tab is written through
unchanged and the indentation is the author's.
"""

import base64
import os
import re
import sys
from urllib.parse import urljoin
from bs4 import BeautifulSoup, NavigableString

# lxml is a hard requirement, deliberately not a preference. html.parser cannot
# recover a table whose tags are not closed - learncpp's 4.11 "Chars" ASCII
# table came out as one 4,000-character line, and other malformed tables were
# re-nested into blobs with cells duplicated - so the parser choice is a
# content-fidelity question, not a performance one. It is imported here rather
# than being tried with a fallback because a fallback would make the output of
# this tool depend on which parser happens to be installed on the machine doing
# the rebuild, and "which tool built this?" is exactly the ambiguity that cost
# this cache an audit round already. Fail loudly instead.
try:
    import lxml  # noqa: F401
except ImportError:
    sys.exit("webextract.py: lxml is required (pip install lxml / apt install "
             "python3-lxml). Refusing to fall back to html.parser: the output "
             "would silently depend on the machine doing the build.")

mode = sys.argv[1]
arg = sys.argv[2] if len(sys.argv) > 2 else ""
base = sys.argv[3] if len(sys.argv) > 3 else ""
opts = set(x for x in (sys.argv[4] if len(sys.argv) > 4 else "").split(",") if x)
raw = sys.stdin.read()


def opt(name):
    """A bare "sphinx"-style flag, or the value of a "gist=DIR"-style one."""
    if name in opts:
        return True
    for o in opts:
        if o.startswith(name + "="):
            return o[len(name) + 1:]
    return False


# Real code-fence languages. Whatever else lands on a fence is a CSS class the
# source leaked through pandoc, not a language: "language-cpp" is Prism's raw
# class (learncpp puts it on terminal output as readily as on code), "verbatim"
# is LaTeX2HTML's, "chroma" is Hugo's. Such a label is worse than none, because
# the reader's highlighter believes it, so the fence keeps the block and drops
# the label. Same allow-list idea as epub_build.sh, which already does this for
# the epub path; the tail of the list is the SyntaxHighlight lexers the OSDev
# wiki actually uses, which the epub list did not need.
_LANGS = set("""
c cpp c++ cc cxx h hpp cs csharp objc rust rs python py py3 js javascript jsx mjs ts
typescript tsx json json5 jsonc sh bash zsh shell console shell-session sh-session
shellsession terminal doscon bat batch powershell ps1 java kotlin kt go golang lua ruby
rb perl pl php swift scala r matlab octave html xhtml xml svg css scss sass less styl
yaml yml toml ini cfg conf sql haskell hs ocaml ml sml fsharp fs asm nasm gas x86asm
armasm mips llvm diff patch udiff make makefile cmake meson ninja dockerfile docker text
plaintext plain txt none nohighlight ada d dart elixir ex erlang clojure clj lisp elisp
scheme racket vim viml vimscript proto protobuf graphql gql markdown md rst tex latex
bibtex verilog systemverilog vhdl gdb ld linker-script nginx apache groovy gradle tcl
awk sed regex ebnf bnf abnf pseudocode
cobol dts fortran modula2 nix objdump pascal vbnet vbscript winbatch zig
""".split())

# A language name that means "no highlighting": Sphinx writes highlight-none
# for a literal block, Hugo and Rouge write "plaintext"/"text" for real plain
# text. The first is the absence of a declaration and must not become a label
# ("``` none" tells the reader nothing and is not a language); the second is a
# declaration and is kept.
_NOLANG = {"none", "default", "nohighlight", "auto"}


def fence_lang(info):
    """The language a fence should carry, or "" for a bare fence. Always
    lowercased: Ghost and Hugo leak the author's "language-C", and a reader's
    highlighter is not obliged to know that "C" is "c" (the rest of the library
    writes it lowercase, so an uppercase label would also read as a different
    language to a grep over the cache)."""
    lang = info[len("language-"):] if info.lower().startswith("language-") else info
    return lang.lower() if lang.lower() in _LANGS else ""


def cell_runs(cell):
    """The cell's text in document order, each run tagged with the href of the
    <a> it sits in: get_text(" ", strip=True) with the links kept. Rebuilding a
    cell from its text alone dropped every link in it, which cost the OSDev
    wiki's link tables (Technical Specifications, Projects, Books) the column
    that is their whole point."""
    runs = []
    for t in cell.find_all(string=True):
        if type(t) is not NavigableString:
            continue  # a comment or a doctype, which get_text() skips too
        s = t.strip()
        if not s:
            continue
        a = t.find_parent("a")
        if a is not None and not a.has_attr("href"):
            a = None
        if runs and a is not None and runs[-1][0] is a:
            runs[-1][1].append(s)
        else:
            runs.append((a, [s]))
    return [(a["href"] if a is not None else None, " ".join(parts)) for a, parts in runs]


def fill(runs, into, soup):
    """Write the runs into an element, one <a> per linked run."""
    for i, (href, text) in enumerate(runs):
        if i:
            into.append(NavigableString(" "))
        if href:
            a = soup.new_tag("a", href=href)
            a.string = text
            into.append(a)
        else:
            into.append(NavigableString(text))


def table_rows(table):
    """The table's rows as (row-is-a-header-row, cells, row element), in
    document order. A row is normally a <tr>, but a <thead> may hold its cells
    with no <tr> around them at all - which is exactly what fasterthanli.me
    serves, and lxml keeps it that way - and then find_all("tr") never sees the
    header cells and the whole header is DROPPED: all six tables in the packer
    book shipped with a blank header line, so the ELF relocation tables lost
    the "Calculation" column that makes "S + A - P" readable, and a CPU history
    table lost "Year | Model | Pins | Data width | Address width | Address
    space". So a <thead>/<tbody>/<tfoot> holding cells directly is a row too."""
    out = []
    for el in table.find_all(["tr", "thead", "tbody", "tfoot"]):
        if el.find_parent("table") is not table:
            continue
        if el.name == "tr":
            if el.find_parent("tr") is not None:
                continue
            cells = [x for x in el.find_all(["td", "th"]) if x.find_parent("tr") is el]
            out.append((el.find_parent("thead") is not None, cells, el))
        else:
            cells = el.find_all(["td", "th"], recursive=False)
            if cells:
                out.append((el.name == "thead", cells, el))
    return out


def grid(table):
    """The table's cells as a rectangular grid with colspan/rowspan expanded:
    (row-is-in-thead, [(cell, tag name) per column]). Ignoring the spans slid
    every later value one column left (the IDT vector table read "No" under
    Type) and left every row after the first of a rowspan block empty (the SIB
    table in X86-64 Instruction Encoding). A rowspan repeats its cell down the
    rows it covers; a colspan keeps its value in the first column it covers and
    pads the rest, so the columns line up with their headers without the text
    being printed twice. A pad carries the name of the cell it pads, because
    pandoc reads a row that mixes <th> and <td> as a body row and then prints
    an empty header above it, which is precisely what a spanning header cell
    would produce."""
    out = []
    carry = {}  # column -> [rows still to fill, entry to repeat there]
    for hdr, cells, r in table_rows(table):
        row, i, col = [], 0, 0
        while True:
            if col in carry:
                left, entry = carry.pop(col)
                row.append(entry)
                if left > 1:
                    carry[col] = [left - 1, entry]
                col += 1
                continue
            if i >= len(cells):
                break
            c = cells[i]
            i += 1

            def span(name, c=c):
                try:
                    return min(max(int(c.get(name, 1)), 1), 64)
                except (TypeError, ValueError):
                    return 1
            cs, rs = span("colspan"), span("rowspan")
            for k in range(cs):
                entry = (c if k == 0 else None, c.name)
                row.append(entry)
                if rs > 1:
                    carry[col] = [rs - 1, entry]
                col += 1
        # a rowspan started further right than this row's own cells reach
        while col <= max(carry, default=-1):
            if col in carry:
                left, entry = carry.pop(col)
                row.append(entry)
                if left > 1:
                    carry[col] = [left - 1, entry]
            else:
                row.append((None, "td"))
            col += 1
        out.append((hdr, row))
    return out


def flatten_tables(el, s):
    """Flatten block-content tables so pandoc's gfm writer never drops them to a
    bare "[TABLE]": a table with block content is linearized (each row -> its
    text, then its <pre> code) so nothing is discarded; a simple table is
    rebuilt with inline-only cells so it can be piped; the <caption> is kept."""
    for table in [t for t in el.select("table") if t.find_parent("table") is None]:
        div = s.new_tag("div")
        cap = table.find("caption")
        if cap:
            p = s.new_tag("p"); st = s.new_tag("strong")
            st.string = cap.get_text(" ", strip=True); p.append(st); div.append(p)
        if table.find(["pre", "ul", "ol"]):
            for _hdr, _cells, r in table_rows(table):
                pres = [pr.extract() for pr in r.find_all("pre")]
                runs = cell_runs(r)
                if runs:
                    p = s.new_tag("p"); fill(runs, p, s); div.append(p)
                for pr in pres:
                    div.append(pr)
        else:
            def cell(c, name):
                nc = s.new_tag(name)
                if c is None:
                    return nc
                runs = cell_runs(c)
                txt = " ".join(t for _, t in runs)
                inner = c.find(["code", "samp", "kbd", "tt", "var"])
                if (inner and txt and not any(h for h, _ in runs)
                        and inner.get_text(" ", strip=True) == txt):
                    # whole cell is verbatim: keep a <code> wrapper so pandoc
                    # does not \-escape it (which drops \' \" \. ( ) etc.)
                    code = s.new_tag("code"); code.string = txt; nc.append(code)
                else:
                    fill(runs, nc, s)
                return nc

            g = grid(table)
            head = [row for hdr, row in g if hdr]
            body = [row for hdr, row in g if not hdr]
            nt = s.new_tag("table")
            if head:
                # A header cell may be a <td> that only a thead CSS selector
                # made bold, and pandoc reads a row of <td> as body text and
                # then invents a BLANK header above it: all six tables in the
                # packer book shipped with an empty header row, which is how
                # the ELF relocation tables lost the "Calculation" column that
                # makes "S + A - P" readable, and how a CPU table lost
                # "Year | Model | Pins | Data width | ...". gfm has exactly one
                # header row, so fold a multi-row thead down its columns. Same
                # rule, and for the same reason, as epub_build.sh.
                nr = s.new_tag("tr")
                for j in range(max(len(r) for r in head)):
                    col = [r[j] for r in head if j < len(r)]
                    # the columns a colspan pads carry its label only when a
                    # sub-header sits under them; a colspan with no second
                    # header row leaves them blank rather than repeating itself
                    sub = any(c is not None for c, _ in col)
                    seen = []
                    for own, _ in col:
                        if own is None:
                            continue
                        if not any(own is x for x in seen):
                            seen.append(own)
                    if len(seen) == 1 and (seen[0] is col[0][0] or sub):
                        nc = cell(seen[0], "th")
                    else:
                        nc = s.new_tag("th")
                        if seen:
                            runs = []
                            for c in seen:
                                runs += cell_runs(c)
                            fill(runs, nc, s)
                    nr.append(nc)
                if nr.find(True):
                    nt.append(nr)
            for row in body:
                nr = s.new_tag("tr")
                for c, name in row:
                    nr.append(cell(c, name))
                if nr.find(True):
                    nt.append(nr)
            div.append(nt)
        table.replace_with(div)


# A permalink glyph: the anchor beside a heading that every static-site
# generator hangs there. Sphinx uses U+00B6 with title="Permalink to this
# headline" (580 of them in the kernel-labs book, shipped as a visible
# "[¶](#x "Permalink to this headline")" on every heading line), mkdocs-material
# and Hugo use a link symbol or a literal "#". drop_empty_links cannot see them
# because the glyph IS text, so match the glyph plus the generator's own class
# or title - never a bare "#" that is part of a sentence.
_PERMA_GLYPH = {"¶", "§", "#", "\U0001f517", "∞", "⚓", "⚭"}
_PERMA_CLASS = {"headerlink", "anchor", "anchor-link", "permalink", "hash-link",
                "header-link", "heading-link", "anchorjs-link", "md-content__button"}


def drop_permalinks(el):
    """Remove the permalink anchor beside a heading. Returns the count."""
    n = 0
    for a in el.find_all("a", href=True):
        if a.get_text(strip=True) not in _PERMA_GLYPH:
            continue
        cls = set(a.get("class") or [])
        title = (a.get("title") or "").lower()
        if (cls & _PERMA_CLASS or title.startswith("permalink")
                or a.get("href", "").startswith("#")
                and a.find_parent(["h1", "h2", "h3", "h4", "h5", "h6"]) is not None):
            a.decompose()
            n += 1
    return n


def undo_cf_email(el):
    """Cloudflare's Email Address Obfuscation replaces anything that looks like
    an address with <a class="__cf_email__" data-cfemail="HEX">[email protected]</a>,
    and it does it inside listings too, so on a technical site it is not a
    privacy feature but silent corruption of the article: `cargo add
    enumflags2@0.6` became `cargo add [email protected]`, a gdb dump's
    `<change_number@got.plt>` was destroyed ten times in one chapter, and a
    hexdump lost the ASCII column of the line holding `.@.8...@`. The attribute
    is the plaintext XORed with its own first byte, so put the author's text
    back. Also covers the "email-protection#HEX" href form and the
    /cdn-cgi/l/email-protection script the page loads to do the same job."""
    n = 0
    for a in el.select(".__cf_email__[data-cfemail]"):
        h = a["data-cfemail"]
        try:
            b = bytes.fromhex(h)
        except ValueError:
            continue
        a.replace_with(NavigableString("".join(chr(c ^ b[0]) for c in b[1:])))
        n += 1
    for a in el.select('a[href*="/cdn-cgi/l/email-protection#"]'):
        h = a["href"].split("#", 1)[1]
        try:
            b = bytes.fromhex(h)
        except ValueError:
            continue
        a.replace_with(NavigableString("".join(chr(c ^ b[0]) for c in b[1:])))
        n += 1
    for sc in el.select('script[src*="/cdn-cgi/scripts/"][src*="email-decode"]'):
        sc.decompose()
    return n


def normalise_verbatim(el, s):
    """<xmp> (and its siblings <listing> and <plaintext>) is the pre-HTML4 way
    of writing a preformatted block. It is deprecated, so pandoc's HTML reader
    has no rule for it and folds the content into the surrounding prose: astra
    chapter 5's ten-line SQL example shipped as one run-on line. The element
    means exactly what <pre> means, so say so."""
    n = 0
    for x in el.find_all(["xmp", "listing", "plaintext"]):
        pre = s.new_tag("pre")
        code = s.new_tag("code")
        code["data-code"] = "1"   # an attribute pandoc cannot write in gfm, so
        code.string = x.get_text()  # the block fences without a bogus label
        pre.append(code)
        x.replace_with(pre)
        n += 1
    return n


def code_block(text, lang, s):
    """<pre><code class="language-X">, the shape pandoc fences. With no
    language, data-code is an attribute pandoc cannot write in gfm, so the
    fence comes out bare instead of the block coming out INDENTED (which is
    what pandoc does with an attribute-less <pre>, losing the "this is
    verbatim" signal and shifting every line four columns)."""
    pre, code = s.new_tag("pre"), s.new_tag("code")
    if lang and lang.lower() not in _NOLANG:
        code["class"] = "language-" + lang.lower()
    else:
        code["data-code"] = "1"
    code.string = text
    pre.append(code)
    return pre


def absolutise(el, page_url):
    """Resolve every relative reference against the page's own URL. Only the
    mediawiki mode used to do this, so a content-mode site that writes its
    images relative shipped "![Fig 1](/wp-content/.../slab-layout.png)": a dead
    link that also READS as an absolute path on the reader's own filesystem."""
    for attr in ("href", "src", "poster", "data"):
        for t in el.find_all(attrs={attr: True}):
            v = t.get(attr) or ""
            if v.startswith(("data:", "mailto:", "javascript:", "#", "tel:")):
                continue
            if re.match(r"[A-Za-z][A-Za-z0-9+.\-]*://", v):
                continue  # already absolute: urljoin would also NORMALISE it,
                          # and it silently dropped the empty fragment off a
                          # link the author wrote as "https://wandbox.org/#"
            t[attr] = urljoin(page_url, v)
    for t in el.find_all(attrs={"srcset": True}):
        parts = []
        for cand in t["srcset"].split(","):
            cand = cand.strip()
            if not cand:
                continue
            bits = cand.split(None, 1)
            parts.append(" ".join([urljoin(page_url, bits[0])] + bits[1:]))
        t["srcset"] = ", ".join(parts)


def drop_empty_links(el):
    """Remove every <a href> that shows the reader nothing, because pandoc
    writes it as a bare "[](url)". Every case in the frozen library is an icon
    the cache cannot carry: MediaWiki's thumbnail "Enlarge" button is an empty
    <a> inside div.magnify drawn with a CSS background (24 on the OSDev wiki),
    and learncpp (57) and rayanfam (220) hang a font-awesome permalink icon off
    every heading. An <a> around a picture is not empty, so it stays."""
    for a in el.find_all("a", href=True):
        if a.get_text(strip=True):
            continue
        if a.find(["img", "svg", "picture", "video", "audio", "object",
                   "embed", "iframe", "canvas"]):
            continue
        a.decompose()


def lift_stray_list_children(el):
    """A <p>, <i> or nested <ol> written as a direct child of a list, rather
    than inside an <li>, is invalid HTML and pandoc silently discards it: the
    RS-232 handshake on OSDev's Serial Port lost the two paragraphs that mark
    where link establishment ends and transmission begins, and the EITHER / OR
    that separate its two alternatives. Move each stray into the <li> before it
    (or ahead of the list, if it comes first), which is where it reads, and the
    numbering of the real items is left alone. An inline stray gets a space in
    front of it, or it welds onto the last word of the item it joins
    ("Link establishment:EITHER")."""
    block = {"p", "div", "ol", "ul", "dl", "table", "pre", "blockquote",
             "figure", "h1", "h2", "h3", "h4", "h5", "h6", "hr"}
    for lst in el.find_all(["ol", "ul"]):
        prev = None
        for child in list(lst.children):
            if getattr(child, "name", None) is None:
                continue
            if child.name == "li":
                prev = child
                continue
            child.extract()
            if prev is None:
                lst.insert_before(child)
            else:
                if child.name not in block and prev.get_text(strip=True):
                    prev.append(NavigableString(" "))
                prev.append(child)


if mode == "clean":
    # Post-pandoc pass over the markdown. Three jobs, all of which have to know
    # where the code blocks are, so they share one walk:
    #
    # 1. Rewrite each fence's info string to a real language or to nothing (see
    #    _LANGS). It runs here rather than in the HTML because pandoc writes an
    #    indented block, not a bare fence, for a <pre> carrying no attribute at
    #    all, so the label cannot simply be dropped upstream.
    # 2. Normalise U+00A0 to a plain space INSIDE a fence. A wiki author who
    #    types a non-breaking space in a listing (the OSDev wiki's HTML carries
    #    1,088 &#160; entities, 551 of them landing inside a fence on 92
    #    articles) hands the reader code that does not compile: gcc reads
    #    `asm ("movl %1,<U+00A0>%%eax;` as a stray byte, not as whitespace. In
    #    prose a non-breaking space is deliberate typography, so this only ever
    #    touches the interior of a code block, never a fence marker and never a
    #    line outside a fence.
    # 3. With "listsep": drop the lone "&nbsp;" paragraph pandoc writes between
    #    two adjacent lists to stop them merging when the markdown is
    #    re-parsed. We show the markdown as text, so the reader just sees the
    #    raw entity; the blank line on either side of it already separates the
    #    two lists on screen. It is opt-in because it rewrites a page that has
    #    no other reason to change, and only the OSDev wiki (whose source makes
    #    a fresh <ul> at every blank line in a list) has it in quantity.
    #
    # The fence tracker follows CommonMark: a block ends only on a fence of the
    # same character, at least as long as the one that opened it, and with no
    # info string. Matching on the character alone closed an outer ```` block
    # at the first ``` line inside it, and then read the rest of the code as
    # prose with fences of its own. The prefix allows blockquote markers,
    # because pandoc indents a quoted listing behind "> " and the two herd7
    # pages that quote a session that way kept their bogus label without it.
    out, fence, width = [], "", 0
    for line in raw.split("\n"):
        m = re.match(r"^([ \t]*(?:>[ \t]*)*)([`~]{3,})[ \t]*(\S*)[ \t]*$", line)
        if m and not fence:
            fence, width = m.group(2)[0], len(m.group(2))
            lang = fence_lang(m.group(3))
            line = m.group(1) + m.group(2) + (" " + lang if lang else "")
        elif m and fence == m.group(2)[0] and len(m.group(2)) >= width and not m.group(3):
            fence, width = "", 0
        elif fence:
            line = line.replace("\u00a0", " ")
        elif "listsep" in opts and line.strip() == "&nbsp;":
            if out and not out[-1].strip():
                out.pop()  # it sits in its own paragraph: drop one of the two
            continue       # blank lines with it, and leave the lists one apart
        elif "nbsp" in opts:
            # Some WordPress sites (exodusintel) sprinkle U+00A0 through PROSE,
            # not typography but an extraction artifact left around links and
            # inline code (342 on 78 lines in one post), which breaks a word
            # search over the cache. In-fence NBSP is already normalised above;
            # this opt extends that to the prose of a page known to carry it, so
            # it is never on by default (a deliberate NBSP elsewhere is kept).
            line = line.replace("\u00a0", " ")
        if "gitbook" in opts:
            # GitBook's liquid {% embed url="<U>" %} shortcode survives to the
            # markdown as literal text that GFM does not interpret, burying a
            # clickable link. Unwrap it to the bare autolink the URL already is
            # (angle brackets added if the shortcode lacked them). Runs on fence
            # and prose lines alike; the shortcode never appears inside code.
            line = re.sub(r'\{%\s*embed\s+url="<?([^"<>]+)>?"\s*%\}',
                          r"<\1>", line)
        out.append(line)
    sys.stdout.write("\n".join(out))
    sys.exit(0)

# fasterthanli.me writes its listings as <code class="scroll-wrapper"> inside a
# <figure>, NOT inside a <pre>. libxml2's HTML parser drops whitespace-only
# text nodes it considers ignorable and makes an exception only for <pre> (and
# friends), so parsing the page as served silently DELETES the leading
# indentation and the blank lines of every listing whose line begins with one
# of the author's <a-c>/<a-f> highlight tags: the packer book's first assembly
# block lost 8 spaces on 9 of its 14 lines. html.parser collapses it too; only
# html5lib preserves it, and this tool requires lxml on purpose (see above), so
# the repair is to rename the element in the BYTE STREAM, before any parser
# sees it. Verified on all 18 chapters: 1,584 of 1,584 code blocks then match
# html5lib's reading of the untouched source exactly. Both counts are asserted,
# because the rewrite is only safe while every code figure closes the same way.
if opt("ftl"):
    _o = raw.count('<code class="scroll-wrapper">')
    _c = raw.count("</code></figure>")
    if _o != _c:
        sys.exit("webextract.py: %d code figures open but %d close as expected"
                 % (_o, _c))
    raw = (raw.replace('<code class="scroll-wrapper">', '<pre class="scroll-wrapper">')
              .replace("</code></figure>", "</pre></figure>"))

s = BeautifulSoup(raw, "lxml")

if mode == "links":
    seen = set()
    for a in s.find_all("a", href=True):
        h = a["href"]
        if arg not in h:
            continue
        h = h.split("#")[0].split("?")[0].rstrip("/")
        if h.startswith("/"):
            h = base.rstrip("/") + h
        if h in seen:
            continue
        t = " ".join(a.get_text(" ", strip=True).split())
        if not t or len(t) > 130:
            continue
        seen.add(h)
        sys.stdout.write(t + "\t" + h + "\n")
    sys.exit(0)
elif mode == "lessontable":
    # learncpp TOC: each div.lessontable-row has the lesson number and the link,
    # so emit "N.M Title\tURL" in document (chapter) order.
    for r in s.select("div.lessontable-row"):
        num = r.select_one(".lessontable-row-number")
        a = r.select_one(".lessontable-row-title a[href]")
        if not (num and a):
            continue
        n = " ".join(num.get_text(" ", strip=True).split())
        t = " ".join(a.get_text(" ", strip=True).split())
        href = a["href"].split("#")[0].split("?")[0].rstrip("/")
        sys.stdout.write(f"{n} {t}\t{href}\n")
    sys.exit(0)

# ---------------------------------------------------------------- page repair
# Everything from here to the mode switch runs on every extracted page, in both
# modes, because the markup it repairs is damage wherever it appears.
undo_cf_email(s)

if mode == "content":
    el = s.select_one(arg) or s.find("article")
    if not el:
        sys.exit(1)

    # --- opt-in, per-generator rules, run before the generic ones so the
    # generic ones see the shapes they know.

    if opt("phrack"):
        # phrack.org renders the whole issue's article index as a table INSIDE
        # div.framed, above the phile: navigation, not content.
        for t in el.select("table.tissue"):
            t.decompose()
        # The phile itself is one attribute-less <pre> of 80-column ASCII.
        # pandoc would write that as an INDENTED block, shifting every line
        # four columns and dropping the "this is verbatim" signal from a
        # document that is nothing but verbatim.
        for pre in el.select("pre"):
            pre.replace_with(code_block(pre.get_text(), "text", s))

    if opt("lwn"):
        # LWN keeps the whole reader-comment thread inside div.ArticleText, in
        # the <form> that carries the "post comments" button, and closes the
        # article with its keyword-index table. Neither is the article.
        for t in el.select("form, table.IndexEntries"):
            t.decompose()
        main = el.select_one("main") or el
        kids = [c for c in main.children if getattr(c, "name", None)]
        while kids and kids[-1].name in ("hr", "br"):
            kids.pop().decompose()

    if opt("jetpack"):
        # WordPress.com hangs Jetpack's sharing block ("Share this:", the X and
        # Facebook links, "Like Loading...", "Related") and its ad markers
        # INSIDE div.entry-content, after the article's own last paragraph.
        for t in el.select("div.sharedaddy, #jp-post-flair, div.jp-relatedposts, "
                           ".sd-block, span.wordads-inline-marker, div[id^=atatags-]"):
            t.decompose()

    if opt("duasynt"):
        # duasynt.com draws its section headings as divs, so they otherwise
        # land as a bare word in a paragraph.
        for d in el.select("div.post-section"):
            d.name = "h2"

    if opt("wbe"):
        # browser.engineering ships a custom pandoc template with NO article
        # wrapper: every chapter is flat siblings under <body>, so the selector
        # has to be "body" and the site chrome comes with it. The prev/next and
        # chapter-contents <nav>s go with the generic nav rule; these are what
        # it does not name - the print-edition ad, the Substack signup iframe,
        # and the copyright footer. The <header> holds the chapter's own <h1>
        # title beside three social links (Twitter/Blog/Discussions), so lift
        # the title out and drop the rest of the header with it.
        for t in el.select("aside.ad, #signup, footer"):
            t.decompose()
        head = el.find("header")
        if head is not None:
            h1 = head.find("h1")
            head.replace_with(h1.extract() if h1 is not None else s.new_tag("span"))
        # The book is itself built by pandoc, so a Python listing is
        # <pre class="sourceCode python"><code class="sourceCode python">.
        # pandoc's gfm writer takes the FIRST class as the fence's info string,
        # which is "sourceCode", not "python", so every one of the book's code
        # listings would fence as "``` sourceCode" and clean() (which does not
        # know that word) would then strip it to a bare fence - the language
        # label the reader wants is the SECOND class. Drop the "sourceCode"
        # token so the real language ("python", "javascript", "html", ...) is
        # what pandoc emits and clean() keeps.
        for c in el.select("pre.sourceCode, code.sourceCode"):
            kept = [x for x in (c.get("class") or []) if x != "sourceCode"]
            if kept:
                c["class"] = kept
            else:
                del c["class"]

    if opt("mkdocs"):
        # mkdocs-material renders the WHOLE site nav plus the page's own table
        # of contents into every article, and hangs a permalink anchor off
        # every heading. Only the article body is the article.
        for t in el.select(".md-nav, .md-sidebar, .md-source-file, "
                           ".md-content__button, .md-footer, .md-header, "
                           ".md-top, .md-dialog, .md-feedback, .md-skip"):
            t.decompose()

    if opt("logl"):
        # learnopengl.com's theme prints TWO <h1> at the top of div#content: the
        # real title in <h1 id="content-title"> and, right after it, the URL
        # path in <h1 id="content-url" style="display:none;"> - hidden in the
        # browser but read by pandoc, so every page otherwise opens with a
        # second, duplicate heading ("Getting-started/Hello-Triangle"). It is
        # metadata the theme's script reads, never shown to a reader.
        for t in el.select("#content-url"):
            t.decompose()

    if opt("reveng"):
        # revers.engineering (WordPress) hangs three plugin blocks at the tail
        # of div.page-contents: the PublishPress multiple-authors box (an
        # "Author" widget heading plus avatar and bio), and the Digiprove
        # plugin's copyright seal and its "license terms" table (table.dprv).
        # None are the article; the author's own "Recommended Reading" list is
        # ordinary body content and stays.
        for t in el.select("div.pp-multiple-authors-boxes-wrapper, "
                           "h2.box-header-title, table.dprv, img[src*=dp_seal]"):
            t.decompose()
        for a in el.select('a[href*="digiprove.com"], a[href^="javascript:dprv"]'):
            tgt = a.find_parent("p") or a
            if tgt.parent is not None:
                tgt.decompose()

    if opt("unescape"):
        # blogs.oracle.com's KFENCE post is double-escaped at the source: its
        # HTML holds "&amp;lt;type of error&amp;gt;", so a BROWSER also shows
        # the reader a literal "&lt;". The intended text is the kernel's own
        # report format from Documentation/dev-tools/kfence.rst. Undo the
        # second escaping inside listings only: in prose a literal "&lt;" can
        # be deliberate.
        _ENT = re.compile(r"&(lt|gt|amp|quot|#39|apos);")
        _SUB = {"lt": "<", "gt": ">", "amp": "&", "quot": '"', "#39": "'", "apos": "'"}
        for pre in el.find_all("pre"):
            for t in pre.find_all(string=True):
                if type(t) is not NavigableString or not _ENT.search(t):
                    continue
                t.replace_with(NavigableString(_ENT.sub(lambda m: _SUB[m.group(1)], str(t))))

    if opt("doare"):
        # doar-e.github.io. The date/author/category strip is inside the
        # article container, and its Pygments blocks are
        # <div class="highlight"><pre><span></span><code> with no language
        # anywhere in the HTML (the author's source declared none) and no
        # attribute on the <pre>, so pandoc would write an INDENTED block and
        # add four spaces to every line of every listing.
        for t in el.select("div.well"):
            t.decompose()
        for div in el.select("div.highlight"):
            code = div.select_one("code") or div.select_one("pre")
            if code is None:
                continue
            div.replace_with(code_block(code.get_text(), "", s))

    if opt("brush"):
        # WordPress SyntaxHighlighter writes <pre class="brush: cpp; title: ;
        # notranslate">. pandoc reads the FIRST class as the language, so the
        # fence comes out labelled "brush:" - which the allow-list then
        # (correctly) throws away, losing a language the author DID declare.
        for pre in el.select("pre[class*=brush]"):
            cls = " ".join(pre.get("class") or [])
            lang = cls.split("brush:", 1)[1].split(";")[0].strip() if "brush:" in cls else ""
            pre["class"] = ["language-" + lang.lower()] if lang else []

    if opt("chroma"):
        # Hugo emits <pre tabindex="0" class="chroma"><code class="language-c"
        # data-lang="c">. pandoc builds the block from the <pre>'s own
        # attributes when it has any, so the language on the <code> is dropped
        # and the fence comes out labelled "chroma" (which clean then strips to
        # nothing) or bare. Move the declared language onto the <pre>.
        for pre in el.find_all("pre"):
            code = pre.find("code")
            if code is None:
                continue
            lang = next((c for c in (code.get("class") or [])
                         if c.lower().startswith("language-")), "") or \
                (("language-" + code["data-lang"]) if code.get("data-lang") else "")
            if not lang:
                continue
            # The frozen library labels C as lowercase "c" (never "C"); Ghost
            # and Hugo both leak the source's "language-C".
            pre.attrs = {"class": [lang.lower()]}

    if opt("ec"):
        # Astro Expressive Code renders every source line as a BLOCK-level
        # <div class="ec-line"><div class="code">...styled spans...</div></div>
        # inside <pre data-language="X"><code>, with NO newline anywhere between
        # the lines, so get_text() welds the whole listing onto one physical
        # line (a "//" comment then silently swallows the next statement). The
        # language is on the <pre>; the whole block sits in a
        # <figure class="frame ..."> whose <figcaption> is a code-frame header
        # ("Terminal window", or a file-name tab) - UI chrome, not code. Rebuild
        # each block from its ec-line divs, one newline per line, taking the
        # inner .code text (never the .gutter line numbers), and replace the
        # frame (dropping its caption) so nothing leaks.
        for pre in el.find_all("pre"):
            lines = pre.select("div.ec-line")
            if not lines:
                continue
            lang = (pre.get("data-language") or "").strip()
            body = "\n".join(((ln.select_one("div.code") or ln).get_text())
                             for ln in lines)
            target = (pre.find_parent("div", class_="expressive-code")
                      or pre.find_parent("figure") or pre)
            target.replace_with(code_block(body.rstrip("\n") + "\n", lang, s))

    if opt("shiki"):
        # Shiki / hexo highlight: each source line is a <span class="line">,
        # and the lines are separated ONLY by <br> (which get_text drops) or by
        # nothing at all, so get_text() welds the whole function onto one line.
        # hexo also puts a line-number gutter in a sibling <td class="gutter">
        # (or a first <pre> of <span class="line">N</span> integers) and the
        # language on <figure class="highlight LANG"> ("plaintext" = none).
        # Rebuild each block from the code cell's line spans, one newline each.
        for fig in el.select("figure.highlight, div.highlight, pre.astro-code"):
            cls = [c for c in (fig.get("class") or []) if c != "highlight"]
            lang = cls[0] if cls else ""
            codecell = fig.select_one("td.code") or fig
            pre_in = codecell.select_one("pre") or fig.select_one("pre")
            if pre_in is None or not pre_in.select("span.line"):
                continue
            body = "\n".join(ln.get_text() for ln in pre_in.select("span.line"))
            fig.replace_with(code_block(body.rstrip("\n") + "\n", lang, s))

    if opt("starlight"):
        # Astro Starlight renders an admonition as <aside class="aside ...">
        # opening with <p class="aside-title" aria-hidden="true">note</p> - a
        # label the theme draws next to an icon, hidden from the browser but read
        # by pandoc, so every note/tip/caution block otherwise opens with a bare
        # "note" word on its own line. Drop the label; the aside body stays.
        for t in el.select("p.aside-title[aria-hidden=true]"):
            t.decompose()

    if opt("lazyimg"):
        # Lazy-loading themes put a placeholder in src (a spinner SVG, a 1x1
        # gif) and the real asset in data-src / data-srcset, so the frozen cache
        # would keep only the placeholder. Promote the real source before
        # absolutise resolves it. A placeholder with no data-* to replace it
        # (a shared 1x1 the theme swaps in by other means) carries no figure, so
        # drop it rather than freeze a spinner.
        _PLACEHOLDER = ("loading.min.svg", "/images/t.png", "lazy.png",
                        "spinner.gif", "blank.gif")
        for img in el.find_all("img"):
            for a, b in (("data-src", "src"), ("data-srcset", "srcset"),
                         ("data-original", "src")):
                if img.get(a):
                    img[b] = img[a]
                    del img[a]
            src = img.get("src") or ""
            if any(p in src for p in _PLACEHOLDER):
                img.decompose()

    if opt("vscode"):
        # Some Blogger posts (willsroot) paste code straight out of VS Code's
        # "Copy With Syntax Highlighting": a run of <span class="hljs-..."> and
        # <span style="...white-space:pre;">, wrapped in a bare <p> with NO
        # <pre> around it. lxml keeps the per-line "\n" text nodes, but with no
        # block element pandoc reads the whole listing as PROSE and
        # backslash-escapes it onto ONE line (\#include \<linux/kernel.h\> ...),
        # destroying every code block on the page. A leaf <p> that carries a
        # preformatted (white-space:pre) or hljs span and spans more than one
        # physical line is such a listing: fence it, keeping the newlines the
        # spans already hold. The multi-line test keeps inline code in prose
        # (single line, no "\n") out of it, and only leaf <p> qualify so the
        # post-body container that wraps everything is never swallowed whole.
        for p in el.find_all("p"):
            if p.find(["p", "div", "ul", "ol", "pre", "table", "blockquote"]):
                continue
            code_span = any(
                "white-space: pre" in (sp.get("style") or "")
                or any(c.startswith("hljs") for c in (sp.get("class") or []))
                for sp in p.find_all("span"))
            text = p.get_text()
            if code_span and "\n" in text:
                p.replace_with(code_block(text.rstrip("\n") + "\n", "", s))

    if opt("latexml"):
        # arXiv's LaTeXML writes a \lstlisting as a stack of
        # <div class="ltx_listingline">, one per line, which pandoc writes as
        # prose: line numbers inline, "buf-\>page", a blank line between every
        # source line. LaTeXML also embeds the listing's exact source as a
        # base64 "download" link, so rebuild each listing from that payload -
        # byte exact, tabs included - and drop the download link.
        for lst in el.select("div.ltx_listing"):
            lang = ""
            for c in lst.get("class") or []:
                m = re.match(r"ltx_lst_language_(.+)", c)
                if m:
                    lang = m.group(1).lower()
            data = lst.select_one("div.ltx_listing_data a[href^='data:']")
            text = None
            if data is not None:
                payload = data["href"].split("base64,", 1)
                if len(payload) == 2:
                    text = base64.b64decode(payload[1]).decode("utf-8", "replace")
            if text is None:  # no embedded source: rebuild from the numbered lines
                lines = []
                for line in lst.select("div.ltx_listingline"):
                    for num in line.select(".ltx_lst_numbers, .ltx_lst_number"):
                        num.decompose()
                    lines.append(line.get_text())
                text = "\n".join(lines)
            lst.replace_with(code_block(text.rstrip("\n") + "\n", lang, s))
        # Every figure carries the placeholder alt "Refer to caption"; the real
        # caption is the figure's own <figcaption>, kept alongside, so the alt
        # is just noise in the rendered "![Refer to caption](url)".
        for img in el.find_all("img", alt="Refer to caption"):
            img["alt"] = ""

    gist = opt("gist")
    if gist:
        # Blogger loads every code block through
        # <script src="https://gist.github.com/<id>.js?file=<name>">. A <script>
        # is chrome everywhere else, and dropping it silently emptied ten C
        # listings out of one writeup, so inline each embed from the gist file
        # fetched into DIR (curl -fsSL
        # https://gist.githubusercontent.com/<user>/<id>/raw/<name> -o DIR/<name>).
        for sc in list(el.find_all("script", src=True)):
            m = re.match(r"https?://gist\.github\.com/([^/]+)/([0-9a-f]+)\.js"
                         r"(?:\?file=(.+))?$", sc["src"])
            if not m:
                continue
            user, gid, fname = m.groups()
            path = os.path.join(gist, fname or gid)
            if not os.path.exists(path):
                sys.exit("webextract.py: gist file not fetched: " + path)
            body = open(path, encoding="utf-8", errors="replace").read()
            lang = "c" if (fname or "").endswith((".c", ".h")) else ""
            sc.replace_with(code_block(body.rstrip("\n") + "\n", lang, s))

    if opt("sphinx"):
        # Sphinx (sphinx_rtd_theme, writer-html4) puts the lexer NOWHERE the
        # code block can be read from: the <pre> and the <code> carry no class
        # at all and the language sits on the GRANDPARENT,
        # <div class="highlight-c"><div class="highlight"><pre>. 460 of the
        # kernel-labs book's 492 listings shipped with no language because of
        # it. "highlight-none" is Sphinx for "a literal block", which is the
        # absence of a language, not a language called none.
        for cont in el.select("div[class*=highlight-]"):
            lang = next((c[len("highlight-"):] for c in (cont.get("class") or [])
                         if c.startswith("highlight-")), "")
            pre_in = cont.select_one("pre")
            if pre_in is None:
                continue
            cont.replace_with(code_block(pre_in.get_text(), lang, s))
        # Sphinx also breaks every inline literal into one <span class="pre">
        # per whitespace-separated token, which pandoc writes as one backtick
        # run per span welded together: `struct`` ``file_operations`. 571 of
        # the book's inline literals came out that way, and a reader cannot
        # tell the stray backticks from the code. The spans are a line-breaking
        # hint, and the whitespace between them is a real space.
        for code in el.find_all("code"):
            if len(code.select("span.pre")) < 1:
                continue
            code.string = " ".join(code.get_text().split())

    if opt("ftl"):
        # fasterthanli.me. Chrome that the fixed list below does not name: the
        # series pager (top and bottom), the reading-time/tag strip, the
        # sponsor roll, the "this page is N years old" banner, the newsletter
        # nudge and the bottom "random post" block. The <h1> page title stays:
        # it is the article's own title.
        for t in el.select("div.series-nav, div.page-metadata, p.sponsor-list, "
                           "#sponsor-list, div.after-page-metadata-spacer, "
                           "div.disclosure, div.gentle-nudge-island, "
                           "div.bottom-nav, aside"):
            t.decompose()
        # Every heading is wrapped in <a class="anchor"> (a self-link); pandoc
        # would write the heading text as a link to a fragment that means
        # nothing offline.
        for a in el.select("a.anchor"):
            a.unwrap()
        # <figure class="code-block" data-lang="rust"> holding the
        # scroll-wrapper renamed above, plus, when the language is named, a
        # <span class="language-tag"> whose only content is a private-use-area
        # icon glyph (U+E6AB and friends) that must not land in the listing.
        # data-lang="raw"/"" means the author declared no language.
        for fig in el.select("figure.code-block"):
            for tag in fig.select("span.language-tag"):
                tag.decompose()
            code = fig.select_one("pre.scroll-wrapper") or fig.select_one("code")
            if code is None:
                continue
            lang = (fig.get("data-lang") or "").strip()
            fig.replace_with(code_block(code.get_text(),
                                        "" if lang == "raw" else lang, s))
        # "Cool bear" asides and the two-character dialogues are article
        # content, not chrome: keep the words and the speaker, drop the avatar.
        # A blockquote is how they read.
        for d in el.select("div.tip, div.dialog"):
            head = d.select_one("div.tip-header, div.dialog-head")
            who = ""
            if head is not None:
                who = " ".join(head.get_text(" ", strip=True).split()) or \
                    (head.get("title") or "")
                head.decompose()
            bq = s.new_tag("blockquote")
            if who:
                p = s.new_tag("p"); st = s.new_tag("strong"); st.string = who
                p.append(st); bq.append(p)
            for c in list(d.children):
                bq.append(c.extract())
            d.replace_with(bq)
        # <picture> -> a plain <img> pandoc can write. The <img> inside points
        # at a .jxl, which almost nothing renders; the same asset is offered as
        # webp and avif in the <source> list, so prefer webp 1x, then avif.
        for pic in el.find_all("picture"):
            src = None
            for want in ("image/webp", "image/avif"):
                for cand in pic.find_all("source"):
                    if cand.get("type") != want or cand.get("media"):
                        continue
                    first = (cand.get("srcset") or "").split(",")[0].strip().split(" ")[0]
                    if first:
                        src = first
                        break
                if src:
                    break
            img = pic.find("img")
            src = src or (img.get("src") if img else None)
            if not src:
                pic.decompose()
                continue
            new = s.new_tag("img", src=src)
            new["alt"] = img.get("alt", "") if img else ""
            pic.replace_with(new)
        for vid in el.find_all("video"):
            src = vid.find("source")
            href = (src.get("src") if src else None) or vid.get("poster")
            p = s.new_tag("p")
            if href:
                em = s.new_tag("em"); em.string = "Video: "
                a = s.new_tag("a", href=href); a.string = href.rsplit("/", 1)[-1]
                p.append(em); p.append(a)
            vid.replace_with(p)
        for w in el.select("div.responsive-table, div.paragraph-like"):
            w.unwrap()
        # None of the diagrams carries an alt, so pandoc writes a bare
        # "![](url)" and the reader gets a line of URL with nothing saying what
        # it shows. The author's own file name does say: data-input-path is the
        # source asset ("assets/elf64-file-header.drawio") and the CDN name is
        # the same word with a content hash after a "~".
        for img in el.find_all("img"):
            if img.get("alt"):
                continue
            name = img.get("data-input-path") or img.get("src") or ""
            name = name.rsplit("/", 1)[-1].split("~")[0]
            name = re.sub(r"\.(drawio|svg|webp|avif|jxl|png|jpe?g|gif)$", "", name)
            if name:
                img["alt"] = name

    # --- generic content rules
    for t in el.select("script, style, ins, iframe, nav, #comments, .comments, .code-block-buttons, .prevnext, .share-buttons, .page__share, .pagination, .code-header, .breadcrumbs, .paginav, .post-tags, .entry-footer, .post-footer"):
        t.decompose()
    # hevea (the diy.inria.fr manuals) prints a Previous/Up/Next bar of linked
    # images at the top and bottom of every page. The images are not carried
    # into the frozen cache, so the bar is only dead links; the rule that
    # separates it from the article goes with it.
    nav = el.select('a:has(> img[src*="_motif.svg"])')
    if nav:
        for a in nav:
            a.decompose()
        kids = [c for c in el.children if getattr(c, "name", None)]
        for edge in kids[:1] + kids[-1:]:
            if edge.name == "hr":
                edge.decompose()
    # Jekyll/Rouge highlight blocks put line numbers in a gutter (pre.lineno)
    # that pandoc turns into a bogus ```lineno block of bare numbers. Rebuild
    # each as a clean <pre><code class="language-X"> with only the code column.
    # The language is on the container for Rouge, but Hugo and Jekyll's own
    # kramdown put it on the inner <code class="language-c"> and leave the
    # <figure> classed only "highlight": reading the container alone dropped
    # EVERY label on the two Hugo sites in the slub book (chapter 3 lost all 8,
    # chapter 12 all 21), so fall back to the inner element.
    for cont in el.select("div.highlighter-rouge, figure.highlight"):
        lang = next((c for c in (cont.get("class") or []) if c.startswith("language-")), "")
        codeel = cont.select_one("td.rouge-code") or cont.select_one("pre")
        if not codeel:
            continue
        if not lang:
            inner = cont.find("code")
            if inner is not None:
                lang = next((c for c in (inner.get("class") or [])
                             if c.lower().startswith("language-")), "") or \
                    (("language-" + inner["data-lang"]) if inner.get("data-lang") else "")
                lang = lang.lower()
        pre = s.new_tag("pre")
        code = s.new_tag("code")
        if lang:
            code["class"] = lang
        code.string = codeel.get_text()
        pre.append(code)
        cont.replace_with(pre)
    # An attribute-less <pre> becomes an INDENTED block in pandoc's gfm output,
    # not a fenced one, so the reader gets no language label and no syntax
    # highlighting (marabos.nl/atomics marks every listing this way). Give each
    # bare <pre> a language class, guessed from its own text, so it fences.
    # Only on request: the vote below reads "let " and "->" as Rust, which are
    # just as common in C++ and in MSVC build output, so on a C++ site it would
    # label compiler output and a lambda skeleton "rust".
    _RUST = ("fn ", "let ", "impl ", "pub fn", "use std", "->", "unsafe", "&self", "static ", "match ")
    _ASM = ("mov ", "ldr ", "str ", "ldxr", "stxr", "dmb ", "lock ", "cmpxchg", "xchg", "%rax", "x0,")
    if "guesslang" in opts:
        for pre in el.find_all("pre"):
            if pre.find("code") is not None or pre.get("class"):
                continue  # already labelled, or pandoc can read the label itself
            body = pre.get_text()
            low = body.lower()
            asm = sum(k in low for k in _ASM)
            rust = sum(k in body for k in _RUST)
            lang = "asm" if asm > rust else ("rust" if rust else None)
            if lang:
                code = s.new_tag("code")
                code["class"] = "language-" + lang
                code.string = body
                pre.clear()
                pre.append(code)

    normalise_verbatim(el, s)
    drop_permalinks(el)
    drop_empty_links(el)
    lift_stray_list_children(el)
    if base:
        absolutise(el, base)
    flatten_tables(el, s)
    sys.stdout.write(str(el))
elif mode == "mediawiki":
    # A rendered MediaWiki page (used for the offline OSDev wiki dump). The
    # article body is div.mw-parser-output, which sits inside #mw-content-text
    # and holds no site chrome except the table of contents; the category
    # links, "printfooter" and the site nav are all outside it. Pass a selector
    # as arg to override, and the site root as base to absolutise wiki links.
    el = s.select_one(arg or ".mw-parser-output") or s.select_one("#mw-content-text")
    if not el:
        sys.exit(1)
    for t in el.select("script, style, .toc, #toc, .toctitle, .mw-editsection, .mw-jump-link, .printfooter, .noprint, .navbox, #catlinks, .mw-empty-elt, .metadata"):
        t.decompose()
    # OSDev renders its maintenance templates (Stub, In Progress, Disputed,
    # BadPractice, Beginner, Tutorial, Tone, ...) as a message box carrying no
    # class at all, only the inline style below, so none of the class-based
    # removals above sees them; flatten_tables then prints each as a one-row
    # table with an empty second column, usually the first thing on the page.
    # Only a box that talks about the page itself goes: an editor who borrows
    # the same styling for a note to the reader (the BIOS warning on Parallel
    # port) is writing article content, not a maintenance banner.
    _AMBOX = re.compile(r"this (page|article|tutorial)\b|the factual accuracy\b")
    for box in el.select('table[style*="#cfcfbf"][style*="#f0f0ff"], '
                         'center[style*="#cfcfbf"][style*="#f0f0ff"]'):
        if box.decomposed:
            continue
        if _AMBOX.match(" ".join(box.get_text(" ", strip=True).split()).lower()):
            box.decompose()
    # SyntaxHighlight blocks are <div class="mw-highlight mw-highlight-lang-c">
    # wrapping a <pre> of pygments <span>s. The language lives on the div, so
    # rebuild each as <pre><code class="language-c"> to keep it in the fence.
    for cont in el.select("div.mw-highlight"):
        lang = next((c[len("mw-highlight-lang-"):] for c in (cont.get("class") or []) if c.startswith("mw-highlight-lang-")), "")
        pre_in = cont.select_one("pre")
        if not pre_in:
            continue
        pre = s.new_tag("pre")
        code = s.new_tag("code")
        if lang:
            code["class"] = "language-" + lang
        else:
            # <syntaxhighlight> with no lang= at all. pandoc indents a code
            # element with no attribute instead of fencing it, and an attribute
            # it cannot write in gfm (this one) leaves the fence unlabelled,
            # which is what an unlabelled listing wants.
            code["data-code"] = "1"
        code.string = pre_in.get_text()
        pre.append(code)
        cont.replace_with(pre)
    normalise_verbatim(el, s)
    # The remaining bare <pre> blocks are mostly not source (memory maps, port
    # tables, directory trees, config files), so label them "text" rather than
    # guess a language: an attribute-less <pre> would otherwise come out as a
    # pandoc indented block instead of a fence.
    for pre in el.find_all("pre"):
        if pre.find("code") is not None or pre.get("class"):
            continue
        code = s.new_tag("code")
        code["class"] = "language-text"
        code.string = pre.get_text()
        pre.clear()
        pre.append(code)
    # Images are not carried into the frozen cache, so drop them and let the
    # caption (div.thumbcaption) carry the figure. An <a class="image"> left
    # behind would otherwise become an empty markdown link.
    for img in el.find_all("img"):
        img.decompose()
    for a in el.select("a.image"):
        a.unwrap()
    # A wikilink whose target does not exist is rendered as a "red link" to the
    # editor rather than to an article: index.php?title=X&action=edit&redlink=1.
    # Offline it is a dead end twice over, because the article was never
    # written and every osdev host answers an automated client with 403, so
    # keep the words the author wrote and drop the link around them. Matching
    # on the query rather than on class="new" also catches the handful the skin
    # styles differently, and an ordinary article link never carries it.
    for a in el.select('a[href*="redlink=1"]'):
        a.unwrap()
    # Wiki links are relative to the site root in the dump ("X86_Paging",
    # "./Category:X"), so absolutise them against base to keep them clickable.
    if base:
        for a in el.find_all("a", href=True):
            h = a["href"]
            if "://" in h or h.startswith(("#", "mailto:")):
                continue
            a["href"] = base.rstrip("/") + "/" + h.lstrip("./")
    drop_permalinks(el)
    drop_empty_links(el)
    lift_stray_list_children(el)
    flatten_tables(el, s)
    sys.stdout.write(str(el))
