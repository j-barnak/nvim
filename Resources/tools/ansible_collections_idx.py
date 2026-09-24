#!/usr/bin/env python3
"""Index the Ansible Collections reference (every module/plugin page) for :Docs.

    python3 ansible_collections_idx.py <site-version|latest> <outdir>

Writes <outdir>/index.tsv, "title<TAB>url" rows the frozen_web_provider reads,
one per collections/* page of https://docs.ansible.com/projects/ansible/<ver>/
(11,891 pages across 207 collections for "latest" in Sept 2026).  The pages
themselves are fetched on first open (hybrid live mode) and cached.

The page list is the site's own Sphinx inventory (objects.inv: 4 header lines,
then a zlib stream of "name domain:role priority uri display-name"), which
already carries each page's display title ("ansible.builtin.copy module –
Copy files to remote locations").  docs.ansible.com sits behind a Cloudflare
JavaScript challenge that no scripted fetch can pass, so the inventory is read
through the Wayback Machine's raw endpoint (web/2id_/<url>: the archived bytes,
unmodified); the URLs written are the ORIGINAL docs.ansible.com ones, and
hybrid_fetch routes those through the archive the same way when a page is
opened.  Standard library only, like the other builders.
"""
import gzip, os, sys, urllib.error, urllib.request, zlib

UA = "Mozilla/5.0 (personal-docs-archive)"


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept-Encoding": "gzip"})
    with urllib.request.urlopen(req, timeout=120) as r:
        data = r.read()
        if r.headers.get("Content-Encoding") == "gzip" or data[:2] == b"\x1f\x8b":
            data = gzip.decompress(data)
        return data


def inventory(raw):
    if not raw.startswith(b"# Sphinx inventory version 2"):
        raise SystemExit("not a Sphinx v2 inventory: %r" % raw[:60])
    p = 0
    for _ in range(4):
        p = raw.index(b"\n", p) + 1
    for line in zlib.decompress(raw[p:]).decode("utf-8", "replace").splitlines():
        parts = line.split(" ", 4)
        if len(parts) == 5:
            yield parts  # name, domain:role, priority, uri, display


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    ver, out = sys.argv[1], sys.argv[2]
    base = "https://docs.ansible.com/projects/ansible/%s/" % ver
    try:
        raw = fetch("https://web.archive.org/web/2id_/" + base + "objects.inv")
    except urllib.error.HTTPError as e:
        print("Ansible %s: objects.inv is not in the Wayback Machine (HTTP %d)" % (ver, e.code), file=sys.stderr)
        sys.exit(2)
    rows = []
    for name, role, _prio, uri, display in inventory(raw):
        if role != "std:doc" or not name.startswith("collections/"):
            continue
        uri = uri.replace("$", name) if uri.endswith("$") else uri
        parts = name.split("/")
        if display in ("-", ""):
            display = ".".join(parts[1:3]) + " — collection index" if len(parts) == 4 and parts[3] == "index" else name
        rows.append((display, base + uri))
    if not rows:
        print("Ansible %s: no collections/* pages in the inventory" % ver, file=sys.stderr)
        sys.exit(2)
    rows.sort(key=lambda r: r[0].lower())
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, "index.tsv"), "w", encoding="utf-8") as fh:
        for title, url in rows:
            fh.write("%s\t%s\n" % (title.replace("\t", " "), url))
    print("Ansible %s: %d collection pages indexed" % (ver, len(rows)))


if __name__ == "__main__":
    main()
