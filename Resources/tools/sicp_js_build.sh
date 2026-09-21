#!/usr/bin/env bash
# Freeze SICP (JavaScript edition, sourceacademy.org/sicpjs) into the :Docs frozen
# web-book layout used by the "SICP JS" picker:
#   Resources/docs/sicp-js/index.tsv            "<title>\t<url>" in section order
#   Resources/docs/.webcache/<sha256(url)>.txt    the rendered section
#
# The /sicpjs/ site is a React SPA; its JS-edition content is the JSON tree served
# at https://sicp.sourceacademy.org/json/<id>.json. This builder enumerates every
# section (front/back matter from toc.json; chapters 1..5 with numbered sub-sections
# probed until 404), renders each JSON tag tree to markdown (SNIPPET -> ```js code,
# TITLE -> heading, TEXT/EM/B/lists/footnotes/exercises), and writes one cache per
# section keyed by its public URL. Entries are numbered 1.0 / 1.1 / 1.1.1 and
# indented by depth.
# Usage: sicp_js_build.sh   (needs python3)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"

CFG="$CFG" python3 - <<'PY'
import os, re, json, hashlib, urllib.request, urllib.error
CFG = os.environ["CFG"]
CACHE = os.path.join(CFG, "Resources/docs/.webcache")
OUT = os.path.join(CFG, "Resources/docs/sicp-js")
JSON_BASE = "https://sicp.sourceacademy.org/json/"
PAGE_BASE = "https://sourceacademy.org/sicpjs/"
os.makedirs(CACHE, exist_ok=True); os.makedirs(OUT, exist_ok=True)

def get(sid):
    try:
        with urllib.request.urlopen(JSON_BASE + sid + ".json", timeout=30) as r:
            return json.loads(r.read().decode("utf-8", "replace"))
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise
    except Exception:
        return None

def norm(s):
    return re.sub(r"\s+", " ", "" if s is None else str(s)).strip()

def bodystr(n):
    b = n.get("body")
    return "" if b is None else str(b)

INLINE_WRAP = {"EM": "*", "IT": "*", "I": "*", "B": "**", "STRONG": "**"}
CODE_INLINE = {"JAVASCRIPTINLINE", "JAVASCRIPT", "SCHEMEINLINE", "TT"}

def kids(n):
    return n.get("child") or []

def inline(n):
    if isinstance(n, list):
        return "".join(inline(c) for c in n)
    tag = n.get("tag"); body = bodystr(n)
    inner = "".join(inline(c) for c in kids(n))
    if tag == "#text":
        return re.sub(r"\s+", " ", body)
    if tag in INLINE_WRAP:
        txt = inner or body
        return INLINE_WRAP[tag] + txt + INLINE_WRAP[tag] if txt.strip() else txt
    if tag in CODE_INLINE:
        return "`" + (body or inner) + "`"
    if tag in ("LATEXINLINE", "LATEX", "META", "MATH"):
        return body or inner
    if tag in ("REF", "LINK", "A", "QUOTE", "CITATION", "FOOTNOTE_REF"):
        return inner or norm(body)
    return inner or re.sub(r"\s+", " ", body)

# Tags that force a paragraph break inside a run of otherwise-inline content.
FLOW_BLOCK = {"SNIPPET", "UL", "OL", "FIGURE", "TABLE", "DISPLAYFOOTNOTE",
              "SUBHEADING", "SUBSUBHEADING", "EXERCISE", "TITLE", "LATEX",
              "SNIPPET_DIsplay"}

def snippet_code(n):
    code = bodystr(n)
    if not code.strip():
        code = "".join(bodystr(c) for c in kids(n) if isinstance(c, dict))
    return code.rstrip()

def flow(cs):
    # Render a node's children as paragraphs: accumulate inline pieces, and flush
    # to a paragraph whenever a real block child (snippet, list, ...) appears.
    out, para = [], []
    def flush():
        if para:
            t = re.sub(r"[ \t]+", " ", "".join(para))
            t = re.sub(r"\s*\n\s*", " ", t).strip()
            if t:
                out.append(t)
            para.clear()
    for c in cs:
        if isinstance(c, dict) and c.get("tag") in FLOW_BLOCK:
            flush()
            b = block(c)
            if b:
                out.append(b)
        else:
            para.append(inline(c))
    flush()
    return "\n\n".join(out)

