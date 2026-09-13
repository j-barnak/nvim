#!/usr/bin/env bash
# Replace the decompilation-wiki "(Paper)" citation stubs with the actual paper
# text (pdftotext), keeping the citation as a header. Paywalled/unreachable
# papers keep their stub. Idempotent-ish: only rewrites when it extracts >800
# chars of real text.
set -u
CFG=/home/jared/.config/nvim
CACHE="$CFG/Resources/docs/.webcache"
IDX="$CFG/Resources/docs/decompilation-wiki/index.tsv"
TMP=/tmp/dp_work; mkdir -p "$TMP"
sha(){ printf '%s' "$1" | sha256sum | awk '{print $1}'; }

got=0; kept=0; n=0
while IFS=$'\t' read -r title url; do
  case "$title" in *"(Paper)"*) : ;; *) continue ;; esac
  n=$((n+1))
  u="${url%%#*}"                        # strip #anchor
  pdf=""
  case "$u" in
    *.pdf)                          pdf="$u" ;;
    *.ps.gz)                        pdf="$u" ;;
    https://arxiv.org/abs/*)        pdf="https://arxiv.org/pdf/${u##*/abs/}" ;;
    https://arxiv.org/pdf/*)        pdf="$u" ;;
    *infoscience.epfl.ch/*/download) pdf="$u" ;;
    https://www.usenix.org/conference/*/presentation/*)
        # presentation page -> find the paper PDF link on it
        pdf=$(curl -fsSL --compressed --max-time 30 "$u" 2>/dev/null \
              | grep -oE 'href="[^"]+\.pdf"' | sed 's/href="//;s/"//' | head -1)
        case "$pdf" in /*) pdf="https://www.usenix.org$pdf" ;; esac ;;
    *ecommons.cornell.edu/*)
        pdf=$(curl -fsSL --compressed --max-time 30 "$u" 2>/dev/null \
              | grep -oE 'href="[^"]+\.pdf[^"]*"' | sed 's/href="//;s/"//' | head -1) ;;
    *) pdf="" ;;                     # acm/doi.org/oup paywall, .ps.gz, wiki #ref
  esac
  if [ -z "$pdf" ]; then echo "KEEP-STUB (no pdf): $title" >&2; kept=$((kept+1)); continue; fi

  f="$TMP/p.pdf"; rm -f "$f"
  # usenix presentation page with no .pdf href: try the sec<NN>-<name>.pdf path
  case "$pdf" in
    "") case "$u" in https://www.usenix.org/conference/usenixsecurity*/presentation/*)
          nn=$(printf '%s' "$u" | sed -E 's#.*usenixsecurity([0-9]+)/.*#\1#')
          pdf="https://www.usenix.org/system/files/sec${nn}-${u##*/}.pdf" ;; esac ;;
  esac
  [ -z "$pdf" ] && { echo "KEEP-STUB (no pdf): $title" >&2; kept=$((kept+1)); continue; }
  txt=""
  case "$pdf" in
    *.ps.gz)  # PostScript: gunzip | ps2pdf | pdftotext gives clean text (ps2ascii does not)
      curl -fsSL --max-time 60 "$pdf" -o "$TMP/p.ps.gz" 2>/dev/null
      gunzip -c "$TMP/p.ps.gz" 2>/dev/null > "$TMP/p.ps" && ps2pdf "$TMP/p.ps" "$f" 2>/dev/null ;;
    *)
      curl -fsSL --compressed --max-time 60 -A 'Mozilla/5.0 docsfreeze' "$pdf" -o "$f" 2>/dev/null ;;
  esac
  if [ ! -s "$f" ] || [ "$(head -c4 "$f")" != "%PDF" ]; then
    echo "KEEP-STUB (fetch/notpdf): $title  <$pdf>" >&2; kept=$((kept+1)); sleep 1; continue
  fi
  txt=$(pdftotext -nopgbrk "$f" - 2>/dev/null)
  if [ "$(printf '%s' "$txt" | wc -c)" -lt 800 ]; then
    echo "KEEP-STUB (short extract): $title" >&2; kept=$((kept+1)); sleep 1; continue
  fi
  cf="$CACHE/$(sha "$url").txt"
  # keep the existing citation stub as a header, then the full text
  { if [ -f "$cf" ]; then cat "$cf"; else printf '# %s\n' "$title"; fi
    printf '\n------------------------------------------------------------------------\n\n## Full text\n\n'
    printf '%s\n' "$txt"; } > "$cf.new" && mv "$cf.new" "$cf"
  echo "GOT ($(printf '%s' "$txt" | wc -c)b): $title"
  got=$((got+1))
  case "$pdf" in *arxiv.org*) sleep 3 ;; *) sleep 1 ;; esac
done < "$IDX"
echo "=== papers: $n | extracted: $got | kept-stub: $kept ==="
