set -e
SRC="$1"; OUT="$2"; TITLE="$3"
# Refuse an empty or root-ish out-dir: the cleanup below globs outside the
# quotes, so "" or "/" would expand to "rm -f /*.txt". Normalise first, so
# "///", "/.", "/.." and a trailing slash cannot slip through, then require at
# least two real path components.
OUTN=$(printf %s "$OUT" | sed 's#//*#/#g; s#/*$##')
if [ "$(printf %s "${OUTN#/}" | tr / '\n' | grep -vc '^\.\{0,2\}$')" -lt 2 ]; then
  echo "epub_build: refusing out-dir '$OUT'" >&2; exit 1
fi
mkdir -p "$OUT"
rm -f "$OUT"/*.md "$OUT"/.complete; rm -rf "$OUT/media" "$OUT/.x"; mkdir -p "$OUT/.x"
( cd "$OUT/.x" && unzip -o -q "$SRC" )
# Primary: split by the epub's own spine/ncx (per-spine when the spine is
# chapter-sized, else group spine docs under the ncx top-level chapters).
# Fallback (malformed/unparseable epub): the whole book as one chapter.
if python3 - "$OUT/.x" "$OUT" "$TITLE" <<'PY'
import sys, os, posixpath, re, subprocess
import xml.etree.ElementTree as ET
from bs4 import BeautifulSoup
root, out, title = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2]), sys.argv[3]
SLUG = os.path.basename(out.rstrip("/"))
BOOK_TITLES = [title]  # plus the OPF dc:title entries, filled in below
# Per-slug chapter names for spine docs the ncx never labels (see the labels code).
NAME_FIX = {"more-ocaml-algorithms-methods-and-diversions": {
    "index_split_001.html": "Title Page", "index_split_002.html": "Copyright",
    "index_split_019.html": "Part: Generating PDF Documents (an extended example)"}}
# Calibre PDF-reflow listings printed as <p> paragraphs whose lines are led by a
# small-font <span class="X">N</span> line number (C++ Initialization Story:
# 55 paragraphs, 7 listing runs). Value: (line-number span class, fence
# language). Keyed per slug because the same shape means something else in
# other epubs (LMM's 12,567 kernel-source lines, footnote numbers in Bootlin
# and Algorithms Illuminated).
NUMBERED_LISTINGS = {"c-initialization-story": ("calibre20", "cpp")}
# --- CSS-carried layout -------------------------------------------------
# Some epubs put a listing's indentation, and the alignment inside a line, in
# CSS instead of in the text: a per-depth paragraph class (Programming in
# Haskell's Code1..Code8 differ only by margin-left), an inline padding-left,
# and EMPTY spacer elements (<span class="space"/>) whose only content is a
# padding-left. get_text() sees none of that, so `where` clauses came out at
# column 1 (a Haskell PARSE error), section numbers fused with their titles
# ("8.1Type declarations") and aligned "=" columns collapsed. Read the book's
# own stylesheets and turn those offsets back into spaces.
_CSSRULE = re.compile(r"([^{}]+)\{([^{}]*)\}")
_CSSEM = re.compile(r"(-?[0-9.]+)\s*em")
_CSSIND = {}   # class name -> left offset in ems (padding-left + margin-left)
def load_css(rootdir):
    for dp, _, fns in os.walk(rootdir):
        for fn in fns:
            if not fn.lower().endswith(".css"): continue
            try: txt = open(os.path.join(dp, fn), encoding="utf-8", errors="replace").read()
            except OSError: continue
            txt = re.sub(r"/\*.*?\*/", " ", txt, flags=re.S)
            for sel, body in _CSSRULE.findall(txt):
                em = 0.0
                for decl in body.split(";"):
                    k, _, v = decl.partition(":")
                    if k.strip().lower() not in ("padding-left", "margin-left"): continue
                    m = _CSSEM.search(v)
                    if m: em += float(m.group(1))
                if em <= 0: continue
                for one in sel.split(","):
                    m = re.fullmatch(r"(?:[A-Za-z][\w-]*)?\.([\w-]+)", one.strip())
                    if m: _CSSIND[m.group(1)] = max(_CSSIND.get(m.group(1), 0.0), em)
# One em of left offset is ~1.6 monospace columns (a 0.625em advance).
# Calibrated on listings whose right answer is known from the code itself:
# Programming in Haskell's "bools n = map ..." / "where bss = ..." (6.25em ->
# the 10 columns of "bools n = ") and "bin2int bits = ..." (9.25em -> 15), and
# its <span class="space1"/> alignment runs (1.19em -> the 2 columns that line
# "rev East  = West" up with "rev South = North"). It approximates a printed
# layout, so what matters is the RELATIVE indentation, which in Haskell is part
# of the syntax, not a typographic reproduction.
_EMCOL = 1.6
_INLEM = re.compile(r"(?:padding|margin)-left\s*:\s*(-?[0-9.]+)\s*em")
def indent_em(el):
    em = sum(_CSSIND.get(c, 0.0) for c in (el.get("class") or []))
    return em + sum(float(x) for x in _INLEM.findall(el.get("style") or ""))
def cols(em): return max(0, int(round(em * _EMCOL)))
def expand_spacers(s):
    # An empty element that exists only to carry a left offset IS a run of
    # spaces. In prose the run collapses to one space (pandoc, like a browser),
    # which is exactly right for "8.1<span class="space"/>Type declarations";
    # inside a listing the run is preserved and restores the column alignment.
    for el in s.find_all("span"):
        if el.find(True) is not None or el.get_text(): continue
        em = indent_em(el)
        if em > 0: el.replace_with(" " * max(1, cols(em)))
    s.smooth()
# Private-use stand-in for a literal TAB, so pandoc's HTML reader cannot expand
# it to spaces; clean() puts the tabs back (see prep_code).
TABMARK = "\ue00a"
def sanitize(t):
    t = re.sub(r'[\\/:*?"<>|]', '-', (t or "").strip())
    if len(t) > 140: t = re.sub(r" [^ ]*$", "", t[:140])  # cut at a word boundary
    return (t or "untitled")

_CIRC = "\u2460\u2461\u2462\u2463\u2464\u2465\u2466\u2467\u2468\u2469\u246a\u246b\u246c\u246d\u246e\u246f\u2470\u2471\u2472\u2473"
def prep_code(s):
    expand_spacers(s)
    # A boxed sidebar (Crafting Interpreters' div.aside, 8-34 per chapter, drawn
    # with a border by the book's own CSS) is not part of the running argument,
    # but pandoc has no reason to know that and merged each one into the
    # neighbouring paragraphs, so a marginal aside read as the main text.
    # A blockquote is the gfm shape that keeps it visibly set apart.
    for el in s.find_all("div", class_="aside"):
        el.name = "blockquote"
        del el["class"]
    # pandoc's HTML reader expands a literal TAB inside a code block to spaces,
    # which corrupted the very listings that demonstrate tab-separated data
    # (Command-Line Rust's books.tsv). Carry tabs across pandoc as a private-use
    # character and put them back in clean().
    for t in s.find_all(string=lambda x: x and "\t" in x):
        if t.find_parent(_VERBATIM): t.replace_with(t.replace("\t", TABMARK))
    # pandoc's HTML reader emits NOTHING for a <section epub:type="titlepage">
    # (or "halftitlepage"), so five books lost their title page (title h1,
    # edition, subtitle, author line, logo) and the builder then skipped the
    # doc as empty. Every other epub:type value passes through pandoc intact
    # (tested), so only these two are dropped.
    for el in s.find_all(attrs={"epub:type": re.compile(r"^(half)?titlepage$")}):
        del el["epub:type"]
    # O'Reilly epubs carry the listing language in data-code-language, which
    # pandoc ignores (it only reads class): copy it into class="language-X" so
    # the fence gets a real label (was: ~1570 unlabeled Rust listings).
    for pre in s.find_all("pre"):
        lang = pre.get("data-code-language")
        if lang: pre["class"] = lang.strip().lower()
        # Token-highlighting spans (<code class="k">if</code>, Crafting
        # Interpreters' pygments output) are not a language label, but when the
        # listing STARTS with such a span pandoc reads its class as the fence
        # language ("c" for a comment token, which is a real language name).
        # Unwrap the spans of exactly those listings; a single <code> wrapping
        # the whole listing is the legitimate label and is kept, and a listing
        # that starts with text is left alone (pandoc gives it no label).
        codes = pre.find_all("code")
        first = pre.contents[0] if pre.contents else None
        # pandoc reads the fence language from a <code> only when it is the very
        # first node, so whether a listing came out fenced or as a 4-space
        # indented block depended on nothing but a leading whitespace or "("
        # text node (17 of 46 listings in one Crafting Interpreters chapter,
        # 823 sites book-wide, all shifted +4 columns from source). Decide on
        # the SPANS, not on which node happens to be first.
        whole = (len(codes) == 1 and getattr(first, "name", None) == "code"
                 and first.get_text().strip() == pre.get_text().strip())
        if any(c.get("class") for c in codes) and not whole:
            for c in codes: c.unwrap()
            # keep the block FENCED as before: pandoc turns an attribute-less
            # <pre> into an indented block; this placeholder class is stripped
            # by clean() to a bare fence, like the CSS classes of other epubs.
            if not pre.get("class"): pre["class"] = "listing"
        # numbered callout markers are <img alt="N" src="assets/N.png"> inside
        # the listing; pandoc drops them from a fence, losing the mapping to the
        # numbered explanations below. Replace with the circled digit O'Reilly prints.
        for img in pre.find_all("img"):
            alt = (img.get("alt") or "").strip()
            if alt.isdigit() and 1 <= int(alt) <= 20: img.replace_with(_CIRC[int(alt) - 1])
            else: img.decompose()
    # Packt / Cambridge epubs mark code as one <p class="source-code"> (Madieu)
    # or <p class="CodeN"> (Programming in Haskell) per line, so pandoc rendered
    # it as escaped prose. Merge each run of consecutive code paragraphs into one
    # <pre> (one line per paragraph, leading whitespace kept).
    def is_code_p(el):
        if getattr(el, "name", None) != "p": return False
        cls = " ".join(el.get("class") or [])
        return bool(re.match(r"(source-code|Code\d*)(\b|$)", cls))
    for p in list(s.find_all("p")):
        if not is_code_p(p) or p.parent is None or getattr(p, "_merged", False): continue
        run = [p]; nxt = p.find_next_sibling()
        while nxt is not None and is_code_p(nxt):
            run.append(nxt); nxt = nxt.find_next_sibling()
        cls0 = " ".join(p.get("class") or [])
        lang = "c" if "source-code" in cls0 else "haskell"  # Packt LDD is C; Cambridge Programming in Haskell
        # Cambridge grades a listing's depth by CLASS (Code1..Code8 differ only
        # by margin-left) plus an inline padding-left, none of which get_text()
        # can see, so `where` clauses landed at column 1 - a real Haskell parse
        # error. Measure each line against the shallowest line of its own run,
        # so a listing that is uniformly indented still starts at column 0.
        base = min(indent_em(x) for x in run)
        # A code paragraph can hold its listing as an IMAGE (Cambridge typesets
        # 116 Haskell listings as <p class="Code1"><img/></p>): keep the image
        # as its own block, in place, and fence only the text paragraphs around
        # it. (get_text() used to discard the image and leave an empty fence.)
        buf = []
        def flush():
            if any(x.strip() for x in buf):
                pre = s.new_tag("pre"); code = s.new_tag("code"); pre["class"] = lang
                code.string = "\n".join(buf); pre.append(code); run[0].insert_before(pre)
            del buf[:]
        for x in run:
            imgs = x.find_all("img")
            for im in imgs:
                flush(); holder = s.new_tag("p"); holder.append(im.extract()); run[0].insert_before(holder)
            t = x.get_text().replace("\u00a0", " ").rstrip()
            if t.strip(): t = " " * cols(indent_em(x) - base) + t
            if t.strip() or not imgs: buf.append(t)
        flush()
        for x in run: x._merged = True; x.decompose()
    # Line-numbered listing paragraphs (see NUMBERED_LISTINGS): pandoc rendered
    # each paragraph (a chunk of 3 to 16 numbered lines) as ONE escaped prose
    # line and swallowed the \" escapes inside it (F7). Merge each run of such
    # paragraphs into a <pre>, one line per numbered span; a listing whose
    # numbering restarts (several listings printed back to back) gets its own.
    spec = NUMBERED_LISTINGS.get(SLUG)
    if spec:
        ncls, lang = spec
        def num_span(c):
            return (getattr(c, "name", None) == "span" and ncls in (c.get("class") or [])
                    and c.get_text().strip().isdigit())
        def lead_num(el):
            if getattr(el, "name", None) != "p": return False
            for c in el.contents:
                if isinstance(c, str) and not c.strip(): continue
                return num_span(c)
            return False
        for p in list(s.find_all("p")):
            if not lead_num(p) or p.parent is None or getattr(p, "_merged", False): continue
            run = [p]; nxt = p.find_next_sibling()
            while nxt is not None and lead_num(nxt):
                run.append(nxt); nxt = nxt.find_next_sibling()
            blocks = []; lines = []; last = 0
            for x in run:
                for c in x.contents:
                    if num_span(c):
                        n = int(c.get_text())
                        if n <= last and lines: blocks.append(lines); lines = []
                        last = n; lines.append(c.get_text().strip())
                    elif lines:
                        lines[-1] += (c if isinstance(c, str) else c.get_text()).replace("\u00a0", " ")
            if lines: blocks.append(lines)
            for b in blocks:
                pre = s.new_tag("pre"); code = s.new_tag("code"); pre["class"] = lang
                code.string = "\n".join(l.rstrip() for l in b); pre.append(code); run[0].insert_before(pre)
            for x in run: x._merged = True; x.decompose()
# pandoc 3.1.3's gfm writer mishandles a backslash in TEXT (outside code): a
# backslash before any ASCII punctuation is written as "\\" and the punctuation
# character is dropped (`A \" B` -> `A \\ B`, likewise \' \* \_ \[ and the
# second of a "\\" pair), so every C/C++/Rust string escape in a paragraph-coded
# listing lost its quote (F7: 63 sites in 3 books). A doubled backslash comes
# through intact (`\\"` -> `\\"`, which renders as `\"`), so double every
# backslash that precedes punctuation in text nodes that pandoc will escape.
# Verbatim contexts (pre, code, kbd, samp, tt, var: pandoc emits them as code)
# are left alone; there the text passes through untouched.
_ESCAPABLE = re.compile(r'\\(?=[!-/:-@\[-`{-~])')
_VERBATIM = ["pre", "code", "kbd", "samp", "tt", "var", "script", "style", "textarea", "math", "svg"]
def guard_backslashes(s):
    from bs4 import NavigableString
    for t in s.find_all(string=True):
        if type(t) is not NavigableString or "\\" not in t: continue   # subclasses are comments, CDATA, doctype
        if t.find_parent(_VERBATIM): continue
        new = _ESCAPABLE.sub(r"\\\\", t)
        if new != t: t.replace_with(new)
def _rows(table):
    return [x for x in table.find_all("tr")
            if x.find_parent("table") is table and x.find_parent("tr") is None]
def grid(table):
    """The table's rows as a rectangular grid with colspan/rowspan expanded:
    (is_header, [(cell-or-None, tag-name, spanning-cell), ...]) per row.
    Ignoring the spans slid every later value one column left, which put
    Writing a C Compiler's "With initializer"/"Without initializer" sub-header
    under Scope/Specifier instead of under Definition?. A rowspan repeats its
    cell down the rows it covers; a colspan keeps its value in the first column
    it covers and pads the rest, so nothing is printed twice."""
    out = []; carry = {}
    for r in _rows(table):
        hdr = r.find_parent("thead") is not None
        cells = [x for x in r.find_all(["td", "th"]) if x.find_parent("tr") is r]
        row, i, col = [], 0, 0
        while True:
            if col in carry:
                left, entry = carry.pop(col); row.append(entry)
                if left > 1: carry[col] = [left - 1, entry]
                col += 1; continue
            if i >= len(cells): break
            c = cells[i]; i += 1
            def span(name, c=c):
                try: return min(max(int(c.get(name, 1)), 1), 64)
                except (TypeError, ValueError): return 1
            cs, rs = span("colspan"), span("rowspan")
            for k in range(cs):
                entry = (c if k == 0 else None, c.name, c)
                row.append(entry)
                if rs > 1: carry[col] = [rs - 1, entry]
                col += 1
        while col <= max(carry, default=-1):   # a rowspan reaching past this row's own cells
            if col in carry:
                left, entry = carry.pop(col); row.append(entry)
                if left > 1: carry[col] = [left - 1, entry]
            else: row.append((None, "td", None))
            col += 1
        out.append((hdr, row))
    return out
def flatten_tables(html):
    # pandoc's gfm writer replaces any table with block-content cells (a <pre>
    # code listing, lists, multiple <p>) with the literal "[TABLE]" and DROPS the
    # body. Pre-flatten so nothing is lost: a table with block content is
    # LINEARIZED (each row -> its cell text, then its <pre> code blocks, so both
    # a label column and its code survive); a simple table is rebuilt with
    # text-only cells so pandoc can pipe it. The <caption> is always preserved as
    # a leading bold line (gfm has no table captions).
    s = BeautifulSoup(html, "html.parser")
    prep_code(s)
    for table in s.find_all("table"):
        # get_text would flatten <sup>/<sub> to "2 63": write them TeX-style,
        # ^{...} / _{...}, braces only when the content is more than one token
        # (F9: Programming Rust Table 3-1). Prose keeps pandoc's own rendering
        # (Unicode superscript digits, or ^(n) when no glyph exists).
        for el in table.find_all(["sup", "sub"]):
            t = el.get_text().strip(); mark = "^" if el.name == "sup" else "_"
            el.replace_with(mark + (t if re.fullmatch(r"\w+", t) else "{" + t + "}"))
        table.smooth()   # merge the new strings with their neighbours, else get_text(" ") prints "2 ^8"
        div = s.new_tag("div")
        cap = table.find("caption")
        if cap:
            p = s.new_tag("p"); st = s.new_tag("strong")
            st.string = cap.get_text(" ", strip=True); p.append(st); div.append(p)
        if table.find(["pre", "ul", "ol"]):
            for r in table.find_all("tr"):
                pres = [pr.extract() for pr in r.find_all("pre")]
                label = r.get_text(" ", strip=True)
                if label:
                    p = s.new_tag("p"); p.string = label; div.append(p)
                for pr in pres:
                    div.append(pr)
        else:
            def cell(c, name):
                nc = s.new_tag(name)
                txt = c.get_text(" ", strip=True) if c is not None else ""
                inner = c.find(["code", "samp", "kbd", "tt", "var"]) if c is not None else None
                if inner and txt and inner.get_text(" ", strip=True) == txt:
                    # whole cell is verbatim: keep a <code> wrapper so pandoc
                    # does not \-escape it (which drops \' \" \. ( ) etc.)
                    code = s.new_tag("code"); code.string = txt; nc.append(code)
                else:
                    nc.string = txt
                return nc
            g = grid(table)
            head = [row for h, row in g if h]
            body = [row for h, row in g if not h]
            if not head and g and g[0][1] and all(nm == "th" for _, nm, _ in g[0][1]):
                head, body = [g[0][1]], [row for _, row in g[1:]]
            nt = s.new_tag("table")
            if head:
                # gfm has exactly one header row, and a header cell may be a <td>
                # that only a thead CSS selector made bold (Crafting Interpreters),
                # which left pandoc inventing a blank header and demoting the real
                # one to data. Emit one <th> row, folding a multi-row header down
                # its columns ("Definition?" over "With initializer").
                nr = s.new_tag("tr")
                for j in range(max(len(r) for r in head)):
                    col = [r[j] for r in head if j < len(r)]
                    # the columns a colspan pads carry its label only when a
                    # sub-header sits under them ("Definition?" + "Without
                    # initializer"); a colspan with no second header row leaves
                    # them blank rather than repeating itself across the row.
                    sub = any(e[0] is not None for e in col)
                    seen = []
                    for own, _, c in col:
                        if c is None or (own is None and not sub): continue
                        if not any(c is x for x in seen): seen.append(c)
                    nc = s.new_tag("th")
                    if len(seen) == 1:
                        nc = cell(seen[0], "th")
                    elif seen:
                        nc.string = " ".join(t for t in (x.get_text(" ", strip=True) for x in seen) if t)
                    nr.append(nc)
                if nr.find(True): nt.append(nr)
            for row in body:
                nr = s.new_tag("tr")
                for c, name, _ in row: nr.append(cell(c, name))
                if nr.find(True): nt.append(nr)
            div.append(nt)
        table.replace_with(div)
    guard_backslashes(s)   # after the tables are rebuilt: their text-only cells are pandoc-escaped text too
    return str(s)
# Real code-fence languages; anything else on a fence line is a CSS/DocBook class
# pandoc leaked from the source's <pre class="..."> (programlisting, insert,
# insert-before, table, less_space, pagebreak-before, ...) - strip it to a plain
# fence so the block still renders as code without a bogus "language".
_LANGS = set("c cpp c++ cc cxx h hpp cs csharp objc rust rs python py py3 js javascript jsx mjs ts typescript tsx json json5 jsonc sh bash zsh shell console shell-session sh-session shellsession terminal doscon bat batch powershell ps1 java kotlin kt go golang lua ruby rb perl pl php swift scala r matlab octave html xhtml xml svg css scss sass less styl yaml yml toml ini cfg conf sql haskell hs ocaml ml sml fsharp fs asm nasm gas x86asm armasm mips llvm diff patch udiff make makefile cmake meson ninja dockerfile docker text plaintext plain txt none nohighlight ada d dart elixir ex erlang clojure clj lisp elisp scheme racket vim viml vimscript proto protobuf graphql gql markdown md rst tex latex bibtex verilog systemverilog vhdl gdb ld linker-script nginx apache toml groovy gradle tcl awk sed regex ebnf bnf abnf pseudocode".split())
# Dead links. Nothing inside a book directory can be a link target except the
# extracted media/ files (chapter anchors do not survive pandoc, the epub's
# .html files are not copied), so every relative link is dead: keep its text,
# drop the target. The link text may hold an escaped bracket (pandoc writes a
# literal [ ] as \[ \]: Database Internals' citations `[\[DEMERS87\]](app01.html#DEMERS87)`,
# System Programming in Linux's `\[[4\]](index_split_014.html#p1236)`) or a
# callout image (Command-Line Rust: `[![1](media/assets/1.png)](#co_...)`);
# the old `[^\]]*` text pattern could cross neither, which left 370 citation
# links and 882 callout links with targets that do not exist (F8).
_LINKTXT = r'((?:\\.|!\[[^\]]*\]\([^)]*\)|[^\]\\])*)'
_EXTERNAL = r'(?:[A-Za-z][\w+.-]*://|mailto:|tel:|urn:|data:|news:|irc:)'
_LINK = re.compile(r'(?<![!\\])\[' + _LINKTXT + r'\]\((?!' + _EXTERNAL + r'|media/)([^)]*)\)')
def _links(seg):
    # a segment of markdown between fences; a link text may span two lines
    # (a hard-broken TOC entry: "54. [`3`  \n    `BINARY OPERATORS`](chapter3.xhtml#ch3)")
    seg = re.sub(r'\[!\[[^\]]*\]\([^)]*\)\]\((?!' + _EXTERNAL + r')[^)]*\.x?html[^)]*\)', '', seg)   # dead linked-image nav thumbnail
    def strip(m):
        # A 4-space-indented line may be an indented code block, where `a[0]()`
        # is code: there only the target shapes the old rules handled go.
        ls = seg.rfind("\n", 0, m.start()) + 1
        if re.match(r'(?: {4}|\t)', seg[ls:]) and not (m.group(2).startswith("#") or re.search(r'\.x?html', m.group(2))):
            return m.group(0)
        return m.group(1)   # dead intra-epub link (or pure anchor): keep the text
    return _LINK.sub(strip, seg)
# GFM splits a table row on "|" BEFORE it parses inline code spans, so a literal
# pipe inside backticks in a cell has to be written "\|". pandoc's gfm writer
# escapes pipes in a cell's plain text but NOT inside a code span it emits, so a
# cell like <td><code>n | 1</code></td> came out as `| `n | 1` |`: the row gained
# a column and the code span was cut in half (22 rows in 3 books). Escape the
# unescaped pipes inside the code spans of a pipe-table row. Only rows of a real
# table are touched (a block of "|...|" lines led by a "|---|" delimiter row), and
# only pipes that are not already escaped, so a cell that pandoc got right, and
# any other line that happens to start with a pipe, are left exactly as they were.
_TBLROW = re.compile(r'^ {0,3}\|.*\|[ \t]*$')
_TBLDELIM = re.compile(r'^ {0,3}\|[ \t:|-]*-[ \t:|-]*\|[ \t]*$')
def _esc_cell_pipes(line):
    out = []; i = 0; n = len(line)
    while i < n:
        c = line[i]
        if c == "\\" and i + 1 < n:          # an escape outside a span: skip the pair
            out.append(line[i:i+2]); i += 2; continue
        if c == "`":
            j = i
            while j < n and line[j] == "`": j += 1
            run = line[i:j]; k = j           # a span closes on a backtick run of the same length
            while True:
                k = line.find(run, k)
                if k < 0: break
                if line[k-1] == "`" or (k + len(run) < n and line[k+len(run)] == "`"): k += 1; continue
                break
            if k < 0:                        # unclosed: not a code span, leave it
                out.append(run); i = j; continue
            body = []; bs = 0
            for ch in line[j:k]:
                body.append("\\|" if (ch == "|" and bs % 2 == 0) else ch)
                bs = bs + 1 if ch == "\\" else 0
            out.append(run + "".join(body) + run); i = k + len(run); continue
        out.append(c); i += 1
    return "".join(out)
def _table_pipes(seg):
    lines = seg.split("\n"); i = 0; n = len(lines)
    while i < n:
        if _TBLROW.match(lines[i]) and i + 1 < n and _TBLDELIM.match(lines[i+1]):
            while i < n and _TBLROW.match(lines[i]):
                lines[i] = _esc_cell_pipes(lines[i]); i += 1
        else: i += 1
    return "\n".join(lines)
# A fence line, blockquote markers and all: a listing inside a boxed sidebar
# comes out of pandoc as "> ```", and reading that as ordinary text would run
# the link and table rules over verbatim source.
_FENCE = re.compile(r'^[ \t]*(?:>[ \t]*)*(?:```|~~~)')
def clean(md):
    # the link rules never run inside a fence: a fence is verbatim source text
    out = []; buf = []; inf = False
    def flush():
        if buf: out.append(_table_pipes(_links("\n".join(buf)))); del buf[:]
    for l in md.split("\n"):
        if _FENCE.match(l): flush(); inf = not inf; out.append(l)
        elif inf: out.append(l)
        else: buf.append(l)
    flush()
    md = "\n".join(out)
    md = re.sub(r'(?m)^((?:[ \t]*>)*[ \t]*`{3,})[ \t]*([A-Za-z][\w+.#-]*)[ \t]*$',
                lambda m: m.group(1) if m.group(2).lower() not in _LANGS else m.group(0), md)
    md = re.sub(r'(?m)^&nbsp;[ \t]*$', '', md)  # a paragraph holding one non-breaking space: an empty line, not a literal entity
    return md.replace(TABMARK, "\t").strip("\n")
def pandoc(p):
    html = flatten_tables(open(p, encoding="utf-8", errors="replace").read())
    # --extract-media is given RELATIVE to cwd=out so the image links come out
    # as "media/<file>", relative to the chapter file; an absolute directory
    # here would leak the build directory into the frozen markdown.
    r = subprocess.run(["pandoc", "-f","html","-t","gfm-raw_html","--wrap=none",
        "--resource-path", os.path.dirname(p), "--extract-media", "media"],
        input=html, capture_output=True, text=True, cwd=out)
    return clean(r.stdout)
try:
    cont = open(os.path.join(root,"META-INF","container.xml"),encoding="utf-8",errors="replace").read()
    opf_rel = re.search(r'full-path="([^"]+)"', cont).group(1); opf_dir = posixpath.dirname(opf_rel)
    uo = lambda p: posixpath.normpath(posixpath.join(opf_dir, p)) if opf_dir else p
    load_css(root)   # the book's own stylesheets carry listing indentation (see above)
    opf = ET.parse(os.path.join(root, opf_rel)).getroot()
    man, ncx_rel = {}, None
    for it in opf.iter():
        if it.tag.endswith("}title") and (it.text or "").strip():
            BOOK_TITLES.append(" ".join(it.text.split()))  # running heads often print the book title
        if it.tag.endswith("}item"):
            man[it.get("id")] = it.get("href")
            if it.get("media-type") == "application/x-dtbncx+xml": ncx_rel = it.get("href")
    spine = [uo(man[ir.get("idref")]) for ir in opf.iter() if ir.tag.endswith("}itemref") and man.get(ir.get("idref"))]
    labels, top, top_a = {}, [], []
    if ncx_rel:
        ncx = ET.parse(os.path.join(root, uo(ncx_rel))).getroot()
        nsn = {"n":"http://www.daisy.org/z3986/2005/ncx/"}
        for np in ncx.iter():
            if np.tag.endswith("}navPoint"):
                lab = np.find(".//n:navLabel/n:text", nsn); con = np.find("n:content", nsn)
                if lab is not None and con is not None:
                    labels.setdefault(posixpath.basename(con.get("src").split("#")[0]), " ".join((lab.text or "").split()))
        # The OPF <guide> cover reference names the cover doc (an image-only
        # page with neither ncx label nor heading): "001 Cover", not "001".
        for ref in opf.iter():
            if ref.tag.endswith("}reference") and ref.get("type") == "cover" and ref.get("href"):
                labels.setdefault(posixpath.basename(ref.get("href").split("#")[0]), "Cover")
        # Per-slug names for docs the ncx does not label at all. More OCaml is a
        # calibre PDF-reflow epub: its title page, copyright page and the Part
        # divider (the ncx points the Part at the previous chapter's doc) have
        # no navPoint of their own; these follow the book's printed Contents.
        for base_, name_ in NAME_FIX.get(SLUG, {}).items(): labels[base_] = name_
        nm = ncx.find("n:navMap", nsn)
        def _lab(np):
            l = np.find("n:navLabel/n:text", nsn); return " ".join((l.text or "").split()) if l is not None else ""
        def _src(np):
            c = np.find("n:content", nsn); return posixpath.basename(c.get("src").split("#")[0]) if c is not None else None
        def _anc(np):
            c = np.find("n:content", nsn); s = (c.get("src") if c is not None else "") or ""
            return s.split("#")[1] if "#" in s else ""
        for np in (nm if nm is not None else []):
            if not np.tag.endswith("}navPoint"): continue
            plab, psrc = _lab(np), _src(np)
            kids = np.findall("n:navPoint", nsn)
            kid_srcs = {_src(c) for c in kids} - {psrc, None}
            # Expand a Part/Section container whose children live in distinct
            # spine docs (real chapters, e.g. WACC's "Part I" -> chapters 1-10),
            # keeping the container itself; else it is a single chapter boundary.
            is_part = re.match(r'(part|section|volume|book|unit)\b', plab, re.I)
            if is_part and len(kid_srcs) >= 2:
                if psrc: top.append((plab, psrc))
                for c in kids:
                    cs = _src(c)
                    if cs: top.append((_lab(c), cs))
            elif psrc:
                top.append((plab, psrc))
            # top_a drives the anchor-split path, which can split several chapters
            # out of one spine doc, so always expand a Part into its children even
            # when they share the Part's spine doc (page-split epubs).
            if is_part and kids:
                if psrc: top_a.append((plab, psrc, _anc(np)))
                for c in kids:
                    cs = _src(c)
                    if cs: top_a.append((_lab(c), cs, _anc(c)))
            elif psrc:
                top_a.append((plab, psrc, _anc(np)))
except Exception as e:
    sys.stderr.write("parse failed: %s\n" % e); sys.exit(2)
# convert each spine doc once
conv = []  # (spine_index, basename, md)
for i, f in enumerate(spine):
    p = os.path.join(root, f)
    if os.path.isfile(p):
        md = pandoc(p)
        # skip empty docs (cover images) and injected watermark/promo interstitials
        if md.strip() and "读累了记得休息一会哦" not in md:
            conv.append((i, posixpath.basename(f), md))
if not conv: sys.exit(1)
_used = set()  # per-book (fresh process): titles already handed out, so a coarse spine doc that spills into the next chapter's running headers still gets a distinct entry
def title_for(base, md):
    def take(t):
        t = t.strip()
        if len(t) > 140: t = re.sub(r" [^ ]*$", "", t[:140])
        _used.add(t); return t
    t = labels.get(base)
    if t: return take(t)
    head = [l.strip() for l in md.lstrip().split("\n")[:12]]
    # A real heading is authoritative.
    for s in head:
        if s.startswith("#"): return take(s.lstrip("# ").strip())
    # Degenerate ncx + no lead heading: mine the recto running header (the
    # chapter title printed beside odd page numbers, e.g. "Software Breakpoints
    # **121**"). The most frequent one names the chapter this spine doc is mostly
    # about, so a single-navPoint epub (Building a Debugger) still gets real
    # chapter titles instead of a table caption or an exercise-section heading.
    # Verso headers ("**120** Chapter 6") lead with the page number, so this
    # title-first pattern never matches them. Skip an already-used title (a doc
    # spilling into the next chapter) and fall to its next-most-frequent header.
    hdr = re.findall(r'(?m)^([A-Z][A-Za-z0-9 ,:/-]{2,58}?) \*\*\d+\*\*\s*$', md)
    if hdr:
        for h in sorted(set(hdr), key=lambda h: (-hdr.count(h), hdr.index(h))):
            if hdr.count(h) >= 3 and h.strip() not in _used: return take(h)
    # Otherwise a bold lead or a clearly title-like first line (capitalized, no
    # code punctuation) - better than dumping a code line like "namespace sdb {".
    for s in head:
        b = re.match(r'\*\*(.+?)\*\*', s)
        if b: return take(b.group(1))
        if (re.match(r'[A-Z][A-Za-z0-9].{2,58}$', s) and not re.search(r'[{};=<>|]', s)
                and not s.rstrip().endswith((',', '-', ':')) and '0x' not in s):
            return take(s)
    stem = re.sub(r'\.x?html?$','',base,flags=re.I)
    if re.fullmatch(r'cover', stem, re.I): return "Cover"  # cover doc of an epub with no <guide> (Programming Rust)
    return "" if re.fullmatch(r'(index_split_\d+|title\w*|copyright|toc|nav|part\d*|\d+)', stem, re.I) else stem
# Some epubs mark code with <p>+<br/>+monospace instead of <pre>, so pandoc
# renders it as escaped, hard-broken prose (\#include \<x\>) rather than a code
# block. Re-fence runs of >=2 hard-break-terminated code lines (Building a
# Debugger, xv6). Conservative: requires a trailing hard-break + code signals +
# almost no English stopwords, never touches inside an existing fence, and skips
# headings/tables/quotes/inline-code/images - so it does not fence real prose.
_STOP = set("the a an and or of to in is are was were be been being that this these those we you it its our your their he she they them his her as at by for from with on off up out into over under then than so if else when while do does did has have had will would can could should may might must not no yes but also each any all some most more less very just like about which who whom whose where why how what onto per via both either neither".split())
_CODE = re.compile(r'[{}();]|::|#\s*(?:include|define|undef|ifn?def|ifdef|elif|else|endif|pragma|if)\b|->|==|!=|<=|>=|&&|\|\||std::|0x[0-9a-fA-F]+|\bsdb>|\(gdb\)|\(lldb\)|\breturn\b|\bvoid\b|\bstruct\b|\bconst\b|\bauto\b|\bclass\b|\btemplate\b|\bnamespace\b|\bstatic\b|\bunsigned\b|\bsizeof\b|\btypedef\b|\bnullptr\b')
# Strong code punctuation that essentially never appears in English prose (bare
# () ; excluded - those do show up in prose). Two or more => code even when word
# operators (if/and/or) inflate the stopword count.
_HARD = re.compile(r'[{}]|==|!=|->|::|<=|>=|\+=|-=|&&|\|\||std::|#\s*(?:include|define|undef|ifn?def|ifdef|elif|else|endif|pragma|if)\b')
# Undo pandoc's markdown escaping. "|" belongs in this set: pandoc escapes a pipe
# in prose, and when fence_code turns that prose back into a code fence the escape
# has to go, because markdown does not unescape inside a fence and the backslash
# would be displayed (xv6's `O_CREATE\|O_WRONLY`, the only 3 such sites).
def _unesc(s): return re.sub(r'\\([\\`*_{}\[\]()>#+.!<>&~=|-])', r'\1', s)
def _is_code(raw):
    t = _unesc(raw.rstrip().strip())
    if not t: return None
    if re.fullmatch(r'>?\s*\d+', t): return None                        # bare gutter line-number: absorb into a run, never break it
    if re.match(r'#{1,6}\s', t) or t.startswith("|") or t.startswith("`") or t.startswith("!["): return False  # heading/table/inline-code/image
    # A line that is only a link or a URL (LDD3's bibliography web sites) is not
    # code by itself: its parentheses used to count as a code signal and fence
    # it. Neutral, so it is still absorbed when it sits inside a listing.
    if re.fullmatch(r'\[[^\]]*\]\([^)\s]*\)|(https?|ftp)://\S+', t): return None
    if re.fullmatch(r'-{2,}\s*snip\s*-{2,}|\.\.\.|\[\.\.\.\]', t): return True
    if raw.endswith("  "):                                              # hard-break-terminated line = the <br/>-per-line code shape
        sig = len(_CODE.findall(t))
        stop = sum(1 for w in re.findall(r"[A-Za-z]{2,}", t) if w.lower() in _STOP)
        # Few stopwords => not prose. Or >=2 strong code punctuations, which
        # fences word-operator code (`if (x and y and z) {`) that trips the
        # stopword filter, while a wordy sentence with a stray `(E)` stays prose.
        if sig >= 1 and (stop <= 2 or len(_HARD.findall(t)) >= 2): return True
    return False
def fence_code(md):
    lines = md.split("\n"); out = []; i = 0; n = len(lines); infence = False
    while i < n:
        if _FENCE.match(lines[i]):
            infence = not infence; out.append(lines[i]); i += 1; continue
        if infence: out.append(lines[i]); i += 1; continue
        j = i; codes = 0; buf = []
        while j < n and not _FENCE.match(lines[j]):
            c = _is_code(lines[j])
            if c is True: codes += 1; buf.append(lines[j]); j += 1
            elif c is None and codes > 0:
                # Bridge a gap of blank / bare line-number lines (a listing that a
                # removed running header split, or a wrapped gutter number) - but
                # only when code actually resumes past the gap, so trailing blanks
                # and prose never get pulled in.
                k = j
                while k < n and not _FENCE.match(lines[k]) and _is_code(lines[k]) is None: k += 1
                if k < n and not _FENCE.match(lines[k]) and _is_code(lines[k]) is True:
                    buf += lines[j:k]; j = k
                else: break
            else: break
        if codes >= 2:
            body = [_unesc(x.rstrip()) for x in buf]
            while body and not body[-1].strip(): body.pop()
            out.append("```cpp"); out += body; out.append("```"); i = j
        else:
            out.append(lines[i]); i += 1
    return "\n".join(out)
# Print page furniture, recognised by SHAPE only, never by raw repetition of
# arbitrary text (an earlier rule deleted any line repeated 6+ times in a
# chapter, which also deleted repeated CODE lines such as `int main(void) {`
# or `@Override`, proof labels, pseudocode and figure descriptions: 1,872
# content lines in 15 books). Two kinds:
#  1. recto/verso print headers ("Chapter Title **page**", "**page** Chapter N",
#     "**Item 35 \| 245**", "**132** \| Chapter 9 - ..."), on their own line or
#     flowed onto the end of a paragraph or into a listing; dropped where they
#     recur (>=4 in a doc = a genuine running header). A head flowed into a
#     paragraph is only cut when its title half is one this document also
#     prints on a line of its own, so the rule never has to guess where in a
#     sentence the furniture begins.
#  1b. bare printed folios ("**366**"), when they form the document's own
#     climbing page sequence, and the title line printed beside them.
#  2. running heads/footers the epub flowed onto every page: a PLAIN PROSE line
#     that recurs >=6 times in the chapter AND has a furniture shape: equals the
#     book title or this chapter's title (slide breadcrumbs, the CONTENTS
#     running head), a bare "CHAPTER N" label (Manning), a copyright footer
#     (© plus a year: LMM early access), a figure-description back-link
#     ("Return to text", No Starch), or a per-slug running head (RUNNING_HEADS).
#     "Plain prose" = outside a fence, not indented, not next to an indented
#     code block, no trailing hard break, no code punctuation, not ending in ":".
#     A line failing any of these is never removed, however often it repeats.
#     A title-shaped head (book/chapter title, "CHAPTER N") is also the text of
#     the chapter opener, so its FIRST occurrence in the file is kept and only
#     the later repeats go (F10: Rust in Action's "CHAPTER N", "INDEX" and
#     "CONTENTS", the section title on a Bootlin section's first slide); a
#     copyright footer, back-link or per-slug head has no opener and goes always.
# A print running head is a PAGE FOLIO and the title printed beside it, and the
# typesetter emphasises either half, both, or neither. Matching one spelling
# ("Title **121**", "**120** Chapter 6") missed every other real shape: the
# whole span bold ("**Item 35 \| 245**"), the folio bold with pandoc's escaped
# pipe as the separator and an en-dash inside the title ("**132** \| Chapter 9
# - Some Common UEFI and PI Functions"), and fully plain text ("Item 28 \|
# 203"). That left 282 leaked heads in Effective Modern C++ (11 of them cutting
# an English word in half) and 25 in one Beyond BIOS chapter. So match the
# SHAPE - a folio, an optional separator, a short title-like run, in either
# order - rather than one book's spelling.
# Typesetters set the gap beside a folio with a NARROW NO-BREAK SPACE or a
# non-breaking space as readily as with an ASCII one (Beyond BIOS uses U+202F),
# so every space in these shapes has to be the Unicode class, not "[ \t]".
_HD_W = r"[ \t  -   ]"
_HD_T = r"[A-Za-z][A-Za-z0-9 ,;:/'’“”.&()!?–—  -   -]{1,70}"
_HD_N = r"\d{1,4}"
_HD_S = r"(?:" + _HD_W + r"+|" + _HD_W + r"*\\?\|" + _HD_W + r"*)"   # a space, or a (pandoc-escaped) pipe
_HD_P = _HD_W + r"*\\?\|" + _HD_W + r"*"                             # an explicit separator
def _hd(t, named=False):
    # the four emphasis shapes a running head takes, folio first and title first
    N = (r"(?P<n>" if named else "(?:") + _HD_N + ")"
    T = (r"(?P<t>" if named else "(?:") + t + ")"
    return (r"\*\*" + N + r"\*\*" + _HD_S + T,
            T + _HD_S + r"\*\*" + N + r"\*\*",
            r"\*\*" + N + _HD_P + T + r"\*\*",
            r"\*\*" + T + _HD_P + N + r"\*\*")
_HEADLINE = [re.compile(x) for x in _hd(_HD_T, named=True)]
# A bare folio alone on a line ("**366**", Manning's printed page number): only
# furniture where it belongs to the document's own page sequence (see _folios).
_FOLIO = re.compile(r"^\*{1,3}(\d{1,4})\*{1,3}$")
# A line that is nothing but emphasis around its own text, so the head and
# title rules can see a bold or italic running head ("***Kernel***"). A bullet
# ("* a") never matches: the opening run must be followed by non-space and the
# closing run must end the line.
_EMPHLINE = re.compile(r"\*{1,3}(\S(?:[^*]*\S)?)\*{1,3}")
def _unemph(t):
    m = _EMPHLINE.fullmatch(t)
    return m.group(1) if m else t
def _headparts(t):
    """(folio, title) when the whole line is a print running head."""
    for rx in _HEADLINE:
        m = rx.fullmatch(t)
        if m: return m.group("n"), m.group("t").strip()
    return None
RUNNING_HEADS = {
    # Bootlin lab book (PDF-derived): the deck title is printed atop every page.
    "bootlin-embedded-linux-qemu-labs": {"Embedded Linux System Development"},
}
_CODEPUNCT = re.compile(r'[{}\[\];=<>`\\|$@#_]|::|->')
_CHAPLABEL = re.compile(r'(chapter|part)\s+(\d+|[ivxlc]+)', re.I)
_BACKLINK = re.compile(r'(return|back) to (the )?text', re.I)
_COPYRIGHT = re.compile(r'©|\(c\)|copyright', re.I)
_YEAR = re.compile(r'\b(19|20)\d\d\b')
def _folios(lines, strong):
    """Line numbers of the bare folios that lie on this document's own page
    sequence. A lone bold number is a printed page number only when it belongs
    to a run of them that climbs through the document by 1 or 2 at a time AND
    that run is anchored to furniture already recognised on other grounds (a
    "CHAPTER N" label, a chapter/book title line, a whole-line running head).
    Both tests are needed: the climb alone also fits The Linux Memory Manager's
    bold chapter numbers 1..14 down its table of contents, and the anchor alone
    would fit a bold count that happens to sit beside a heading."""
    idx = []; inf = False
    for i, l in enumerate(lines):
        if _FENCE.match(l): inf = not inf; continue
        if inf: continue
        m = _FOLIO.match(l.strip())
        if m: idx.append((i, int(m.group(1))))
    if len(idx) < 6: return set()
    best = [1] * len(idx); prev = [-1] * len(idx)
    for b in range(len(idx)):
        for a in range(b):
            if 1 <= idx[b][1] - idx[a][1] <= 2 and best[a] + 1 > best[b]:
                best[b] = best[a] + 1; prev[b] = a
    k = max(range(len(idx)), key=lambda j: best[j])
    if best[k] < 6: return set()
    chain = set()
    while k >= 0: chain.add(idx[k][0]); k = prev[k]
    n = len(lines)
    def anchored(i):
        for st in (-1, 1):
            j = i + st
            while 0 <= j < n and not lines[j].strip(): j += st
            if 0 <= j < n and j in strong: return True
        return False
    return chain if any(anchored(i) for i in chain) else set()
def _norm(s): return re.sub(r"[^a-z0-9]+", " ", _unesc(s).lower()).strip()
def _title_keys(t):
    ks = set()
    for s in (t, re.sub(r"\s*\([^)]*\)\s*$", "", t)):   # also without a trailing "(2e)"
        n = _norm(s); ks.add(n)
        m = re.match(r"(?:chapter|part|appendix|section)\s+[0-9ivxlc]+\s*(.*)", n)  # "chapter 3 virtual memory"
        if m: ks.add(m.group(1))
        m = re.match(r"[0-9]+\s+(.*)", n)                                          # "2 language foundations"
        if m: ks.add(m.group(1))
    return {k for k in ks if len(k) >= 4}
HEAD_TITLES = set()   # every title this BOOK prints as a running head (see learn_heads)
BOOK_WORDS = set()    # every word the book uses, to judge a broken hyphenation
# Print FOOTERS. Unlike a running head these are not "title + folio" but a fixed
# strap line the deck prints under every slide ("Kernel, drivers and embedded
# Linux - ... -https://bootlin.com 109/436"), and the next slide's title is
# often fused onto the end of it, so an exact-line-repeat filter never fired:
# 466 leaks in the Bootlin kernel deck, 71 and 33 in the two lab books.
# Declared per slug, and matched LITERALLY, on purpose: I tried inferring the
# strap line as "a line-leading prefix shared by >=6 lines that carries a URL",
# and it deleted real content in two other books (The Linux Memory Manager's
# repeated kernel-source links, Rust in Action's `git clone https://...` lines)
# and truncated the very titles it was meant to preserve here ("50/436 Kernel
# configuration" -> "configuration"). A repeated prefix is not a shape.
RUNNING_FOOTERS = {
    "bootlin-linux-kernel-slides": (
        "Kernel, drivers and embedded Linux - Development, consulting, training and support -https://bootlin.com",),
    "bootlin-embedded-linux-bbb-labs": (
        "© 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license",
        "© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license"),
    "bootlin-embedded-linux-qemu-labs": (
        "© 2004-2025 [Bootlin](https://bootlin.com), CC BY-SA license",
        "© 2004-2025 [Bootlin,](https://bootlin.com) CC BY-SA license"),
}
_LEAD = re.compile(r"^[ \t]*(?:[-*+\u2022\u25b6\u25b8][ \t]+)?(?:\d{1,4}(?:/\d{1,4})?[ \t]+)?")
_FOOT_PATS = [re.compile(_LEAD.pattern + re.escape(f) + r"(?:[ \t]*\d{1,4}(?:/\d{1,4})?)?[ \t]*")
              for f in RUNNING_FOOTERS.get(SLUG, ())]
def _headlines(md):
    """{line number: head title} for the whole-line running heads of one doc."""
    hl = {}; inf = False
    for i, l in enumerate(md.split("\n")):
        if _FENCE.match(l): inf = not inf; continue
        if inf: continue
        hp = _headparts(_unesc(l.strip()))
        if hp: hl[i] = hp[1]
    return hl
def learn_heads(md):
    # A running head flowed onto the end of a paragraph is cut only when its
    # title half is one the book prints on a line of its own somewhere, so the
    # rule never guesses where in a sentence the furniture starts. Learn those
    # titles from the WHOLE book first: a section head can be flowed into
    # paragraphs in the one chapter and printed on its own line only in
    # another (Beyond BIOS's "Remote Console Support").
    hl = _headlines(md)
    if len(hl) >= 4: HEAD_TITLES.update(hl.values())   # a contents page is a fine place to learn them
    BOOK_WORDS.update(w.lower() for w in re.findall(r"[A-Za-z]{3,}", md))
def strip_furniture(md, ttl=""):
    lines = md.split("\n"); n = len(lines)
    keys = set()
    for t in [ttl] + BOOK_TITLES: keys |= _title_keys(t)
    heads = {_norm(h) for h in RUNNING_HEADS.get(SLUG, ())}
    # whole-line running heads, and the titles they print - the same titles are
    # what a head flowed onto the END of a paragraph is made of, so collecting
    # them here is what makes the tail rule below safe (it never has to guess
    # where in a sentence the furniture starts).
    hline = _headlines(md)
    # A document that is MOSTLY "title | page" lines is a table of contents or
    # an index, where those lines are the content: Beyond BIOS's Contents is
    # 77% of them, while the densest real chapter anywhere in the library is
    # under 12%, so the two never come close to meeting.
    if len(hline) * 4 > max(1, sum(1 for l in lines if l.strip())): hline = {}
    nfurn = len(hline)
    tail_rx = None
    if nfurn >= 4:
        # the head titles this document prints on their own, plus each one with
        # its trailing number generalised: a page that breaks mid-paragraph can
        # carry the head of the PREVIOUS section ("Item 17" in the chapter that
        # only prints Items 18-22 on lines of its own).
        pieces = set()
        for t in set(hline.values()) | HEAD_TITLES:
            pieces.add(re.escape(t))
            m = re.fullmatch(r"(.*?)(\d{1,4})", t)
            if m and m.group(1).strip(): pieces.add(re.escape(m.group(1)) + r"\d{1,4}")
        alt = "(?:" + "|".join(sorted(pieces, key=len, reverse=True)) + ")"
        tail_rx = re.compile("(?:" + "|".join(list(_hd(alt)) +
            [_HD_N + _HD_P + alt, alt + _HD_P + _HD_N]) + r")" + _HD_W + r"*$")
    def plain(i):
        l = lines[i]
        if not l or l[0].isspace() or l.endswith("  "): return None
        # see through a whole-line emphasis wrapper: the running head's title
        # half is bold-italic in some books ("***Kernel***"), and excluding
        # every emphasised line left all 13 of that book's per-chapter heads in
        # place, 6 of them inside a listing.
        t = _unemph(_unesc(l.strip()))
        if not t or len(t) > 120 or t[0] in "#|-*>!`+<" or t.endswith(":") or _CODEPUNCT.search(t): return None
        j = i - 1
        while j >= 0 and not lines[j].strip(): j -= 1
        k = i + 1
        while k < n and not lines[k].strip(): k += 1
        if (j >= 0 and lines[j][0].isspace()) or (k < n and lines[k][0].isspace()): return None
        return t
    strong = set(hline); inf = False
    for i, l in enumerate(lines):
        if _FENCE.match(l): inf = not inf; continue
        if inf: continue
        t = plain(i)
        if t is not None and (_norm(t) in keys or _CHAPLABEL.fullmatch(t)): strong.add(i)
    fol = _folios(lines, strong)
    def near_folio(i):
        for st in (-1, 1):
            j = i + st
            while 0 <= j < n and not lines[j].strip(): j += st
            if 0 <= j < n and j in fol: return True
        return False
    def shape(t, i):
        nt = _norm(t)
        if nt in keys or _CHAPLABEL.fullmatch(t): return "title"      # doubles as the opener: first occurrence kept
        if nt in heads: return "runhead"    # a per-slug running head: also the title page's own title
        if _BACKLINK.fullmatch(t) or (_COPYRIGHT.search(t) and _YEAR.search(t)): return "furniture"
        # the title half of a running head, printed next to a page folio: a
        # short line whose nearest neighbour is one of this document's own
        # folios. Treated as a "title" so its FIRST appearance survives - in
        # these books a section heading and its running head are typeset
        # identically, and only the order tells them apart.
        if fol and len(t) <= 70 and near_folio(i): return "headtitle"
        return None
    from collections import Counter
    cnt = Counter(); cand = {}; kinds = {}; first = {}; inf = False
    for i, l in enumerate(lines):
        if _FENCE.match(l): inf = not inf; continue
        if inf: continue
        t = plain(i)
        if t is None: continue
        first.setdefault(t, i)     # where this text first appears at all, candidate or not
        k = shape(t, i)
        if k: cnt[t] += 1; cand[i] = (t, k); kinds[t] = k
    # A repeat alone is never enough (an earlier rule that deleted any line
    # repeated 6+ times took 1,872 real code lines with it), so the count is
    # only a second opinion on a line that already has a furniture SHAPE. Two
    # is enough for a title printed beside one of this document's own page
    # folios, which is structural evidence on its own.
    rep = {t for t, c in cnt.items()
           if c >= 6 or (c >= 2 and kinds.get(t) in ("headtitle", "furniture", "runhead"))}
    if nfurn < 4 and not rep and not fol and not _FOOT_PATS: return md
    opener = next((i for i, l in enumerate(lines) if l.strip()), -1)
    out = []; inf = False; hyph = set()
    for i, l in enumerate(lines):
        if _FENCE.match(l): inf = not inf; out.append(l); continue
        if not inf:
            if i in fol: continue                     # a bare printed folio
            if nfurn >= 4 and i in hline: continue    # a whole-line running head
            for fp in _FOOT_PATS:                     # the deck's printed strap-line footer
                m = fp.match(l)
                if m and m.end():
                    l = l[m.end():].strip(); break
            if not l.strip() and lines[i].strip(): continue
            if tail_rx is not None and l.strip() not in ("", "|"):
                m = tail_rx.search(l)
                if m and m.start() > 0:               # a head flowed onto the end of a paragraph
                    l = l[:m.start()].rstrip()
                    if not l: continue
                    # the page broke mid-word, so the paragraph ends on the
                    # hyphen and the next one carries the rest ("Neverthe-" +
                    # "less"): rejoin them now that the head between is gone.
                    if re.search(r"[a-z]-$", l): hyph.add(len(out))
            c = cand.get(i)
            if c and c[0] in rep:
                # a declared running head is also the text of the title page it
                # is derived from, so it survives where it OPENS the document
                # (Bootlin's decks print "Embedded Linux System Development" as
                # the title on page 1 and atop every page after it)
                if c[1] == "runhead" and i == opener: out.append(l); continue
                # a title-shaped head is also the text of the chapter or section
                # opener, so its FIRST appearance in the document stays, even
                # when that appearance is not itself furniture-shaped (Rust in
                # Action prints the section heading in the same bold italic as
                # its running head, and only the order tells them apart)
                if c[1] in ("furniture", "runhead") or first.get(c[0]) != i: continue
        out.append(l)
    for k in sorted(hyph, reverse=True):
        j = k + 1
        while j < len(out) and not out[j].strip(): j += 1
        if j >= len(out) or not out[j][:1].islower(): continue
        pre = re.search(r"([A-Za-z]+)-$", out[k]).group(1)
        post = re.match(r"[A-Za-z]+", out[j]).group(0)
        # The hyphen the printer added to break a word over the page goes only
        # when the whole word is attested elsewhere in this book: "Neverthe-" +
        # "less" is one word, "stack-" + "based" is a real compound and keeps
        # its hyphen. Nothing is invented either way; the two halves are joined
        # regardless, because the page break between them is gone.
        drop = (pre + post).lower() in BOOK_WORDS and (pre.lower() + "-" + post.lower()) not in BOOK_WORDS
        out[k] = (out[k][:-1] if drop else out[k]) + out[j]; del out[k+1:j+1]
    return "\n".join(out)
# U+00A0 survives pandoc unchanged, and it is invisible until it bites: a line
# made of nothing but non-breaking spaces renders as a blank line that is not
# blank (11,252 of them across 8 books, 7,183 in The Linux Memory Manager
# alone), and a non-breaking space inside code makes the copied listing fail to
# compile (gcc: "invalid character (0xc2) in mnemonic"; More OCaml carries
# 4,541 of them inside its inline code spans). Inside code - a fence, an
# indented block, or an inline `span` - it is a plain space; a whitespace-only
# line becomes genuinely empty; everywhere else it is deliberate publisher
# typography ("Figure 17-2", "Chapter 4.", "245 8th Street") and is left alone,
# which is the same line the web pipeline drew.
def _nbsp_spans(line):
    parts = re.split(r"(`+)", line); depth = None
    for k in range(len(parts)):
        if k % 2:
            if depth is None: depth = len(parts[k])
            elif depth == len(parts[k]): depth = None
        elif depth is not None:
            parts[k] = parts[k].replace("\u00a0", " ")
    return "".join(parts)
def nbsp(md):
    out = []; inf = False
    for l in md.split("\n"):
        if _FENCE.match(l): inf = not inf; out.append(l); continue
        if "\u00a0" not in l: out.append(l); continue
        if inf or re.match(r"(?: {4}|\t)", l): out.append(l.replace("\u00a0", " "))
        elif not l.strip(): out.append("")
        else: out.append(_nbsp_spans(l))
    return "\n".join(out)
def write(idx, ttl, md):
    name = ("%03d %s" % (idx, sanitize(ttl))) if ttl else ("%03d" % idx)
    open(os.path.join(out, name + ".md"), "w", encoding="utf-8").write(nbsp(fence_code(strip_furniture(md, ttl))))
def pandoc_html(html, srcdir):
    r = subprocess.run(["pandoc","-f","html","-t","gfm-raw_html","--wrap=none",
        "--resource-path", srcdir, "--extract-media", "media"],   # relative, see pandoc()
        input=flatten_tables(html), capture_output=True, text=True, cwd=out)
    return clean(r.stdout)
# Anchor-split books: the spine/ncx does not line up with chapters (several
# chapters share one spine doc, or a chapter is marked only by an in-page
# anchor, or the spine is a coarse page-split). Split each spine document at the
# ncx chapter anchors (the Part-expanded top-level boundaries) so the picker
# matches the printed TOC. Every other book keeps the spine/group strategies.
ANCHOR_SPLIT = {"expert-c-programming","effective-modern-c","c-initialization-story",
    "linux-device-drivers-3rd-edition","algorithms-illuminated-part-2","system-programming-in-linux",
    "rust-in-action","bootlin-embedded-linux-bbb-labs","bootlin-linux-kernel-slides",
    "bootlin-embedded-linux-qemu-labs", "the-linux-memory-manager"}
# Per-book label fixes applied to the ncx labels: LMM names Chapter 1 just
# "Introduction" (its siblings are "Chapter N: ...") and its Chapter 11
# bookmark misspells Pressure.
RELABEL = {"the-linux-memory-manager": {"Introduction": "Chapter 1: Introduction",
    "Chapter 11: Reclaim and Memory Pressue": "Chapter 11: Reclaim and Memory Pressure"},
    # The PDF-derived ncx invents an "Appendix" navPoint over the section the
    # published deck (and the file's own first line) calls "Backup slides".
    "bootlin-linux-kernel-slides": {"Appendix": "Backup slides"}}
# A spine AND an ncx too coarse to split on. xv6's only source on disk is a
# third-party PDF-to-epub conversion with a 2-item spine and a single navPoint,
# so the whole 106-page book landed in two files with no chapter boundary
# anywhere in it and not one markdown heading. The book still prints its own
# chapter openers - a bold "Chapter 4" line whose next bold line is the title -
# which is a boundary the ncx cannot give. Value: the pattern a bold line must
# match exactly to open a chapter. Keyed per slug because a bold "Chapter 4"
# mid-paragraph means something else in a book whose ncx already works.
HEADING_SPLIT = {"xv6-x86": r"(?:Chapter\s+\d+|Appendix\s+[A-Z]|Index)"}
SENT = "§§CHAPSPLIT§§"
def split_segments(parts):
    """Cut the concatenated per-spine markdown at the sentinel paragraphs."""
    segs = []; lbl = "Front Matter"; buf = []
    rx = re.compile(re.escape(SENT) + r"(.*?)" + re.escape(SENT))
    for line in ("\n\n".join(parts)).split("\n"):
        m = rx.search(line)
        if m:
            segs.append((lbl, "\n".join(buf))); lbl = m.group(1).strip() or "untitled"; buf = []
        else:
            buf.append(line)
    segs.append((lbl, "\n".join(buf)))
    return segs
if SLUG in HEADING_SPLIT:
    rx = re.compile(HEADING_SPLIT[SLUG])
    parts = []
    for f in spine:
        p = os.path.join(root, f)
        if not os.path.isfile(p): continue
        soup = BeautifulSoup(open(p, encoding="utf-8", errors="replace").read(), "html.parser")
        body = soup.body or soup
        for b in list(body.find_all(["b", "strong"])):
            t = " ".join(b.get_text().split())
            if not rx.fullmatch(t): continue
            nx = b.find_next(["b", "strong"])       # the chapter title sits in the next bold run
            lab = t
            if nx is not None:
                t2 = " ".join(nx.get_text().split())
                if t2 and len(t2) <= 60 and not rx.fullmatch(t2): lab = t + ": " + t2
            mk = soup.new_tag("p"); mk.string = SENT + lab + SENT
            b.insert_before(mk)
        parts.append(pandoc_html(str(body), os.path.dirname(p)))
    segs = split_segments(parts)
    for _, md in segs: learn_heads(md)
    idx = 0
    for lbl, md in segs:
        md = md.strip("\n")
        if md.strip():
            idx += 1; write(idx, lbl, md)
    if idx >= 3:
        print("strategy=heading-split chapters=%d" % idx); sys.exit(0)
_rl = RELABEL.get(posixpath.basename(out.rstrip("/")), {})
if _rl: top_a = [(_rl.get(l, l), b, a) for (l, b, a) in top_a]
if posixpath.basename(out.rstrip("/")) in ANCHOR_SPLIT and top_a:
    spine_i = {}
    for i, f in enumerate(spine): spine_i.setdefault(posixpath.basename(f), i)
    parts = []  # per-spine markdown, with a sentinel paragraph at each chapter start
    for i, f in enumerate(spine):
        p = os.path.join(root, f)
        if not os.path.isfile(p): continue
        soup = BeautifulSoup(open(p, encoding="utf-8", errors="replace").read(), "html.parser")
        body = soup.body or soup
        for lbl, base, anc in top_a:
            if spine_i.get(base) != i: continue
            mk = soup.new_tag("p"); mk.string = SENT + lbl + SENT
            el = (body.find(id=anc) or body.find(attrs={"name": anc})) if anc else None
            if el is not None:
                # An ncx anchor is often a bare page marker that precedes the
                # chapter heading by up to a page (Expert C, LMM), so the chapter
                # file opened with the previous chapter's tail. Snap the boundary
                # to the heading the anchor sits in, else to the first heading
                # shortly after it (never crossing another chapter's anchor).
                H = ("h1", "h2", "h3", "h4")
                others = {a2 for (_, b2, a2) in top_a if spine_i.get(b2) == i and a2 and a2 != anc}
                def _nrm(x): return re.sub(r"^[0-9]+", "", re.sub(r"[^a-z0-9]", "", (x or "").lower()))
                keys = {_nrm(lbl)}
                m1 = re.match(r"(?:chapter|part|appendix)\s*[0-9ivxlc]+[.:]?\s*(.*)", lbl, re.I)
                if m1: keys.add(_nrm(m1.group(1)))
                m2 = re.match(r"[0-9]+[.:]\s*(.*)", lbl)
                if m2: keys.add(_nrm(m2.group(1)))
                keys = {k for k in keys if len(k) >= 4}
                h = el if el.name in H else el.find_parent(H)
                start = el if el.name == "p" else (el.find_parent("p") or el)
                if h is None:
                    # Walk forward over block elements: the first one whose own text
                    # IS the chapter title (calibre epubs title chapters with a bold
                    # <p>, No Starch with "<h1>5 MEMORY MAPPING</h1>") wins; else the
                    # first heading; never past another chapter anchor or ~4000 chars.
                    first_head, seen_chars = None, 0
                    # Start with the anchor element itself: a calibre page anchor
                    # often sits ON the title paragraph (<p id="page_15"><b>Revision
                    # History</b></p>); find_all_next() skips it, which pushed the
                    # boundary to the next page-number heading (C++ Initialization
                    # Story's Revision History file opened with chapter 1's first page).
                    # An INLINE anchor (<p><a id="p57"></a><i>Language foundations</i></p>,
                    # Rust in Action) is tested through the paragraph that holds it:
                    # walking from the <a> skipped that title and matched the same
                    # words in the next page's running head, so every chapter's
                    # opener page sat at the tail of the previous chapter file.
                    for n in [start] + start.find_all_next(True, limit=600):
                        if n.get("id") in others: break
                        if n.name not in H and n.name != "p": continue
                        t = _nrm(n.get_text())
                        if any(t == k or (t.startswith(k) and len(t) <= len(k) * 2 + 4) for k in keys): h = n; break
                        # a title wrapped over two paragraphs ("Lifetimes, ownership," /
                        # "and borrowing"): the first holds a prefix, the next completes it.
                        # The two halves can be separated by a spacer paragraph
                        # (<p class="whitespace"> </p>), which made three C++
                        # Initialization Story chapters open at their second page
                        # with their own title left in the previous file.
                        if n.name == "p" and len(t) >= 6 and any(k.startswith(t) for k in keys):
                            nx = n.find_next_sibling("p")
                            while nx is not None and not _nrm(nx.get_text()): nx = nx.find_next_sibling("p")
                            if nx is not None and any((t + _nrm(nx.get_text())).startswith(k) for k in keys): h = n; break
                        if n.name in H and first_head is None: first_head = n
                        seen_chars += len(n.get_text());
                        if seen_chars > 4000: break
                    if h is None: h = first_head
                # What the printed page puts ABOVE the title still belongs to
                # the chapter: the opener's splash image (which in No Starch
                # epubs carries the chapter's own anchor, so a forward-only
                # snap left it at the tail of the previous chapter) and the
                # big chapter number set over the title. Take those back, never
                # reaching past the chapter's own anchor or another chapter's.
                if h is not None and start is not None:
                    for _ in range(6):
                        if h is start: break
                        pv = h.find_previous_sibling(["p"] + list(H))
                        if pv is None or pv.get("id") in others: break
                        txt = " ".join(pv.get_text().split())
                        if txt and not re.fullmatch(r"(?:(?:chapter|part|appendix)\s*)?[0-9ivxlc]{1,4}",
                                                    txt, re.I): break
                        h = pv
                        if pv is start: break   # the anchor itself: never go further back
                # A bare "CHAPTER N" label paragraph right before the title
                # belongs to the chapter (Effective Modern C++ prints it on
                # its own line above the title).
                if h is not None:
                    pv = h.find_previous_sibling(["p"] + list(H))
                    if (pv is not None and pv.get("id") not in others
                            and re.fullmatch(r"(chapter|part|appendix)\s*[0-9ivxlc]+", " ".join(pv.get_text().split()), re.I)):
                        h = pv
                (h if h is not None else el).insert_before(mk)
            else: body.insert(0, mk)                  # whole-doc boundary
        parts.append(pandoc_html(str(body), os.path.dirname(p)))
    segs = split_segments(parts)
    idx = 0
    for _, md in segs: learn_heads(md)
    for lbl, md in segs:
        md = md.strip("\n")
        if md.strip() and "读累了记得休息一会哦" not in md:
            idx += 1; write(idx, lbl, md)
    if idx >= 3:
        print("strategy=anchor-split chapters=%d" % idx); sys.exit(0)
for _, _, md in conv: learn_heads(md)
if len(conv) <= 60 or len(top) < 3:
    for idx,(i,base,md) in enumerate(conv, 1): write(idx, title_for(base,md), md)
    print("strategy=per-spine chapters=%d" % len(conv)); sys.exit(0)
spine_base = {}
for i, f in enumerate(spine):
    spine_base.setdefault(posixpath.basename(f), i)
def group_by(bnds):
    bnds = sorted(set(bnds))
    def chapter_of(si):
        lab, best = "Front Matter", -1
        for bsi, blabel in bnds:
            if bsi <= si and bsi > best: best, lab = bsi, blabel
        return best, lab
    groups = []; order = {}
    for si, base, md in conv:
        key, lab = chapter_of(si)
        if key not in order:
            order[key] = len(groups); groups.append([key, lab, []])
        groups[order[key]][2].append(md)
    return groups
def blobbed(groups):
    gl = [sum(m.count(chr(10)) + 1 for _, _, mds in [g] for m in mds) for g in groups]
    return len(groups) < 2 or max(gl, default=0) > 0.6 * (sum(gl) or 1)
def emit(groups):
    for _, _, mds in groups: learn_heads("\n\n".join(mds))   # book-wide head titles first
    for idx,(key,lab,mds) in enumerate(groups, 1):
        write(idx, lab if key >= 0 else "Front Matter", "\n\n".join(mds))
# C1: group under the (Part-expanded) top-level ncx boundaries.
g1 = group_by([(spine_base[sf], label) for label, sf in top if sf in spine_base])
if not blobbed(g1):
    emit(g1); print("strategy=grouped chapters=%d" % len(g1)); sys.exit(0)
# C1 blobbed (the ncx top-level does not line up with the real chapters). C2:
# group under EVERY distinct spine doc the ncx references, which recovers books
# whose chapters are not top-level nav points (e.g. a trailing-blob book).
g2 = group_by([(spine_base[b], lb) for b, lb in labels.items() if b in spine_base])
if 3 <= len(g2) <= 60 and not blobbed(g2):
    emit(g2); print("strategy=grouped-ncx chapters=%d" % len(g2)); sys.exit(0)
# Otherwise per-spine (navigable, content-complete, no blob).
for idx,(i,base,md) in enumerate(conv, 1): write(idx, title_for(base,md), md)
print("strategy=per-spine(fallback) chapters=%d" % len(conv)); sys.exit(0)
PY
then :
else
  # cd so --extract-media stays relative (links must be "media/<file>", never the build dir)
  SRCA=$(readlink -f "$SRC")
  ( cd "$OUT" && pandoc "$SRCA" -t gfm-raw_html --wrap=none --extract-media=media -o "001 Full Text.md" )
fi
rm -rf "$OUT/.x"
if [ -n "$(find "$OUT" -maxdepth 1 -name '*.md' -print -quit)" ]; then touch "$OUT/.complete"; fi