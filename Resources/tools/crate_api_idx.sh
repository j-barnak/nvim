#!/bin/sh
# Build a docs.rs item index for a crate, one row per item:
#   <module>\t<kind> <name>\t<relative href>
# e.g.  serde::de\ttrait Visitor\tde/trait.Visitor.html
# Generalises aya_api_idx.sh to any crate. Used by the live docs.rs crate
# browsers (:Docs -> Serde/Dioxus/chumsky -> Crate reference). Network-dependent
# by design (crate API docs are not frozen; see the offline-clone-goal memory).
crate="$1"
[ -n "$crate" ] || { echo "usage: crate_api_idx.sh <crate>" >&2; exit 2; }
base="https://docs.rs/$crate/latest/$crate/"
curl -fsSL --compressed "${base}all.html" \
 | grep -oE 'href="([a-z0-9_]+/)*(struct|enum|trait|fn|macro|type|constant|union|primitive|derive|attr|keyword|static)\.[A-Za-z0-9_]+\.html"' \
 | sed -E 's/^href="//; s/"$//' | sort -u \
 | while IFS= read -r h; do
     b=${h##*/}; k=${b%%.*}; r=${b#*.}; n=${r%.html}; d=${h%/*}
     if [ "$d" = "$h" ]; then m="$crate"; else m="$crate::$(printf '%s' "$d" | sed 's#/#::#g')"; fi
     printf '%s\t%s %s\t%s\n' "$m" "$k" "$n" "$h"
   done | sort
