#!/usr/bin/env bash
# Freeze (or update) Beautiful Racket (beautifulracket.com) into the :Docs frozen
# web-book layout used by the "Beautiful Racket" picker:
#   Resources/docs/beautiful-racket/index.tsv    "[Section] Title" in TOC order
#   Resources/docs/.webcache/<sha256(url)>.txt    the rendered pages
#
# Body selector is div#doc; br_clean.py strips the site's soft hyphens and the
# breadcrumb header. Following the site's own table of contents: Start (2), the
# eleven Tutorials (each is the tutorial's landing page; the tutorial continues
# via its own "next" links, not frozen here), and all Explainers.
# Usage: br_build.sh   (run from anywhere)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
BR="$CFG/Resources/tools/br_clean.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/beautiful-racket"
SEL='div#doc'
BASE="https://beautifulracket.com"
mkdir -p "$OUT" "$CACHE"

# display <TAB> path, in the site's table-of-contents order.
PAGES=$(cat <<'ROWS'
[Start] Introduction	/introduction.html
[Start] Setup	/setup.html
[Tutorials] Make a language in one hour: stacker	/stacker/intro.html
[Tutorials] Learn some functional programming: funstacker	/funstacker/intro.html
[Tutorials] Dive deeper into macros: stackerizer	/stackerizer/intro.html
[Tutorials] Follow the grammar: bf	/bf/intro.html
[Tutorials] Extend a data format: jsonic	/jsonic/intro.html
[Tutorials] Level up: jsonic revisited	/jsonic-2/intro.html
[Tutorials] Finishing moves: jsonic	/jsonic-3/intro.html
[Tutorials] Imagine a language: wires	/wires/intro.html
[Tutorials] Go with the flow: basic	/basic/intro.html
[Tutorials] Into the rapids: more basic	/basic-2/intro.html
[Tutorials] Closing the loop: basic	/basic-3/intro.html
[Explainers] Booleans & conditionals	/explainer/booleans-and-conditionals.html
[Explainers] Continuations	/explainer/continuations.html
[Explainers] Contracts	/explainer/contracts.html
[Explainers] Data structures	/explainer/data-structures.html
[Explainers] Equality	/explainer/equality.html
[Explainers] Errors & exceptions	/explainer/errors-and-exceptions.html
[Explainers] Evaluation	/explainer/evaluation.html
[Explainers] Functions	/explainer/functions.html
[Explainers] Hygiene	/explainer/hygiene.html
[Explainers] Identifiers	/explainer/identifiers.html
[Explainers] Importing & exporting	/explainer/importing-and-exporting.html
[Explainers] Interposition points	/explainer/interposition-points.html
[Explainers] The #lang line	/explainer/lang-line.html
[Explainers] Lists	/explainer/lists.html
[Explainers] Loops	/explainer/loops.html
[Explainers] Macros	/explainer/macros.html
[Explainers] Modules	/explainer/modules.html
[Explainers] Numbers	/explainer/numbers.html
[Explainers] Pairs	/explainer/pairs.html
[Explainers] Parameters	/explainer/parameters.html
[Explainers] Recursion	/explainer/recursion.html
[Explainers] The REPL	/explainer/repl.html
[Explainers] Stringlike types	/explainer/stringlike-types.html
[Explainers] Syntax objects	/explainer/syntax-objects.html
[Explainers] Syntax patterns	/explainer/syntax-patterns.html
[Explainers] Unit testing	/explainer/unit-testing.html
ROWS
)

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r disp path; do
  [ -z "$path" ] && continue
  url="$BASE$path"
  html=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null)
  [ -z "$html" ] && { echo "FAIL fetch $url" >&2; fail=$((fail+1)); continue; }
  body=$(printf '%s' "$html" | python3 "$WE" content "$SEL" "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null \
    | python3 "$BR")
  [ "$(printf '%s' "$body" | wc -c)" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  printf '%s' "$body" > "$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  printf '%s\t%s\n' "$disp" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.3
done <<< "$PAGES"
echo "==> beautiful racket: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
