import sys
from bs4 import BeautifulSoup
mode = sys.argv[1]
arg = sys.argv[2] if len(sys.argv) > 2 else ""
base = sys.argv[3] if len(sys.argv) > 3 else ""
s = BeautifulSoup(sys.stdin.read(), "html.parser")
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
    for t in el.select("script, style, ins, iframe, nav, #comments, .comments, .code-block-buttons, .prevnext, .share-buttons, .page__share, .pagination, .code-header"):
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
    # Flatten block-content tables so pandoc's gfm writer never drops them to a
    # bare "[TABLE]": a table with block content is linearized (each row -> its
    # text, then its <pre> code) so nothing is discarded; a simple table is
    # rebuilt with text-only cells so it can be piped; the <caption> is kept.
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
    sys.stdout.write(str(el))

