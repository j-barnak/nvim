"""Extract the article body from a saved web page, for the frozen doc cache.

The build pipeline is not otherwise recorded anywhere in this repository, and
an audit has already been burned once by "rebuild with the current tool" being
ambiguous while this file had uncommitted changes, so the exact commands that
produced Resources/docs/.webcache live here, next to the tool that runs them:

    osdev         python3 webextract.py mediawiki "" https://wiki.osdev.org
                    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs
                    | python3 webextract.py clean "" "" listsep
    learncpp      python3 webextract.py content div.entry-content   | pandoc ... | clean
    rayanfam      python3 webextract.py content div.post-content    | pandoc ... | clean
    rust-atomics  python3 webextract.py content article "" guesslang| pandoc ... | clean
    herd7         python3 webextract.py content body                | pandoc ... | clean

    cache file = Resources/docs/.webcache/<sha256 of the index.tsv URL>.txt

--preserve-tabs is not optional. Without it pandoc expands a tab inside <code>
to the next tab stop computed from the character's ABSOLUTE COLUMN in the input,
and this tool writes the whole document as a single line, so every tab-indented
listing is indented by an amount that depends on how much text happens to
precede it in the file. Deleting one icon-only anchor in a heading re-indented
19 code lines two files away. With --preserve-tabs the tab is written through
unchanged and the indentation is the author's.
"""

import re
import sys
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


def fence_lang(info):
    """The language a fence should carry, or "" for a bare fence."""
    lang = info[len("language-"):] if info.lower().startswith("language-") else info
    return lang if lang.lower() in _LANGS else ""


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


def grid(table):
    """The table's cells as a rectangular grid with colspan/rowspan expanded,
    one (cell, tag name) per column. Ignoring the spans slid every later value
    one column left (the IDT vector table read "No" under Type) and left every
    row after the first of a rowspan block empty (the SIB table in X86-64
    Instruction Encoding). A rowspan repeats its cell down the rows it covers;
    a colspan keeps its value in the first column it covers and pads the rest,
    so the columns line up with their headers without the text being printed
    twice. A pad carries the name of the cell it pads, because pandoc reads a
    row that mixes <th> and <td> as a body row and then prints an empty header
    above it, which is precisely what a spanning header cell would produce."""
    rows = [x for x in table.find_all("tr")
            if x.find_parent("table") is table and x.find_parent("tr") is None]
    out = []
    carry = {}  # column -> [rows still to fill, entry to repeat there]
    for r in rows:
        cells = [x for x in r.find_all(["td", "th"]) if x.find_parent("tr") is r]
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
        out.append(row)
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
            for r in [x for x in table.find_all("tr") if x.find_parent("table") is table and x.find_parent("tr") is None]:
                pres = [pr.extract() for pr in r.find_all("pre")]
                runs = cell_runs(r)
                if runs:
                    p = s.new_tag("p"); fill(runs, p, s); div.append(p)
                for pr in pres:
                    div.append(pr)
        else:
            nt = s.new_tag("table")
            for row in grid(table):
                nr = s.new_tag("tr")
                for c, name in row:
                    nc = s.new_tag(name)
                    if c is not None:
                        runs = cell_runs(c)
                        txt = " ".join(t for _, t in runs)
                        inner = c.find(["code", "samp", "kbd", "tt", "var"])
                        if (inner and txt and not any(h for h, _ in runs)
                                and inner.get_text(" ", strip=True) == txt):
                            # whole cell is verbatim: keep a <code> wrapper so
                            # pandoc does not \-escape it (which drops \' \" \.
                            # ( ) etc.)
                            code = s.new_tag("code"); code.string = txt; nc.append(code)
                        else:
                            fill(runs, nc, s)
                    nr.append(nc)
                if nr.find(True):
                    nt.append(nr)
            div.append(nt)
        table.replace_with(div)


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
        out.append(line)
    sys.stdout.write("\n".join(out))
    sys.exit(0)

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
elif mode == "content":
    el = s.select_one(arg) or s.find("article")
    if not el:
        sys.exit(1)
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
    for cont in el.select("div.highlighter-rouge, figure.highlight"):
        lang = next((c for c in (cont.get("class") or []) if c.startswith("language-")), "")
        codeel = cont.select_one("td.rouge-code") or cont.select_one("pre")
        if not codeel:
            continue
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

    drop_empty_links(el)
    lift_stray_list_children(el)
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
    drop_empty_links(el)
    lift_stray_list_children(el)
    flatten_tables(el, s)
    sys.stdout.write(str(el))
