#!/usr/bin/env python3
"""markdown source tree -> a frozen book of numbered chapters.

    python3 mdrepo_build.py <slug> <source-root> <out-dir> [--check]

Turns a documentation git repo (or a saved site capture) into the shape the
rest of Resources/docs/books uses: "NNN Title.md" chapters, a "media/"
directory beside them holding every asset the chapters reference, a
".complete" marker, and nothing else.  The out-dir basename must be the book's
slug; the per-book rules below are keyed on it.

Flattening a nested tree into one level of numbered files breaks every
relative reference the source wrote, so the two passes that matter are not the
copy but what follows it:

  media/    every referenced image (and every referenced non-markdown example
            file) is copied to "media/<sha1 of its bytes>.<ext>" and the
            reference rewritten to point there.  This is the convention
            epub_build.sh already established, so a book from a repo and a
            book from an epub resolve their pictures the same way.  Naming by
            content hash also folds duplicates together, which matters for a
            site capture that saves the same banner GIF beside every post.

  links     every relative cross-reference is re-pointed at the numbered file
            the target became.  A target that is in the source but not in the
            book (it lives outside the part that was included) becomes the
            absolute upstream URL, so the reference still leads somewhere; a
            target that does not exist in the source either (an upstream link
            that was already broken) loses its destination and keeps its text,
            the way epub_build.sh treats a dead intra-epub link.

Chapter text is otherwise byte-identical to the source document.  The two
exceptions are the ir0nstone book, whose GitBook YAML front matter is stripped
and whose "description:" key is kept as an italic line under the heading, and
the CodeCrafters courses, whose stage descriptions carry no heading of their
own so one is prepended (see plan_codecrafters).

Slugs:
  linux-insides                    0xAX/linux-insides, ordered by SUMMARY.md
  ebpf-developer-tutorial          eunomia-bpf/bpf-developer-tutorial,
                                   src/SUMMARY.md then the unlisted lessons
  heap-exploitation-dhaval-kapil   DhavalKapil/heap-exploitation, SUMMARY.md
  ir0nstone-binary-exploitation    ir0nstone/cybersec-notes, the Binary
                                   Exploitation part of SUMMARY.md
  build-your-own-git               codecrafters-io/build-your-own-git
  build-your-own-sqlite            codecrafters-io/build-your-own-sqlite
  build-your-own-docker            codecrafters-io/build-your-own-docker.  All
                                   three are one course repo apiece and share
                                   plan_codecrafters: an overview generated
                                   from course-definition.yml, then one
                                   chapter per stage.
  linternals-sam4k                 a saved sam4k.com capture.  Its chapters
                                   are produced by webextract.py + pandoc, not
                                   here, so this slug runs in attach mode: it
                                   reads the chapters already in the out-dir
                                   and only does the media/ and link passes
                                   against the capture root.  Everything else
                                   about the file stays byte-identical.
"""

import argparse
import hashlib
import os
import re
import shutil
import sys
import urllib.parse

# ── generic helpers ─────────────────────────────────────────────────────

_NUM = re.compile(r"(\d+(?:\.\d+)*)")


def natkey(name):
    """Sort key that reads runs of digits (dotted numbers included) as numbers.

    "5" < "5.1" < "6" < "45", which is the order these courses number their
    own directories in, unlike a lexical sort where "45" lands before "5.1".
    """
    key = []
    for i, part in enumerate(_NUM.split(name)):
        if i % 2:
            key.append((0, tuple(int(x) for x in part.split("."))))
        elif part:
            key.append((1, part.lower()))
    return key


def sanitize(title):
    """Make a display title safe as a file name, keeping it readable."""
    t = title.replace("/", "-").replace("\\", "-")
    t = re.sub(r"[\x00-\x1f]", " ", t)
    t = re.sub(r"\s+", " ", t).strip()
    return t.rstrip(". ") or "Untitled"


def clean_title(text):
    """Strip markdown inline markup out of a heading so it reads as a title."""
    t = text.strip()
    t = re.sub(r"<a\b[^>]*>.*?</a>", "", t, flags=re.S)  # gitbook anchors
    t = re.sub(r"!\[([^\]]*)\]\([^)]*\)", r"\1", t)  # images
    t = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", t)  # links
    t = t.replace("`", "")
    # only paired markers are emphasis; a lone one belongs to the title, as in
    # "*CTF 2019" and "malloc\_consolidate()"
    for pat in (r"\*\*([^*]+)\*\*", r"\*([^*]+)\*", r"__([^_]+)__"):
        t = re.sub(pat, r"\1", t)
    t = re.sub(r"\\([^A-Za-z0-9])", r"\1", t)  # markdown escapes
    t = t.replace("\\", "")
    return re.sub(r"\s+", " ", t).strip()


HEADING = re.compile(r"^(#{1,3})\s+(.*?)\s*#*\s*$")


def first_heading(text):
    """The document's first ATX heading, ignoring anything inside a fence."""
    fence = None
    for line in text.split("\n"):
        s = line.strip()
        if fence:
            if s.startswith(fence):
                fence = None
            continue
        if s.startswith("```") or s.startswith("~~~"):
            fence = s[:3]
            continue
        m = HEADING.match(line)
        if m:
            t = clean_title(m.group(2))
            if t:
                return t
    return None


