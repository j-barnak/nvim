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
Overview	lec/01-overview.pdf
Register Allocation	lec/02-registerallocation.pdf
Register Allocation Notes	lec/02-regopt-notes.pdf
Intro to SSA / CFG / Basic Blocks	lec/03-registerallocation-2.pdf
Instruction Selection	lec/04-instruction-selection.pdf
SSA	lec/05-ssa.pdf
SSA II	lec/06-ssa-into-outof.pdf
Lab 1: Straight Line Code	hw/lab1.pdf
Lab 1: Straight Line Code Checkpoint	hw/lab1checkpoint.pdf
Middle End	lec/07-middle-end.pdf
Data Flow Analysis	lec/08-df-1.pdf
Data Flow Analysis II	lec/08-df-2b.pdf
Dataflow Theory	lec/09-df-theory.pdf
Lexing / Parsing	lec/10-lex-parse.pdf
Lexing / Parsing Pt 2	lec/10-bottom-up.pdf
Type Checking	lec/11-typechecking.pdf
Static Semantics	lec/11-statics-notes.pdf
Calling Conventions	lec/12-calling.pdf
Lab 2: Control	hw/lab2.pdf
Lab 2: Control Checkpoint	hw/lab2checkpoint.pdf
Dynamic Semantics	lec/13-dynamic-sem.pdf
Dynamic Semantics Notes	lec/13-dynamic-notes.pdf
Mutable Store	lec/14-mutable.pdf
Mutable Store Notes	lec/14-mutable-notes.pdf
Structs	lec/15-structs.pdf
Structs Notes	lec/15-structs-notes.pdf
Lab 3: Functions	hw/lab3.pdf
Loops	lec/16-loop.pdf
Loops Notes	lec/16-peepsub.pdf
Partial Redundancy Elimination	lec/17-pre.pdf
Lab 4: Memory	hw/lab4.pdf
Locality 1	lec/18-locality1.pdf
A Data Locality Optimizing Algorithm	lec/lam03.pdf
Locality 2	lec/20-locality2.pdf
Instruction Scheduling	lec/21-scheduling.pdf
Alias Analysis	lec/22-alias.pdf
Alias Analysis Notes	lec/22-alias-notes.pdf
Lab 5: Optimization	hw/lab5.pdf
Lab 5: Optimization Checkpoint	hw/lab5checkpoint.pdf
Lab 6: Garbage Collection	hw/lab6gc.pdf
C0 and Beyond	hw/lab6c1.pdf
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
  { printf '# %s\n\n' "$title"; pdftotext -nopgbrk "$tmp" - 2>/dev/null; } > "$cf"
  rm -f "$tmp"
  [ "$(wc -c < "$cf")" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.2
done <<< "$PAGES"
echo "==> CMU 15-411: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
