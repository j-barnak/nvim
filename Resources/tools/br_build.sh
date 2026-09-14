#!/usr/bin/env bash
# Freeze (or update) Beautiful Racket (beautifulracket.com) into the :Docs frozen
# web-book layout used by the "Beautiful Racket" picker:
#   Resources/docs/beautiful-racket/index.tsv    "[Section] Title" in TOC order
#   Resources/docs/.webcache/<sha256(url)>.txt    the rendered pages
#
# Body selector is div#doc; br_clean.py strips the site's soft hyphens, the
# breadcrumb header and the icon-font glyphs. Following the site's own table of
# contents: Start (2), the eleven Tutorials in full (every page of each tutorial,
# crawled along its "next" links, grouped "[Tutorials / <name>] <step>"), and
# all Explainers.
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
[Tutorials / Make a language in one hour: stacker] Introduction	/stacker/intro.html
[Tutorials / Make a language in one hour: stacker] Why make languages	/stacker/why-make-languages.html
[Tutorials / Make a language in one hour: stacker] Setup	/stacker/setup.html
[Tutorials / Make a language in one hour: stacker] The reader	/stacker/the-reader.html
[Tutorials / Make a language in one hour: stacker] The expander	/stacker/the-expander.html
[Tutorials / Make a language in one hour: stacker] Recap	/stacker/recap.html
[Tutorials / Make a language in one hour: stacker] Source listing	/stacker/source-listing.html
[Tutorials / Learn some functional programming: funstacker] Introduction	/funstacker/intro.html
[Tutorials / Learn some functional programming: funstacker] Project setup	/funstacker/project-setup.html
[Tutorials / Learn some functional programming: funstacker] The rewrite	/funstacker/the-rewrite.html
[Tutorials / Learn some functional programming: funstacker] Recap	/funstacker/recap.html
[Tutorials / Learn some functional programming: funstacker] Source listing	/funstacker/source-listing.html
[Tutorials / Dive deeper into macros: stackerizer] Introduction	/stackerizer/intro.html
[Tutorials / Dive deeper into macros: stackerizer] Specification and setup	/stackerizer/specification-and-setup.html
[Tutorials / Dive deeper into macros: stackerizer] The expander	/stackerizer/the-expander.html
[Tutorials / Dive deeper into macros: stackerizer] Recap	/stackerizer/recap.html
[Tutorials / Dive deeper into macros: stackerizer] Source listing	/stackerizer/source-listing.html
[Tutorials / Follow the grammar: bf] Introduction	/bf/intro.html
[Tutorials / Follow the grammar: bf] Grammars and parsers	/bf/grammars-and-parsers.html
[Tutorials / Follow the grammar: bf] Grammar notation	/bf/grammar-notation.html
[Tutorials / Follow the grammar: bf] The parser	/bf/the-parser.html
[Tutorials / Follow the grammar: bf] The tokenizer and reader	/bf/the-tokenizer-and-reader.html
[Tutorials / Follow the grammar: bf] An imperative expander	/bf/an-imperative-expander.html
[Tutorials / Follow the grammar: bf] A functional expander	/bf/a-functional-expander.html
[Tutorials / Follow the grammar: bf] Packaging our language	/bf/packaging-our-language.html
[Tutorials / Follow the grammar: bf] Recap	/bf/recap.html
[Tutorials / Follow the grammar: bf] Source listing	/bf/source-listing.html
[Tutorials / Extend a data format: jsonic] Introduction	/jsonic/intro.html
[Tutorials / Extend a data format: jsonic] Specification	/jsonic/specification.html
[Tutorials / Extend a data format: jsonic] Setup	/jsonic/setup.html
[Tutorials / Extend a data format: jsonic] The reader	/jsonic/the-reader.html
[Tutorials / Extend a data format: jsonic] The tokenizer	/jsonic/the-tokenizer.html
[Tutorials / Extend a data format: jsonic] The parser	/jsonic/the-parser.html
[Tutorials / Extend a data format: jsonic] The expander	/jsonic/the-expander.html
[Tutorials / Extend a data format: jsonic] Testing the language	/jsonic/testing-the-language.html
[Tutorials / Extend a data format: jsonic] Recap	/jsonic/recap.html
[Tutorials / Extend a data format: jsonic] Source listing	/jsonic/source-listing.html
[Tutorials / Level up: jsonic revisited] Introduction	/jsonic-2/intro.html
[Tutorials / Level up: jsonic revisited] Setup	/jsonic-2/setup.html
[Tutorials / Level up: jsonic revisited] Contracts	/jsonic-2/contracts.html
[Tutorials / Level up: jsonic revisited] Unit tests	/jsonic-2/unit-tests.html
[Tutorials / Level up: jsonic revisited] Source locations	/jsonic-2/source-locations.html
[Tutorials / Level up: jsonic revisited] DrRacket integration	/jsonic-2/drracket-integration.html
[Tutorials / Level up: jsonic revisited] Syntax coloring	/jsonic-2/syntax-coloring.html
[Tutorials / Level up: jsonic revisited] Indenting	/jsonic-2/indenting.html
[Tutorials / Level up: jsonic revisited] Toolbar buttons	/jsonic-2/toolbar-buttons.html
[Tutorials / Level up: jsonic revisited] Recap	/jsonic-2/recap.html
[Tutorials / Level up: jsonic revisited] Source listing	/jsonic-2/source-listing.html
[Tutorials / Finishing moves: jsonic] Introduction	/jsonic-3/intro.html
[Tutorials / Finishing moves: jsonic] Documentation	/jsonic-3/documentation.html
[Tutorials / Finishing moves: jsonic] The info.rkt file	/jsonic-3/the-info.rkt-file.html
[Tutorials / Finishing moves: jsonic] The package server	/jsonic-3/the-package-server.html
[Tutorials / Finishing moves: jsonic] Recap	/jsonic-3/recap.html
[Tutorials / Finishing moves: jsonic] Source listing	/jsonic-3/source-listing.html
[Tutorials / Imagine a language: wires] Introduction	/wires/intro.html
[Tutorials / Imagine a language: wires] Specification and setup	/wires/specification-and-setup.html
[Tutorials / Imagine a language: wires] The reader	/wires/the-reader.html
[Tutorials / Imagine a language: wires] The expander	/wires/the-expander.html
[Tutorials / Imagine a language: wires] Testing the language	/wires/testing-the-language.html
[Tutorials / Imagine a language: wires] Recap	/wires/recap.html
[Tutorials / Imagine a language: wires] Source listing	/wires/source-listing.html
[Tutorials / Go with the flow: basic] Introduction	/basic/intro.html
[Tutorials / Go with the flow: basic] Specification and setup	/basic/specification-and-setup.html
[Tutorials / Go with the flow: basic] The lexer	/basic/the-lexer.html
[Tutorials / Go with the flow: basic] The tokenizer	/basic/the-tokenizer.html
[Tutorials / Go with the flow: basic] The parser	/basic/the-parser.html
[Tutorials / Go with the flow: basic] The reader	/basic/the-reader.html
[Tutorials / Go with the flow: basic] The expander	/basic/the-expander.html
[Tutorials / Go with the flow: basic] Testing the language	/basic/testing-the-language.html
[Tutorials / Go with the flow: basic] Recap	/basic/recap.html
[Tutorials / Go with the flow: basic] Source listing	/basic/source-listing.html
[Tutorials / Into the rapids: more basic] Introduction	/basic-2/intro.html
[Tutorials / Into the rapids: more basic] Specification and setup	/basic-2/specification-and-setup.html
[Tutorials / Into the rapids: more basic] The syntax colorer	/basic-2/the-syntax-colorer.html
[Tutorials / Into the rapids: more basic] Better line errors	/basic-2/better-line-errors.html
[Tutorials / Into the rapids: more basic] Variables and input	/basic-2/variables-and-input.html
[Tutorials / Into the rapids: more basic] Expressions	/basic-2/expressions.html
[Tutorials / Into the rapids: more basic] Conditionals	/basic-2/conditionals.html
[Tutorials / Into the rapids: more basic] Subroutines and loops	/basic-2/subroutines-and-loops.html
[Tutorials / Into the rapids: more basic] Recap	/basic-2/recap.html
[Tutorials / Into the rapids: more basic] Source listing	/basic-2/source-listing.html
[Tutorials / Closing the loop: basic] Introduction	/basic-3/intro.html
[Tutorials / Closing the loop: basic] Specification and setup	/basic-3/specification-and-setup.html
[Tutorials / Closing the loop: basic] Functions	/basic-3/functions.html
[Tutorials / Closing the loop: basic] Imports	/basic-3/imports.html
[Tutorials / Closing the loop: basic] Exports	/basic-3/exports.html
[Tutorials / Closing the loop: basic] The REPL	/basic-3/the-repl.html
[Tutorials / Closing the loop: basic] Command line arguments	/basic-3/command-line-arguments.html
[Tutorials / Closing the loop: basic] Recap	/basic-3/recap.html
[Tutorials / Closing the loop: basic] Source listing	/basic-3/source-listing.html
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
