#!/usr/bin/env bash
# Freeze MIT 6.5950/6.5951 "Secure Hardware Design" (shd.mit.edu, 2026) into the
# :Docs frozen web-book layout used by the "MIT 6.5950 Secure Hardware Design"
# book:
#   Resources/docs/mit-shd/index.tsv           "<title>\t<url>" in book order
#   Resources/docs/.webcache/<sha256(url)>.txt  rendered chapter
#
# Chapters: a hand-formatted "Paper Discussion" reading list; every lecture and
# recitation SLIDE deck from calendar.html (pdftotext); the 4 recitation writeup
# pages; the labs overview + each lab page; and two included papers (Bigger Fish,
# Mesh Attack). Videos are not included. HTML body selector is #main-content
# (Just-the-Docs). Usage: mit_shd_build.sh   (needs curl, pdftotext, pandoc, python3)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/mit-shd"
B="https://shd.mit.edu/2026"
mkdir -p "$OUT" "$CACHE"
sha() { printf '%s' "$1" | sha256sum | awk '{print $1}'; }

: > "$OUT/index.tsv"; ok=0; fail=0

emit_index() { printf '%s\t%s\n' "$1" "$2" >> "$OUT/index.tsv"; }

# (A) Paper Discussion - hand-formatted reading list (synthetic url key).
PD_URL="$B/#paper-discussion"
cat > "$CACHE/$(sha "$PD_URL").txt" <<'MD'
# Paper Discussion

In each discussion session, we discuss 5 papers around one particular topic. The
discussion of each paper is led by 2 students (who take the graduate version of
the course, 6.5950). Throughout the semester, each student leads the discussion
once. The papers are selected from top security and computer architecture
conferences, covering broad hardware security topics representing the state of
the art.

For the presenters, check Piazza posts to know when you present which paper. As
you prepare, refer to the detailed paper reading guidance for how to read a
hardware security paper, what is required for the presentation, and how it is
graded. For the audience, pick a paper to read before each session and ask
questions during the Q&A; good questions earn bonus points.

## Modern Side-Channel Attacks (April 15)

- Prime+Probe 1, JavaScript 0: Overcoming Browser-based Side-Channel Defenses
- Theory and Practice of Finding Eviction Sets
- Port Contention for Fun and Profit
- Augury: Using Data Memory-Dependent Prefetchers to Leak Data at Rest
- ÆPIC Leak: Architecturally Leaking Uninitialized Data from the Microarchitecture
- Hertzbleed: Turning Power Side-Channel Attacks into Remote Timing Attacks on x86

## Physical Attacks (April 22)

- CLKSCREW: Exposing the Perils of Security-Oblivious Energy Management
- SRAM Has No Chill: Exploiting Power Domain Separation to Steal On-Chip Secrets
- Eddie: EM-based Detection of Deviations in Program Execution
- One Glitch to Rule Them All: Fault Injection Attacks Against AMD's Secure Encrypted Virtualization
- ProTRR: Principled yet Optimal In-DRAM Target Row Refresh
- QPRAC: Towards Secure and Practical PRAC-based Rowhammer Mitigation using Priority Queues

## Hardware Support for Software Safety (April 27)

- Speculative Probing: Hacking Blind in the Spectre Era
- When Good Kernel Defenses Go Bad: Reliable and Stable Kernel Exploits via Defense-Amplified TLB Side-Channel Leaks
- An Analysis of Speculative Type Confusion Vulnerabilities in the Wild
- The CHERI Capability Model: Revisiting RISC in an Age of Risk
- SecureCells: A Secure Compartmentalized Architecture
- PACMem: Enforcing Spatial and Temporal Memory Safety via ARM Pointer Authentication

## Fuzzing and Formal Verification (April 29)

- SiliFuzz: Fuzzing CPUs by Proxy
- Cascade: CPU Fuzzing via Intricate Program Generation
- SpecDoctor: Differential Fuzz Testing to Find Transient Execution Vulnerabilities
- Revizor: Testing Black-Box CPUs against Speculation Contracts
- SPECS: A Lightweight Runtime Mechanism for Protecting Software from Security-Critical Processor Bugs
- MileSan: Detecting Exploitable Microarchitectural Leakage via Differential Hardware-Software Taint Tracking

## TEE Designs + Potpourri (May 4)

- Sanctum: Minimal Hardware Extensions for Strong Software Isolation
- Keystone: An Open Framework for Architecting Trusted Execution Environments
- Leaky Cauldron on the Dark Land: Understanding Memory Side-Channel Hazards in SGX
- CIPHERLEAKS: Breaking Constant-time Cryptography on AMD SEV via the Ciphertext Side Channel
MD
emit_index "Paper Discussion" "$PD_URL"; ok=$((ok+1))

