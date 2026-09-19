#!/usr/bin/env bash
# Freeze the "AFL++ Articles" book (the tutorials/write-ups the AFL++ README
# recommends, plus a couple of saved articles) into the :Docs frozen web layout:
#   Resources/docs/aflpp-articles/index.tsv       "<title>\t<url>" in list order
#   Resources/docs/.webcache/<sha256(url)>.txt     rendered content per row
#
# Two kinds of rows:
#   html   <index-url> <css-selector>  -> curl | webextract content | pandoc | clean
#   readme <index-url> <raw-md-url>    -> the repo README.md, keyed by the repo url
# securitylab.github.com/research/* now redirects to /resources/* (kept); the
# apache post moved to github.blog; bushido-sec.com is offline so its article is
# taken from the Wayback Machine; the nullprogram "Tips" post is the live URL.
# Usage: aflpp_articles_build.sh   (needs curl, python3, pandoc)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/aflpp-articles"
mkdir -p "$OUT" "$CACHE"
sha() { printf '%s' "$1" | sha256sum | awk '{print $1}'; }

# title <TAB> kind <TAB> index-url <TAB> (selector | raw-md-url)
ROWS=$(cat <<'ROWS'
Fuzzing Module (newbie guide)	readme	https://github.com/alex-maleno/Fuzzing-Module	https://raw.githubusercontent.com/alex-maleno/Fuzzing-Module/main/README.md
Fuzzing libxml2 (AFL++ tutorial)	html	https://aflplus.plus/docs/tutorials/libxml2_tutorial/	article.markdown
Fuzzing Game Boy games (gb-fuzz)	html	https://bananamafia.dev/post/gb-fuzz/	div.content-width
The Art of Fuzzing (bushido-sec, via Wayback)	html	https://web.archive.org/web/20260305102426/https://bushido-sec.com/index.php/2023/06/19/the-art-of-fuzzing/	div.entry-content
Fuzzing Challenges and Solutions Part 1	html	https://securitylab.github.com/resources/fuzzing-challenges-solutions-1	main#content
Fuzzing Software Part 2	html	https://securitylab.github.com/resources/fuzzing-software-2	main#content
Fuzzing Sockets Part 1: FTP	html	https://securitylab.github.com/resources/fuzzing-sockets-FTP	main#content
Fuzzing Sockets Part 2: FreeRDP	html	https://securitylab.github.com/resources/fuzzing-sockets-FreeRDP	main#content
Fuzzing Apache httpd Part 1	html	https://github.blog/security/vulnerability-research/fuzzing-sockets-apache-http-part-1-mutations/	section.post__content
Fuzzing a map parser Part 1: Teeworlds	html	https://mmmds.pl/fuzzing-map-parser-part-1-teeworlds/	article.post
AFL Reading Notes 2: Virgin Bits, Calibration and Queue Culling	html	https://mem2019.github.io/jekyll/update/2019/08/26/AFL-Fuzzer-Notes-2.html	div.post-content
Tips for more effective fuzz testing with AFL++ (nullprogram)	html	https://nullprogram.com/blog/2025/02/05/	div.single
Fuzzing101 (exercises, antonio-morales)	readme	https://github.com/antonio-morales/Fuzzing101	https://raw.githubusercontent.com/antonio-morales/Fuzzing101/main/Readme.md
AFL++ workflow (Trail of Bits appsec.guide)	html	https://appsec.guide/docs/fuzzing/c-cpp/aflpp/	article.markdown
AFL++ QEMU mode workflow (Airbus Seclab)	html	https://airbus-seclab.github.io/AFLplusplus-blogpost/	section#main_content
Android greybox fuzzing with AFL++ Frida mode (Quarkslab)	html	https://blog.quarkslab.com/android-greybox-fuzzing-with-afl-frida-mode.html	div.entry-content
AFL++ protobuf mutator (P1umer)	readme	https://github.com/P1umer/AFLplusplus-protobuf-mutator	https://raw.githubusercontent.com/P1umer/AFLplusplus-protobuf-mutator/main/README.md
libprotobuf-mutator raw custom mutator (bruce30262)	readme	https://github.com/bruce30262/libprotobuf-mutator_fuzzing_learning/tree/master/4_libprotobuf_aflpp_custom_mutator	https://raw.githubusercontent.com/bruce30262/libprotobuf-mutator_fuzzing_learning/master/4_libprotobuf_aflpp_custom_mutator/README.md
afl-libprotobuf-mutator (old API, thebabush)	readme	https://github.com/thebabush/afl-libprotobuf-mutator	https://raw.githubusercontent.com/thebabush/afl-libprotobuf-mutator/master/README.md
Superion mutator for AFL++ (adrian-rt)	readme	https://github.com/adrian-rt/superion-mutator	https://raw.githubusercontent.com/adrian-rt/superion-mutator/master/README.md
ROWS
)

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r title kind url arg; do
  [ -z "$title" ] && continue
  cf="$CACHE/$(sha "$url").txt"
  if [ "$kind" = "readme" ]; then
    body=$( { printf '# %s\n\n' "$title"; curl -fsSL --compressed --max-time 40 "$arg" 2>/dev/null; } )
  else
    body=$(curl -fsSL --compressed --max-time 45 -A "Mozilla/5.0" "$url" 2>/dev/null \
      | python3 "$WE" content "$arg" "$url" abs 2>/dev/null \
      | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
      | python3 "$WE" clean "" "" 2>/dev/null \
      | sed -E 's/!\[[^]]*\]\(data:[^)]*\)//g')
  fi
  if [ "$(printf '%s' "$body" | wc -c)" -lt 200 ]; then
    echo "FAIL/empty: $title <- $url" >&2; fail=$((fail+1)); continue
  fi
  printf '%s' "$body" > "$cf"
  printf '%s\t%s\n' "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.3
done <<< "$ROWS"
echo "==> aflpp articles: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
