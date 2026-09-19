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
    Linux Kernel target	tutorials/linux/fuzzing_linux_kernel.html
  Windows Target	tutorials/windows/index.html
    Driver	tutorials/windows/driver/index.html
    Userspace	tutorials/windows/userspace/index.html
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
echo "==> kAFL: $ok pages, $hdr section labels, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
