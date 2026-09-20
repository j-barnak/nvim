#!/usr/bin/env bash
# Freeze the "Awesome Databases" reading collection into the :Docs frozen web-book
# layout used by the "Awesome Databases" picker:
#   Resources/docs/awesome-databases/index.tsv    "<title>\t<url>" in list order
#   Resources/docs/.webcache/<sha256(url)>.txt      the rendered paper/article
#
# Mixed sources: PDFs (huachaohuang/awesome-dbdev papers + a TUM paper) frozen
# with pdftotext; Wikipedia articles (div.mw-parser-output); two blog posts; and
# the Linux ext4 on-disk format docs concatenated from their Sphinx subpages.
# Usage: awesome_dbdev_build.sh   (needs curl, python3+bs4+lxml, pandoc, pdftotext)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/awesome-databases"
mkdir -p "$OUT" "$CACHE"
PAPERS="https://raw.githubusercontent.com/huachaohuang/awesome-dbdev/master/papers"
EXT4="https://www.kernel.org/doc/html/latest/filesystems/ext4"

render_html() { # <selector> <url> <opts>
  curl -fsSL --compressed --max-time 40 "$2" 2>/dev/null \
    | python3 "$WE" content "$1" "$2" "$3" 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null
}
render_pdf() { # <url>
  local tmp; tmp=$(mktemp --suffix=.pdf)
  curl -fsSL --max-time 90 "$1" -o "$tmp" 2>/dev/null
  pdftotext -layout -nopgbrk "$tmp" - 2>/dev/null
  rm -f "$tmp"
}
build_ext4() {
  # concatenate the ext4 subpages (logical order) into one document
  local subs="about overview blocks bitmaps blockgroup group_descr globals super \
dynamic inodes inode_table ifork attributes eainode inlinedata directory \
special_inodes allocators bigalloc journal orphan mmp checksums atomic_writes verity"
  local p
  for p in $subs; do
    render_html "div[role=main]" "$EXT4/$p.html" "sphinx,abs"
    printf '\n\n'
  done
}

# <title> <TAB> <type> <TAB> <url>   type = pdf | wiki | html:<selector> | ext4
ROWS=$(cat <<TOC
TinyLFU: A Highly Efficient Cache Admission Policy	pdf	$PAPERS/tinylfu.pdf
LeanStore: In-Memory Data Management Beyond Main Memory	pdf	$PAPERS/leanstore.pdf
HotRing: A Hotspot-Aware In-Memory Key-Value Store	pdf	$PAPERS/hotring.pdf
Cost/Performance in Modern Data Stores	pdf	$PAPERS/cost-performance.pdf
The ART of Practical Synchronization	pdf	https://db.in.tum.de/~leis/papers/artsync.pdf
The Five-Minute Rule 30 Years Later	pdf	$PAPERS/five-minute-rule-2017.pdf
NVM Express (NVMe)	wiki	https://en.wikipedia.org/wiki/NVM_Express
Serial Attached SCSI (SAS)	wiki	https://en.wikipedia.org/wiki/Serial_Attached_SCSI
Serial ATA (SATA)	wiki	https://en.wikipedia.org/wiki/Serial_ATA
PCI Express (PCIe)	wiki	https://en.wikipedia.org/wiki/PCI_Express
Cache Craftiness for Fast Multicore Key-Value Storage (Masstree)	pdf	$PAPERS/masstree.pdf
Modern B-Tree Techniques	pdf	$PAPERS/modern-btree.pdf
Building a Bw-Tree Takes More Than Just Buzz Words (Open Bw-Tree)	pdf	$PAPERS/open-bwtree.pdf
WiscKey: Separating Keys from Values in SSD-Conscious Storage	pdf	$PAPERS/wisckey.pdf
LSM-based Storage Techniques: A Survey	pdf	$PAPERS/lsmsurvey.pdf
The Log-Structured Merge-Tree (LSM-Tree)	pdf	$PAPERS/lsmtree.pdf
FASTER: A Concurrent Key-Value Store with In-Place Updates	pdf	$PAPERS/faster.pdf
How We Built a Vectorized SQL Engine (CockroachDB)	html:div.blog-content	https://www.cockroachlabs.com/blog/how-we-built-a-vectorized-sql-engine/
Morsel-Driven Parallelism	pdf	$PAPERS/morsel-driven.pdf
Efficiently Compiling Efficient Query Plans for Modern Hardware (Neumann)	pdf	$PAPERS/p539-neumann.pdf
The Design and Implementation of Modern Column-Oriented Database Systems	pdf	$PAPERS/modern-column-stores.pdf
Paxos Made Simple	pdf	$PAPERS/paxos-made-simple.pdf
In Search of an Understandable Consensus Algorithm (Raft)	pdf	$PAPERS/raft.pdf
Linearizability versus Serializability (Bailis)	html:div.content	http://www.bailis.org/blog/linearizability-versus-serializability/
Logical Physical Clocks (Hybrid Logical Clocks)	pdf	$PAPERS/hybrid-logical-clocks.pdf
Linux ext4 Disk Layout	ext4	$EXT4/index.html
Hard Disk Drive	wiki	https://en.wikipedia.org/wiki/Hard_disk_drive
Solid-State Drive	wiki	https://en.wikipedia.org/wiki/Solid-state_drive
TOC
)

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r title type url; do
  [ -z "$url" ] && continue
  case "$type" in
    pdf)   body=$(render_pdf "$url") ;;
    wiki)  body=$(render_html "div.mw-parser-output" "$url" "abs") ;;
    ext4)  body=$(build_ext4) ;;
    html:*) body=$(render_html "${type#html:}" "$url" "abs") ;;
    *) echo "unknown type $type" >&2; fail=$((fail+1)); continue ;;
  esac
  if [ "$(printf '%s' "$body" | wc -c)" -lt 200 ]; then
    echo "FAIL ($type) $url" >&2; fail=$((fail+1)); continue
  fi
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  { printf '# %s\n\n' "$title"; printf '%s\n' "$body"; } > "$cf"
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.25
done <<< "$ROWS"
echo "==> Awesome Databases: $ok entries, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
