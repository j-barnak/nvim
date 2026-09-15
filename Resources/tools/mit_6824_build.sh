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

# title <TAB> url-tail (relative to $B), in schedule order: lectures numbered
# "LEC N", each paper right after its lecture, each "Lab N" at the point it is
# assigned in the schedule (Lab 1@LEC1, 2@LEC3, 3@LEC4, 4@LEC9, 5@LEC14).
PAGES=$(cat <<'ROWS'
LEC 1: Introduction	notes/l01.txt
Paper: MapReduce (2004)	papers/mapreduce.pdf
Lab 1: MapReduce	labs/lab-mr.html
LEC 2: RPC and Threads	notes/l-rpc.txt
LEC 3: GFS	notes/l-gfs.txt
Paper: GFS (2003)	papers/gfs.pdf
Lab 2: Key/Value server	labs/lab-kvsrv1.html
LEC 4: Paxos	notes/l-paxos.txt
Paper: Paxos Made Simple	papers/paxos-simple.pdf
Lab 3: Raft	labs/lab-raft1.html
LEC 5: Go patterns	notes/Go-MIT6824-2026.pdf
LEC 6: Fault Tolerance: Raft (1)	notes/l-raft.txt
Paper: Raft (extended)	papers/raft-extended.pdf
LEC 7: Fault Tolerance: Raft (2)	notes/l-raft2.txt
LEC 8: Consistency and Linearizability	notes/l-linearizability.txt
Paper: Linearizability (Herlihy)	papers/p463-herlihy.pdf
LEC 9: Zookeeper	notes/l-zookeeper.txt
Paper: ZooKeeper	papers/zookeeper.pdf
Lab 4: KV Raft	labs/lab-kvraft1.html
LEC 10: Q&A Lab 3A+B	notes/l-raft-QA.txt
LEC 11: Distributed Transactions	notes/l-2pc.txt
LEC 12: Spanner	notes/l-spanner.txt
Paper: Spanner	papers/spanner.pdf
LEC 13: Chain Replication	notes/l-cr.txt
Paper: Chain Replication	papers/cr-osdi04.pdf
LEC 14: Optimistic Concurrency Control	notes/l-farm.txt
Paper: FaRM	papers/farm-2015.pdf
Lab 5: Sharded KV	labs/lab-shard1.html
LEC 15: Verification of distributed systems	notes/l-ironfleet.txt
Paper: IronFleet	papers/ironfleet.pdf
LEC 16: Cache Consistency: Memcached at Facebook	notes/l-memcached.txt
Paper: Memcached at Facebook	papers/memcache-fb.pdf
LEC 17: AWS Lambda	notes/mbrooker_cs_slides_2026.pdf
Paper: On-demand Container Loading	papers/atc23-brooker.pdf
LEC 18: Ray	notes/l-ray.txt
Paper: Ray	papers/ray.pdf
LEC 19: Fork Consistency, SUNDR	notes/l-sundr.txt
Paper: SUNDR	papers/li-sundr.pdf
LEC 20: Bitcoin	notes/l-bitcoin.txt
Paper: Bitcoin	papers/bitcoin.pdf
LEC 21: Byzantine Fault Tolerance	notes/l-bft.txt
LEC 21: Byzantine Fault Tolerance (slides)	notes/65840-pbft.pdf
Paper: Practical BFT	papers/castro-practicalbft.pdf
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
      # strip site chrome (the "[6.5840]" nav heading, the Collaboration nav
      # line, and the page's own "# 6.5840 Lab N: ..." H1) so the chapter opens
      # with our numbered "# <title>" and nothing else.
      body=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null \
        | python3 "$WE" content body "$url" abs 2>/dev/null \
        | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
        | python3 "$WE" clean "" "" 2>/dev/null \
        | sed -E '/^#+ \[6\.5840\]/d; /^\*\*\[Collaboration policy\]/d; /^# 6\.5840 Lab /d')
      [ -z "$body" ] && { echo "FAIL fetch $url" >&2; fail=$((fail+1)); continue; }
      # drop leading blank lines, then prepend our numbered title
      body=$(printf '%s\n' "$body" | sed -E '/./,$!d')
      { printf '# %s\n\n' "$title"; printf '%s\n' "$body"; } > "$cf"
      ;;
  esac
  [ "$(wc -c < "$cf")" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.2
done <<< "$PAGES"
echo "==> MIT 6.824: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
