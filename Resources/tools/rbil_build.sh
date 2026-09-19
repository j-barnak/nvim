#!/usr/bin/env bash
# Freeze a reasonable slice of Ralf Brown's Interrupt List (RBIL, the HTML build
# at ctyme.com) into the :Docs frozen web-book layout used by the "Ralf Brown's
# Interrupt List" picker:
#   Resources/docs/rbil/index.tsv               "INT XXh - <category>\t<url>"
#   Resources/docs/.webcache/<sha256(url)>.txt   the rendered interrupt page
#
# The list has ~10000 individual entries; the reasonable granularity is the 256
# per-interrupt pages (int-00.htm .. int-ff.htm), each of which already contains
# ALL of that interrupt's function entries inline. So this freezes the complete
# interrupt list, organised one chapter per interrupt number. rbil_extract.py
# strips the navigation tables and keeps the entries.
# Usage: rbil_build.sh   (needs curl, python3+bs4+lxml)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
EX="$CFG/Resources/tools/rbil_extract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/rbil"
BASE="https://www.ctyme.com/intr"
mkdir -p "$OUT" "$CACHE"

# Well-known interrupts get a descriptive suffix; the rest are just "INT XXh"
# (the page content names each function's category inline). Hex key -> label.
label_for() {
  case "$1" in
    00) echo "CPU: Divide Error" ;; 01) echo "CPU: Single Step" ;;
    02) echo "NMI" ;; 03) echo "CPU: Breakpoint" ;; 04) echo "CPU: Overflow" ;;
    05) echo "Print Screen / BOUND" ;; 08) echo "IRQ0: System Timer" ;;
    09) echo "IRQ1: Keyboard" ;; 0d) echo "IRQ5" ;; 0e) echo "IRQ6: Diskette" ;;
    10) echo "VIDEO" ;; 11) echo "BIOS: Equipment List" ;; 12) echo "BIOS: Memory Size" ;;
    13) echo "DISK" ;; 14) echo "SERIAL" ;; 15) echo "SYSTEM / BIOS" ;;
    16) echo "KEYBOARD" ;; 17) echo "PRINTER" ;; 18) echo "ROM BASIC" ;;
    19) echo "BOOTSTRAP LOADER" ;; 1a) echo "TIME / RTC" ;; 1b) echo "Ctrl-Break" ;;
    1c) echo "Timer Tick" ;; 1e) echo "Diskette Parameters" ;; 1f) echo "Video Graphics Chars" ;;
    20) echo "DOS: Terminate Program" ;; 21) echo "DOS: Function Dispatcher" ;;
    22) echo "DOS: Terminate Address" ;; 23) echo "DOS: Ctrl-C Handler" ;;
    24) echo "DOS: Critical Error" ;; 25) echo "DOS: Absolute Disk Read" ;;
    26) echo "DOS: Absolute Disk Write" ;; 27) echo "DOS: TSR" ;;
    28) echo "DOS: Idle" ;; 29) echo "DOS: Fast Console Output" ;;
    2a) echo "DOS: Network / Critical Section" ;; 2e) echo "DOS: Execute Command" ;;
    2f) echo "DOS: Multiplex" ;; 31) echo "DPMI" ;; 33) echo "MOUSE" ;;
    40) echo "Diskette (relocated)" ;; 41) echo "Fixed Disk 0 Params" ;;
    43) echo "EGA/VGA Char Table" ;; 4a) echo "User Alarm" ;;
    5c) echo "NetBIOS" ;; 67) echo "EMS (LIM/EMM)" ;; 70) echo "IRQ8: RTC" ;;
    74) echo "IRQ12: Mouse" ;; 76) echo "IRQ14: Hard Disk" ;;
    *) echo "" ;;
  esac
}

: > "$OUT/index.tsv"; ok=0; fail=0
for n in $(seq 0 255); do
  hex=$(printf '%02x' "$n")
  url="$BASE/int-$hex.htm"
  html=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null)
  [ -z "$html" ] && { echo "MISS int-$hex" >&2; fail=$((fail+1)); continue; }
  printf '%s' "$html" | python3 "$EX" > /tmp/rbil_body.txt 2>/dev/null
  if [ "$(wc -c < /tmp/rbil_body.txt)" -lt 40 ]; then
    echo "EMPTY int-$hex" >&2; fail=$((fail+1)); continue
  fi
  HEX=$(printf '%02X' "$n"); lbl=$(label_for "$hex")
  title="INT ${HEX}h"; [ -n "$lbl" ] && title="INT ${HEX}h - $lbl"
  cf="$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  { printf '# %s\n\n' "$title"; cat /tmp/rbil_body.txt; } > "$cf"
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.15
done
rm -f /tmp/rbil_body.txt
echo "==> RBIL: $ok interrupt pages, $fail missing, index rows: $(wc -l < "$OUT/index.tsv")"
