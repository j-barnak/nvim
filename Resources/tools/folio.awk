# folio.awk -- page-furniture filter for pdf_build.sh.
#
# It replaces the old one-liner's "a bare digit line after a blank line is a
# page number" guess, which had no idea where a page began: it deleted real
# content (program output, footnote markers, formula numerators) and left every
# roman-numeral folio behind. This one decides structurally, by position on the
# PHYSICAL page, and confirms the decision against the book's own page-number
# sequence.
#
# INPUT. Feed it the pdftotext stream with the form feeds INTACT, i.e.
#     pdftotext -layout ... | tr '\000-\010\013\015-\037' '[?*]' | sed "$LIG"
# (\014 is left out of the tr range on purpose). pdftotext writes the form feed
# as a SEPARATOR: page 1 has none, and every later page's first line carries one
# as a prefix, so a page that extracts to nothing puts two form feeds on one
# line. The page counter therefore counts occurrences per line rather than
# assuming one form feed per line, and the line carrying the feed belongs to the
# page it opens. The form feeds are removed from the text that is printed, so
# the output is exactly what the old `sed 's/\f//g'` produced.
#
# THE RULE. A line is dropped as a page folio only when all three hold:
#   1. its trimmed text is a bare 1-4 digit number, or a well-formed roman
#      numeral written all-lowercase or all-uppercase (see roman() below: the
#      value must render back to exactly the same string, so "iiii" and "vx" are
#      not numerals, while "mix" and "did" are handled by rule 3);
#   2. it is within DEPTH (2) surviving non-blank lines of the top or the bottom
#      of its physical page;
#   3. its value equals <pdf page number> + k, for an offset k that the same end
#      of the page attests on at least MINVOTE (5) pages of this book.
#
# Condition 3 is what keeps a chapter-number heading ("11" above "Threads" on a
# chapter opener), an index letter heading ("C", "L", "X"), a word that happens
# to be a roman numeral ("MMX", "MIX"), a footnote marker, a figure axis label
# and a line of program output: none of them march in step with the printed page
# numbers. Condition 2 is what keeps a bare number in the middle of a page (the
# "72" of Dead Simple Python's program output).
#
# TWO INVOCATIONS. Condition 3 needs the whole book to vote, but pdf_build.sh
# filters one chapter at a time and a two-page Part divider has nothing to vote
# with. So the offsets are learned once per book and then applied per chapter:
#
#   awk -v mode=learn -v book=... -v furn=... -v titles=... -f folio.awk
#                                                             < whole-book stream
#       Prints "#lines <n>" and then one attested key per line: a folio offset
#       key such as "bot:n:-24", or a running-head key (see above). $titles is
#       the outline dump the caller already has (depth, page, title per line)
#       plus the PDF's own Title; it is read only by this pass, because the
#       apply pass just looks the finished key up.
#
#   awk -v keys=<that file> -v first_page=<N> -v book=... -v furn=... -f folio.awk
#       Filters one chapter range and prints the surviving text. first_page is
#       the PDF page the range starts at, so "pdf page + k" is computed against
#       real page numbers rather than 1-based positions inside the range.
#
# Splitting the work this way is exact, not an approximation: pdftotext's output
# for `-f F -l L` is byte-identical to the same pages of the whole-book run
# (verified on four books), chapter ranges never share a page, and every rule
# below is a function of one line plus its position on its own page. So a
# chapter's verdicts equal the whole book's verdicts for those pages.
#
# RUNNING HEADS. The same two passes also strip the running head / footer that
# most of these books print on every page, which used to leak into the body and
# land inside code listings. It is decided by POSITION first, exactly as the
# folio rule is, and never by repetition alone (see the epub-furniture-rule
# memory: a frequency-only stripper once deleted 1,872 real code lines).
#
#   GEOMETRY (a line that fails this is never touched, whatever it looks like).
#   Within a physical page, peel at most MAXBLOCKS (3) "edge blocks" from the
#   top and from the bottom. An edge block is a maximal run of consecutive
#   non-blank lines starting at the page edge; it only qualifies when it is at
#   most MAXBLOCK (8) lines, is separated from the rest of the page by at least
#   MINGAP (1) blank line, and leaves some content behind on the same page.
#   Pages with fewer than 3 surviving non-blank lines are skipped entirely.
#   Peeling stops at the first line that is not furniture, so nothing is ever
#   reached "through" a body line.
#
#   ATTESTATION (learned once per book, applied per chapter, like the folios).
#   A candidate line's trimmed, whitespace-collapsed text t is keyed three ways:
#     H1  folio-anchored: t carries a leading and/or trailing page-number token;
#         key is <end>:<side>:<value - pdf page>:<stem>, where <stem> is t with
#         that token replaced by "#". So the shape must repeat AND the number it
#         carries must march in step with the printed page sequence.
#     H2  title-anchored: <end>:T:<stem>, offered only when the line's canonical
#         form is the canonical form of one of the book's own outline titles
#         (this is the "equal to a heading in the file" test the epub memory
#         calls for). Covers heads that carry no folio at all, e.g. Apress's
#         "Chapter 4 <U+25A0> AVX Programming" and Building Git's chapter title.
#     H3  colophon: <end>:X:<exact text>, for the fixed decoration that carries
#         neither folio nor title (OSTEP's "O PERATING / S YSTEMS / [V ERSION
#         1.01]" page corner and its "T HREE / E ASY / P IECES" side tab,
#         perfbook's "v2025.12.18a", C++ Templates' "ensurehelveticaisembedded_()").
#   A key is attested when
#     - H1/H2: it occurs on >= MINPG (4) distinct pages and those pages are
#       dense (>= DENS percent of the span they cover), i.e. it RUNS, the way a
#       running head does and the way a section heading that merely recurs
#       once per chapter does not;
#     - H3: it occurs on at least H3FRAC percent of the book's pages, and on at
#       least H3MIN (30) of them;
#     - and, for all three, it is EDGE-EXCLUSIVE: of all the occurrences of that
#       text anywhere in the book, all but at most SLACK (2) are at a page edge
#       (or at least RATIO percent are). This is what separates a running head
#       from a line of code that happens to fall at a page edge often: "}" in
#       Building a Debugger is at a page edge 1,136 times but occurs 1,996 times
#       in all, and "end" in Building Git 698 of 1,948, while OSTEP's colophon
#       and C++ Templates' LaTeX artifact are 100 percent page-edge.
#   Lines whose shape is a dot/rule leader ("4.1. The parent field ...... 45")
#   or whose alphanumeric core is shorter than MINCORE (3) are never candidates,
#   which keeps a table of contents and a stray brace out of it.
#
# Written to run under both gawk and mawk. Note mawk cannot compile a NESTED
# interval regex, which is why roman() is spelled out as a canonical round-trip
# instead of the usual /^m{0,3}(cm|cd|d?c{0,3}).../ pattern, and why the
# repetition below is written out rather than braced.