# helper: fetch a PDF -> "# title" + pdftotext
add_pdf() {
  local title="$1" url="$2" tmp cf
  tmp=$(mktemp --suffix=.pdf)
  if ! curl -fsSL --max-time 90 "$url" -o "$tmp" 2>/dev/null; then echo "FAIL fetch $url" >&2; fail=$((fail+1)); rm -f "$tmp"; return; fi
  cf="$CACHE/$(sha "$url").txt"
  { printf '# %s\n\n' "$title"; pdftotext -nopgbrk "$tmp" - 2>/dev/null; } > "$cf"; rm -f "$tmp"
  [ "$(wc -c < "$cf")" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); return; }
  emit_index "$title" "$url"; ok=$((ok+1)); sleep 0.2
}
# helper: fetch an HTML page (Just-the-Docs #main-content)
add_html() {
  local title="$1" url="$2" cf body
  cf="$CACHE/$(sha "$url").txt"
  body=$(curl -fsSL --compressed --max-time 60 "$url" 2>/dev/null \
    | python3 "$WE" content '#main-content' "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null \
    | sed -E 's/!\[[^]]*\]\(data:[^)]*\)//g; s/\]\(data:[^)]*\)/]()/g')
  if [ "$(printf '%s' "$body" | wc -c)" -lt 40 ]; then echo "FAIL empty $url" >&2; fail=$((fail+1)); return; fi
  { printf '# %s\n\n' "$title"; printf '%s\n' "$body"; } > "$cf"
  emit_index "$title" "$url"; ok=$((ok+1)); sleep 0.2
}

# (B) all slide decks from calendar.html, in calendar order
add_pdf "Lecture 1: Introduction"                 "$B/lectures/slides/1-Introduction.pdf"
add_pdf "Lecture 2: Side-Channels"                "$B/lectures/slides/2-Side-Channels.pdf"
add_pdf "Recitation 1: CTF of C Programming"      "$B/recitations/slides/1-CTF-Of-C-Programming.pdf"
add_pdf "Lecture 3: Cache Attacks"                "$B/lectures/slides/3-Cache-Attacks.pdf"
add_pdf "Recitation 2: Caches"                    "$B/recitations/slides/Recitation-2-Caches.pdf"
add_pdf "Lecture 4: Transient Attacks"            "$B/lectures/slides/4-Transient-Attacks.pdf"
add_pdf "Lecture 5: Software-Hardware Contract"   "$B/lectures/slides/5-Software-Hardware-Contract.pdf"
add_pdf "Lecture 6: Spectre Mitigations"          "$B/lectures/slides/6-Spectre-Mitigations.pdf"
add_pdf "Lecture 7: Physical Attacks"             "$B/lectures/slides/7-Physical-Attacks.pdf"
add_pdf "Lecture 9: RowHammer"                    "$B/lectures/slides/9-RowHammer.pdf"
add_pdf "Lecture 10: Reliability Solutions"       "$B/lectures/slides/10-Reliability-Solutions.pdf"
add_pdf "Lecture 10: Root of Trust"               "$B/lectures/slides/10-Root-of-Trust.pdf"
add_pdf "Lecture 11: Memory Safety"               "$B/lectures/slides/11-MemorySafety.pdf"
add_pdf "Lecture 12: Fuzzing"                     "$B/lectures/slides/12-Fuzzing.pdf"
add_pdf "Lecture 13: Formal"                      "$B/lectures/slides/13-Formal.pdf"
add_pdf "Recitation 3: Intro to Verilog"          "$B/recitations/slides/3-Intro-to-Verilog.pdf"
add_pdf "Lecture 14: TEE"                         "$B/lectures/slides/14-TEE.pdf"

# (C) recitation writeup pages
add_html "Recitation: CTF of C Programming"               "$B/recitations/cpp.html"
add_html "Recitation: Cache Attack"                       "$B/recitations/cache.html"
add_html "Recitation: Binary Exploitation and RISC-V Warmup" "$B/recitations/riscv.html"
add_html "Recitation: Formal Verification"                "$B/recitations/formal.html"

# (D) labs
add_html "Labs (overview)"               "$B/labs.html"
add_html "Lab 0: C Crash Course"         "$B/labs/ccc.html"
add_html "Lab 1: Website Fingerprinting" "$B/labs/fingerprinting.html"
add_html "Lab 2: Cache Attacks"          "$B/labs/cache.html"
add_html "Lab 3: Spectre Attacks"        "$B/labs/spectre.html"
add_html "Lab 4: Rowhammer"              "$B/labs/rowhammer.html"
add_html "Lab 5: ASLR Bypasses"          "$B/labs/aslr.html"
add_html "Lab: Pretty Secure Processor"  "$B/labs/psp.html"
add_html "Lab 6: CPU Fuzzing"            "$B/labs/fuzz.html"
add_html "Lab 7: CPU Verification"       "$B/labs/formal.html"

# (E) included papers
add_pdf "Bigger Fish (2022 ISCA)" "https://people.csail.mit.edu/mengjia/data/2022.ISCA.BiggerFish.pdf"
add_pdf "Mesh Attack (2022 USENIX)" "https://people.csail.mit.edu/mengjia/data/2022.USENIX.MeshAttack.pdf"

echo "==> MIT SHD: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