def titlecase_slug(slug):
    """Last-resort title: a slug or file name turned into words."""
    s = re.sub(r"\.md$", "", slug)
    s = re.sub(r"^\d+(\.\d+)*[-_]", "", s)
    s = re.sub(r"\s+", " ", s.replace("_", " ").replace("-", " ")).strip()
    return " ".join(w if w.isupper() else w.capitalize() for w in s.split())


def norm(s):
    """Compare titles ignoring case, punctuation and spacing."""
    return re.sub(r"[^a-z0-9]+", "", s.lower())


def read(path):
    with open(path, encoding="utf-8", errors="replace") as fh:
        return fh.read()


# ── inline reference scanner ────────────────────────────────────────────
#
# Every reference in a chapter that could point at a local file, with the exact
# span of its destination so a rewrite can splice a new one in without touching
# a byte of the surrounding text.  Three shapes occur in these sources:
#
#   ![alt](dest)   markdown image
#   [text](dest)   markdown link
#   src="dest"     raw HTML the source wrote by hand (GitBook <figure> blocks)
#   href="dest"
#
# A destination may be wrapped in <> or may carry balanced parentheses, which
# both the sam4k capture (".../The (Modern) Boot Process ..._files/x.gif") and
# the GitBook assets (".gitbook/assets/image (20).png") rely on.

EXTERNAL = re.compile(r"(?:[A-Za-z][\w+.-]*://|mailto:|tel:|urn:|data:|news:|irc:|//)", re.I)
HTML_ATTR = re.compile(r'\b(?:src|href)="([^"]*)"')
VIEWER_LINK = re.compile(r'(?<!\\)(!?)\[([^\]\n]*)\]\(([^)\n]+)\)')


def _fence_spans(text):
    """Character ranges covered by fenced code blocks (verbatim, never rewritten)."""
    spans, fence, start = [], None, 0
    pos = 0
    for line in text.split("\n"):
        s = line.lstrip()
        if fence is None and (s.startswith("```") or s.startswith("~~~")):
            fence, start = s[:3], pos
        elif fence is not None and s.startswith(fence):
            spans.append((start, pos + len(line)))
            fence = None
        pos += len(line) + 1
    if fence is not None:
        spans.append((start, len(text)))
    return spans


def _close_bracket(text, i):
    """Index of the ']' closing the '[' at i, or -1."""
    depth, j, n = 0, i, len(text)
    while j < n:
        c = text[j]
        if c == "\\":
            j += 2
            continue
        if c == "[":
            depth += 1
        elif c == "]":
            depth -= 1
            if depth == 0:
                return j
        elif c == "\n" and text[j : j + 2] == "\n\n":
            return -1
        j += 1
    return -1


def _destination(text, i):
    """Parse "(dest[ \"title\"])" at i.  Returns (dest, dstart, dend, end)."""
    n = len(text)
    j = i + 1
    while j < n and text[j] in " \t\n":
        j += 1
    if j < n and text[j] == "<":
        k = text.find(">", j + 1)
        if k < 0:
            return None
        # The edit span covers the brackets too, not just what is between
        # them: once a rewrite fires, the new destination is always one this
        # builder made safe on its own (a sha1 media name, a percent-quoted
        # chapter link, a percent-quoted upstream URL), so the "<...>" wrapper
        # the source needed for a raw path with a space or a paren (GitBook's
        # ".gitbook/assets/image (41).png") is never needed for what replaces
        # it. Keeping the wrapper's inner span here would splice the new
        # destination back inside the brackets and hand the viewer's image
        # resolver (which does not strip them) a literal "<...>" path that
        # can never be a file on disk. An untouched reference (new == dest)
        # never reaches the splice, so its original "<...>" form is left
        # exactly as the source wrote it.
        dest, dstart, dend = text[j + 1 : k], j, k + 1
        j = k + 1
    else:
        depth, start = 0, j
        while j < n:
            c = text[j]
            if c == "\\":
                j += 2
                continue
            if c in " \t\n":
                break
            if c == "(":
                depth += 1
            elif c == ")":
                if depth == 0:
                    break
                depth -= 1
            j += 1
        dest, dstart, dend = text[start:j], start, j
    while j < n and text[j] in " \t\n":
        j += 1
    if j < n and text[j] in "\"'(":
        close = {"\"": "\"", "'": "'", "(": ")"}[text[j]]
        k = text.find(close, j + 1)
        if k < 0:
            return None
        j = k + 1
        while j < n and text[j] in " \t\n":
            j += 1
    if j >= n or text[j] != ")":
        return None
    return dest, dstart, dend, j + 1


