#!/usr/bin/env bash
# Freeze Wisconsin CS/ECE 752 "Advanced Computer Architecture" (Fall 2020) into
# the :Docs frozen web-book layout used by the "Wisconsin CS/ECE 752" book:
#   Resources/docs/wisc-cs752/index.tsv          "<title>\t<url>" in schedule order
#   Resources/docs/.webcache/<sha256(url)>.txt    the PDF rendered to text
#
# Each lecture slide deck (the course's own handouts/lecture/*.pdf) is a chapter,
# titled by its schedule topic; interleaved in schedule order are the reading
# PAPERS the schedule links (Read/Review/Reference), titled "Paper: <Author Year>".
# Several markhill/restricted/* readings are access-controlled (403) and are
# skipped automatically at build time. Videos, non-paper links and the "Quantum
# Computing for Computer Architects" book chapters are excluded. Source:
# https://pages.cs.wisc.edu/~sinclair/courses/cs752/fall2020/includes/schedule.html
# Usage: wisc_cs752_build.sh   (needs curl, pdftotext)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/wisc-cs752"
mkdir -p "$OUT" "$CACHE"

# title <TAB> full url, in schedule order (slides + reading papers interleaved).
PAGES=$(cat <<'ROWS'
Unit 1: Introduction	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/01-intro.pdf
Paper: Moore's Law	http://www.cs.wisc.edu/~markhill/restricted/electronics65_moore.pdf
Paper: Mudge 2001	http://pages.cs.wisc.edu/~markhill/restricted/computer01_power.pdf
Unit 2: Technology	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/02-tech.pdf
Paper: Blem 2013	https://research.cs.wisc.edu/vertical/papers/2013/hpca13-isa-power-struggles.pdf
Paper: Colwell 1985	http://www.cs.wisc.edu/~markhill/restricted/ieeecomputer85_cisc.pdf
Unit 3: Technology II / Instruction Sets	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/03-isa.pdf
Paper: Seznec 2002	http://pages.cs.wisc.edu/~markhill/restricted/isca2002_branchpred.pdf
Unit 4: Pipelining	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/04-pipeline.pdf
Architectural Simulation	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/archSim.pdf
Paper: Huck 2000	http://pages.cs.wisc.edu/~markhill/restricted/ieeemicro2000_ia64isa.pdf
Unit 5: Static ILP (Wide Issue)	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/05-wideissue.pdf
Paper: Mahlke 1995	http://pages.cs.wisc.edu/~markhill/restricted/isca95_predication.pdf
Paper: Sohi 1990	http://www.cs.wisc.edu/~markhill/restricted/toc90_interruptable.pdf
Unit 6: Dynamic ILP (Out-of-Order Basics)	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/06-ooo-basics.pdf
Paper: Smith 1988	http://www.cs.wisc.edu/~markhill/restricted/toc88_precise.pdf
Paper: Yeager 1996	http://www.cs.wisc.edu/~markhill/restricted/ieeemicro96_r10000.pdf
Unit 7: Dynamic ILP (Speculation)	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/07-ooo-spec.pdf
Paper: Hammarlund 2014	http://pages.cs.wisc.edu/~rajwar/papers/ieee_micro_haswell.pdf
Unit 8: Advanced Out-of-Order	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/08-advanced-ooo.pdf
Unit 9: Memory Building Blocks	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/09-memory-building-blocks.pdf
Unit 10: Caches	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/10-caches.pdf
Paper: Pugsley 2014	http://www.cs.utah.edu/~rajeev/pubs/hpca14p.pdf
Paper: Albonesi 1999	http://pages.cs.wisc.edu/~markhill/restricted/micro99_selective_cache.pdf
Paper: Ghandi 2016	https://research.cs.wisc.edu/multifacet/papers/isca16_agile_paging.pdf
Unit 11: Virtual Memory	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/11-vm.pdf
Paper: Adams 2006	http://pages.cs.wisc.edu/~markhill/restricted/asplos06_vm.pdf
Unit 12: DRAM / Main Memory	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/12-dram.pdf
Unit 13: Reliability	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/13-reliability.pdf
Paper: Tullsen 1996	http://pages.cs.wisc.edu/~markhill/restricted/isca96_smt.pdf
Unit 14: Multithreading	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/14-multithread.pdf
Unit 15: Multiprocessing / Coherence	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/15-multiproc.pdf
Paper: Nickolls 2010	http://pages.cs.wisc.edu/~markhill/restricted/ieeemicro10_gpu.pdf
Paper: Bakhoda 2009	http://www.ece.ubc.ca/~aamodt/publications/papers/gpgpusim.ispass09.pdf
Unit 16: GPUs & Data-Level Parallelism	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/16-dlp-gpu.pdf
Paper: Wall 2019	http://parallel.princeton.edu/papers/wall-hpca19.pdf
Unit 17: Accelerators	http://www.cs.wisc.edu/~sinclair/courses/cs752/fall2020/handouts/lecture/17-accelWall.pdf
ROWS
)

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r title url; do
  [ -z "$url" ] && continue
  tmp=$(mktemp --suffix=.pdf)
  if ! curl -fsSL --max-time 60 "$url" -o "$tmp" 2>/dev/null; then
    echo "SKIP (fetch failed) $title <- $url" >&2; fail=$((fail+1)); rm -f "$tmp"; continue
  fi
  # must be a real PDF
  if ! head -c 5 "$tmp" | grep -q "%PDF"; then
    echo "SKIP (not a PDF) $title <- $url" >&2; fail=$((fail+1)); rm -f "$tmp"; continue
  fi
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  { printf '# %s\n\n' "$title"; pdftotext -nopgbrk "$tmp" - 2>/dev/null; } > "$cf"
  rm -f "$tmp"
  [ "$(wc -c < "$cf")" -lt 40 ] && { echo "SKIP (empty) $title" >&2; fail=$((fail+1)); continue; }
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.2
done <<< "$PAGES"
echo "==> Wisconsin CS752: $ok ok, $fail skipped, index rows: $(wc -l < "$OUT/index.tsv")"
