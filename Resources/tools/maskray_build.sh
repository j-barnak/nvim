#!/usr/bin/env bash
# Freeze Fangrui Song's (MaskRay's) linker/ELF blog posts into the :Docs frozen
# web-book layout used by the "MaskRay Linker" picker:
#   Resources/docs/maskray-linker/index.tsv       "<title>\t<url>" in order
#   Resources/docs/.webcache/<sha256(url)>.txt      the rendered post
#
# One post per chapter; body is div.e-content, title from h1.article-title. Code
# (<pre>) survives pandoc as fenced blocks. The slug list is the user's, de-duped
# (first occurrence kept). Source: https://maskray.me/blog/
# Usage: maskray_build.sh   (needs curl, python3+bs4+lxml, pandoc)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
PF="$CFG/Resources/tools/maskray_prefilter.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/maskray-linker"
B="https://maskray.me/blog"
mkdir -p "$OUT" "$CACHE"

SLUGS=$(cat <<'S'
all-about-thread-local-storage
init-ctors-init-array
all-about-global-offset-table
2021-10-10-when-can-glibc-be-built-with-clang
stack-unwinding
all-about-procedure-linkage-table
elf-interposition-and-bsymbolic
all-about-symbol-versioning
relative-relocations-and-relr
c++-exception-handling-abi
weak-symbol
all-about-leak-sanitizer
the-dark-side-of-riscv-linker-relaxation
evolution-of-elf-object-file-format
gnu-indirect-function
elf-hash-function
lld-and-gnu-linker-incompatibilities
control-flow-integrity
linker-notes-on-aarch64
relocatable-linking
why-isnt-ld.lld-faster
odr-violation-detection
symbol-processing
copy-relocations-canonical-plt-entries-and-protected
unwinding-through-signal-handler
toolchain-notes-on-mips
call-relocation-types
long-branches-in-compilers-assemblers-and-linkers
stack-walking-space-and-time-trade-offs
relocation-generation-in-assemblers
skipping-boring-functions-in-debuggers
understanding-orphan-sections
mapping-symbols-rethinking-for-efficiency
exploring-gnu-extensions-in-linux-kernel
2024-03-17-c++-exit-time-destructors
a-compact-relocation-format-for-elf
toolchain-notes-on-z-architecture
exploring-the-section-layout-in-linker-output
raw-symbol-names-in-inline-assembly
dso-undef-and-non-exported-definition
exploring-object-file-formats
c++-standard-library-abi-compatibility
compressed-arbitrary-sections
a-deep-dive-into-clang-source-file-compilation
linker-notes-on-aarch32
linker-notes-on-x86
assemblers
linker-notes-on-power-isa
relocation-overflow-and-code-models
all-about-sanitizer-interceptors
all-about-undefined-behavior-sanitizer
fortify-source
dwarf-in-reproducible-builds
glibc
linker-garbage-collection
S
)

: > "$OUT/index.tsv"; ok=0; fail=0
for slug in $SLUGS; do
  [ -z "$slug" ] && continue
  url="$B/$slug"
  html=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null)
  [ -z "$html" ] && { echo "FAIL fetch $url" >&2; fail=$((fail+1)); continue; }
  title=$(printf '%s' "$html" | python3 -c "
import sys
from bs4 import BeautifulSoup
s=BeautifulSoup(sys.stdin.read(),'lxml')
h=s.select_one('h1.article-title')
t=(s.title.string or '') if s.title else ''
print((h.get_text(strip=True) if h else t.replace(' | MaskRay','')).strip())")
  [ -z "$title" ] && title="$slug"
  body=$(printf '%s' "$html" \
    | python3 "$PF" 2>/dev/null \
    | python3 "$WE" content div.e-content "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null)
  if [ "$(printf '%s' "$body" | wc -c)" -lt 200 ]; then
    echo "FAIL empty $url" >&2; fail=$((fail+1)); continue
  fi
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  { printf '# %s\n\n' "$title"; printf '%s\n' "$body"; } > "$cf"
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.3
done
echo "==> MaskRay: $ok posts, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
