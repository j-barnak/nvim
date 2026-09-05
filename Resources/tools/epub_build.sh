set -e
SRC="$1"; OUT="$2"; TITLE="$3"
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
def sanitize(t):
    t = re.sub(r'[\\/:*?"<>|]', '-', (t or "").strip())
    if len(t) > 140: t = re.sub(r" [^ ]*$", "", t[:140])  # cut at a word boundary
    return (t or "untitled")

_CIRC = "\u2460\u2461\u2462\u2463\u2464\u2465\u2466\u2467\u2468\u2469\u246a\u246b\u246c\u246d\u246e\u246f\u2470\u2471\u2472\u2473"
def prep_code(s):
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
        first = pre.contents[0] if pre.contents else None   # pandoc labels only when <code> is the very first node (a leading newline defeats it)
        if (codes and getattr(first, "name", None) == "code" and first.get("class")
                and (len(codes) > 1 or first.get_text().strip() != pre.get_text().strip())):
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
            if t.strip() or not imgs: buf.append(t)
        flush()
        for x in run: x._merged = True; x.decompose()
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
            nt = s.new_tag("table")
            for r in table.find_all("tr"):
                nr = s.new_tag("tr")
                for c in r.find_all(["td", "th"]):
                    nc = s.new_tag(c.name)
                    txt = c.get_text(" ", strip=True)
                    inner = c.find(["code", "samp", "kbd", "tt", "var"])
                    if inner and txt and inner.get_text(" ", strip=True) == txt:
                        # whole cell is verbatim: keep a <code> wrapper so pandoc
                        # does not \-escape it (which drops \' \" \. ( ) etc.)
                        code = s.new_tag("code"); code.string = txt; nc.append(code)
                    else:
                        nc.string = txt
                    nr.append(nc)
                if nr.find(True):
                    nt.append(nr)
            div.append(nt)
        table.replace_with(div)
    return str(s)