def find_refs(text):
    """[(kind, dest, dstart, dend, lstart, lend, tstart, tend)] per reference.

    kind is "image", "link" or "html"; (dstart, dend) spans the destination,
    (lstart, lend) the whole reference and (tstart, tend) its link text, which
    is what a reference with no possible target falls back to.  Destinations
    inside a fence, external URLs and bare "#anchor" targets are skipped: none
    of them is a file reference this builder can or should redirect.
    """
    fences = _fence_spans(text)

    def fenced(p):
        return any(a <= p < b for a, b in fences)

    refs, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == "\\":
            i += 2
            continue
        if c == "[" and not fenced(i):
            close = _close_bracket(text, i)
            if close > 0 and close + 1 < n and text[close + 1] == "(":
                d = _destination(text, close + 1)
                if d:
                    dest, ds, de, end = d
                    img = bool(i) and text[i - 1] == "!"
                    kind = "image" if img else "link"
                    if dest and not EXTERNAL.match(dest) and not dest.startswith("#"):
                        refs.append((kind, dest, ds, de, i - (1 if img else 0), end,
                                     i + 1, close))
        i += 1
    # The viewer's own link pattern is looser than CommonMark: it takes
    # everything up to the first ")" as the destination, so a malformed link
    # CommonMark rejects still reads as a link on screen and still reports
    # "Link target not found" (linux-insides writes "[Intel 8253](Programmable
    # interval timer)", a Wikipedia article title where a URL belongs).  Pick
    # those up too, but only where they do not overlap a reference the strict
    # scan already found, and never across a line or an angle-bracket target.
    taken = [(r[4], r[5]) for r in refs]
    for m in VIEWER_LINK.finditer(text):
        dest = m.group(3).strip()   # "[video]( https://...)": still a URL
        if fenced(m.start()) or EXTERNAL.match(dest) or dest.startswith("#") or "<" in dest:
            continue
        if any(a <= m.start() < b or a < m.end() <= b for a, b in taken):
            continue
        kind = "image" if m.group(1) else "link"
        refs.append((kind, dest, m.start(3), m.end(3), m.start(), m.end(),
                     m.start(2), m.end(2)))
    for m in HTML_ATTR.finditer(text):
        if fenced(m.start()):
            continue
        dest = m.group(1)
        if dest and not EXTERNAL.match(dest) and not dest.startswith("#"):
            refs.append(("html", dest, m.start(1), m.end(1),
                         m.start(1), m.end(1), m.start(1), m.start(1)))
    refs.sort(key=lambda r: r[2])
    return refs


# ── media and link passes ───────────────────────────────────────────────

# Only what a reader can actually open in the viewer is worth carrying in the
# repo: pictures, which snacks.image renders, and the plain-text example files
# that a chapter links to, which open as source.  An archive or a prebuilt
# binary (ir0nstone embeds 34 challenge .zip files, 7.6 MB) would be dead
# weight in the git history and `is_binary` refuses to show it anyway, so those
# references go to the upstream URL instead.
ASSET_EXT = {
    ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp", ".bmp", ".ico",
    ".c", ".h", ".cc", ".cpp", ".hpp", ".rs", ".go", ".py", ".sh", ".lua",
    ".s", ".asm", ".pl", ".rb", ".js", ".json", ".yaml", ".yml", ".toml",
    ".txt", ".cfg", ".conf", ".ld", ".mk", ".diff", ".patch", ".csv",
}
ASSET_MAX = 16 * 1024 * 1024  # --max-asset; the sam4k capture has a 10 MiB GIF


def sha1_name(path):
    h = hashlib.sha1()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    ext = os.path.splitext(path)[1].lower()
    return h.hexdigest() + ext


def rewrite(records, src_root, out_dir, upstream, stats, max_asset=ASSET_MAX, prev_media=None):
    """Repoint every relative reference, copying the assets it needs.

    records: [{"out": file name, "body": text, "src": path relative to
    src_root}].  A record's references resolve against its own source
    directory, exactly as they did in the tree the chapter came from.
    """
    chapters = {}
    for r in records:
        chapters[os.path.normpath(r["src"])] = r["out"]

    media = os.path.join(out_dir, "media")
    copied = {}

    def asset(abspath):
        """Copy an asset into media/ once; return its book-relative path."""
        key = os.path.realpath(abspath)
        if key not in copied:
            name = sha1_name(abspath)
            os.makedirs(media, exist_ok=True)
            dst = os.path.join(media, name)
            if not os.path.exists(dst):
                shutil.copyfile(abspath, dst)
            copied[key] = "media/" + name
        return copied[key]

    def up(rel, frag):
        """The upstream URL for a source path (percent-encoded, "/" kept)."""
        return upstream + urllib.parse.quote(rel) + frag if upstream else None

    def target_for(src_dir, dest):
        """(new destination, disposition) for one reference, or (None, why)."""
        # A rebuild reads back its own output (attach mode literally does), so
        # a reference this builder already pointed at media/ must resolve
        # against the previous build's media rather than look "missing".
        raw = dest.split("#", 1)
        frag = "#" + raw[1] if len(raw) > 1 else ""
        path = urllib.parse.unquote(raw[0]).replace("\\", "").strip()
        if not path:
            return None, "anchor"
        if prev_media and path.startswith("media/"):
            old = os.path.join(prev_media, os.path.basename(path))
            if os.path.isfile(old):
                return asset(old) + frag, "media"
        if path.startswith("/"):
            return (up(path.lstrip("/"), frag), "upstream") if upstream else (None, "missing")
        # GitBook renders <page>.md at the URL <page>/, so a link it wrote can
        # carry one ".." more than the source layout has.  Try the literal
        # resolution first, then that one-level-shallower reading.
        tries = [path]
        p = path
        while p.startswith("../"):
            p = p[3:]
            tries.append(p)
        rels = []
        for t in tries:
            r = os.path.normpath(os.path.join(src_dir, t))
            if not r.startswith("..") and r not in rels:
                rels.append(r)
        for rel in rels:
            for cand in (rel, os.path.join(rel, "README.md"), rel + ".md"):
                if cand in chapters:
                    return urllib.parse.quote(chapters[cand], safe="") + frag, "chapter"
        for rel in rels:
            full = os.path.join(src_root, rel)
            if os.path.isfile(full):
                ext = os.path.splitext(full)[1].lower()
                if ext in ASSET_EXT and os.path.getsize(full) <= max_asset:
                    return asset(full) + frag, "media"
                # In the source but not worth carrying: the upstream URL still
                # leads a reader to it.  A capture has no upstream mapping for
                # its "<page>_files/" directories, so there the reference is
                # left exactly as it was rather than pointed somewhere false.
                return (up(rel, frag), "upstream") if upstream else (None, "missing")
            if os.path.isdir(full):
                return (up(rel + "/", frag), "upstream") if upstream else (None, "missing")
        return None, "missing"

    for r in records:
        src_dir = os.path.dirname(os.path.normpath(r["src"]))
        text = r["body"]
        edits = []
        for kind, dest, ds, de, ls, le, ts, te in find_refs(text):
            new, why = target_for(src_dir, dest)
            stats[why] = stats.get(why, 0) + 1
            if why == "anchor":
                continue
            if why == "missing":
                # The target is not in the source tree either, so there is
                # nothing to point at.  An image keeps its (dead) reference so
                # the alt text still reads as a caption; a link drops its
                # destination and keeps its text, as epub_build.sh does.
                if kind == "link":
                    edits.append((ls, le, text[ts:te]))
                    stats["dropped"] = stats.get("dropped", 0) + 1
                continue
            if new != dest:
                edits.append((ds, de, new))
        for a, b, s in sorted(edits, reverse=True):
            text = text[:a] + s + text[b:]
        r["body"] = text
    return copied


