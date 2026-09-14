#!/usr/bin/env bash
# Freeze (or update) OCaml By Example (o1-labs.github.io/ocamlbyexample) into the
# :Docs frozen web-book layout used by the "OCaml by Example" picker:
#   Resources/docs/ocaml-byexample/index.tsv     sidebar order, "[Section] Title"
#   Resources/docs/.webcache/<sha256(url)>.txt    the rendered pages
#
# Content body is div.chapter. The site stores its prose as literal (unrendered)
# markdown, so obe_unescape.py un-escapes emphasis/inline-code/links outside code
# fences. Only the three sections the library carries (Language Basics, Project
# Management, Advanced Ocaml); the site's "Libraries" section is not included.
# sets / functors / monads are placeholders on the site (sidebar entries with no
# page): they get a short stub so the picker mirrors the site's own structure.
# Usage: ocaml_byexample_build.sh   (run from anywhere)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
UN="$CFG/Resources/tools/obe_unescape.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/ocaml-byexample"
SEL='div.chapter'
BASE="https://o1-labs.github.io/ocamlbyexample"
mkdir -p "$OUT" "$CACHE"

# display <TAB> slug   (slug "-" marks a site placeholder with no page: stub it).
PAGES=$(cat <<'ROWS'
[Language Basics] opam	basics-opam.html
[Language Basics] hello world	basics-hello-world.html
[Language Basics] utop	basics-utop.html
[Language Basics] values	basics-values.html
[Language Basics] functions	basics-functions.html
[Language Basics] imperative	basics-imperative.html
[Language Basics] match	basics-match.html
[Language Basics] tuples	basics-tuples.html
[Language Basics] variants	basics-variants.html
[Language Basics] lists	basics-list.html
[Language Basics] sets	-
[Language Basics] arrays	basics-array.html
[Language Basics] records	basics-records.html
[Language Basics] mutability	basics-mutability.html
[Language Basics] recursion	basics-recursion.html
[Language Basics] hash tables	basics-map.html
[Language Basics] modules	basics-modules.html
[Language Basics] errors	basics-errors.html
[Language Basics] bits	basics-bits.html
[Language Basics] commands	basics-commands.html
[Language Basics] files	basics-files.html
[Project Management] dune	build-dune.html
[Project Management] libraries	build-libraries.html
[Project Management] tests	build-inline-tests.html
[Project Management] property tests	build-qcheck.html
[Project Management] test coverage	build-bisect_ppx.html
[Project Management] publishing	build-dune-release.html
[Project Management] pins	build-opam-pin.html
[Advanced Ocaml] functors	-
[Advanced Ocaml] macros	advanced-macros.html
[Advanced Ocaml] monads	-
ROWS
)

: > "$OUT/index.tsv"; ok=0; stub=0; fail=0
while IFS=$'\t' read -r disp slug; do
  [ -z "$disp" ] && continue
  name=${disp#*] }               # the title after "[Section] "
  if [ "$slug" = "-" ]; then
    # placeholder on the site (no page yet): honest stub, keyed by an anchor url
    url="$BASE/#$(printf '%s' "$name" | tr ' A-Z' '-a-z')"
    printf '# %s\n\nThis chapter is listed in the OCaml By Example sidebar but has not been written yet on o1-labs.github.io/ocamlbyexample (the site shows it as a placeholder with no page).\n\nSee <%s/> for the chapters that are available.\n' \
      "$name" "$BASE" > "$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
    printf '%s\t%s\n' "$disp" "$url" >> "$OUT/index.tsv"; stub=$((stub+1)); continue
  fi
  url="$BASE/$slug"
  html=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null)
  [ -z "$html" ] && { echo "FAIL fetch $url" >&2; fail=$((fail+1)); continue; }
  body=$(printf '%s' "$html" | python3 "$WE" content "$SEL" "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null \
    | python3 "$UN")
  [ "$(printf '%s' "$body" | wc -c)" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  printf '%s' "$body" > "$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  printf '%s\t%s\n' "$disp" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.3
done <<< "$PAGES"
echo "==> ocaml by example: $ok pages, $stub stubs, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
