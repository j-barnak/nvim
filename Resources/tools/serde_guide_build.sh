#!/usr/bin/env bash
# Freeze (or update) the Serde guide (serde.rs) into the :Docs frozen web-book
# layout used by the "Serde -> Guide (serde.rs)" picker:
#   Resources/docs/serde-guide/index.tsv         narrative order, "[Section] Title"
#   Resources/docs/.webcache/<sha256(url)>.txt    the rendered pages
#
# serde.rs is a legacy-GitBook site; the readable body is section.normal.
# The crate API reference is NOT frozen (it is browsed live from docs.rs).
# Usage: serde_guide_build.sh   (run from anywhere)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/serde-guide"
SEL='section.normal'
BASE="https://serde.rs"
mkdir -p "$OUT" "$CACHE"

# display <TAB> page-slug, in serde.rs sidebar order. "[Section] Title" tags a
# page that lives under a section header on the site.
PAGES=$(cat <<'ROWS'
Overview	index.html
Help	help.html
Serde data model	data-model.html
Using derive	derive.html
Attributes	attributes.html
[Attributes] Container attributes	container-attrs.html
[Attributes] Variant attributes	variant-attrs.html
[Attributes] Field attributes	field-attrs.html
Custom serialization	custom-serialization.html
[Custom serialization] Implementing Serialize	impl-serialize.html
[Custom serialization] Implementing Deserialize	impl-deserialize.html
[Custom serialization] Unit testing	unit-testing.html
Writing a data format	data-format.html
[Writing a data format] Conventions	conventions.html
[Writing a data format] Error handling	error-handling.html
[Writing a data format] Implementing a Serializer	impl-serializer.html
[Writing a data format] Implementing a Deserializer	impl-deserializer.html
Deserializer lifetimes	lifetimes.html
Examples	examples.html
[Examples] Structs and enums in JSON	json.html
[Examples] Enum representations	enum-representations.html
[Examples] Default value for a field	attr-default.html
[Examples] Struct flattening	attr-flatten.html
[Examples] Handwritten generic type bounds	attr-bound.html
[Examples] Deserialize for custom map type	deserialize-map.html
[Examples] Array of values without buffering	stream-array.html
[Examples] Serialize enum as number	enum-number.html
[Examples] Serialize fields as camelCase	attr-rename.html
[Examples] Skip serializing field	attr-skip-serializing.html
[Examples] Derive for remote crate	remote-derive.html
[Examples] Manually deserialize struct	deserialize-struct.html
[Examples] Discarding data	ignored-any.html
[Examples] Transcode into another format	transcode.html
[Examples] Either string or struct	string-or-struct.html
[Examples] Convert error types	convert-error.html
[Examples] Custom date format	custom-date-format.html
No-std support	no-std.html
Feature flags	feature-flags.html
ROWS
)

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r disp slug; do
  [ -z "$slug" ] && continue
  url="$BASE/$slug"
  html=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null)
  [ -z "$html" ] && { echo "FAIL fetch $url" >&2; fail=$((fail+1)); continue; }
  body=$(printf '%s' "$html" | python3 "$WE" content "$SEL" "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null)
  [ "$(printf '%s' "$body" | wc -c)" -lt 50 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  printf '%s' "$body" > "$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  printf '%s\t%s\n' "$disp" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.3
done <<< "$PAGES"
echo "==> serde guide: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