def clean_out(out_dir):
    """Drop the previous build's chapters and media before writing the new one."""
    os.makedirs(out_dir, exist_ok=True)
    for f in os.listdir(out_dir):
        p = os.path.join(out_dir, f)
        if f.endswith(".md"):
            os.remove(p)
        elif f == "media":
            shutil.rmtree(p)


def write_book(out_dir, records, terminate):
    for r in records:
        body = r["body"]
        if terminate and body and not body.endswith("\n"):
            body += "\n"
        with open(os.path.join(out_dir, r["out"]), "w", encoding="utf-8") as fh:
            fh.write(body)
    open(os.path.join(out_dir, ".complete"), "w").close()


# ── per-book chapter plans ──────────────────────────────────────────────


def slashonly(title):
    """Only "/" is unusable in a file name; keep everything else as printed."""
    return title.replace("/", "-")


def number(records, start=0, safe=sanitize):
    for i, r in enumerate(records):
        r["out"] = "%03d %s.md" % (i + start, safe(r["title"]))
    return records


BULLET = re.compile(r"^(?P<indent>\s*)\* \[(?P<title>[^\]]*)\]\((?P<path>[^)]*)\)\s*$")


def plan_linux_insides(src):
    """SUMMARY.md order; a part's README becomes that part's "Overview"."""
    recs = [{"title": "Overview", "src": "README.md"}]
    part = None
    for raw in read(os.path.join(src, "SUMMARY.md")).split("\n"):
        m = BULLET.match(raw)
        if not m:
            continue
        title, path = m.group("title").strip(), m.group("path").strip()
        if m.group("indent") == "":
            if path == "":
                part = title  # a part the author has not written yet
                continue
            if path.endswith("README.md"):
                part = title
                recs.append({"title": "%s - Overview" % part, "src": path})
            else:
                part = None
                recs.append({"title": title, "src": path})
        else:
            if path == "":
                continue
            recs.append({"title": "%s - %s" % (part, title) if part else title, "src": path})
    return number([r for r in recs if os.path.isfile(os.path.join(src, r["src"]))], safe=slashonly)


EBPF_LINK = re.compile(r"^\s*-\s*\[([^\]]*)\]\(([^)]+)\)\s*(.*?)\s*$")


def plan_ebpf(src):
    """src/SUMMARY.md order, then the English lessons SUMMARY does not list."""
    recs = [{"title": "eBPF Developer Tutorial - Overview", "src": "README.md"}]
    seen = set()
    for line in read(os.path.join(src, "src", "SUMMARY.md")).split("\n"):
        m = EBPF_LINK.match(line)
        if not m:
            continue
        label, target, tail = m.group(1), m.group(2), m.group(3)
        if target.startswith("http") or target.endswith(".zh.md"):
            continue
        rel = os.path.normpath(target)
        if rel in seen or not os.path.isfile(os.path.join(src, "src", rel)):
            continue
        seen.add(rel)
        lm = re.match(r"^lesson\s+(\d+)-", label)
        clean = lambda t: re.sub(r"\s+", " ", t.replace("`", "").strip())
        if lm and tail:
            title = "Lesson %s - %s" % (lm.group(1), clean(tail))
        else:
            title = clean(tail) or clean(label) or rel
        recs.append({"title": title, "src": os.path.join("src", rel)})
    for d in sorted(os.listdir(os.path.join(src, "src"))):
        rel = os.path.join(d, "README.md")
        if not os.path.isfile(os.path.join(src, "src", rel)) or rel in seen:
            continue
        t = re.sub(r"\s+", " ", (first_heading(read(os.path.join(src, "src", rel))) or rel).strip())
        hm = re.match(r"^eBPF Tutorial by Example (\d+):\s*(.+)$", t)
        if hm:
            t = "Lesson %s - %s" % (hm.group(1), hm.group(2))
        recs.append({"title": t, "src": os.path.join("src", rel)})
    return number(recs, safe=slashonly)


