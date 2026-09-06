# Resources/tools

Build scripts, kept as files so the Neovim config carries no embedded shell or
python. Two kinds:

Frozen-library generators (run once by hand; the config only reads their
output under `Resources/docs`):

- `epub_build.sh`: epub -> per-chapter markdown
  (`sh -c "$(cat epub_build.sh)" epub <src.epub> <out-dir> <title>`).
  Splits by the epub's ncx (anchor-split for books whose spine does not line up
  with chapters), re-fences code, strips running headers, keeps tables/figures.
- `pdf_build.sh`: pdf -> per-chapter text
  (`sh -c "$(cat pdf_build.sh)" pdf <src.pdf> <out-dir> "" book`).
  Splits by the outline using the printed table-of-contents shape (Parts,
  chapters, appendices), emits front matter before the first bookmark. The
  config also runs it (without the `book` mode) for the downloaded PDF specs.
- `webextract.py`: article HTML -> body HTML for pandoc, then a pass over
  pandoc's markdown
  (`curl -fsSL <url> | python3 webextract.py content <css-selector> "" <opts> | pandoc -f html -t gfm-raw_html --wrap=none | python3 webextract.py clean`).
  Flattens tables (outermost table, direct rows/cells only) so nothing is
  dropped or duplicated, expanding `colspan`/`rowspan` so the columns line up
  with their headers and keeping the links inside the cells; drops anchors that
  show nothing (icon-only permalinks, MediaWiki's "Enlarge" button); and moves
  a `<p>` or `<i>` misplaced as a direct child of a list into the item before
  it, which pandoc would otherwise discard. The fourth argument is a
  comma-separated opt list: `guesslang` labels an attribute-less `<pre>` from
  its own text (right only for marabos.nl/atomics, which is where it came
  from). The `clean` mode reads pandoc's markdown, not HTML, and rewrites each
  fence's info string to a real language or to none, so a CSS class the source
  leaked through (`language-cpp`, `verbatim`) does not sit on a fence
  pretending to be one, and normalises U+00A0 to a plain space inside a fence
  (a non-breaking space a source author typed into a listing is a stray byte to
  a compiler, while in prose it is deliberate typography and is left alone);
  with the `listsep` opt it also drops the lone `&nbsp;` paragraph pandoc
  writes between two adjacent lists.

  The `mediawiki` mode does the same for a rendered MediaWiki page
  (`python3 webextract.py mediawiki "" https://wiki.osdev.org`): it keeps
  `div.mw-parser-output`, drops the table of contents, the other in-body chrome
  and the maintenance banners (stub, in progress, disputed, "written like a
  tutorial"), turns SyntaxHighlight `div.mw-highlight` wrappers back into
  language-tagged fences, renders a red link (a wikilink to a page that was
  never written, which MediaWiki points at its own editor) as its plain link
  text, and absolutises the relative wiki links. It built the
  frozen OSDev wiki provider from the site's offline dump, with `clean listsep`
  on the tail of the pipe.

- `folio.awk`: page-folio filter, required by `pdf_build.sh` (which fails
  loudly without it). Two modes: `mode=learn` reads a whole book and prints the
  page-number offsets its pages actually attest; apply mode takes those keys
  plus the range's `first_page` and filters one chapter. A line is dropped only
  if it is a bare number or a strict roman numeral, sits within 2 non-blank
  lines of a physical page edge, AND its value marches in step with the printed
  page numbers. The third test is what keeps chapter headings, index letter
  dividers, footnote markers, figure axis labels and program output: the old
  rule dropped any digits-only line after a blank one and destroyed 501 real
  lines across 16 books. Form feeds must reach it, so `pdf_build.sh` no longer
  strips them before the filter.
- `mdrepo_build.py`: markdown source tree -> per-chapter markdown
  (`python3 mdrepo_build.py <slug> <source-root> <out-dir>`).
  Flattens a documentation git repo (or a saved site capture) into
  `NNN Title.md` chapters in the order the source's own SUMMARY gives, then
  does the two passes the flattening makes necessary: it copies every
  referenced image and example file to `media/<sha1>.<ext>` beside the
  chapters (the convention `epub_build.sh` set, and the content hash folds
  duplicates together), and re-points every relative cross-reference at the
  numbered file its target became. A target that is in the source but not in
  the book becomes the absolute upstream URL; a target that is not in the
  source either loses its destination and keeps its text, as `epub_build.sh`
  does. `--max-asset` caps what goes into `media/` (default 16M; the sam4k
  capture alone is 96 MiB of animated GIFs). The per-book rules are keyed on
  the slug: `linux-insides`, `ebpf-developer-tutorial`,
  `heap-exploitation-dhaval-kapil`, `ir0nstone-binary-exploitation`, and
  `linternals-sam4k`, which runs in attach mode because `webextract.py`
  produces its chapters (it only adds `media/` and rewrites the references).

Loaded on demand by `lua/config/docs.lua` (`tool_script()`), only when a live
provider builds its cache for the first time:

- `api_build.sh`: kernel-doc index for `:Docs kernel-api` (`$1` = kernel tree).
- `dox_pipeline.sh`: doxygen -> markdown for the doxygen-based providers.
- `sdm_build.sh` + `figextract.py`: Intel SDM download, split and figure crop.
- `aya_api_idx.sh`: aya crate item index.

The out-dir basename must be the book's slug (a few books have per-slug rules).
Sources (epub/pdf) are not kept in the repo.