function rval(s,    l, i, v, c, p, n) {           # roman numeral -> integer
  l = tolower(s); v["i"]=1; v["v"]=5; v["x"]=10; v["l"]=50; v["c"]=100; v["d"]=500; v["m"]=1000
  n = 0; p = 0
  for (i = length(l); i >= 1; i--) { c = v[substr(l, i, 1)]; if (c < p) n -= c; else { n += c; p = c } }
  return n
}
function rstr(n,    i, out, V, S) {                # integer -> canonical roman
  split("1000 900 500 400 100 90 50 40 10 9 5 4 1", V, " ")
  split("m cm d cd c xc l xl x ix v iv i", S, " ")
  out = ""
  for (i = 1; i <= 13; i++) while (n >= V[i]) { out = out S[i]; n -= V[i] }
  return out
}
# A strict roman numeral: all one case, only roman letters, and the canonical
# rendering of its value is the string itself, so "iiii" or "vx" are rejected.
function roman(s,    l) {
  if (s == "") return 0
  l = tolower(s)
  if (s != l && s != toupper(s)) return 0         # must be all one case
  if (l !~ /^[ivxlcdm]+$/) return 0
  return (rstr(rval(l)) == l)
}
# A roman folio is a front-matter folio, so its value is small. Capping it at
# ROMANMAX (60: i..lx) means an index letter divider "C" (100), "D" (500) or
# "M" (1000) can never collide with a page number even by accident; "L" (50) and
# "X" (10) would still need the divider to land on the page whose PRINTED number
# is exactly 50 or 10, which no index does.
function key(end, i, p,   v) {                    # vote key for line i on page p
  if (T[i] ~ /^[0-9]{1,4}$/) return end ":n:" (T[i] - p)
  if (roman(T[i])) { v = rval(T[i]); if (v <= ROMANMAX) return end ":r:" (v - p) }
  return ""
}