GITBOOK_LINK = re.compile(r"^(\s*)\*\s+\[(.+?)\]\((.+?)\)\s*$")


def _gitbook_summary(path, lo=1, hi=10 ** 9):
    """[(indent columns, title, target)] for the SUMMARY lines in [lo, hi]."""
    out = []
    for i, line in enumerate(read(path).split("\n"), 1):
        if not lo <= i <= hi:
            continue
        m = GITBOOK_LINK.match(line)
        if m:
            title = m.group(2)
            for a, b in (("\\_", "_"), ("\\*", "*"), ("\\[", "["), ("\\]", "]")):
                title = title.replace(a, b)
            out.append((len(m.group(1).expandtabs(4)), title, m.group(3).split("#")[0]))
    return out


def plan_heap(src):
    """SUMMARY.md order, each chapter named by its full nesting chain."""
    recs, stack = [], []
    for indent, title, target in _gitbook_summary(os.path.join(src, "SUMMARY.md")):
        while stack and stack[-1][0] >= indent:
            stack.pop()
        stack.append((indent, title))
        if not os.path.isfile(os.path.join(src, target)):
            continue
        name = " - ".join(t for _, t in stack)
        name = re.sub(r"\s+", " ", name.replace("/", "-").replace(":", " -").replace("\\", "-")).strip()
        recs.append({"title": name, "src": target})
    return number(recs, safe=slashonly)


GENERIC = {"exploitation", "introduction", "overview", "readme", "exploit", "intro"}


def strip_front_matter(text):
    """Split a leading YAML front matter block off, keeping its description."""
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        return text, None
    end = next((i for i in range(1, min(len(lines), 40)) if lines[i].strip() == "---"), None)
    if end is None:
        return text, None
    block, desc = lines[1:end], None
    for i, b in enumerate(block):
        m = re.match(r"^description:\s*(.*)$", b)
        if not m:
            continue
        val = m.group(1).strip()
        if val in (">-", ">", "|", "|-", ""):
            cont = []
            for c in block[i + 1 :]:
                if re.match(r"^[A-Za-z_][A-Za-z0-9_]*:", c):
                    break
                cont.append(c.strip())
            val = " ".join(x for x in cont if x)
        desc = val.strip().strip("'\"") or None
        break
    return "\n".join(lines[end + 1 :]).lstrip("\n"), desc


def apply_description(body, desc):
    """Keep a front matter description as an italic line under the heading."""
    if not desc:
        return body
    line = "*" + desc.replace("*", "") + "*"
    lines, fence = body.split("\n"), None
    for i, l in enumerate(lines):
        s = l.strip()
        if fence:
            if s.startswith(fence):
                fence = None
            continue
        if s.startswith("```") or s.startswith("~~~"):
            fence = s[:3]
            continue
        if HEADING.match(l):
            rest = lines[i + 1 :]
            while rest and not rest[0].strip():
                rest.pop(0)
            return "\n".join(lines[: i + 1] + ["", line, ""] + rest)
    return line + "\n\n" + body


def uniquify(records):
    """Force every chapter title in a book to be distinct.

    Each record carries "alts", candidate titles from the plainest to the most
    qualified.  Colliding records step to their next candidate, so a clash is
    broken by naming the enclosing part, never by a bare number.  A landing
    page (README) keeps the plain name and its siblings take the qualified one.
    """
    for r in records:
        r.setdefault("alt", 0)
        r["title"] = r["alts"][r["alt"]]

    def group():
        by = {}
        for r in records:
            by.setdefault(r["title"], []).append(r)
        return by

    for _ in range(8):
        dupes = [rs for rs in group().values() if len(rs) > 1]
        if not dupes:
            break
        for rs in dupes:
            movable = [r for r in rs if r["alt"] + 1 < len(r["alts"])]
            junior = [r for r in movable if r.get("rank", 1)]
            for r in junior if junior and len(junior) < len(rs) else movable:
                r["alt"] += 1
                r["title"] = r["alts"][r["alt"]]
    left = [k for k, v in group().items() if len(v) > 1]
    if left:
        raise SystemExit("could not disambiguate: %r" % left)
    return records