def block(n):
    tag = n.get("tag"); body = bodystr(n); cs = kids(n)
    if tag == "TITLE":
        return "# " + norm(body)
    if tag in ("SUBHEADING", "SUBSUBHEADING"):
        return "## " + (norm(body) or flow(cs).strip())
    if tag == "SNIPPET":
        code = snippet_code(n)
        return "```javascript\n" + code + "\n```" if code.strip() else ""
    if tag in ("UL", "OL"):
        out = []
        i = 1
        for c in cs:
            if isinstance(c, dict) and c.get("tag") == "LI":
                mark = "- " if tag == "UL" else ("%d. " % i); i += 1
                out.append(mark + flow(kids(c)).replace("\n\n", " ").strip())
        return "\n".join(out)
    if tag == "EXERCISE":
        return "**Exercise**\n\n" + flow(cs)
    if tag == "DISPLAYFOOTNOTE":
        t = flow(cs).replace("\n\n", "\n").strip()
        return "\n".join("> " + ln for ln in t.split("\n"))
    if tag == "FIGURE":
        cap = flow(cs).strip()
        return "*(figure)* " + cap if cap else "*(figure)*"
    # TEXT, P, EPIGRAPH, None, or any unknown container: flow the children
    return flow(cs).strip() or norm(body)

def render(doc):
    nodes = doc if isinstance(doc, list) else [doc]
    return "\n\n".join(b for b in (block(n) for n in nodes) if b).strip()

def title_of(doc, fallback):
    nodes = doc if isinstance(doc, list) else [doc]
    for n in nodes:
        if isinstance(n, dict) and n.get("tag") == "TITLE":
            return norm(n.get("body", ""))
    return fallback

rows = []
def emit(indent, title, sid, doc):
    body = render(doc)
    if len(body) < 5:
        return
    url = PAGE_BASE + sid
    cf = os.path.join(CACHE, hashlib.sha256(url.encode()).hexdigest() + ".txt")
    open(cf, "w", encoding="utf-8").write(body + "\n")
    rows.append("%s%s\t%s" % ("  " * indent, title, url))

# Walk toc.json in order: front matter, chapters 1..5 (each with its numbered
# sub-sections probed until 404), then back matter.
toc = get("toc") or []
order = [str(x.get("nodeData", "")) for x in toc]
for sid in order:
    if re.fullmatch(r"[1-5]", sid):
        n = int(sid)
        doc = get(sid)
        if doc:
            ct = title_of(doc, sid)
            ct = re.sub(r"^%d\s+" % n, "%d.0 " % n, ct) or ct  # "1 Building..." -> "1.0 Building..."
            if not ct.startswith("%d.0" % n):
                ct = "%d.0  %s" % (n, ct)
            emit(0, ct, sid, doc)
        m = 1
        while True:
            sec = "%d.%d" % (n, m)
            sdoc = get(sec)
            if sdoc is None:
                break
            emit(1, title_of(sdoc, sec), sec, sdoc)
            k = 1
            while True:
                sub = "%d.%d.%d" % (n, m, k)
                bdoc = get(sub)
                if bdoc is None:
                    break
                emit(2, title_of(bdoc, sub), sub, bdoc)
                k += 1
            m += 1
    else:
        # front/back matter (rendered in toc order)
        lab = next((x["label"] for x in toc if str(x.get("nodeData")) == sid), sid)
        doc = get(sid)
        if doc is not None:
            emit(0, title_of(doc, lab), sid, doc)

open(os.path.join(OUT, "index.tsv"), "w", encoding="utf-8").write("\n".join(rows) + "\n")
print("==> SICP JS: %d sections, index rows: %d" % (len(rows), len(rows)))
PY
echo "index rows: $(wc -l < "$CFG/Resources/docs/sicp-js/index.tsv" 2>/dev/null)"
