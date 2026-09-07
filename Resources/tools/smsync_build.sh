set -e
SRC="$1"; OUT="$2"; REPAIRED="$3"; AWKF="$4"; ALL="$5"; FIXAWK="$6"
MODE=book
LIG="s/$(printf '\357\254\200')/ff/g; s/$(printf '\357\254\201')/fi/g; s/$(printf '\357\254\202')/fl/g; s/$(printf '\357\254\203')/ffi/g; s/$(printf '\357\254\204')/ffl/g"
CC=$(printf '\001\002\003\004\005\006\007\010\013\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037')
CTL=":a
s/^\([ $(printf '\t\014')]*\)[$CC]/\1 /
ta"
TOTAL=$(pdfinfo "$SRC" | awk '/^Pages:/{print $2}')
mkdir -p "$OUT"
rm -f "$OUT"/*.txt "$OUT"/.complete "$OUT"/.folio.keys "$OUT"/.titles
# titles = outline titles + PDF Title
{ cut -f3 "$ALL"; pdfinfo "$SRC" 2>/dev/null | sed -n 's/^Title: *//p'; } > "$OUT/.titles"
# slice helper: pages F..L from repaired file, matching pdftotext -f -l (trailing \f)
slice(){ awk -v F="$1" -v L="$2" 'BEGIN{RS="\f"; ORS=""} NR>=F && NR<=L { if(NR>F) printf "\f"; printf "%s",$0 } END{printf "\f"}' "$REPAIRED"; }
# learn pass over whole repaired book
cat "$REPAIRED" | sed "$CTL" | tr '\000-\010\013\015-\037' '[?*]' | sed "$LIG" \
  | awk -v book="$MODE" -v furn="" -v titles="$OUT/.titles" -v mode=learn -f "$AWKF" > "$OUT/.folio.keys"
idx=0
emit(){
  idx=$((idx+1)); n=$(printf '%03d' "$idx")
  f=$(printf '%s' "$3" | tr '/' '-' | awk '{ if (length($0) > 140) { s = substr($0, 1, 140); sub(/ [^ ]*$/, "", s); print s } else print }')
  slice "$1" "$2" | sed "$CTL" | tr '\000-\010\013\015-\037' '[?*]' | sed "$LIG" \
    | awk -v book="$MODE" -v furn="" -v keys="$OUT/.folio.keys" -v first_page="$1" -f "$AWKF" \
    | awk -f "$FIXAWK" \
    | cat -s > "$OUT/$n $f.txt"
}
# boundary map (outline top-level; Preface folds Acks/Contents/About; Front Matter 1-6)
emit 1 6 "Front Matter"
emit 7 14 "Preface"
emit 15 23 "1 Introduction"
emit 24 47 "2 Architectural Background"
emit 48 72 "3 Essential Theory"
emit 73 97 "4 Practical Spin Locks"
emit 98 113 "5 Busy-Wait Synchronization with Conditions"
emit 114 128 "6 Read-Mostly Atomicity"
emit 129 148 "7 Synchronization and Scheduling"
emit 149 193 "8 Nonblocking Algorithms"
emit 194 226 "9 Transactional Memory"
emit 227 "$TOTAL" "References"
# drop blank files
for t in "$OUT"/*.txt; do [ -e "$t" ] && [ "$(tr -d '[:space:]\f' < "$t" | wc -c)" -lt 3 ] && rm -f "$t"; done
rm -f "$OUT/.folio.keys" "$OUT/.titles"
touch "$OUT/.complete"
