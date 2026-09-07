# shared-memory-synchronization: drop the recto running head that folio.awk's
# page-edge vote misses. The verso head ("<page>  N Chapter Title") carries a
# stem constant over the whole chapter and is attested/stripped; the recto head
# ("N.M Section Title            <printed page>") changes every section, so it
# never reaches folio.awk's MINPG/DENS threshold and leaks into the body.
# Anchored on BOTH ends -- a leading "N.M " section number and a trailing 1-3
# digit page number separated by a run of >=6 spaces -- and it rejects any
# dot/space leader (the printed table of contents), so it matches only the
# running head and never a body heading (which carries no trailing page number)
# or a TOC entry (which has dot leaders).
{
  line=$0
  if (line ~ /^[0-9]+\.[0-9]+[ \t]+[A-Z][^\t]*[ \t]{6,}[0-9]{1,3}[ \t]*$/ \
      && line !~ /\. \. \./ && line !~ /\. \./) next
  print
}