# Real code-fence languages; anything else on a fence line is a CSS/DocBook class
# pandoc leaked from the source's <pre class="..."> (programlisting, insert,
# insert-before, table, less_space, pagebreak-before, ...) - strip it to a plain
# fence so the block still renders as code without a bogus "language".
_LANGS = set("c cpp c++ cc cxx h hpp cs csharp objc rust rs python py py3 js javascript jsx mjs ts typescript tsx json json5 jsonc sh bash zsh shell console shell-session sh-session shellsession terminal doscon bat batch powershell ps1 java kotlin kt go golang lua ruby rb perl pl php swift scala r matlab octave html xhtml xml svg css scss sass less styl yaml yml toml ini cfg conf sql haskell hs ocaml ml sml fsharp fs asm nasm gas x86asm armasm mips llvm diff patch udiff make makefile cmake meson ninja dockerfile docker text plaintext plain txt none nohighlight ada d dart elixir ex erlang clojure clj lisp elisp scheme racket vim viml vimscript proto protobuf graphql gql markdown md rst tex latex bibtex verilog systemverilog vhdl gdb ld linker-script nginx apache toml groovy gradle tcl awk sed regex ebnf bnf abnf pseudocode".split())
def clean(md):
    md = re.sub(r'\[!\[[^\]]*\]\([^)]*\)\]\((?!\w+://)[^)]*\.x?html[^)]*\)', '', md)  # dead linked-image nav thumbnail
    md = re.sub(r'\[([^\]]*)\]\(#[^)]*\)', r'\1', md)                        # dead pure-anchor link
    md = re.sub(r'\[([^\]]*)\]\((?!\w+://)[^)]*\.x?html[^)]*\)', r'\1', md)  # dead intra-epub .html link (kept text)
    md = re.sub(r'(?m)^([ \t]*`{3,})[ \t]*([A-Za-z][\w+.#-]*)[ \t]*$',
                lambda m: m.group(1) if m.group(2).lower() not in _LANGS else m.group(0), md)
    md = re.sub(r'(?m)^&nbsp;[ \t]*$', '', md)  # a paragraph holding one non-breaking space: an empty line, not a literal entity
    return md.strip("\n")
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
def _unesc(s): return re.sub(r'\\([\\`*_{}\[\]()>#+.!<>&~=-])', r'\1', s)
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
        if lines[i].lstrip()[:3] in ("```", "~~~"):
            infence = not infence; out.append(lines[i]); i += 1; continue
        if infence: out.append(lines[i]); i += 1; continue
        j = i; codes = 0; buf = []
        while j < n and lines[j].lstrip()[:3] not in ("```", "~~~"):
            c = _is_code(lines[j])
            if c is True: codes += 1; buf.append(lines[j]); j += 1
            elif c is None and codes > 0:
                # Bridge a gap of blank / bare line-number lines (a listing that a
                # removed running header split, or a wrapped gutter number) - but
                # only when code actually resumes past the gap, so trailing blanks
                # and prose never get pulled in.
                k = j
                while k < n and lines[k].lstrip()[:3] not in ("```", "~~~") and _is_code(lines[k]) is None: k += 1
                if k < n and lines[k].lstrip()[:3] not in ("```", "~~~") and _is_code(lines[k]) is True:
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
#  1. recto/verso print headers ("Chapter Title **page**", "**page** Chapter N"),
#     often flowed into the middle of a paragraph or a listing; dropped where
#     they recur (>=4 in a doc = a genuine running header).
#  2. running heads/footers the epub flowed onto every page: a PLAIN PROSE line
#     that recurs >=6 times in the chapter AND has a furniture shape: equals the
#     book title or this chapter's title (slide breadcrumbs, the CONTENTS
#     running head), a bare "CHAPTER N" label (Manning), a copyright footer
#     (© plus a year: LMM early access), a figure-description back-link
#     ("Return to text", No Starch), or a per-slug running head (RUNNING_HEADS).
#     "Plain prose" = outside a fence, not indented, not next to an indented
#     code block, no trailing hard break, no code punctuation, not ending in ":".
#     A line failing any of these is never removed, however often it repeats.
_RECTO = re.compile(r"^[A-Za-z][A-Za-z0-9 ,:/'’.&-]{2,58}? \*\*\d+\*\*$")
_VERSO = re.compile(r"^\*\*\d+\*\* [A-Z][A-Za-z0-9 ,:/'’.&-]{1,58}$")
RUNNING_HEADS = {
    # Bootlin lab book (PDF-derived): the deck title is printed atop every page.
    "bootlin-embedded-linux-qemu-labs": {"Embedded Linux System Development"},
}
_CODEPUNCT = re.compile(r'[{}\[\];=<>`\\|$@#_]|::|->')
_CHAPLABEL = re.compile(r'(chapter|part)\s+(\d+|[ivxlc]+)', re.I)
_BACKLINK = re.compile(r'(return|back) to (the )?text', re.I)
_COPYRIGHT = re.compile(r'©|\(c\)|copyright', re.I)
_YEAR = re.compile(r'\b(19|20)\d\d\b')
def _furn(l):
    t = _unesc(l.strip()); return bool(_RECTO.match(t) or _VERSO.match(t))
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
def strip_furniture(md, ttl=""):
    lines = md.split("\n"); n = len(lines)
    keys = set()
    for t in [ttl] + BOOK_TITLES: keys |= _title_keys(t)
    heads = {_norm(h) for h in RUNNING_HEADS.get(SLUG, ())}
    def plain(i):
        l = lines[i]
        if not l or l[0].isspace() or l.endswith("  "): return None
        t = _unesc(l.strip())
        if not t or len(t) > 120 or t[0] in "#|-*>!`+<" or t.endswith(":") or _CODEPUNCT.search(t): return None
        j = i - 1
        while j >= 0 and not lines[j].strip(): j -= 1
        k = i + 1
        while k < n and not lines[k].strip(): k += 1
        if (j >= 0 and lines[j][0].isspace()) or (k < n and lines[k][0].isspace()): return None
        return t
    def shape(t):
        nt = _norm(t)
        return bool(nt in keys or nt in heads or _CHAPLABEL.fullmatch(t) or _BACKLINK.fullmatch(t)
                    or (_COPYRIGHT.search(t) and _YEAR.search(t)))
    from collections import Counter
    cnt = Counter(); cand = {}; inf = False
    for i, l in enumerate(lines):
        if l.lstrip()[:3] in ("```", "~~~"): inf = not inf; continue
        if inf: continue
        t = plain(i)
        if t is not None and shape(t): cnt[t] += 1; cand[i] = t
    rep = {t for t, c in cnt.items() if c >= 6}
    nfurn = sum(1 for l in lines if _furn(l))
    if nfurn < 4 and not rep: return md
    out = []; inf = False
    for i, l in enumerate(lines):
        if l.lstrip()[:3] in ("```", "~~~"): inf = not inf; out.append(l); continue
        if not inf and ((nfurn >= 4 and _furn(l)) or cand.get(i) in rep): continue
        out.append(l)
    return "\n".join(out)
def write(idx, ttl, md):
    name = ("%03d %s" % (idx, sanitize(ttl))) if ttl else ("%03d" % idx)
    open(os.path.join(out, name + ".md"), "w", encoding="utf-8").write(fence_code(strip_furniture(md, ttl)))
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
SENT = "§§CHAPSPLIT§§"
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
                    for n in [el] + el.find_all_next(True, limit=600):
                        if n.get("id") in others: break
                        if n.name not in H and n.name != "p": continue
                        t = _nrm(n.get_text())
                        if any(t == k or (t.startswith(k) and len(t) <= len(k) * 2 + 4) for k in keys): h = n; break
                        if n.name in H and first_head is None: first_head = n
                        seen_chars += len(n.get_text());
                        if seen_chars > 4000: break
                    if h is None: h = first_head
                (h if h is not None else el).insert_before(mk)
            else: body.insert(0, mk)                  # whole-doc boundary
        parts.append(pandoc_html(str(body), os.path.dirname(p)))
    # split the concatenated stream at the sentinels
    segs = []; lbl = "Front Matter"; buf = []
    rx = re.compile(re.escape(SENT) + r"(.*?)" + re.escape(SENT))
    for line in ("\n\n".join(parts)).split("\n"):
        m = rx.search(line)
        if m:
            segs.append((lbl, "\n".join(buf))); lbl = m.group(1).strip() or "untitled"; buf = []
        else:
            buf.append(line)
    segs.append((lbl, "\n".join(buf)))
    idx = 0
    for lbl, md in segs:
        md = md.strip("\n")
        if md.strip() and "读累了记得休息一会哦" not in md:
            idx += 1; write(idx, lbl, md)
    if idx >= 3:
        print("strategy=anchor-split chapters=%d" % idx); sys.exit(0)
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