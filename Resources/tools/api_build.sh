set -e
cd "$1"
grep -rhoE '^\.\. kernel-doc:: \S+' Documentation --include='*.rst' | awk '{print $3}' | sort -u > .kd_files.txt
# set -e is blind to failures inside a pipeline (POSIX XCU 2.9.2), so check the
# result: an empty index otherwise fails later as a confusing git error.
[ -s .kd_files.txt ] || { echo "api_build: no kernel-doc directives found under Documentation" >&2; exit 1; }
# /scripts holds the perl kernel-doc on older trees; recent kernels rewrote it
# in Python (scripts/kernel-doc symlinks to /tools/docs/kernel-doc) which imports
# the kdoc package from /tools/lib/python. Fetch all three or the recent-kernel
# API path renders nothing (dangling symlink / missing kdoc module).
git sparse-checkout add /scripts /tools/docs /tools/lib/python
sed 's|^|/|' .kd_files.txt | xargs -d '\n' git sparse-checkout add
git checkout
python3 - "$PWD" <<'PY'
import re, os, sys
root = sys.argv[1]
# Write the index atomically: a build killed mid-write must not leave a
# partial api-index.tsv that filereadable() then treats as complete.
tmp = os.path.join(root, "api-index.tsv.tmp")
out = open(tmp, "w")
hdr = re.compile(r'\s*\*\s*(?:(?:struct|union|enum|typedef)\s+)?([A-Za-z_]\w*)\s*(?:\(\))?\s*[-:]')
for rel in open(os.path.join(root, ".kd_files.txt")):
    rel = rel.strip(); p = os.path.join(root, rel)
    try:
        lines = open(p, encoding="utf-8", errors="replace").read().splitlines()
    except OSError:
        continue
    for i, l in enumerate(lines):
        if l.strip() == "/**" and i + 1 < len(lines):
            nxt = lines[i + 1]
            if "DOC:" in nxt:
                continue
            m = hdr.match(nxt)
            if m:
                out.write(m.group(1) + "\t" + rel + "\n")
out.close()
os.replace(tmp, os.path.join(root, "api-index.tsv"))
PY