# ---- running-head helpers -------------------------------------------------
# squash(): trimmed text with internal whitespace runs collapsed, so a right-
# justified head and a centred one key the same whatever the gutter looks like.
function squash(s) { gsub(/[ \t]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); return s }
# tokval(): the value of a page-number token, or -1 if it is not one. Arabic
# 1-4 digits, a strict roman numeral up to ROMANMAX, or the per-chapter form
# Linkers and Loaders prints ("5-107" -> 107).
function tokval(s,   b, v) {
  if (s ~ /^[0-9][0-9]?[0-9]?[0-9]?$/) return s + 0
  if (s ~ /^[0-9][0-9]?[0-9]?-[0-9][0-9]?[0-9]?[0-9]?$/) { b = s; sub(/^[0-9]+-/, "", b); return b + 0 }
  if (roman(s)) { v = rval(s); if (v <= ROMANMAX) return v }
  return -1
}
# hparse(): fills HSTEM with t's shape (its page-number tokens replaced by "#")
# and HN/HS[]/HV[] with the sides that carried one. HN = -1 means "t is itself
# a bare folio", which belongs to the folio rule above, not here.
function hparse(t,   tok, rest, v) {
  HN = 0; HSTEM = t
  if (t !~ / /) { if (tokval(t) >= 0) { HN = -1; HSTEM = "" }; return }
  tok = t; sub(/ .*$/, "", tok); v = tokval(tok)
  if (v >= 0) { rest = t; sub(/^[^ ]+ /, "", rest); HSTEM = "# " rest; HN++; HS[HN] = "L"; HV[HN] = v }
  tok = HSTEM; sub(/^.* /, "", tok); v = tokval(tok)
  if (v >= 0) { rest = HSTEM; sub(/ [^ ]+$/, "", rest); HSTEM = rest " #"; HN++; HS[HN] = "R"; HV[HN] = v }
}
# shapeok(): reject leaders (a table of contents line, a rule of dashes, a run
# of OCR replacement characters) and anything with almost no letters in it.
function shapeok(s,   c) {
  if (s ~ REJRE) return 0
  c = s; gsub(/[^0-9A-Za-z]/, "", c)
  return (length(c) >= MINCORE)
}
# canonf(): the comparable form of a title or of a candidate head - lowercase,
# every run of other characters a single space, and any leading numbering or
# "Chapter"/"Part"/"Appendix" label dropped, so "Chapter 4 <U+25A0> AVX Programming"
# and the outline's "Chapter 4: AVX Programming" meet, and so do Building Git's
# head "Getting to know .git" and its outline entry "2. Getting to know .git".
function canonf(s,   r, n, i, out, A) {
  r = tolower(s); gsub(/[^0-9a-z]+/, " ", r); sub(/^ /, "", r); sub(/ $/, "", r)
  n = split(r, A, " "); i = 1
  while (i <= n && (A[i] ~ /^(chapter|appendix|part|section|ch|app|lecture|unit)$/ \
                    || A[i] ~ /^[0-9]+$/ || A[i] ~ /^[ivxlcdm]+$/ || A[i] ~ /^[a-z]$/)) i++
  out = ""
  for (; i <= n; i++) out = (out == "" ? A[i] : out " " A[i])
  return out
}
# hkeys(): the keys line t could be furniture under, most specific last. Sets
# HK[1..HKN]. In LEARN mode the H2 key is offered only when the text matches one
# of the book's titles; the apply pass does not need to re-check that, because a
# key is only in the attested set if some line with that exact stem did match.
function hkeys(t, p, end,   j, core) {
  HKN = 0
  HK[++HKN] = end ":X:" t
  hparse(t)
  if (HN <= 0 && HSTEM == "") return
  if (!shapeok(HSTEM)) { HKN = 0; HK[++HKN] = end ":X:" t; return }
  for (j = 1; j <= HN; j++) HK[++HKN] = end ":" HS[j] ":" (HV[j] - p) ":" HSTEM
  core = HSTEM; gsub(/#/, " ", core)
  if (!learn || canonf(t) in TITLE || canonf(core) in TITLE) HK[++HKN] = end ":T:" HSTEM
}

BEGIN {
  if (DEPTH == "") DEPTH = 2
  if (MINVOTE == "") MINVOTE = 5
  if (ROMANMAX == "") ROMANMAX = 60
  # running-head tunables (see the header)
  if (MAXBLOCKS == "") MAXBLOCKS = 3
  if (MAXBLOCK == "") MAXBLOCK = 8
  if (MINGAP == "") MINGAP = 1
  if (MINPG == "") MINPG = 4
  if (DENS == "") DENS = 34
  if (MINCORE == "") MINCORE = 3
  if (MINNB == "") MINNB = 2
  if (H3FRAC == "") H3FRAC = 20
  if (H3MIN == "") H3MIN = 30
  if (SLACK == "") SLACK = 2
  if (RATIO == "") RATIO = 95
  if (MAXTEXT == "") MAXTEXT = 250
  # A leader run: dots, underscores or dashes three deep (a contents line), a
  # doubled rule glyph, or the U+FFFD the OCR leaves where it could not read a
  # leader. Written as literal alternatives, not a back-reference, so mawk and
  # gawk compile the same thing.
  REJRE = "\\. *\\. *\\.|_ *_ *_|- *- *-|\357\277\275|\302\267 *\302\267|\342\226\240 *\342\226\240|\342\200\224 *\342\200\224|\342\200\223 *\342\200\223"
  if (first_page == "") first_page = 1
  page = first_page + 0
  learn = (mode == "learn")
  if (learn && titles != "") {
    while ((getline tl < titles) > 0) {
      sub(/^[0-9]+\t[0-9-]+\t/, "", tl)      # depth and page from the outline dump
      tc = canonf(tl)
      tcore = tc; gsub(/[^0-9a-z]/, "", tcore)
      if (length(tcore) >= MINCORE) TITLE[tc] = 1
    }
    close(titles)
  }
  if (!learn && keys != "") {
    while ((getline kl < keys) > 0) if (substr(kl, 1, 1) != "#") ok[kl] = 1
    close(keys)
  }
}
{
  line = $0
  page += gsub(/\014/, "", line)                  # a blank page emits two \f on one line
  o = line; s = line
  gsub(/\[Trial version\]/, "", s)
  t = s; gsub(/^[ \t]+|[ \t]+$/, "", t)

  # The filters that are not the folio rule, unchanged from the old one-liner.
  drop = 0
  if (o != s && t == "") drop = 1
  else if (book != "book" && (t ~ /^ISO\/IEC [0-9]/ || t ~ /^© ISO\/IEC/)) drop = 1
  else if (t ~ /ABC Amber|Team LiB|processtext\.com/) drop = 1
  else if (book == "book" && t ~ /^Page [0-9]+$/) drop = 1
  else if (book == "book" && t == "Click here to view code image") drop = 1
  else if (furn != "" && t ~ furn) drop = 1

  n++; T[n] = t; D[n] = drop
  # Page-ordered list of every surviving line, blanks included: the running-head
  # rule needs the blank lines to see where an edge block ends.
  if (!drop) { m[page]++; PL[page, m[page]] = n }
  if (learn && t != "") { q = squash(t); if (length(q) <= MAXTEXT) TOT[q]++ }
  if (!learn) L[n] = s
  # pdftotext closes the stream with a bare form feed and no trailing newline,
  # so the old `sed 's/\f//g'` left nothing there and awk never saw a record.
  # Keeping the form feeds makes that a real (empty) record, which would append
  # a blank line to every chapter file whose last page ends in text. Remember it
  # and drop it at END; only the LAST record qualifies, so a genuinely blank
  # line anywhere else is untouched.
  ffeof = ($0 ~ /^\014+$/)
  # Only surviving non-blank lines count towards "top" and "bottom" of the page,
  # so furniture stripped above cannot push a folio out of reach.
  if (!drop && t != "") { cnt[page]++; IDX[page, cnt[page]] = n }
}
# scan(): walk the edge blocks of page p from one end and hand each candidate
# line to the caller's mode. dir is +1 for the top of the page, -1 for the
# bottom. V[1..q] must already hold the page's surviving line indices in page
# order. Nothing outside a qualifying edge block is ever visited, which is the
# whole guarantee: a line in the middle of a page cannot be reached from here.
function scan(p, dir, q, act,   end, cur, bi, a, b, g, j, x, step, stop, t) {
  end = (dir > 0 ? "top" : "bot")
  cur = (dir > 0 ? 1 : q); stop = 0
  for (bi = 1; bi <= MAXBLOCKS; bi++) {
    a = cur
    while (a >= 1 && a <= q && T[V[a]] == "") a += dir
    if (a < 1 || a > q) return
    b = a
    while (b + dir >= 1 && b + dir <= q && T[V[b + dir]] != "") b += dir
    g = 0; j = b + dir
    while (j >= 1 && j <= q && T[V[j]] == "") { g++; j += dir }
    if ((dir > 0 ? b - a : a - b) + 1 > MAXBLOCK) return   # too big to be a head
    if (g < MINGAP) return                                 # not set off from the body
    if (j < 1 || j > q) return                             # nothing left on the page
    for (x = a; (dir > 0 ? x <= b : x >= b); x += dir) {
      t = squash(T[V[x]])
      hkeys(t, p, end)
      if (act == "learn") { for (step = 1; step <= HKN; step++) hvote(HK[step], p, t) }
      else {
        stop = 1
        for (step = HKN; step >= 1; step--) if (HK[step] in ok) { D[V[x]] = 1; stop = 0; break }
        if (stop) return
      }
    }
    cur = j
  }
}
# hvote(): one page-edge sighting of key k on page p, carrying text t.
function hvote(k, p, t) {
  if (!((k SUBSEP p) in seenp)) { seenp[k SUBSEP p] = 1; pgn[k]++ }
  if (!(k in minp) || p < minp[k]) minp[k] = p
  if (!(k in maxp) || p > maxp[k]) maxp[k] = p
  ec[k]++
  if (!((k SUBSEP t) in seent)) { seent[k SUBSEP t] = 1; tk[k] += (t in TOT ? TOT[t] : 1) }
}
# hattest(): is key k a running head? Edge-exclusivity first (all but SLACK of
# the text's occurrences in the whole book are at a page edge, or RATIO percent
# of them), then the per-rule strength test.
function hattest(k, npages,   sp) {
  if (!((tk[k] - ec[k] <= SLACK) || (ec[k] * 100 >= RATIO * tk[k]))) return 0
  if (k ~ /^(top|bot):X:/) return (pgn[k] >= H3MIN && pgn[k] * 100 >= H3FRAC * npages)
  sp = maxp[k] - minp[k] + 1
  return (pgn[k] >= MINPG && pgn[k] * 100 >= DENS * sp)
}
END {
  if (learn) {
    for (p = first_page; p <= page; p++) {
      if (!(p in cnt)) continue
      for (d = 1; d <= DEPTH && d <= cnt[p]; d++) {
        k = key("top", IDX[p, d], p);              if (k != "") vote[k]++
        k = key("bot", IDX[p, cnt[p] - d + 1], p); if (k != "") vote[k]++
      }
    }
  }
  if (!learn) {
    if (ffeof) D[n] = 1                           # the closing form feed
    for (p = first_page; p <= page; p++) {        # drop only attested folios
      if (!(p in cnt)) continue
      for (d = 1; d <= DEPTH && d <= cnt[p]; d++) {
        i = IDX[p, d];              k = key("top", i, p); if (k != "" && (k in ok)) D[i] = 1
        i = IDX[p, cnt[p] - d + 1]; k = key("bot", i, p); if (k != "" && (k in ok)) D[i] = 1
      }
    }
  }
  # Running heads, on the page as it stands once the folios are gone: a head
  # sitting under its own folio is the top line of the page by then.
  for (p = first_page; p <= page; p++) {
    if (!(p in m)) continue
    q = 0
    for (j = 1; j <= m[p]; j++) { i = PL[p, j]; if (D[i]) continue; q++; V[q] = i }
    if (q == 0) continue
    nb = 0
    for (j = 1; j <= q; j++) if (T[V[j]] != "") nb++
    if (nb < MINNB) continue                      # too little on the page to judge
    scan(p, 1, q, learn ? "learn" : "apply")
    scan(p, -1, q, learn ? "learn" : "apply")
  }
  if (learn) {
    print "#lines " n
    for (k in vote) if (vote[k] >= MINVOTE) print k
    npages = page - first_page + 1
    for (k in pgn) if (hattest(k, npages)) print k
    exit
  }
  for (i = 1; i <= n; i++) if (!D[i]) print L[i]
}
