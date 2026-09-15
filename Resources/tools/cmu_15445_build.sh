#!/usr/bin/env bash
# Freeze CMU 15-445/645 "Database Systems" (Fall 2025) into the :Docs frozen
# web-book layout used by the "CMU 15-445 Database Systems" book:
#   Resources/docs/cmu-15445/index.tsv          "<title>\t<url>" in schedule order
#   Resources/docs/.webcache/<sha256(url)>.txt   PDF (pdftotext) / project page (html)
#
# Source: https://15445.courses.cs.cmu.edu/fall2025/schedule.html
# Each lecture contributes two chapters (slides PDF + notes PDF); plus the
# written homeworks (files/hw*-clean.pdf and the SQL homework page) and the
# programming projects (project0..4 pages). Videos and readings are excluded.
# Usage: cmu_15445_build.sh   (needs curl, pdftotext, pandoc, python3)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/cmu-15445"
mkdir -p "$OUT" "$CACHE"

PAGES=$(cat <<'ROWS'
01 Relational Model & Algebra (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/01-relationalmodel.pdf
01 Relational Model & Algebra (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/01-relationalmodel.pdf
Project: C++ Primer	https://15445.courses.cs.cmu.edu/fall2025/project0/
02 Modern SQL (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/02-modernsql.pdf
02 Modern SQL (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/02-modernsql.pdf
Homework: SQL	https://15445.courses.cs.cmu.edu/fall2025/homework1/
03 Database Storage I (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/03-storage1.pdf
03 Database Storage I (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/03-storage1.pdf
04 Memory Management (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/04-bufferpool.pdf
04 Memory Management (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/04-bufferpool.pdf
Project: Buffer Pool Manager	https://15445.courses.cs.cmu.edu/fall2025/project1/
05 Database Storage II (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/05-storage2.pdf
05 Database Storage II (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/05-storage2.pdf
Homework: Storage	https://15445.courses.cs.cmu.edu/fall2025/files/hw2-clean.pdf
06 Storage Models & Compression (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/06-storage3.pdf
06 Storage Models & Compression (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/06-storage3.pdf
07 Hash Tables (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/07-hashtables.pdf
07 Hash Tables (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/07-hashtables.pdf
08 Indexes & Filters I (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/08-indexes1.pdf
08 Indexes & Filters I (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/08-indexes1.pdf
09 Indexes & Filters II (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/09-indexes2.pdf
09 Indexes & Filters II (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/09-indexes2.pdf
Homework: Indexes & Filters	https://15445.courses.cs.cmu.edu/fall2025/files/hw3-clean.pdf
10 Index Concurrency Control (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/10-indexconcurrency.pdf
10 Index Concurrency Control (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/10-indexconcurrency.pdf
Project: Database Index	https://15445.courses.cs.cmu.edu/fall2025/project2/
11 Sorting & Aggregations Algorithms (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/11-sorting.pdf
11 Sorting & Aggregations Algorithms (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/11-sorting.pdf
12 Joins Algorithms (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/12-joins.pdf
12 Joins Algorithms (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/12-joins.pdf
13 Query Execution I (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/13-queryexecution1.pdf
13 Query Execution I (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/13-queryexecution1.pdf
Project: Query Execution	https://15445.courses.cs.cmu.edu/fall2025/project3/
14 Query Execution II (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/14-queryexecution2.pdf
14 Query Execution II (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/14-queryexecution2.pdf
Homework: Execution & Planning	https://15445.courses.cs.cmu.edu/fall2025/files/hw4-clean.pdf
15 Query Planning & Optimization I (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/15-optimization1.pdf
15 Query Planning & Optimization I (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/15-optimization1.pdf
16 Query Planning & Optimization II (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/16-optimization2.pdf
16 Query Planning & Optimization II (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/16-optimization2.pdf
17 Concurrency Control Theory (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/17-concurrencycontrol.pdf
17 Concurrency Control Theory (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/17-concurrencycontrol.pdf
18 Two-Phase Locking Concurrency Control (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/18-twophaselocking.pdf
18 Two-Phase Locking Concurrency Control (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/18-twophaselocking.pdf
Homework: Transactions!	https://15445.courses.cs.cmu.edu/fall2025/files/hw5-clean.pdf
19 Timestamp Ordering Concurrency Control (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/19-timestampordering.pdf
19 Timestamp Ordering Concurrency Control (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/19-timestampordering.pdf
Project: Concurrency Control	https://15445.courses.cs.cmu.edu/fall2025/project4/
20 Multi-Version Concurrency Control (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/20-multiversioning.pdf
20 Multi-Version Concurrency Control (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/20-multiversioning.pdf
21 Database Logging (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/21-logging.pdf
21 Database Logging (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/21-logging.pdf
22 Database Recovery (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/22-recovery.pdf
22 Database Recovery (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/22-recovery.pdf
23 Distributed Database Systems I (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/23-distributed1.pdf
23 Distributed Database Systems I (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/23-distributed1.pdf
Homework: Recovery	https://15445.courses.cs.cmu.edu/fall2025/files/hw6-clean.pdf
24 Distributed Database Systems II (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/24-distributed2.pdf
24 Distributed Database Systems II (notes)	https://15445.courses.cs.cmu.edu/fall2025/notes/24-distributed2.pdf
25 Final Review + Systems Potpourri (slides)	https://15445.courses.cs.cmu.edu/fall2025/slides/25-potpourri.pdf
ROWS
)

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r title url; do
  [ -z "$url" ] && continue
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  case "$url" in
    *.pdf)
      tmp=$(mktemp --suffix=.pdf)
      if ! curl -fsSL --max-time 60 "$url" -o "$tmp" 2>/dev/null; then echo "FAIL fetch $url" >&2; fail=$((fail+1)); rm -f "$tmp"; continue; fi
      { printf '# %s\n\n' "$title"; pdftotext -nopgbrk "$tmp" - 2>/dev/null; } > "$cf"; rm -f "$tmp" ;;
    *)
      body=$(curl -fsSL --compressed --max-time 45 "$url" 2>/dev/null \
        | python3 "$WE" content 'div.main-content' "$url" abs 2>/dev/null \
        | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
        | python3 "$WE" clean "" "" 2>/dev/null \
        | sed -E 's/!\[[^]]*\]\(data:[^)]*\)//g; s/\]\(data:[^)]*\)/]()/g')
      printf '%s' "$body" > "$cf" ;;
  esac
  [ "$(wc -c < "$cf")" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.2
done <<< "$PAGES"
echo "==> CMU 15-445: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
