# primer_fix.awk - drop the running heads folio.awk leaves in A Primer on Memory
# Consistency and Cache Coherence (book_fix / $FIXAWK stage).
#
# folio.awk's page vote misses these because each head recurs on too few pages:
# the even-page chapter head "<folio> <n>. TITLE" prints only every other page,
# and each odd-page section head "<n.m>. TITLE <folio>" spans just its section.
# 174 heads survive. Both are keyed on the title being ALL-CAPS: the printed
# TOC uses Title-Case with dot leaders, and a body section heading carries no
# trailing folio and no lowercase-free title, so both are preserved. The
# nolower() guard is what makes it body-safe. Line-drop only.

function squash(s){ gsub(/[ \t]+/," ",s); sub(/^ /,"",s); sub(/ $/,"",s); return s }
function nolower(s){ return (s !~ /[a-z]/) }
{ t = squash($0)
  # even page: "<folio> <n>. ALL-CAPS TITLE"
  if (t ~ /^[0-9]{1,3} [0-9]{1,2}\. [A-Z(]/) { b = t; sub(/^[0-9]{1,3} [0-9]{1,2}\. /, "", b); if (nolower(b)) next }
  # odd page: "<n.m[.k]>. ALL-CAPS TITLE <folio>"
  if (t ~ /^[0-9]{1,2}\.[0-9]{1,2}(\.[0-9]{1,2})?\. [A-Z(].* [0-9]{1,3}$/) { b = t; sub(/^[0-9]{1,2}\.[0-9]{1,2}(\.[0-9]{1,2})?\. /, "", b); sub(/ [0-9]{1,3}$/, "", b); if (nolower(b)) next }
  print }