def plan_ir0nstone(src):
    """The Binary Exploitation part of SUMMARY.md, in order."""
    entries, inbin = [], False
    for line in read(os.path.join(src, "SUMMARY.md")).split("\n"):
        if line.startswith("## "):
            inbin = "Binary Exploitation" in line
            continue
        m = re.match(r"^(\s*)\* \[(.*)\]\((.*)\)\s*$", line)
        if m and inbin:
            entries.append((len(m.group(1)) // 2, clean_title(m.group(2)), m.group(3)))

    recs, chain = [], {}
    for depth, title, path in entries:
        chain[depth] = title
        for k in [k for k in chain if k > depth]:
            del chain[k]
        parents = [chain[k] for k in sorted(chain) if k < depth]
        body, desc = strip_front_matter(read(os.path.join(src, path)))
        body = apply_description(body, desc)
        name = title or first_heading(body) or titlecase_slug(os.path.basename(path))
        alts = []
        for k in range(len(parents) + 1):
            cand = " - ".join(parents[len(parents) - k :] + [name])
            if cand not in alts:
                alts.append(cand)
        if depth >= 2 and len(alts) > 1:
            alts.pop(0)  # always qualify a grandchild with its parent
            while len(alts) > 1 and parents and norm(parents[-1]) in GENERIC:
                alts.pop(0)
                parents = parents[:-1]
        recs.append({
            "alts": alts,
            "body": body,
            "src": path,
            "rank": 0 if os.path.basename(path).lower() == "readme.md" else 1,
        })
    return number(uniquify(recs), start=1)


# ── CodeCrafters courses ────────────────────────────────────────────────
#
# A CodeCrafters course repo is not a book, it is the data a course page is
# rendered from, so this book is assembled rather than collected.  Two files
# hold everything a reader wants: course-definition.yml carries the course
# name, the blurb the overview page shows and the ordered "stages:" list, and
# stage_descriptions/ carries one markdown file per stage, named
# "base-<NN>-<stage slug>.md" and written with no heading of its own (the
# course page supplies the stage's title and difficulty around it).  So the
# book is an "000 Overview" generated from the YAML, then one chapter per
# stage: the YAML's stage name as the heading, its difficulty as an italic
# line, and the stage description verbatim under both.
#
# The YAML has two traps, each of which costs or invents a chapter:
#
#   - "languages:" is also a list of "- slug:" entries (docker's are c, go,
#     nim, php, python, ruby, rust, swift).  They are the languages the course
#     can be solved in, not stages, so the list under "stages:" has to be read
#     as such -- parse the YAML rather than grep for "- slug:".
#   - a stage may carry extra keys between "name" and "difficulty" (docker's
#     last stage has should_skip_previous_stages_for_test_run), so key order
#     is not something to key off either.
#
# What ships is deliberately not cleaned up.  A stage description is written
# for the course renderer, so it still carries unresolved Mustache
# conditionals ({{#lang_is_rust}} ... {{/lang_is_rust}}) fencing off
# language-specific advice, literal <details>/<summary> HTML around optional
# material, and in one case a whole description commented out with "<!-- -->".
# The difficulty likewise ships as the raw enum the YAML writes (very_easy).
# The first two of these books shipped that way and this keeps it: the three
# read alike, and nothing the course says is silently dropped from the book.

STAGE_DESC = re.compile(r"^base-\d+-(.+)\.md$")


def plan_codecrafters(src):
    """A generated overview from course-definition.yml, then one stage each."""
    import yaml  # only these books need it, the way bs4 is linternals-only

    with open(os.path.join(src, "course-definition.yml"), encoding="utf-8") as fh:
        course = yaml.safe_load(fh)

    desc_dir = os.path.join(src, "stage_descriptions")
    files = {}
    for name in sorted(os.listdir(desc_dir)):
        m = STAGE_DESC.match(name)
        if m:
            files[m.group(1)] = name

    overview = ["# " + course["name"], "",
                course["description_md"].rstrip("\n"), "",
                "## Stages", ""]
    recs = []
    for i, stage in enumerate(course["stages"], 1):
        slug, name, hard = stage["slug"], stage["name"], stage["difficulty"]
        overview.append("%d. %s  (%s)" % (i, name, hard))
        if slug not in files:
            raise SystemExit("stage %r (%s) has no stage_descriptions file" % (slug, name))
        rel = os.path.join("stage_descriptions", files.pop(slug))
        recs.append({
            "title": name,
            "src": rel,
            "body": "# %s\n\n*Difficulty: %s*\n\n%s" % (name, hard, read(os.path.join(src, rel))),
        })
    # A description the stage list never claims would be a chapter of the
    # course that silently never reached the book, so stop rather than ship a
    # book that is quietly short.
    if files:
        raise SystemExit("stage_descriptions not listed under stages: %s"
                         % ", ".join(sorted(files.values())))

    recs.insert(0, {"title": "Overview", "src": "course-definition.yml",
                    "body": "\n".join(overview) + "\n"})
    return number(recs, safe=slashonly)


# ── linternals fence-language recovery ─────────────────────────────────
#
# webextract.py's "content" mode has no special case for Hugo's chroma
# highlighter, so pandoc's HTML reader reads a chroma block's language off
# the *outer* <pre class="chroma"> rather than the <code class="language-X"
# data-lang="X"> that actually carries it. Every fence in this book landed on
# the info string "chroma", a CSS class rather than a language, which
# "clean" mode's fence_lang() has no reason to keep either way (it is not in
# _LANGS). webextract.py belongs to another agent, so the real language is
# recovered here instead, straight from the HTML the capture saved, and
# spliced into the fence marker without touching anything else on the line.
#
# Hugo's own guess is not trustworthy enough to use blindly: of the 77 chroma
# blocks in this capture, 29 come back data-lang="fallback" (chroma gave up)
# and 8 come back "gdscript3" (chroma guessed wrong -- checked against the
# actual content, which is kernel C, /proc output and strace sessions, never
# anything resembling Godot's scripting language). Both cases fall through to
# reading the block itself. Every block in this capture, read by hand, is one
# of exactly four things: a kernel/user C listing, an interactive gdb
# session, a shell prompt transcript, or a hand-drawn ASCII diagram, so the
# sniff below only has to tell those apart, and leaves a block bare rather
# than force a label onto the handful (a hand-written call-stack list, a
# bit-layout table) that fit none of them.
LINTERNALS_HTML = {
    "002 The (Modern) Boot Process [0x01].md": "Linternals_ The (Modern) Boot Process [0x01] _ sam4k.html",
    "003 The (Modern) Boot Process [0x02].md": "Linternals_ The (Modern) Boot Process [0x02] _ sam4k.html",
    "004 Introducing Virtual Memory.md": "Linternals_ Introducing Virtual Memory _ sam4k.html",
    "005 The User Virtual Address Space.md": "Linternals_ The User Virtual Address Space _ sam4k.html",
    "006 Exploring The mm Subsystem via mmap [0x01].md": "Linternals_ Exploring The mm Subsystem via mmap [0x01] _ sam4k.html",
    "007 Exploring The mm Subsystem via mmap [0x02].md": "Linternals_ Exploring The mm Subsystem via mmap [0x02] _ sam4k.html",
    "008 Exploring Linux's New Random Kmalloc Caches.md": "Exploring Linux's New Random Kmalloc Caches _ sam4k.html",
    "009 Kernel Exploitation Techniques - modprobe_path.md": "Kernel Exploitation Techniques_ modprobe_path _ sam4k.html",
    "010 Kernel Exploitation Techniques - Turning The (Page) Tables.md": "Kernel Exploitation Techniques_ Turning The (Page) Tables _ sam4k.html",
}

# form-feed bytes the PDF pipeline's own filter deliberately still lets
# through (it strips them at emit time itself); these two chapters are not
# that pipeline's output, they are pandoc's own PDF-to-markdown conversion of
# the two slide decks, and no shipped file should carry a raw 0x0C.
LINTERNALS_FORMFEED = {
    "011 No Tux Given (slides).md",
    "012 So You Wanna Find Bugs In The Kernel (slides).md",
}

FENCE_LINE = re.compile(r"^([ \t]*(?:>[ \t]*)*)([`~]{3,})[ \t]*(\S*)[ \t]*$")


def _chroma_blocks(html_path):
    """[(data-lang, text)] for every Hugo chroma block, in document order."""
    from bs4 import BeautifulSoup
    with open(html_path, encoding="utf-8", errors="replace") as fh:
        soup = BeautifulSoup(fh.read(), "html.parser")
    out = []
    for pre in soup.select("pre.chroma"):
        code = pre.select_one("code")
        if code is not None:
            out.append((code.get("data-lang", ""), code.get_text()))
    return out


def _sniff_lang(data_lang, text):
    """The real language for one chroma block, or "" if it can't be told."""
    dl = (data_lang or "").strip().lower()
    if dl == "c":
        return "c"
    if dl in ("console", "sh", "bash", "shell", "shell-session"):
        return "console"
    lines = [ln for ln in text.split("\n") if ln.strip()]
    first = lines[0].strip() if lines else ""
    stripped = text.strip()
    # an interactive gdb session: either the prompt itself, or (because a
    # wrapped frame's own "at file:line" can land on its continuation line) a
    # backtrace whose first line is a numbered frame
    if re.match(r"^\(gdb\)", first, re.I):
        return "gdb"
    if re.match(r"^#\d+\s", stripped) and re.search(r"\bat\s+\S+:\d+", text[:400]):
        return "gdb"
    # a shell prompt followed by a command
    if (re.match(r"^\[[^\]]+\]\$\s", first) or re.match(r"^\$\s", first)
            or re.match(r"^>\s+\S", first) or re.match(r"^root#\s", first)):
        return "console"
    # a hand-drawn diagram carries no language at all: box-drawing glyphs, a
    # bit-layout table, or a "+----+"/"~~~~" ruled border with no code syntax
    if any(ch in text for ch in "├│└┌┐┘┬┴┼"):
        return ""
    if re.match(r"^\[#\d+\]", first):
        return ""
    if re.search(r"^\s*Bit:\s", text, re.M):
        return ""
    if re.search(r"[+\-~]{5,}", text) and not re.search(r"[;{}]", text):
        return ""
    # everything else this capture's chroma blocks contain is a C listing
    return "c"


def _norm(text):
    return re.sub(r"\s+", "", text)


def label_linternals_fences(recs, src):
    """Replace each fence's "chroma"/bare info string with its real language.

    Fences are matched to chroma blocks positionally within a chapter (pandoc
    preserves document order), and each pair's content is compared before the
    match is trusted, so a page that does not line up aborts the build loudly
    instead of mislabelling a fence.
    """
    stats = {}
    for r in recs:
        html_name = LINTERNALS_HTML.get(r["out"])
        if not html_name:
            continue
        blocks = _chroma_blocks(os.path.join(src, html_name))
        lines = r["body"].split("\n")
        markers = [i for i, ln in enumerate(lines) if FENCE_LINE.match(ln)]
        opens, closes = markers[0::2], markers[1::2]
        if len(opens) != len(closes) or len(opens) != len(blocks):
            raise SystemExit(
                "%s: %d fences but %s has %d chroma blocks"
                % (r["out"], len(opens), html_name, len(blocks)))
        for oi, ci, (data_lang, ctext) in zip(opens, closes, blocks):
            body_text = "\n".join(lines[oi + 1 : ci])
            if _norm(body_text)[:60] != _norm(ctext)[:60]:
                raise SystemExit(
                    "%s: fence at line %d does not match its chroma block"
                    % (r["out"], oi + 1))
            lang = _sniff_lang(data_lang, ctext)
            m = FENCE_LINE.match(lines[oi])
            lines[oi] = m.group(1) + m.group(2) + (" " + lang if lang else "")
            stats[lang or "(bare)"] = stats.get(lang or "(bare)", 0) + 1
        r["body"] = "\n".join(lines)
    if stats:
        print("linternals-sam4k fence languages: %s"
              % ", ".join("%s=%d" % kv for kv in sorted(stats.items())))
    return recs


def plan_linternals(src, out_dir):
    """Attach mode: the chapters already exist, only their assets are missing.

    Each chapter's relative asset paths were written by pandoc against the
    capture root ("./<Page Title>_files/x.gif"), so every record's source
    directory is that root. Two more fixes belong here rather than upstream:
    recovering each fence's real language (see label_linternals_fences), and
    stripping the literal form-feed bytes that survive in the two PDF-derived
    slide decks (pandoc's own PDF path, not the shared PDF pipeline, which
    already handles its own form feeds at emit time).
    """
    recs = []
    for name in sorted(f for f in os.listdir(out_dir) if f.endswith(".md")):
        body = read(os.path.join(out_dir, name))
        if name in LINTERNALS_FORMFEED:
            body = body.replace("\x0c", "")
        recs.append({"out": name, "title": name[:-3], "src": name[:-3] + ".html",
                     "body": body})
    return label_linternals_fences(recs, src)


# slug -> (plan, upstream base, terminate).  "terminate" adds the final newline
# a few upstream files end without; it is per book because each book's shipped
# chapters have to keep reproducing byte for byte.
BOOKS = {
    "linux-insides": (plan_linux_insides, "https://github.com/0xAX/linux-insides/blob/master/", False),
    "ebpf-developer-tutorial": (plan_ebpf, "https://github.com/eunomia-bpf/bpf-developer-tutorial/blob/main/", True),
    "heap-exploitation-dhaval-kapil": (plan_heap, "https://github.com/DhavalKapil/heap-exploitation/blob/master/", False),
    "ir0nstone-binary-exploitation": (plan_ir0nstone, "https://github.com/ir0nstone/cybersec-notes/blob/master/", True),
    "build-your-own-git": (plan_codecrafters, "https://github.com/codecrafters-io/build-your-own-git/blob/main/", False),
    "build-your-own-sqlite": (plan_codecrafters, "https://github.com/codecrafters-io/build-your-own-sqlite/blob/main/", False),
    "build-your-own-docker": (plan_codecrafters, "https://github.com/codecrafters-io/build-your-own-docker/blob/main/", False),
    # a browser capture's "<page>_files/" directories exist only on disk, so
    # this book has no upstream path to fall back on
    "linternals-sam4k": (plan_linternals, None, False),
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("slug")
    ap.add_argument("src")
    ap.add_argument("out")
    ap.add_argument("--check", action="store_true", help="print the plan, write nothing")
    ap.add_argument("--max-asset", default=None,
                    help="skip an asset bigger than this (e.g. 512k, 2M); default 16M. "
                         "The sam4k capture is 96 MiB of animated GIFs, so a small "
                         "cap keeps the book to its diagrams at the cost of leaving "
                         "the oversized references as they were.")
    a = ap.parse_args()
    if a.slug not in BOOKS:
        sys.exit("unknown slug %r (known: %s)" % (a.slug, ", ".join(sorted(BOOKS))))
    if os.path.basename(a.out.rstrip("/")) != a.slug:
        sys.exit("the out-dir basename must be the slug")

    plan, upstream, terminate = BOOKS[a.slug]
    records = plan(a.src, a.out) if a.slug == "linternals-sam4k" else plan(a.src)
    for r in records:
        if "body" not in r:
            r["body"] = read(os.path.join(a.src, r["src"]))
    if a.check:
        for r in records:
            print("%s\t%s" % (r["out"], r["src"]))
        return

    cap = ASSET_MAX
    if a.max_asset:
        m = re.match(r"^(\d+)\s*([kKmMgG]?)$", a.max_asset.strip())
        if not m:
            sys.exit("--max-asset wants a byte count, optionally suffixed k, M or G")
        cap = int(m.group(1)) * {"": 1, "k": 1 << 10, "m": 1 << 20, "g": 1 << 30}[m.group(2).lower()]

    # Keep the previous build's media/ aside so a rebuild that reads back its
    # own chapters (attach mode) still resolves the references it wrote last
    # time; the new build re-copies what it still needs and the rest goes.
    prev = None
    if os.path.isdir(os.path.join(a.out, "media")):
        prev = a.out.rstrip("/") + "/.media.prev"
        shutil.rmtree(prev, ignore_errors=True)
        os.rename(os.path.join(a.out, "media"), prev)
    try:
        clean_out(a.out)
        stats = {}
        copied = rewrite(records, a.src, a.out, upstream, stats, cap, prev)
        write_book(a.out, records, terminate)
    finally:
        if prev:
            shutil.rmtree(prev, ignore_errors=True)
    size = sum(os.path.getsize(os.path.join(a.out, p)) for p in copied.values())
    print("%s: %d chapters, %d media files (%.1f KiB), refs %s"
          % (a.slug, len(records), len(copied), size / 1024.0,
             ", ".join("%s=%d" % kv for kv in sorted(stats.items()))))


if __name__ == "__main__":
    main()
