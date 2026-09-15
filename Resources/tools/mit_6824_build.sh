#!/usr/bin/env bash
# Freeze MIT 6.824 / 6.5840 (Distributed Systems) into the :Docs frozen web-book
# layout used by the "MIT 6.824 Distributed Systems" book:
#   Resources/docs/mit-6824/index.tsv           "<title>\t<url>" in schedule order
#   Resources/docs/.webcache/<sha256(url)>.txt   the rendered content
#
# Source: https://pdos.csail.mit.edu/6.824/schedule.html . Each chapter is a
# lecture note (notes/*.txt, kept verbatim), a guest lecture's slides
# (notes/*.pdf via pdftotext), a reading paper (papers/*.pdf via pdftotext,
# titled "Paper: <name>", placed after its lecture), or a lab handout
# (labs/lab-*.html via webextract+pandoc). EXCLUDED: videos, FAQ files
# (*-faq.txt), "Question" links, code examples (*.go/*.tar.gz), external
# (non-pdos) readings, and "Project demos" (LEC 22, no content).
# Usage: mit_6824_build.sh   (needs curl, pdftotext, pandoc, python3)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/mit-6824"
B="https://pdos.csail.mit.edu/6.824"
mkdir -p "$OUT" "$CACHE"

# title <TAB> url-tail (relative to $B), in schedule order (lectures, then labs).
PAGES=$(cat <<'ROWS'
Introduction	notes/l01.txt
Paper: MapReduce (2004)	papers/mapreduce.pdf
RPC and Threads	notes/l-rpc.txt
GFS	notes/l-gfs.txt
Paper: GFS (2003)	papers/gfs.pdf
Paxos	notes/l-paxos.txt
Paper: Paxos Made Simple	papers/paxos-simple.pdf
Go patterns	notes/Go-MIT6824-2026.pdf
Fault Tolerance: Raft (1)	notes/l-raft.txt
Paper: Raft (extended)	papers/raft-extended.pdf
Fault Tolerance: Raft (2)	notes/l-raft2.txt
Consistency and Linearizability	notes/l-linearizability.txt
Paper: Linearizability (Herlihy)	papers/p463-herlihy.pdf
Zookeeper	notes/l-zookeeper.txt
Paper: ZooKeeper	papers/zookeeper.pdf
Q&A Lab 3A+B	notes/l-raft-QA.txt
Distributed Transactions	notes/l-2pc.txt
Spanner	notes/l-spanner.txt
Paper: Spanner	papers/spanner.pdf
Chain Replication	notes/l-cr.txt
Paper: Chain Replication	papers/cr-osdi04.pdf
Optimistic Concurrency Control	notes/l-farm.txt
Paper: FaRM	papers/farm-2015.pdf
Verification of distributed systems	notes/l-ironfleet.txt
Paper: IronFleet	papers/ironfleet.pdf
Cache Consistency: Memcached at Facebook	notes/l-memcached.txt
Paper: Memcached at Facebook	papers/memcache-fb.pdf
AWS Lambda	notes/mbrooker_cs_slides_2026.pdf
Paper: On-demand Container Loading	papers/atc23-brooker.pdf
Ray	notes/l-ray.txt
Paper: Ray	papers/ray.pdf
Fork Consistency, SUNDR	notes/l-sundr.txt
Paper: SUNDR	papers/li-sundr.pdf
Bitcoin	notes/l-bitcoin.txt
Paper: Bitcoin	papers/bitcoin.pdf
Byzantine Fault Tolerance	notes/l-bft.txt
Byzantine Fault Tolerance (slides)	notes/65840-pbft.pdf
Paper: Practical BFT	papers/castro-practicalbft.pdf
Lab: MapReduce	labs/lab-mr.html
Lab: Key/Value server	labs/lab-kvsrv1.html
Lab: Raft	labs/lab-raft1.html
Lab: KV Raft	labs/lab-kvraft1.html
Lab: Sharded KV	labs/lab-shard1.html
ROWS
)

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r title tail; do
  [ -z "$tail" ] && continue
  url="$B/$tail"
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  case "$tail" in
    *.txt)
      body=$(curl -fsSL --max-time 40 "$url" 2>/dev/null)
      [ -z "$body" ] && { echo "FAIL fetch $url" >&2; fail=$((fail+1)); continue; }
      { printf '# %s\n\n```text\n' "$title"; printf '%s\n' "$body"; printf '```\n'; } > "$cf"
      ;;
    *.pdf)
      tmp=$(mktemp --suffix=.pdf)
      curl -fsSL --max-time 60 "$url" -o "$tmp" 2>/dev/null || { echo "FAIL fetch $url" >&2; fail=$((fail+1)); rm -f "$tmp"; continue; }
      { printf '# %s\n\n' "$title"; pdftotext -nopgbrk "$tmp" - 2>/dev/null; } > "$cf"
      rm -f "$tmp"
      ;;
    *.html)
      body=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null \
        | python3 "$WE" content body "$url" abs 2>/dev/null \
        | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
        | python3 "$WE" clean "" "" 2>/dev/null \
        | sed -E '/^#+ \[6\.5840\]/d; /^\*\*\[Collaboration policy\]/d')
      [ -z "$body" ] && { echo "FAIL fetch $url" >&2; fail=$((fail+1)); continue; }
      printf '%s\n' "$body" > "$cf"
      ;;
  esac
  [ "$(wc -c < "$cf")" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.2
done <<< "$PAGES"
echo "==> MIT 6.824: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
