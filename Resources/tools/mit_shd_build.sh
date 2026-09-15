#!/usr/bin/env bash
# Freeze MIT 6.5950/6.5951 "Secure Hardware Design" (shd.mit.edu, 2026) into the
# :Docs frozen web-book layout used by the "MIT 6.5950 Secure Hardware Design"
# book:
#   Resources/docs/mit-shd/index.tsv           "<title>\t<url>" in CALENDAR order
#   Resources/docs/.webcache/<sha256(url)>.txt  rendered chapter
#
# Chapters follow the course calendar (calendar.html): lectures, recitations and
# labs interleaved by date, then the Paper Discussion sessions + the two included
# papers (mid/late April), then the last labs. Slide decks (lectures and
# recitations) are rendered with `pdftotext -layout` so bullet nesting and the
# spatial layout of diagram text read correctly; the two academic papers use
# plain pdftotext (two-column, -layout would interleave the columns). HTML pages
# (recitation writeups, labs) use #main-content (Just-the-Docs). Videos excluded.
# Usage: mit_shd_build.sh   (needs curl, pdftotext, pandoc, python3)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/mit-shd"
B="https://shd.mit.edu/2026"
mkdir -p "$OUT" "$CACHE"
sha() { printf '%s' "$1" | sha256sum | awk '{print $1}'; }
: > "$OUT/index.tsv"; ok=0; fail=0
emit() { printf '%s\t%s\n' "$1" "$2" >> "$OUT/index.tsv"; ok=$((ok+1)); }

# slide deck: -layout keeps bullet nesting + diagram text position
add_slide() {
  local title="$1" url="$2" tmp cf
  tmp=$(mktemp --suffix=.pdf)
  if ! curl -fsSL --max-time 90 "$url" -o "$tmp" 2>/dev/null; then echo "FAIL fetch $url" >&2; fail=$((fail+1)); rm -f "$tmp"; return; fi
  cf="$CACHE/$(sha "$url").txt"
  { printf '# %s\n\n' "$title"; pdftotext -layout -nopgbrk "$tmp" - 2>/dev/null; } > "$cf"; rm -f "$tmp"
  [ "$(wc -c < "$cf")" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); return; }
  emit "$title" "$url"; sleep 0.2
}
# academic paper: plain pdftotext (two columns; -layout would interleave them)
add_paper() {
  local title="$1" url="$2" tmp cf
  tmp=$(mktemp --suffix=.pdf)
  if ! curl -fsSL --max-time 90 "$url" -o "$tmp" 2>/dev/null; then echo "FAIL fetch $url" >&2; fail=$((fail+1)); rm -f "$tmp"; return; fi
  cf="$CACHE/$(sha "$url").txt"
  { printf '# %s\n\n' "$title"; pdftotext -nopgbrk "$tmp" - 2>/dev/null; } > "$cf"; rm -f "$tmp"
  [ "$(wc -c < "$cf")" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); return; }
  emit "$title" "$url"; sleep 0.2
}
# Just-the-Docs page
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
  emit "$title" "$url"; sleep 0.2
}

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

# ── Calendar order (dates from calendar.html) ───────────────────────────────
add_slide "Lecture 1: Overview"                                  "$B/lectures/slides/1-Introduction.pdf"                 # Feb 2
add_slide "Lecture 2: Side Channel Overview"                     "$B/lectures/slides/2-Side-Channels.pdf"                # Feb 4
add_slide "Recitation 1: CTF of C Programming"                   "$B/recitations/slides/1-CTF-Of-C-Programming.pdf"      # Feb 9
add_html  "Recitation: CTF of C Programming"                     "$B/recitations/cpp.html"
add_slide "Lecture 3: Deep Dive of Cache Side Channels"          "$B/lectures/slides/3-Cache-Attacks.pdf"                # Feb 11
add_html  "Labs (overview)"                                      "$B/labs.html"
add_html  "Lab 0: C Crash Course"                                "$B/labs/ccc.html"                                     # Feb 12
add_html  "Lab 1: Website Fingerprinting"                        "$B/labs/fingerprinting.html"                          # Feb 12
add_slide "Recitation 2: Cache Attacks"                          "$B/recitations/slides/Recitation-2-Caches.pdf"        # Feb 17
add_html  "Recitation: Cache Attack"                             "$B/recitations/cache.html"
add_slide "Lecture 4: Transient Execution Side Channels"         "$B/lectures/slides/4-Transient-Attacks.pdf"            # Feb 18
add_slide "Lecture 5: Software-Hardware Contract"                "$B/lectures/slides/5-Software-Hardware-Contract.pdf"   # Feb 23
add_slide "Lecture 6: Spectre Mitigations"                       "$B/lectures/slides/6-Spectre-Mitigations.pdf"          # Feb 25
add_slide "Lecture 7: Physical Attacks"                          "$B/lectures/slides/7-Physical-Attacks.pdf"             # Mar 2
add_html  "Lab 2: Cache Attacks"                                 "$B/labs/cache.html"                                   # Mar 3
add_slide "Lecture 8: Rowhammer Attacks"                         "$B/lectures/slides/9-RowHammer.pdf"                    # Mar 9
add_slide "Lecture 9: Rowhammer Mitigation + Reliability Solutions" "$B/lectures/slides/10-Reliability-Solutions.pdf"    # Mar 11
add_html  "Lab 3: Spectre Attacks"                               "$B/labs/spectre.html"                                 # Mar 12
add_slide "Lecture 10: Root of Trust"                            "$B/lectures/slides/10-Root-of-Trust.pdf"               # Mar 16
add_slide "Lecture 11: Hardware Support for Software Security"    "$B/lectures/slides/11-MemorySafety.pdf"               # Mar 18
add_slide "Lecture 12: Fuzzing and Bug Finding"                  "$B/lectures/slides/12-Fuzzing.pdf"                     # Mar 30
add_html  "Lab 4: Rowhammer"                                     "$B/labs/rowhammer.html"                               # Apr 2
add_slide "Lecture 13: Formal Verification for Hardware Security" "$B/lectures/slides/13-Formal.pdf"                     # Apr 6
add_slide "Recitation 3: Formal Verification"                    "$B/recitations/slides/3-Intro-to-Verilog.pdf"          # Apr 8
add_html  "Recitation: Binary Exploitation and RISC-V Warmup"    "$B/recitations/riscv.html"
add_html  "Recitation: Formal Verification"                      "$B/recitations/formal.html"
add_html  "Lab 5: ASLR Bypasses"                                 "$B/labs/aslr.html"                                    # Apr 9
add_slide "Lecture 14: Trusted Execution Environment (TEE)"      "$B/lectures/slides/14-TEE.pdf"                         # Apr 13
emit "Paper Discussion" "$PD_URL"                                                                                       # Apr 15 - May 4
add_paper "Bigger Fish (2022 ISCA)"   "https://people.csail.mit.edu/mengjia/data/2022.ISCA.BiggerFish.pdf"
add_paper "Mesh Attack (2022 USENIX)" "https://people.csail.mit.edu/mengjia/data/2022.USENIX.MeshAttack.pdf"
add_html  "Lab 6: CPU Fuzzing"                                   "$B/labs/fuzz.html"                                    # Apr 23
add_html  "Lab: Pretty Secure Processor"                         "$B/labs/psp.html"
add_html  "Lab 7: CPU Verification"                              "$B/labs/formal.html"                                  # Apr 30

echo "==> MIT SHD: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
