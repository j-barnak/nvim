curl -fsSL https://docs.rs/aya/latest/aya/all.html \
 | grep -oE 'href="([a-z0-9_]+/)*(struct|enum|trait|fn|macro|type|constant|union|primitive|derive|attr|keyword|static)\.[A-Za-z0-9_]+\.html"' \
 | sed -E 's/^href="//; s/"$//' | sort -u \
 | while IFS= read -r h; do
     b=${h##*/}; k=${b%%.*}; r=${b#*.}; n=${r%.html}; d=${h%/*}
     if [ "$d" = "$h" ]; then m="aya"; else m="aya::$(printf '%s' "$d" | sed 's#/#::#g')"; fi
     printf '%s\t%s %s\t%s\n' "$m" "$k" "$n" "$h"
   done | sort
