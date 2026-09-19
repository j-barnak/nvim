#!/usr/bin/env bash
# Freeze the kAFL documentation (https://intellabs.github.io/kAFL/) into the
# :Docs frozen web-book layout used by the kAFL "Browse Documentation" picker:
#   Resources/docs/kafl-docs/index.tsv          "<title>\t<url>" in ToC order
#   Resources/docs/.webcache/<sha256(url)>.txt   the rendered page
#
# The table of contents mirrors the site's own tabs (Tutorials / How-to guides /
# Reference / Context). Section labels are indentation-only rows with no URL;
# every other row is a page. Indentation (2 spaces per level) reproduces the ToC
# tree: DVKM / Linux Kernel target sit under Linux Target, Driver / Userspace
# under Windows Target. Source: https://github.com/IntelLabs/kAFL
# Usage: kafl_build.sh   (needs curl, python3+bs4+lxml, pandoc)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/kafl-docs"
BASE="https://intellabs.github.io/kAFL"
mkdir -p "$OUT" "$CACHE"

# "<indented title>\t<url-tail>"  -- an empty url-tail is a section label (no page).
# Order and indentation follow the requested table of contents.
ROWS=$(cat <<'TOC'
Tutorials
  Introduction	tutorials/introduction.html
  Installation	tutorials/installation.html
  Concepts	tutorials/concepts.html
  Linux Target	tutorials/linux/index.html
    DVKM	tutorials/linux/dvkm/index.html
      1 - Target analysis	tutorials/linux/dvkm/target.html
      2 - kAFL workflow	tutorials/linux/dvkm/workflow.html
      3 - Building the agent	tutorials/linux/dvkm/agent.html
      4 - Fuzzing campaign	tutorials/linux/dvkm/fuzzing.html
      5 - Exploring campaign results	tutorials/linux/dvkm/results.html
      6 - Improvements: KASAN	tutorials/linux/dvkm/improvements.html
    Linux Kernel target	tutorials/linux/fuzzing_linux_kernel.html
  Windows Target	tutorials/windows/index.html
    Driver	tutorials/windows/driver/index.html
      Target analysis	tutorials/windows/driver/target.html
      Windows VM Template	tutorials/windows/windows_template.html
      Provision the guest VM	tutorials/windows/driver/target_setup.html
      Fuzzing Campaign	tutorials/windows/driver/campaign.html
      Crash Analysis	tutorials/windows/driver/crash.html
    Userspace	tutorials/windows/userspace/index.html
      Target analysis	tutorials/windows/userspace/target.html
      Provision the guest VM	tutorials/windows/userspace/target_setup.html
      Fuzzing Campaign	tutorials/windows/userspace/campaign.html
      Improvements	tutorials/windows/userspace/improvements.html
How-to guides
  Github Actions CI/CD	how_to/github_actions.html
Reference
  Fuzzer Configuration	reference/fuzzer_configuration.html
  Deployment	reference/deployment.html
  kAFL/Nyx Hypercall API	reference/hypercall_api.html
  kAFL Workdir	reference/workdir_layout.html
  kAFL User Interface	reference/user_interface.html
Context
  Research Papers	context/research_papers.html
TOC
)

: > "$OUT/index.tsv"; ok=0; fail=0; hdr=0
while IFS=$'\t' read -r title tail; do
  [ -z "$title" ] && continue
  if [ -z "$tail" ]; then
    # Section label: a visual heading with no page.
    printf '%s\n' "$title" >> "$OUT/index.tsv"; hdr=$((hdr+1)); continue
  fi
  url="$BASE/$tail"
  body=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null \
    | python3 "$WE" content article "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null)
  if [ "$(printf '%s' "$body" | wc -c)" -lt 40 ]; then
    echo "FAIL empty $url" >&2; fail=$((fail+1)); continue
  fi
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  printf '%s\n' "$body" > "$cf"
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.2
done <<< "$ROWS"

# Research papers referenced by the docs (Context > Research Papers). Each is a
# PDF frozen to text (pdftotext), listed indented under the Research Papers node.
# The Nyx paper shares its cache with the Nyx provider (same URL). Needs pdftotext.
PAPERS=$(cat <<'PAP'
    kAFL: Hardware-Assisted Feedback Fuzzing for OS Kernels (2017)	https://nyx-fuzz.com/papers/kafl.pdf
    REDQUEEN: Fuzzing with Input-to-State Correspondence (2019)	https://nyx-fuzz.com/papers/redqueen.pdf
    NAUTILUS: Fishing for Deep Bugs with Grammars (2019)	https://nyx-fuzz.com/papers/nautilus.pdf
    GRIMOIRE: Synthesizing Structure while Fuzzing (2019)	https://nyx-fuzz.com/papers/grimoire.pdf
    IJON: Exploring Deep State Spaces via Fuzzing (2020)	https://nyx-fuzz.com/papers/ijon.pdf
    HYPER-CUBE: High-Dimensional Hypervisor Fuzzing (2020)	https://nyx-fuzz.com/papers/hypercube.pdf
    Nyx: Greybox Hypervisor Fuzzing (USENIX Security 2021)	https://www.usenix.org/system/files/sec21-schumilo.pdf
PAP
)
pap=0
while IFS=$'\t' read -r title url; do
  [ -z "$url" ] && continue
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  if [ ! -s "$cf" ]; then
    tmp=$(mktemp --suffix=.pdf)
    if curl -fsSL --max-time 60 "$url" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
      t=$(printf '%s' "$title" | sed 's/^ *//')
      { printf '# %s\n\n' "$t"; pdftotext -layout -nopgbrk "$tmp" - 2>/dev/null; } > "$cf"
    fi
    rm -f "$tmp"
  fi
  if [ -s "$cf" ]; then
    printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; pap=$((pap+1))
  else
    echo "FAIL paper $url" >&2
  fi
  sleep 0.2
done <<< "$PAPERS"

echo "==> kAFL: $ok pages, $hdr section labels, $pap papers, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
