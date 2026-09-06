import sys
from bs4 import BeautifulSoup
mode = sys.argv[1]
arg = sys.argv[2] if len(sys.argv) > 2 else ""
base = sys.argv[3] if len(sys.argv) > 3 else ""
s = BeautifulSoup(sys.stdin.read(), "html.parser")


def flatten_tables(el):
    """Flatten block-content tables so pandoc's gfm writer never drops them to a
    bare "[TABLE]": a table with block content is linearized (each row -> its
    text, then its <pre> code) so nothing is discarded; a simple table is
    rebuilt with text-only cells so it can be piped; the <caption> is kept."""
    for table in [t for t in el.select("table") if t.find_parent("table") is None]:
        div = s.new_tag("div")
        cap = table.find("caption")
        if cap:
            p = s.new_tag("p"); st = s.new_tag("strong")
            st.string = cap.get_text(" ", strip=True); p.append(st); div.append(p)
        if table.find(["pre", "ul", "ol"]):
            for r in [x for x in table.find_all("tr") if x.find_parent("table") is table and x.find_parent("tr") is None]:
                pres = [pr.extract() for pr in r.find_all("pre")]
                label = r.get_text(" ", strip=True)
                if label:
                    p = s.new_tag("p"); p.string = label; div.append(p)
                for pr in pres:
                    div.append(pr)
        else:
            nt = s.new_tag("table")
            for r in [x for x in table.find_all("tr") if x.find_parent("table") is table and x.find_parent("tr") is None]:
                nr = s.new_tag("tr")
                for c in [x for x in r.find_all(["td", "th"]) if x.find_parent("tr") is r]:
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
    _RUST = ("fn ", "let ", "impl ", "pub fn", "use std", "->", "unsafe", "&self", "static ", "match ")
    _ASM = ("mov ", "ldr ", "str ", "ldxr", "stxr", "dmb ", "lock ", "cmpxchg", "xchg", "%rax", "x0,")
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

    flatten_tables(el)
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
    # Wiki links are relative to the site root in the dump ("X86_Paging",
    # "./Category:X"), so absolutise them against base to keep them clickable.
    if base:
        for a in el.find_all("a", href=True):
            h = a["href"]
            if "://" in h or h.startswith(("#", "mailto:")):
                continue
            a["href"] = base.rstrip("/") + "/" + h.lstrip("./")
    flatten_tables(el)
    sys.stdout.write(str(el))

