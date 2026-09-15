#!/usr/bin/env bash
# Freeze CMU 15-411 "Compiler Design" (Fall 2020) into the :Docs frozen web-book
# layout used by the "CMU 15-411 Compiler Design" book:
#   Resources/docs/cmu-15411/index.tsv          "<title>\t<pdf url>" in course order
#   Resources/docs/.webcache/<sha256(url)>.txt   the PDF rendered to text
#
# Each lecture / lab / notes PDF is a chapter (pdftotext). Source:
# https://www.cs.cmu.edu/afs/cs/academic/class/15411-f20/www/schedule.html
# Usage: cmu_15411_build.sh   (needs curl, pdftotext)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/cmu-15411"
B="https://www.cs.cmu.edu/afs/cs/academic/class/15411-f20/www"
mkdir -p "$OUT" "$CACHE"

# title <TAB> url-tail (relative to $B), in schedule order.
PAGES=$(cat <<'ROWS'
LEC 1: Overview	lec/01-overview.pdf
LEC 2: Register Allocation	lec/02-registerallocation.pdf
LEC 2: Register Allocation (notes)	lec/02-regopt-notes.pdf
LEC 3: Intro to SSA / CFG / Basic Blocks	lec/03-registerallocation-2.pdf
LEC 4: Instruction Selection	lec/04-instruction-selection.pdf
LEC 5: SSA	lec/05-ssa.pdf
LEC 6: SSA II	lec/06-ssa-into-outof.pdf
Lab 1: Straight Line Code	hw/lab1.pdf
Lab 1: Straight Line Code Checkpoint	hw/lab1checkpoint.pdf
LEC 7: Middle End	lec/07-middle-end.pdf
LEC 8: Data Flow Analysis	lec/08-df-1.pdf
LEC 9: Data Flow Analysis II	lec/08-df-2b.pdf
LEC 10: Dataflow Theory	lec/09-df-theory.pdf
LEC 11: Lexing / Parsing	lec/10-lex-parse.pdf
LEC 12: Lexing / Parsing Pt 2	lec/10-bottom-up.pdf
LEC 13: Type Checking	lec/11-typechecking.pdf
LEC 13: Type Checking (notes)	lec/11-statics-notes.pdf
LEC 14: Calling Conventions	lec/12-calling.pdf
Lab 2: Control	hw/lab2.pdf
Lab 2: Control Checkpoint	hw/lab2checkpoint.pdf
LEC 15: Dynamic Semantics	lec/13-dynamic-sem.pdf
LEC 15: Dynamic Semantics (notes)	lec/13-dynamic-notes.pdf
LEC 16: Mutable Store	lec/14-mutable.pdf
LEC 16: Mutable Store (notes)	lec/14-mutable-notes.pdf
LEC 17: Structs	lec/15-structs.pdf
LEC 17: Structs (notes)	lec/15-structs-notes.pdf
Lab 3: Functions	hw/lab3.pdf
LEC 18: Loops	lec/16-loop.pdf
LEC 18: Loops (notes)	lec/16-peepsub.pdf
LEC 19: Partial Redundancy Elimination	lec/17-pre.pdf
Lab 4: Memory	hw/lab4.pdf
LEC 20: Locality 1	lec/18-locality1.pdf
Paper: A Data Locality Optimizing Algorithm (Lam 1991)	lec/lam03.pdf
LEC 21: Locality 2	lec/20-locality2.pdf
LEC 22: Instruction Scheduling	lec/21-scheduling.pdf
LEC 23: Alias Analysis	lec/22-alias.pdf
LEC 23: Alias Analysis (notes)	lec/22-alias-notes.pdf
Lab 5: Optimization	hw/lab5.pdf
Lab 5: Optimization Checkpoint	hw/lab5checkpoint.pdf
Lab 6: Garbage Collection	hw/lab6gc.pdf
LEC 24: C0 and Beyond	hw/lab6c1.pdf
ROWS
)

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r title tail; do
  [ -z "$tail" ] && continue
  url="$B/$tail"
  tmp=$(mktemp --suffix=.pdf)
  if ! curl -fsSL --max-time 60 "$url" -o "$tmp" 2>/dev/null; then
    echo "FAIL fetch $url" >&2; fail=$((fail+1)); rm -f "$tmp"; continue
  fi
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  { printf '# %s\n\n' "$title"; pdftotext -layout -nopgbrk "$tmp" - 2>/dev/null; } > "$cf"
  rm -f "$tmp"
  [ "$(wc -c < "$cf")" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.2
done <<< "$PAGES"
echo "==> CMU 15-411: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
